import SwiftUI

public struct StepFocusView: View {
    @ObservedObject var appState: AppState

    private var isFarFocus: Bool {
        let cycle = (appState.breakTotalSeconds - appState.breakSecondsRemaining) % 20
        return cycle < 10
    }

    public var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: OphthalmicProtocol.accommodativeFlex.sfSymbolName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.amberGold)
                    Text("P-ACCOM-FLEX • Step-Focusing")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Text("Train dynamic accommodative facility and release ciliary muscle spasms")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            // Alternating Focal Plane Target Indicator
            HStack(spacing: 40) {
                // Far Plane Target
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(isFarFocus ? Color.amberGold.opacity(0.2) : Color.white.opacity(0.05))
                            .frame(width: 100, height: 100)

                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 36))
                            .foregroundColor(isFarFocus ? .amberGold : .white.opacity(0.3))
                    }
                    .overlay(
                        Circle()
                            .stroke(isFarFocus ? Color.amberGold : Color.clear, lineWidth: 3)
                    )

                    Text("FAR TARGET\n(> 20 feet)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isFarFocus ? .amberGold : .white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }

                Image(systemName: "arrow.right.arrow.left")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.amberGold.opacity(0.7))

                // Near Plane Target
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(!isFarFocus ? Color.amberGold.opacity(0.2) : Color.white.opacity(0.05))
                            .frame(width: 100, height: 100)

                        Image(systemName: "hand.point.up.fill")
                            .font(.system(size: 36))
                            .foregroundColor(!isFarFocus ? .amberGold : .white.opacity(0.3))
                    }
                    .overlay(
                        Circle()
                            .stroke(!isFarFocus ? Color.amberGold : Color.clear, lineWidth: 3)
                    )

                    Text("NEAR TARGET\n(15 cm / Finger tip)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(!isFarFocus ? .amberGold : .white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
            }
            .animation(.spring(), value: isFarFocus)

            // Current Action Callout
            Text(isFarFocus ? "LOOK AT DISTANT WALL OR WINDOW" : "LOOK AT FINGERTIP HELD 15cm AWAY")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.amberGold)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.amberGold.opacity(0.15))
                .cornerRadius(20)

            // Countdown
            Text("\(appState.breakSecondsRemaining) seconds remaining")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(40)
    }
}
