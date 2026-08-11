import AppKit
import SwiftUI

public final class OverlayWindowManager: ObservableObject {
    private var overlayControllers: [OverlayWindowController] = []
    private var toastWindowController: NSWindowController?

    public init() {}

    public func presentBreakOverlay(
        appState: AppState,
        preferences: UserPreferences,
        onComplete: @escaping () -> Void,
        onSnooze: @escaping () -> Void
    ) {
        dismissAllOverlays()

        // Create elevated NSWindow for each attached display
        for screen in NSScreen.screens {
            let containerView = NSHostingView(
                rootView: BreakOverlayContainer(
                    appState: appState,
                    preferences: preferences,
                    onComplete: { [weak self] in
                        self?.dismissBreakOverlay(completion: onComplete)
                    },
                    onSnooze: { [weak self] in
                        self?.dismissBreakOverlay(completion: onSnooze)
                    }
                )
            )

            let controller = OverlayWindowController(for: screen, contentView: containerView)
            overlayControllers.append(controller)
            controller.fadeIn(duration: 1.0)
        }
    }

    public func dismissBreakOverlay(completion: (() -> Void)? = nil) {
        let group = DispatchGroup()

        for controller in overlayControllers {
            group.enter()
            controller.fadeOut(duration: 0.8) {
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.overlayControllers.removeAll()
            completion?()
        }
    }

    public func showPreBreakToast(
        appState: AppState,
        onStartNow: @escaping () -> Void,
        onSnooze: @escaping () -> Void
    ) {
        dismissToast()

        guard let mainScreen = NSScreen.main else { return }

        let toastView = NSHostingView(
            rootView: PreBreakToastView(
                appState: appState,
                onStartNow: { [weak self] in
                    self?.dismissToast()
                    onStartNow()
                },
                onSnooze: { [weak self] in
                    self?.dismissToast()
                    onSnooze()
                }
            )
        )

        // Calculate top-right position on main display
        let screenFrame = mainScreen.visibleFrame
        let toastWidth: CGFloat = 380
        let toastHeight: CGFloat = 72
        let margin: CGFloat = 20

        let toastRect = NSRect(
            x: screenFrame.maxX - toastWidth - margin,
            y: screenFrame.maxY - toastHeight - margin,
            width: toastWidth,
            height: toastHeight
        )

        let toastWindow = NSWindow(
            contentRect: toastRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        toastWindow.level = .floating
        toastWindow.backgroundColor = .clear
        toastWindow.isOpaque = false
        toastWindow.hasShadow = true
        toastWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        toastWindow.contentView = toastView

        toastWindowController = NSWindowController(window: toastWindow)
        toastWindow.alphaValue = 0.0
        toastWindow.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            toastWindow.animator().alphaValue = 1.0
        }
    }

    public func dismissToast() {
        guard let window = toastWindowController?.window else { return }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            window.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            window.orderOut(nil)
            self?.toastWindowController = nil
        })
    }

    public func dismissAllOverlays() {
        dismissToast()
        dismissBreakOverlay()
    }
}
