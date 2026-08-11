import SwiftUI

public extension Color {
    static let emeraldGreen = Color(red: 0.18, green: 0.80, blue: 0.55)
    static let amberGold = Color(red: 1.00, green: 0.72, blue: 0.22)
    static let deepLavender = Color(red: 0.65, green: 0.52, blue: 0.95)
    static let coralPink = Color(red: 0.96, green: 0.42, blue: 0.48)
    static let softCyan = Color(red: 0.25, green: 0.78, blue: 0.92)
    
    // Ergonomic dark background tokens
    static let gwenBackground = Color(red: 0.07, green: 0.09, blue: 0.12)
    static let gwenDarkCard = Color(red: 0.12, green: 0.15, blue: 0.20).opacity(0.85)
    static let gwenGlassBorder = Color.white.opacity(0.12)
}
