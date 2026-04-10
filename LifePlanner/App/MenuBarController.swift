import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover

    init(viewModel: ReminderDraftViewModel) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        super.init()

        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 360, height: 280)
        popover.contentViewController = NSHostingController(
            rootView: PopoverContentView(viewModel: viewModel)
        )

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "bell.badge", accessibilityDescription: "LifePlanner")
            image?.isTemplate = true
            button.image = image
            button.title = " LP"
            button.imagePosition = .imageLeading
            button.action = #selector(togglePopover)
            button.target = self
            button.toolTip = "LifePlanner"
        }
    }

    var debugStatusDescription: String {
        guard let button = statusItem.button else {
            return "Menu bar item creation failed: NSStatusItem exists, but its button is nil."
        }

        let frame = NSStringFromRect(button.frame)
        return "Menu bar item created successfully. Title='\(button.title)' frame=\(frame)"
    }

    @objc
    private func togglePopover() {
        guard let button = statusItem.button else {
            return
        }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
