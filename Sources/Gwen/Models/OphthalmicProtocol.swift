import Foundation
import SwiftUI

/// Clinically validated ophthalmic protocols to prevent and ameliorate Digital Eye Strain (DES).
public enum OphthalmicProtocol: String, CaseIterable, Identifiable, Codable {
    case microBreak = "P-20-MICRO"
    case meibomianBlink = "P-BLINK-MEI"
    case accommodativeFlex = "P-ACCOM-FLEX"
    case thermalPalming = "P-PALM-THERM"
    case extraocularMotility = "P-MOTILITY"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .microBreak:
            return "20-20-20 Micro Relaxation"
        case .meibomianBlink:
            return "Meibomian Gland Blink Drill"
        case .accommodativeFlex:
            return "Step-Focusing Accommodative Agility"
        case .thermalPalming:
            return "Thermal Palming & Cortical Reset"
        case .extraocularMotility:
            return "Smooth Pursuit Eye Motility"
        }
    }

    public var subtitle: String {
        switch self {
        case .microBreak:
            return "Ciliary Muscle Relaxation & Tear Redistribution"
        case .meibomianBlink:
            return "Active Lipid Layer Expression & TBUT Restoration"
        case .accommodativeFlex:
            return "Near-Far Ciliary Spasm Relief"
        case .thermalPalming:
            return "Photoreceptor Deprivation & Deep Relaxation"
        case .extraocularMotility:
            return "Orbital Muscle Circulation & Lymphatic Clearance"
        }
    }

    /// Target duration in seconds for the protocol.
    public var defaultDurationSeconds: Int {
        switch self {
        case .microBreak: return 20
        case .meibomianBlink: return 60
        case .accommodativeFlex: return 45
        case .thermalPalming: return 90
        case .extraocularMotility: return 30
        }
    }

    /// Default recommended trigger interval in minutes.
    public var defaultIntervalMinutes: Int {
        switch self {
        case .microBreak: return 20
        case .meibomianBlink: return 60
        case .accommodativeFlex: return 40
        case .thermalPalming: return 90
        case .extraocularMotility: return 120
        }
    }

    public var sfSymbolName: String {
        switch self {
        case .microBreak: return "eye"
        case .meibomianBlink: return "sparkles.tv"
        case .accommodativeFlex: return "arrow.left.and.right.square"
        case .thermalPalming: return "hands.sparkles"
        case .extraocularMotility: return "infinity"
        }
    }

    public var clinicalGuidance: String {
        switch self {
        case .microBreak:
            return "Gaze into the distance beyond 20 feet (6 meters). Light rays enter parallel, allowing your ciliary muscle to fully relax."
        case .meibomianBlink:
            return "Perform slow, conscious blinks: Close gently (2s), squeeze eyelids firmly (2s), then reopen (2s). Re-establishes your protective lipid layer."
        case .accommodativeFlex:
            return "Alternate focus between a distant object (>20 ft) for 10s and a close object (15 cm from nose) for 10s. Restores dynamic ciliary agility."
        case .thermalPalming:
            return "Rub your palms together until warm, then cup them over your closed eyes without pressure. Excludes light to reset retinal photoreceptors."
        case .extraocularMotility:
            return "Keep your head still and follow the moving target with your eyes along the figure-8 path across your display borders."
        }
    }

    public var accentColor: Color {
        switch self {
        case .microBreak: return Color.cyan
        case .meibomianBlink: return Color.emeraldGreen
        case .accommodativeFlex: return Color.amberGold
        case .thermalPalming: return Color.deepLavender
        case .extraocularMotility: return Color.coralPink
        }
    }
}
