import SwiftUI

public struct PreBreakToastView: View {
    @ObservedObject var appState: AppState
    var onStartNow: () -> Void
    var onSnooze: () -> Void

    public var body: some View {
        GlassmorphicCard(cornerRadius: 16) {
            HStack(spacing: 16) {
                // Protocol Icon
                ZStack {
                    Circle()
                        .fill(appState.currentProtocol.accentColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: appState.currentProtocol.sfSymbolName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(appState.currentProtocol.accentColor)
                }

                // Info Text
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(appState.currentProtocol.title)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(appState.secondsRemaining)s")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(appState.currentProtocol.accentColor)
                    }

                    Text("Eye-health break starting shortly...")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }

                // Action Buttons
                HStack(spacing: 8) {
                    Button(action: onSnooze) {
                        Text("Snooze")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    Button(action: onStartNow) {
                        Text("Start")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(appState.currentProtocol.accentColor)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
        }
        .frame(width: 380, height: 72)
    }
}
