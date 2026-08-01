import Foundation

/// Demographic facts the user volunteers about their household, used ONLY to
/// personalise risk and advice. Never leaves the device — there is no code
/// path that serialises this to the network, and it must stay that way.
struct HouseholdProfile: Codable, Equatable {
    var hasElderly = false
    var hasYoungChildren = false
    var hasLimitedMobility = false
    var nearCoastOrRiver = false
    var singleStorey = false
}

@MainActor
final class HouseholdProfileStore: ObservableObject {
    @Published var profile: HouseholdProfile {
        didSet {
            if let data = try? JSONEncoder().encode(profile) {
                UserDefaults.standard.set(data, forKey: "householdProfile")
            }
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "householdProfile"),
           let saved = try? JSONDecoder().decode(HouseholdProfile.self, from: data) {
            profile = saved
        } else {
            profile = HouseholdProfile()
        }
    }
}

// MARK: - Personalised risk

/// The output of combining active alerts with the household profile:
/// what the banner on the map says, and which extra advice lines apply.
struct PersonalRisk {
    let severity: Severity
    let phase: AlertPhase
    /// The alert that drives the assessment; nil when nothing is active.
    let drivingAlert: HazardAlert?
    /// Localized advice lines specific to this household (L10n keys, so
    /// every line comes from the verified string bank — nothing generated).
    let adviceKeys: [L10n.Key]
}

enum RiskEngine {
    /// Water hazards where coastal/low-lying and single-storey factors bite.
    private static let waterHazards: Set<HazardType> = [.stormSurge, .tsunami, .flashFlood, .typhoon]

    static func assess(alerts: [HazardAlert], profile: HouseholdProfile) -> PersonalRisk {
        let active = alerts.filter { $0.phase != .allClear && $0.supersededByID == nil }
        guard let worst = active.max(by: { $0.severity < $1.severity }) else {
            return PersonalRisk(severity: .advisory, phase: .prepare, drivingAlert: nil, adviceKeys: [])
        }

        var advice: [L10n.Key] = []
        if worst.severity >= .warning {
            if profile.nearCoastOrRiver, waterHazards.contains(worst.hazard) {
                advice.append(.adviceCoast)
            }
            if profile.singleStorey, waterHazards.contains(worst.hazard) {
                advice.append(.adviceSingleStorey)
            }
            if profile.hasElderly || profile.hasLimitedMobility {
                advice.append(.adviceLeaveEarlier)
            }
            if profile.hasYoungChildren {
                advice.append(.adviceChildren)
            }
        }
        return PersonalRisk(severity: worst.severity, phase: worst.phase, drivingAlert: worst, adviceKeys: advice)
    }
}
