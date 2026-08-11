import SwiftUI

public struct MeibomianBlinkView: View {
    @ObservedObject var appState: AppState
    @State private var phaseTimer: Int = 0

    private var currentCyclePhase: String {
        let cycleTime = (appState.breakTotalSeconds - appState.breakSecondsRemaining) % 6
        switch cycleTime {
        case 0, 1:
            return "GENTLY CLOSE (2s)"
        case 2, 3:
            return "SQUEEZE EYELIDS (2s)"
        default:
            return "REOPEN & RE-OXYGENATE (2s)"
        }
    }

    private var phaseColor: Color {
        let cycleTime = (appState.breakTotalSeconds - appState.breakSecondsRemaining) % 6
        switch cycleTime {
        case 0, 1: return .emeraldGreen
        case 2, 3: return .amberGold
        default: return .softCyan
        }
    }

    private var completedCycles: Int {
        let elapsed = appState.breakTotalSeconds - appState.breakSecondsRemaining
        return elapsed / 6
    }

    public var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: OphthalmicProtocol.meibomianBlink.sfSymbolName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.emeraldGreen)
                    Text("P-BLINK-MEI • Meibomian Expression")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Expresses lipid oils onto your tear film to prevent dry eye evaporation (TBUT > 10s)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            // Concentric Pacing Visual
            ZStack {
                Circle()
                    .fill(phaseColor.opacity(0.12))
                    .frame(width: 220, height: 220)

                Circle()
                    .stroke(phaseColor, lineWidth: 6)
                    .frame(width: 180, height: 180)

                VStack(spacing: 6) {
                    Text(currentCyclePhase)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(phaseColor)
                        .multilineTextAlignment(.center)
                        .frame(width: 150)

                    Text("Cycle \(completedCycles + 1) of 10")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentCyclePhase)

            // Progress Bar & Counter
            VStack(spacing: 8) {
                HStack {
                    Text("Routine Progress")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(appState.breakSecondsRemaining)s remaining")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.emeraldGreen)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.emeraldGreen)
                            .frame(width: geo.size.width * CGFloat(appState.breakProgressFraction))
                    }
                }
                .frame(height: 8)
            }
            .frame(maxWidth: 440)

            // Guidance
            HStack(spacing: 12) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.emeraldGreen)
                    .font(.system(size: 16))
                Text(OphthalmicProtocol.meibomianBlink.clinicalGuidance)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.emeraldGreen.opacity(0.3), lineWidth: 1)
            )
            .frame(maxWidth: 480)
        }
        .padding(40)
    }
}
