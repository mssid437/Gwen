import SwiftUI

public struct MenuBarExtraView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var preferences: UserPreferences

    var onStartBreak: (OphthalmicProtocol) -> Void
    var onSnooze: () -> Void
    var onTogglePause: () -> Void
    var onQuit: () -> Void

    @State private var selectedTab: Int = 0

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.cyan, .emeraldGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 24, height: 24)
                        Image(systemName: "eye.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Text("GWEN")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                // State Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(appState.timerState.statusBadgeColor)
                        .frame(width: 8, height: 8)
                    Text(appState.timerState.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }
            .padding(16)
            .background(Color.gwenBackground)

            Divider().background(Color.white.opacity(0.1))

            // Content Area
            VStack(spacing: 16) {
                // Next Break Card
                GlassmorphicCard(cornerRadius: 16) {
                    HStack(spacing: 16) {
                        // Countdown Ring
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 5)
                                .frame(width: 64, height: 64)

                            Circle()
                                .trim(from: 0, to: CGFloat(appState.progressFraction))
                                .stroke(
                                    appState.currentProtocol.accentColor,
                                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 64, height: 64)

                            Text(appState.formattedTimeRemaining)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("NEXT UP")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(appState.currentProtocol.accentColor)

                            Text(appState.currentProtocol.title)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text(appState.currentProtocol.subtitle)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                    .padding(12)
                }

                // Protocol Selector Grid
                VStack(alignment: .leading, spacing: 8) {
                    Text("CLINICAL PROTOCOLS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(OphthalmicProtocol.allCases) { proto in
                                Button(action: {
                                    appState.currentProtocol = proto
                                    onStartBreak(proto)
                                }) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Image(systemName: proto.sfSymbolName)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(proto.accentColor)
                                            Spacer()
                                            Text("\(proto.defaultDurationSeconds)s")
                                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                                .foregroundColor(.white.opacity(0.5))
                                        }

                                        Text(proto.rawValue)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)

                                        Text("\(proto.defaultIntervalMinutes)m interval")
                                            .font(.system(size: 9, weight: .regular))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(10)
                                    .frame(width: 124, height: 76)
                                    .background(appState.currentProtocol == proto ? proto.accentColor.opacity(0.2) : Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(appState.currentProtocol == proto ? proto.accentColor : Color.white.opacity(0.08), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Smart Intelligence Status Badges
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "video.fill")
                            .foregroundColor(preferences.enableMeetingShield ? .emeraldGreen : .gray)
                            .font(.system(size: 11))
                        Text("Meeting Shield")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)

                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                            .foregroundColor(preferences.enableIdleDetection ? .emeraldGreen : .gray)
                            .font(.system(size: 11))
                        Text("AFK Sensing")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)

                    HStack(spacing: 6) {
                        Image(systemName: "cpu")
                            .foregroundColor(preferences.enableVisionTracking ? .emeraldGreen : .gray)
                            .font(.system(size: 11))
                        Text("M4 Vision")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }

                // Daily Metrics Summary
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BREAKS TODAY")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(appState.breaksCompletedToday)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.emeraldGreen)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("RELIEF TIME")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(appState.totalRelaxationSecondsToday / 60) min")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.cyan)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("TBUT INDEX")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(appState.estimatedTearFilmScore)%")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.amberGold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .background(Color.white.opacity(0.04))
                .cornerRadius(12)

                // Main Action Buttons
                HStack(spacing: 10) {
                    Button(action: { onStartBreak(appState.currentProtocol) }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Break")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(LinearGradient(colors: [.cyan, .emeraldGreen], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Button(action: onSnooze) {
                        HStack {
                            Image(systemName: "clock")
                            Text("Snooze 5m")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Button(action: onTogglePause) {
                        Image(systemName: appState.timerState == .pausedIdle ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(Color.gwenBackground)

            Divider().background(Color.white.opacity(0.1))

            // Footer
            HStack {
                Text("Gwen v1.0 • M4 Optimized")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Button("Quit Gwen", action: onQuit)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.coralPink)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.5))
        }
        .frame(width: 380)
    }
}
