import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false  // Keep app running when window is hidden
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
    let dockMenu = NSMenu()

    // Show/Hide TxtPocket
    let showHideItem = NSMenuItem(title: "Show TxtPocket", action: #selector(showWindow), keyEquivalent: "")
    showHideItem.target = self
    dockMenu.addItem(showHideItem)

    dockMenu.addItem(NSMenuItem.separator())

    // Quit
    let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    dockMenu.addItem(quitItem)

    return dockMenu
  }

  @objc func showWindow() {
    // Show the main window
    if let window = NSApplication.shared.windows.first {
      window.makeKeyAndOrderFront(nil)
      NSApplication.shared.activate(ignoringOtherApps: true)
    }
  }
}
