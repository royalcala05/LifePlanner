import AppKit
import SwiftUI

@main
struct LifePlannerApp: App {
    @NSApplicationDelegateAdaptor(LifePlannerAppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
                .frame(width: 0, height: 0)
        }
    }
}

@MainActor
final class LifePlannerAppDelegate: NSObject, NSApplicationDelegate {
    private var coordinator: AppCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        coordinator = AppCoordinator()
        logStartupDiagnostics()
    }

    private func logStartupDiagnostics() {
        let activationPolicy: String
        switch NSApp.activationPolicy() {
        case .regular:
            activationPolicy = "regular"
        case .accessory:
            activationPolicy = "accessory"
        case .prohibited:
            activationPolicy = "prohibited"
        @unknown default:
            activationPolicy = "unknown"
        }

        let statusDescription = coordinator?.debugStatusDescription ?? "Coordinator was not created."
        let message = "LifePlanner launch diagnostics: activationPolicy=\(activationPolicy). \(statusDescription)"
        NSLog("%@", message)

#if DEBUG
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "LifePlanner Debug"
            alert.informativeText = message + "\n\nLook for 'LP' in the top-right menu bar."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
#endif
    }
}
