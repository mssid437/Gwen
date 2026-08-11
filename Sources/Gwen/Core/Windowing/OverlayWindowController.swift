import AppKit
import SwiftUI

public final class OverlayWindowController: NSWindowController {
    public convenience init(for screen: NSScreen, contentView: NSView) {
        let overlayWindow = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Elevate window above Menu Bar, Dock, and native full-screen applications
        overlayWindow.level = .screenSaver
        overlayWindow.backgroundColor = .clear
        overlayWindow.isOpaque = false
        overlayWindow.hasShadow = false
        overlayWindow.ignoresMouseEvents = false

        // Configure Spaces & FullScreen behavior
        overlayWindow.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        overlayWindow.setFrameOrigin(screen.frame.origin)
        overlayWindow.contentView = contentView

        self.init(window: overlayWindow)
    }

    public func fadeIn(duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        guard let window = self.window else { return }
        window.alphaValue = 0.0
        window.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            window.animator().alphaValue = 1.0
        }, completionHandler: completion)
    }

    public func fadeOut(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        guard let window = self.window else {
            completion?()
            return
        }

        window.ignoresMouseEvents = true

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            window.orderOut(nil)
            completion?()
        })
    }
}
