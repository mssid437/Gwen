import AppKit
import SwiftUI
import Combine

public class AppDelegate: NSObject, NSApplicationDelegate {
    public var statusItem: NSStatusItem?
    public var popover: NSPopover?

    public let appState = AppState()
    public let preferences = UserPreferences()
    public var breakEngine: BreakTimerEngine?

    private var cancellables = Set<AnyCancellable>()

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent app from quitting when windows are closed
        NSApp.setActivationPolicy(.accessory)

        // Instantiate master break engine
        breakEngine = BreakTimerEngine(appState: appState, preferences: preferences)

        // Setup native Menu Bar item
        setupStatusItem()

        // Bind timer state changes to update status item icon & title
        appState.$secondsRemaining
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)

        appState.$timerState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)
    }

    private func setupStatusItem() {
        // Use fixed width of 72 points to prevent menu bar layout recalculation & background flicker
        statusItem = NSStatusBar.system.statusItem(withLength: 72.0)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "Gwen Eye Health")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarExtraView(
                appState: appState,
                preferences: preferences,
                onStartBreak: { [weak self] proto in
                    self?.popover?.performClose(nil)
                    self?.breakEngine?.startBreakRoutine(protocol: proto)
                },
                onSnooze: { [weak self] in
                    self?.popover?.performClose(nil)
                    self?.breakEngine?.snoozeBreak(minutes: 5)
                },
                onTogglePause: { [weak self] in
                    guard let self = self else { return }
                    if self.appState.timerState == .pausedIdle {
                        self.breakEngine?.startEngine()
                    } else {
                        self.appState.timerState = .pausedIdle
                    }
                },
                onQuit: {
                    NSApp.terminate(nil)
                }
            )
        )
        self.popover = popover
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    private func updateStatusItemTitle() {
        guard let button = statusItem?.button else { return }

        let text: String
        let symbolName: String

        switch appState.timerState {
        case .working:
            text = appState.formattedTimeRemaining
            symbolName = "eye.fill"
        case .preBreakWarning:
            text = "Break!"
            symbolName = "eye.circle.fill"
        case .inBreak:
            text = appState.formattedBreakTimeRemaining
            symbolName = "sparkles"
        case .pausedMeeting:
            text = "Call"
            symbolName = "video.fill"
        case .pausedIdle:
            text = "AFK"
            symbolName = "pause.circle"
        }

        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Gwen")

        let font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        button.attributedTitle = NSAttributedString(string: " \(text)", attributes: attributes)
    }
}
