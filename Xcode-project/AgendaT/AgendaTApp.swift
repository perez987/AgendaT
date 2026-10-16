import SwiftUI

@main
struct AgendaTApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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

    }
}
