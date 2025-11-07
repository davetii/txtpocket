import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:path/path.dart' as path;
import 'services/database_service.dart';
import 'widgets/launcher_widget.dart';

// System tray instances (Windows only)
final SystemTray systemTray = SystemTray();
final Menu menuMain = Menu();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for frameless window
  await windowManager.ensureInitialized();

  // Initialize hotkey manager
  await hotKeyManager.unregisterAll();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 500),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true, // Hide from taskbar/dock - background app only
    titleBarStyle: TitleBarStyle.hidden,
  );

  // Initialize database and load sample data if first run
  await DatabaseService().initialize();

  // Setup window but don't show on startup (background app behavior)
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Window ready but hidden - will show via hotkey or tray menu
    debugPrint('Window ready (hidden). Use Cmd+Shift+T to show.');
  });

  runApp(const TxtPocketApp());

  // Initialize system tray (Windows only) and global hotkey
  Future.delayed(const Duration(milliseconds: 100), () async {
    if (Platform.isWindows) {
      await initSystemTray();
    }
    await registerHotKey();
  });
}

Future<void> initSystemTray() async {
  try {
    String iconPath = '';

    if (Platform.isWindows) {
      // Try multiple possible locations for the icon
      final possiblePaths = [
        path.join(Directory.current.path, 'data', 'flutter_assets', 'assets', 'app_icon.ico'),
        path.join(Directory.current.path, 'assets', 'app_icon.ico'),
      ];

      for (final testPath in possiblePaths) {
        if (File(testPath).existsSync()) {
          iconPath = testPath;
          debugPrint('Found icon at: $testPath');
          break;
        }
      }

      if (iconPath.isEmpty) {
        debugPrint('NOTE: System tray icon not found. App will work without tray icon.');
        debugPrint('Checked paths: ${possiblePaths.join(", ")}');
      }
    }

    // Initialize system tray with icon
    await systemTray.initSystemTray(
      title: "TxtPocket",
      iconPath: iconPath,
    );

    // Build menu
    await menuMain.buildFrom([
      MenuItemLabel(label: 'Show TxtPocket', onClicked: (menuItem) => showWindow()),
      MenuSeparator(),
      MenuItemLabel(label: 'Quit', onClicked: (menuItem) => quitApp()),
    ]);

    await systemTray.setContextMenu(menuMain);

    // Handle system tray click
    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        showWindow();
      } else if (eventName == kSystemTrayEventRightClick) {
        systemTray.popUpContextMenu();
      }
    });

    debugPrint('System tray initialized successfully');
  } catch (e) {
    debugPrint('ERROR: Failed to initialize system tray: $e');
    debugPrint('App will continue without system tray. Use Ctrl+Shift+T to show window.');
  }
}

Future<void> registerHotKey() async {
  try {
    // Register Cmd+Shift+T (macOS) or Ctrl+Shift+T (Windows/Linux)
    final modifiers = Platform.isMacOS
        ? [KeyModifier.meta, KeyModifier.shift]
        : [KeyModifier.control, KeyModifier.shift];

    HotKey hotKey = HotKey(
      KeyCode.keyT,
      modifiers: modifiers,
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        showWindow();
      },
    );

    final shortcutName = Platform.isMacOS ? 'Cmd+Shift+T' : 'Ctrl+Shift+T';
    debugPrint('Global hotkey ($shortcutName) registered successfully');
  } catch (e) {
    debugPrint('ERROR: Failed to register global hotkey: $e');
    debugPrint('App will continue without global hotkey.');
  }
}

void showWindow() async {
  debugPrint('>>> showWindow() called');
  try {
    // Center window before showing (Alfred-style behavior)
    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  } catch (e) {
    debugPrint('ERROR: Failed to show window: $e');
  }
}

void hideWindow() async {
  debugPrint('>>> hideWindow() called');
  debugPrint('>>> Stack trace: ${StackTrace.current}');
  try {
    await windowManager.hide();
  } catch (e) {
    debugPrint('ERROR: Failed to hide window: $e');
  }
}

void quitApp() async {
  await hotKeyManager.unregisterAll();
  if (Platform.isWindows) {
    await systemTray.destroy();
  }
  exit(0);
}

class TxtPocketApp extends StatelessWidget {
  const TxtPocketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TxtPocket',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  bool _allowAutoHide = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // Delay auto-hide to prevent immediate hiding on startup
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _allowAutoHide = true;
        });
      }
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // Auto-hide on focus loss (Alfred-style behavior)
  @override
  void onWindowBlur() {
    if (_allowAutoHide) {
      hideWindow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: LauncherWidget(
          onHide: hideWindow,
          onQuit: quitApp,
        ),
      ),
    );
  }
}
