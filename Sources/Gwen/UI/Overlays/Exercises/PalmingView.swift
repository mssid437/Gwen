import SwiftUI

public struct PalmingView: View {
    @ObservedObject var appState: AppState

    private var breathState: (String, Color) {
        let cycle = (appState.breakTotalSeconds - appState.breakSecondsRemaining) % 16
        switch cycle {
        case 0...3: return ("INHALE SLOWLY (4s)", .deepLavender)
        case 4...7: return ("HOLD BREATH (4s)", .softCyan)
        case 8...11: return ("EXHALE SLOWLY (4s)", .emeraldGreen)
        default: return ("HOLD BREATH (4s)", .amberGold)
        }
    }

    public var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: OphthalmicProtocol.thermalPalming.sfSymbolName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.deepLavender)
                    Text("P-PALM-THERM • Thermal Palming")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Exclude all light to rest retinal photoreceptors and relieve peri-orbital muscle tension")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            // Step Instructions Card
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("1")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 28, height: 28)
                        .background(Color.deepLavender)
                        .clipShape(Circle())
                    Text("Rub palms together briskly until warm")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(width: 140)

                VStack(spacing: 8) {
                    Text("2")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 28, height: 28)
                        .background(Color.deepLavender)
                        .clipShape(Circle())
                    Text("Cup palms over closed eyes (no pressure)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(width: 140)

                VStack(spacing: 8) {
                    Text("3")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 28, height: 28)
                        .background(Color.deepLavender)
                        .clipShape(Circle())
                    Text("Follow the box-breathing rhythm")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(width: 140)
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)

            // Box Breathing Rhythm Circle
            ZStack {
                Circle()
                    .fill(breathState.1.opacity(0.15))
                    .frame(width: 160, height: 160)

                Circle()
                    .stroke(breathState.1, lineWidth: 4)
                    .frame(width: 140, height: 140)

                VStack(spacing: 4) {
                    Text(breathState.0)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(breathState.1)
                        .multilineTextAlignment(.center)
                    Text("\(appState.breakSecondsRemaining)s")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .animation(.easeInOut(duration: 1), value: breathState.0)
        }
        .padding(40)
    }
}
