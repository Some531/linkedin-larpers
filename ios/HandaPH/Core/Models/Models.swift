import Foundation
import CoreLocation

// MARK: - Language

/// Languages the app renders. Raw values are stable identifiers used for
/// persistence and, later, the API contract — do not reorder or rename.
enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "en"
    case tagalog = "tl"
    case cebuano = "ceb"
    case ilocano = "ilo"
    case hiligaynon = "hil"
    case bikol = "bcl"
    case waray = "war"

    var id: String { rawValue }

    /// The language named in itself — what a speaker looks for on first launch.
    var nativeName: String {
        switch self {
        case .english: "English"
        case .tagalog: "Tagalog"
        case .cebuano: "Binisaya (Cebuano)"
        case .ilocano: "Ilokano"
        case .hiligaynon: "Ilonggo (Hiligaynon)"
        case .bikol: "Bikol"
        case .waray: "Winaray (Waray)"
        }
    }

    /// BCP-47 code for AVSpeechSynthesizer. iOS ships no Cebuano/Waray/etc.
    /// voice, so all Philippine languages use the Filipino voice — an honest
    /// limitation we surface in the pitch rather than hide.
    var speechVoiceCode: String {
        self == .english ? "en-US" : "fil-PH"
    }
}

// MARK: - Translation honesty

/// Every non-English string in the app carries one of these. Renders as a
/// visible chip; "no AI slop" is a product property, not a slogan.
enum TranslationState: String, Codable {
    case humanVerified      // reviewed by a community speaker
    case machineAssisted    // drafted, awaiting community verification
    case untranslated       // falls back to English
}

/// A piece of text with per-language renderings and their verification state.
struct LocalizedText: Codable, Hashable {
    var values: [AppLanguage: String]
    var verified: Set<AppLanguage>

    init(_ values: [AppLanguage: String], verified: Set<AppLanguage> = [.english]) {
        self.values = values
        self.verified = verified
    }

    struct Resolved {
        let text: String
        let language: AppLanguage
        let state: TranslationState
    }

    /// Best available rendering for `language`, falling back to English.
    func resolved(for language: AppLanguage) -> Resolved {
        if let text = values[language] {
            let state: TranslationState = verified.contains(language) ? .humanVerified : .machineAssisted
            return Resolved(text: text, language: language, state: state)
        }
        return Resolved(text: values[.english] ?? "", language: .english, state: .untranslated)
    }
}

// MARK: - Hazards

/// The ten disaster types named in the brief (README "Disasters" section).
enum HazardType: String, Codable, CaseIterable, Identifiable {
    case typhoon, stormSurge, flashFlood, landslide, earthquake
    case tsunami, volcanicEruption, wildfire, drought, tornado

    var id: String { rawValue }

    /// Emoji doubles as the SMS symbol (README: emoji denote disaster type).
    var emoji: String {
        switch self {
        case .typhoon: "🌀"
        case .stormSurge: "🌊"
        case .flashFlood: "🌧️"
        case .landslide: "⛰️"
        case .earthquake: "🫨"
        case .tsunami: "🌊"
        case .volcanicEruption: "🌋"
        case .wildfire: "🔥"
        case .drought: "☀️"
        case .tornado: "🌪️"
        }
    }

    var symbolName: String {
        switch self {
        case .typhoon: "hurricane"
        case .stormSurge: "water.waves"
        case .flashFlood: "cloud.heavyrain"
        case .landslide: "mountain.2"
        case .earthquake: "waveform.path.ecg"
        case .tsunami: "water.waves.and.arrow.up"
        case .volcanicEruption: "mountain.2.fill"
        case .wildfire: "flame"
        case .drought: "sun.max.trianglebadge.exclamationmark"
        case .tornado: "tornado"
        }
    }

    var name: LocalizedText {
        switch self {
        case .stormSurge:
            LocalizedText([
                .english: "Storm surge",
                .tagalog: "Daluyong ng bagyo",
                .cebuano: "Dakong balod sa bagyo",
                .waray: "Dako nga balod han bagyo",
            ])
        case .typhoon:
            LocalizedText([.english: "Typhoon", .tagalog: "Bagyo", .cebuano: "Bagyo", .waray: "Bagyo"])
        case .flashFlood:
            LocalizedText([.english: "Flash flood", .tagalog: "Biglaang baha", .cebuano: "Kalit nga baha", .waray: "Tigda nga baha"])
        case .landslide:
            LocalizedText([.english: "Landslide", .tagalog: "Pagguho ng lupa", .cebuano: "Pagdahili sa yuta", .waray: "Pagrumpag han tuna"])
        case .earthquake:
            LocalizedText([.english: "Earthquake", .tagalog: "Lindol", .cebuano: "Linog", .waray: "Linog"])
        case .tsunami:
            LocalizedText([.english: "Tsunami", .tagalog: "Tsunami / malaking alon", .cebuano: "Tsunami / dagkong balod", .waray: "Tsunami / dagko nga balod"])
        case .volcanicEruption:
            LocalizedText([.english: "Volcanic eruption", .tagalog: "Pagputok ng bulkan", .cebuano: "Pagbuto sa bulkan", .waray: "Pagbuto han bulkan"])
        case .wildfire:
            LocalizedText([.english: "Wildfire", .tagalog: "Sunog sa parang", .cebuano: "Sunog sa kalasangan", .waray: "Sunog ha kagurangan"])
        case .drought:
            LocalizedText([.english: "Drought", .tagalog: "Tagtuyot", .cebuano: "Hulaw", .waray: "Huraw"])
        case .tornado:
            LocalizedText([.english: "Tornado", .tagalog: "Buhawi", .cebuano: "Buhawi", .waray: "Buhawi"])
        }
    }
}

// MARK: - Severity & phase

/// Traffic-light classification (README: "can be traffic-lighted").
/// Never rendered by colour alone — always colour + symbol + words.
enum Severity: String, Codable, CaseIterable, Comparable {
    case danger, warning, advisory

    var emoji: String {
        switch self {
        case .danger: "🔴"
        case .warning: "🟠"
        case .advisory: "🟢"
        }
    }

    private var rank: Int {
        switch self {
        case .danger: 2
        case .warning: 1
        case .advisory: 0
        }
    }

    static func < (lhs: Severity, rhs: Severity) -> Bool { lhs.rank < rhs.rank }
}

/// Which phase the message refers to — the brief requires this to be explicit
/// ("the disaster will happen soon" vs "it is happening now").
enum AlertPhase: String, Codable {
    case prepare        // preparedness, no event in view
    case expectedSoon   // event forecast
    case happeningNow   // response
    case allClear       // recovery / retraction
}

// MARK: - Alert

/// One rendered alert as the app receives it. Mirrors the backend `Alert` +
/// `AlertRendering` model (docs/architecture.md §6); flattened for the client.
struct HazardAlert: Identifiable, Codable {
    let id: String
    /// Opaque token from the SMS short link (rdy.ph/a/{token}).
    let token: String
    let hazard: HazardType
    let severity: Severity
    let phase: AlertPhase
    let issuedAt: Date
    /// Human-readable place, e.g. "Brgy San Jose, Tacloban City".
    let areaName: String
    let headline: LocalizedText
    /// Imperative, numbered actions — every message carries an action.
    let actions: [LocalizedText]
    let details: LocalizedText
    /// Issuing authority chain, shown verbatim for trust ("PAGASA via Tacloban CDRRMO").
    let issuedBy: String
    /// Set when a newer alert replaces this one (the Grenfell lesson).
    var supersededByID: String?
    /// Trusted-messenger co-sign: a named local figure (barangay captain,
    /// parish, DRRMO officer) who confirmed this alert to their community.
    var endorsedBy: String?
    /// Optional point for the map marker (region-wide alerts have none).
    /// Stored as raw doubles because CLLocationCoordinate2D is not Codable.
    var latitude: Double?
    var longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Glossary

/// Plain-language hazard explanations — the Haiyan intervention.
struct GlossaryTerm: Identifiable, Codable {
    let id: String
    let hazard: HazardType
    let term: LocalizedText
    /// Short plain-language explanation of what it IS.
    let meaning: LocalizedText
    /// What to DO about it, stated imperatively.
    let action: LocalizedText
}

// MARK: - Preparedness plan

struct ChecklistItem: Identifiable, Codable {
    let id: String
    let text: LocalizedText
}

// MARK: - Places

/// Landmarks highlighted on the map (README: "hospitals" named explicitly).
struct Landmark: Identifiable {
    enum Kind: String {
        case hospital, evacuationCenter, barangayHall

        var symbolName: String {
            switch self {
            case .hospital: "cross.fill"
            case .evacuationCenter: "figure.walk.arrival"
            case .barangayHall: "building.columns.fill"
            }
        }
    }

    let id: String
    let name: String
    let kind: Kind
    let coordinate: CLLocationCoordinate2D
}
