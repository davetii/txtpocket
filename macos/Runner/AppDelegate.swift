import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  var statusBar: NSStatusItem?

  override func applicationWillFinishLaunching(_ notification: Notification) {
    // Create menu bar icon early in the launch process
    setupMenuBar()
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)

    // Ensure menu bar is setup even if applicationWillFinishLaunching didn't fire
    if statusBar == nil {
      setupMenuBar()
    }
  }

  func setupMenuBar() {
    // Create menu bar icon
    statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusBar?.isVisible = true

    if let button = statusBar?.button {
      // Try to load the app icon from Flutter assets
      let frameworkPath = Bundle.main.privateFrameworksPath ?? ""
      let appFrameworkPath = (frameworkPath as NSString).appendingPathComponent("App.framework")
      let iconPath = (appFrameworkPath as NSString).appendingPathComponent("Resources/flutter_assets/assets/app_icon.png")

      if FileManager.default.fileExists(atPath: iconPath), let image = NSImage(contentsOfFile: iconPath) {
        // Resize image to fit menu bar (18x18 looks good)
        image.size = NSSize(width: 18, height: 18)
        image.isTemplate = true  // Makes it adapt to light/dark mode
        button.image = image
      } else {
        // Fallback to text if icon not found
        button.title = "T"
      }

      button.action = #selector(statusBarButtonClicked(_:))
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    // Create menu
    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Quit TxtPocket", action: #selector(quitApp), keyEquivalent: "q"))
    statusBar?.menu = menu
  }

  @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
    let event = NSApp.currentEvent!

    if event.type == .rightMouseUp {
      // Right click - show menu
      statusBar?.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.frame.height), in: sender)
    } else {
      // Left click - toggle window
      showWindow()
    }
  }

  @objc func quitApp() {
    NSApplication.shared.terminate(self)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false  // Keep app running when window is hidden
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  @objc func showWindow() {
    // Show the main window
    if let window = NSApplication.shared.windows.first {
      window.center()
      window.makeKeyAndOrderFront(nil)
      NSApplication.shared.activate(ignoringOtherApps: true)
    }
  }
}
