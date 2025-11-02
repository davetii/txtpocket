import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path/path.dart' as path;
import 'services/database_service.dart';
import 'widgets/launcher_widget.dart';

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
    skipTaskbar: true, // Changed to true since we're using system tray
    titleBarStyle: TitleBarStyle.hidden,
  );

  // Initialize database and load sample data if first run
  await DatabaseService().initialize();

  // Setup window but start hidden
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Don't show on startup - user will use hotkey or tray to show
    // await windowManager.show();
    // await windowManager.focus();
  });

  runApp(const TxtPocketApp());

  // Initialize system tray and hotkey after app starts
  // This prevents blocking the app startup if these fail
  Future.delayed(const Duration(milliseconds: 100), () async {
    await initSystemTray();
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
    } else {
      iconPath = path.join(Directory.current.path, 'assets', 'app_icon.png');
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
        Platform.isWindows ? showWindow() : systemTray.popUpContextMenu();
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
    // Register Ctrl+Shift+T
    HotKey hotKey = HotKey(
      KeyCode.keyT,
      modifiers: [KeyModifier.control, KeyModifier.shift],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        showWindow();
      },
    );

    debugPrint('Global hotkey (Ctrl+Shift+T) registered successfully');
  } catch (e) {
    debugPrint('ERROR: Failed to register global hotkey: $e');
    debugPrint('App will continue without global hotkey.');
  }
}

void showWindow() async {
  await windowManager.show();
  await windowManager.focus();
}

void hideWindow() async {
  await windowManager.hide();
}

void quitApp() async {
  await hotKeyManager.unregisterAll();
  await systemTray.destroy();
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

  // Hide window when it loses focus (but only if window is actually shown)
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
