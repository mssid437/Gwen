import SwiftUI

public struct BreakOverlayContainer: View {
    @ObservedObject var appState: AppState
    @ObservedObject var preferences: UserPreferences
    var onComplete: () -> Void
    var onSnooze: () -> Void

    public var body: some View {
        ZStack {
            // Full Screen Glass Blur Backdrop
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow, state: .active)
                .edgesIgnoringSafeArea(.all)

            // Dark Low-Luminance Tint Overlay
            Color.black.opacity(0.72)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Top Bar Controls
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.emeraldGreen)
                        Text("GWEN EYE-HEALTH ASSISTANT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    if preferences.enableVisionTracking {
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(appState.isBlinkRateDeficient ? .amberGold : .emeraldGreen)
                                Text("\(appState.blinksPerMinute) blinks/min")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(appState.isPostureOptimal ? .emeraldGreen : .amberGold)
                                Text("\(Int(appState.postureAngleDegrees))° stance")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                    }

                    Button(action: onSnooze) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Snooze 5m")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Button(action: onComplete) {
                        Text("Skip")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
                .padding(.top, 30)

                Spacer()

                // Protocol Content Selector
                GlassmorphicCard(cornerRadius: 24) {
                    switch appState.currentProtocol {
                    case .microBreak:
                        MicroBreakView(appState: appState)
                    case .meibomianBlink:
                        MeibomianBlinkView(appState: appState)
                    case .accommodativeFlex:
                        StepFocusView(appState: appState)
                    case .thermalPalming:
                        PalmingView(appState: appState)
                    case .extraocularMotility:
                        MotilityTrackerView(appState: appState)
                    }
                }
                .frame(maxWidth: 680)

                Spacer()
            }
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // ESC key
                    onComplete()
                    return nil
                }
                return event
            }
        }
    }
}
