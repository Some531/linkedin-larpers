import Foundation
import CoreLocation

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
    /// Quantified personal risk index, 0–100 (see RiskEngine.score docs).
    let score: Int
}

enum RiskEngine {
    /// Water hazards where coastal/low-lying and single-storey factors bite.
    private static let waterHazards: Set<HazardType> = [.stormSurge, .tsunami, .flashFlood, .typhoon]

    /// A located alert only drives someone's personal risk within this
    /// distance. Region-wide alerts (no coordinates) always apply.
    static let relevanceRadius: CLLocationDistance = 10_000

    /// Whether an alert is relevant at a location: coordinate-less alerts
    /// are region-wide; located ones must fall inside the relevance radius.
    static func isRelevant(_ alert: HazardAlert, at location: CLLocationCoordinate2D) -> Bool {
        guard let c = alert.coordinate else { return true }
        let a = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let b = CLLocation(latitude: c.latitude, longitude: c.longitude)
        return a.distance(from: b) <= relevanceRadius
    }

    // MARK: The personal risk index

    /// Per-alert personal risk, R = min(1, H · P · E · V):
    ///
    ///   H  hazard intensity from the official classification
    ///      (danger 1.0 · warning 0.6 · advisory 0.3)
    ///   P  proximity decay, e^(−d/10 km) from the alert centroid;
    ///      region-wide alerts (no centroid) use 0.5
    ///   E  exposure from geodata: inside the mapped hazard zone ×1.5
    ///      (in production the zone comes from Project NOAH / DEM
    ///      elevation over OSM base data); self-reported near-coast ×1.25
    ///   V  household vulnerability: 1 + 0.15·elderly + 0.15·mobility
    ///      + 0.10·children + 0.10·single-storey, capped at 1.5
    ///
    /// The index is max R over relevant alerts, ×100. Bands: ≥75 danger,
    /// ≥35 warning, else advisory. General reasoning (official alert +
    /// geography) times demographic-specific data — that product IS the
    /// app's thesis, in one line of arithmetic.
    static func riskR(for alert: HazardAlert, profile: HouseholdProfile, at location: CLLocationCoordinate2D) -> Double {
        let h: Double = switch alert.severity {
        case .danger: 1.0
        case .warning: 0.6
        case .advisory: 0.3
        }

        let p: Double
        if let c = alert.coordinate {
            let d = CLLocation(latitude: location.latitude, longitude: location.longitude)
                .distance(from: CLLocation(latitude: c.latitude, longitude: c.longitude))
            p = exp(-d / relevanceRadius)
        } else {
            p = 0.5
        }

        let isWater = waterHazards.contains(alert.hazard)
        let e: Double = if isWater, contains(polygon: FixtureStore.surgeZone, point: location) {
            1.5
        } else if isWater, profile.nearCoastOrRiver {
            1.25
        } else {
            1.0
        }

        var v = 1.0
        if profile.hasElderly { v += 0.15 }
        if profile.hasLimitedMobility { v += 0.15 }
        if profile.hasYoungChildren { v += 0.10 }
        if profile.singleStorey { v += 0.10 }
        v = min(v, 1.5)

        return min(1.0, h * p * e * v)
    }

    /// Personal risk for a household AT a place. The location does two jobs:
    /// it filters alerts to the relevance radius, and it checks the hazard
    /// zone directly — being inside the surge zone outranks anything the
    /// profile self-reports.
    ///
    /// Advice order is a fixed priority: in-zone > coast > single-storey >
    /// leave-earlier > children. The banner shows the top two.
    static func assess(
        alerts: [HazardAlert],
        profile: HouseholdProfile,
        at location: CLLocationCoordinate2D
    ) -> PersonalRisk {
        let relevant = alerts.filter {
            $0.phase != .allClear && $0.supersededByID == nil && isRelevant($0, at: location)
        }
        let scored = relevant
            .map { (alert: $0, r: riskR(for: $0, profile: profile, at: location)) }
            .max { $0.r < $1.r }
        guard let (worst, r) = scored.map({ ($0.alert, $0.r) }) else {
            return PersonalRisk(severity: .advisory, phase: .prepare, drivingAlert: nil, adviceKeys: [], score: 0)
        }

        let banded: Severity = r >= 0.75 ? .danger : (r >= 0.35 ? .warning : .advisory)

        var advice: [L10n.Key] = []
        if worst.severity >= .warning {
            let isWater = waterHazards.contains(worst.hazard)
            if isWater, contains(polygon: FixtureStore.surgeZone, point: location) {
                // Measured location beats self-report: user IS in the zone.
                advice.append(.adviceInSurgeZone)
            } else if isWater, profile.nearCoastOrRiver {
                advice.append(.adviceCoast)
            }
            if profile.singleStorey, isWater {
                advice.append(.adviceSingleStorey)
            }
            if profile.hasElderly || profile.hasLimitedMobility {
                advice.append(.adviceLeaveEarlier)
            }
            if profile.hasYoungChildren {
                advice.append(.adviceChildren)
            }
        }
        return PersonalRisk(
            severity: banded,
            phase: worst.phase,
            drivingAlert: worst,
            adviceKeys: advice,
            score: Int((r * 100).rounded())
        )
    }

    /// Ray-casting point-in-polygon on lat/lon — fine at barangay scale.
    static func contains(polygon: [CLLocationCoordinate2D], point: CLLocationCoordinate2D) -> Bool {
        guard polygon.count >= 3 else { return false }
        var inside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let a = polygon[i], b = polygon[j]
            if (a.longitude > point.longitude) != (b.longitude > point.longitude),
               point.latitude < (b.latitude - a.latitude)
                   * (point.longitude - a.longitude) / (b.longitude - a.longitude) + a.latitude {
                inside.toggle()
            }
            j = i
        }
        return inside
    }
}
