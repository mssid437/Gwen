import SwiftUI

public struct MicroBreakView: View {
    @ObservedObject var appState: AppState
    @State private var pulseScale: CGFloat = 1.0

    public var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: OphthalmicProtocol.microBreak.sfSymbolName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.cyan)
                    Text("P-20-MICRO • 20-20-20 Shift")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Relax your ciliary muscle by focusing on a distant target (>20 feet / 6 meters)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            // Infinite Depth Focal Visual Target
            ZStack {
                Circle()
                    .stroke(Color.cyan.opacity(0.2), lineWidth: 2)
                    .frame(width: 220, height: 220)

                Circle()
                    .stroke(Color.cyan.opacity(0.4), lineWidth: 3)
                    .frame(width: 170, height: 170)
                    .scaleEffect(pulseScale)
                    .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulseScale)

                // Countdown Ring
                Circle()
                    .trim(from: 0, to: CGFloat(appState.breakProgressFraction))
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .emeraldGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)
                    .animation(.linear(duration: 1), value: appState.breakSecondsRemaining)

                // Inner Time Counter
                VStack(spacing: 2) {
                    Text("\(appState.breakSecondsRemaining)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("SECONDS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)
                }
            }
            .onAppear {
                pulseScale = 1.25
            }

            // Ophthalmic Tip Box
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.cyan)
                    .font(.system(size: 16))
                Text(OphthalmicProtocol.microBreak.clinicalGuidance)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
            .frame(maxWidth: 480)
        }
        .padding(40)
    }
}
