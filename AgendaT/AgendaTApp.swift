import SwiftUI
import Sparkle

@main
struct AgendaTApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var updaterController = UpdaterController()

    var body: some Scene {
			//Single instance app
        Window("AgendaT", id: "main") {
            ContentView()
        }

			// Set width of 660 pixels to the main window
			// macOS 13 Ventura or newer
//		.defaultSize(width: 660, height: 600)

			// Window resizability derived from the window’s content
			// macOS 13 Ventura or newer
		.windowResizability(.contentSize)
        
        .commands {
              // Updater menu
              CommandGroup(after: .appInfo) {
                  Button(
                      NSLocalizedString(
                          "Check for Updates...",
                          comment: "Menu item to check for app updates"
                      ),
  //                    systemImage: "square.and.arrow.down.badge.checkmark"
                      systemImage: "arrow.triangle.2.circlepath"
                  ) {
                      updaterController.checkForUpdates()
                  }
                  .keyboardShortcut("u", modifiers: [.command])
                  .disabled(!updaterController.canCheckForUpdates)
              }
          }

    }
}
