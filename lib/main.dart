import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'services/database_service.dart';
import 'widgets/launcher_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for frameless window
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 500),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize database and load sample data if first run
  await DatabaseService().initialize();

  runApp(const TxtPocketApp());
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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _closeApp() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: LauncherWidget(onClose: _closeApp),
      ),
    );
  }
}
