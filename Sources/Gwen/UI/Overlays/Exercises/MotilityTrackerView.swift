import SwiftUI

public struct MotilityTrackerView: View {
    @ObservedObject var appState: AppState
    @State private var progress: Double = 0.0

    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            // Calculate Lemniscate of Bernoulli (Figure-8) trajectory point
            let scaleX = width * 0.35
            let scaleY = height * 0.25
            let centerX = width / 2
            let centerY = height / 2
            
            let t = progress * 2 * Double.pi
            let denom = 1 + sin(t) * sin(t)
            let posX = centerX + (scaleX * cos(t)) / denom
            let posY = centerY + (scaleY * sin(t) * cos(t)) / denom

            ZStack {
                // Outer Instruction Bar
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: OphthalmicProtocol.extraocularMotility.sfSymbolName)
                            .foregroundColor(.coralPink)
                            .font(.system(size: 20, weight: .bold))
                        Text("P-MOTILITY • Follow the moving target with your eyes (Keep head stationary)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(appState.breakSecondsRemaining)s")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.coralPink)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.coralPink.opacity(0.3), lineWidth: 1)
                    )
                    .padding(32)

                    Spacer()
                }

                // Smooth Pursuit Node Target
                ZStack {
                    Circle()
                        .fill(Color.coralPink.opacity(0.3))
                        .frame(width: 60, height: 60)

                    Circle()
                        .fill(Color.coralPink)
                        .frame(width: 28, height: 28)
                        .shadow(color: .coralPink, radius: 12)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
                .position(x: posX, y: posY)
            }
            .onReceive(timer) { _ in
                progress += 0.005
                if progress > 1.0 { progress = 0.0 }
            }
        }
    }
}
