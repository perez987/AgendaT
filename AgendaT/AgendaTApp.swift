import SwiftUI

@main
struct AgendaTApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

			// set width of 580 pixels to the main window
			// macOS 13 Ventura or newer
//		.defaultSize(width: 580, height: 600)

			// window resizability derived from the window’s content
			// macOS 13 Ventura or newer
		.windowResizability(.contentSize)

    }
}
