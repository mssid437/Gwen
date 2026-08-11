import Foundation
import Combine

public enum IntensityPreset: String, CaseIterable, Codable {
    case relaxed = "Relaxed (30m micro-breaks)"
    case balanced = "Balanced (20m clinical standard)"
    case deepWork = "Deep Work (45m long blocks)"

    public var microBreakInterval: Int {
        switch self {
        case .relaxed: return 30
        case .balanced: return 20
        case .deepWork: return 45
        }
    }
}

public class UserPreferences: ObservableObject {
    @Published public var microBreakIntervalMinutes: Int {
        didSet { UserDefaults.standard.set(microBreakIntervalMinutes, forKey: "microBreakIntervalMinutes") }
    }
    
    @Published public var meibomianIntervalMinutes: Int {
        didSet { UserDefaults.standard.set(meibomianIntervalMinutes, forKey: "meibomianIntervalMinutes") }
    }
    
    @Published public var accommodativeIntervalMinutes: Int {
        didSet { UserDefaults.standard.set(accommodativeIntervalMinutes, forKey: "accommodativeIntervalMinutes") }
    }
    
    @Published public var thermalPalmingIntervalMinutes: Int {
        didSet { UserDefaults.standard.set(thermalPalmingIntervalMinutes, forKey: "thermalPalmingIntervalMinutes") }
    }
    
    @Published public var motilityIntervalMinutes: Int {
        didSet { UserDefaults.standard.set(motilityIntervalMinutes, forKey: "motilityIntervalMinutes") }
    }

    // Smart Overrides & Intelligence
    @Published public var enableMeetingShield: Bool {
        didSet { UserDefaults.standard.set(enableMeetingShield, forKey: "enableMeetingShield") }
    }
    
    @Published public var enableIdleDetection: Bool {
        didSet { UserDefaults.standard.set(enableIdleDetection, forKey: "enableIdleDetection") }
    }
    
    @Published public var idleThresholdMinutes: Int {
        didSet { UserDefaults.standard.set(idleThresholdMinutes, forKey: "idleThresholdMinutes") }
    }
    
    @Published public var enablePreBreakToast: Bool {
        didSet { UserDefaults.standard.set(enablePreBreakToast, forKey: "enablePreBreakToast") }
    }
    
    @Published public var preBreakToastSeconds: Int {
        didSet { UserDefaults.standard.set(preBreakToastSeconds, forKey: "preBreakToastSeconds") }
    }

    @Published public var enableSoundEffects: Bool {
        didSet { UserDefaults.standard.set(enableSoundEffects, forKey: "enableSoundEffects") }
    }

    @Published public var enableVisionTracking: Bool {
        didSet { UserDefaults.standard.set(enableVisionTracking, forKey: "enableVisionTracking") }
    }

    @Published public var selectedPreset: IntensityPreset {
        didSet {
            UserDefaults.standard.set(selectedPreset.rawValue, forKey: "selectedPreset")
            self.microBreakIntervalMinutes = selectedPreset.microBreakInterval
        }
    }

    public init() {
        self.microBreakIntervalMinutes = UserDefaults.standard.object(forKey: "microBreakIntervalMinutes") as? Int ?? 20
        self.meibomianIntervalMinutes = UserDefaults.standard.object(forKey: "meibomianIntervalMinutes") as? Int ?? 60
        self.accommodativeIntervalMinutes = UserDefaults.standard.object(forKey: "accommodativeIntervalMinutes") as? Int ?? 40
        self.thermalPalmingIntervalMinutes = UserDefaults.standard.object(forKey: "thermalPalmingIntervalMinutes") as? Int ?? 90
        self.motilityIntervalMinutes = UserDefaults.standard.object(forKey: "motilityIntervalMinutes") as? Int ?? 120

        self.enableMeetingShield = UserDefaults.standard.object(forKey: "enableMeetingShield") as? Bool ?? true
        self.enableIdleDetection = UserDefaults.standard.object(forKey: "enableIdleDetection") as? Bool ?? true
        self.idleThresholdMinutes = UserDefaults.standard.object(forKey: "idleThresholdMinutes") as? Int ?? 3
        self.enablePreBreakToast = UserDefaults.standard.object(forKey: "enablePreBreakToast") as? Bool ?? true
        self.preBreakToastSeconds = UserDefaults.standard.object(forKey: "preBreakToastSeconds") as? Int ?? 15
        self.enableSoundEffects = UserDefaults.standard.object(forKey: "enableSoundEffects") as? Bool ?? true
        self.enableVisionTracking = UserDefaults.standard.object(forKey: "enableVisionTracking") as? Bool ?? false

        if let savedPresetRaw = UserDefaults.standard.string(forKey: "selectedPreset"),
           let savedPreset = IntensityPreset(rawValue: savedPresetRaw) {
            self.selectedPreset = savedPreset
        } else {
            self.selectedPreset = .balanced
        }
    }
}
