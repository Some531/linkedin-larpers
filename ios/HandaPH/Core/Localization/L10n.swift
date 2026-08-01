import Foundation

/// UI chrome strings (tab names, buttons, section titles), keyed per language
/// with English fallback. Alert/glossary *content* is NOT here — content comes
/// from the template bank via `FixtureStore`/`APIClient` and carries its own
/// verification state.
///
/// Philippine-language strings below are drafts awaiting community
/// verification — same standard as content, tracked in `unverified`.
enum L10n {
    enum Key: String {
        case tabAlerts, tabMap, tabGlossary, tabPlan, tabSettings
        case alertsTitle, noAlerts
        case whatToDoNow, moreDetail, issuedBy, listen, stopListening
        case happeningNow, expectedSoon, prepare, allClear
        case severityDanger, severityWarning, severityAdvisory
        case glossaryTitle, glossarySubtitle, whatItIs, whatToDo
        case planTitle, planSubtitle
        case mapTitle, youAreHere, locationOff, locationOffBody
        case settingsTitle, language, largerText, speechRate, about
        case chooseLanguage, chooseLanguageBody, continueButton
        case unverifiedChip, untranslatedChip
        case supersededNotice
        case listenHint, doneStatus, notDoneStatus
        case voiceUnavailableNote
        case searchPrompt, noSearchResults
    }

    /// Languages whose UI strings have not yet been reviewed by a community
    /// speaker. Rendered honestly in Settings.
    static let unverified: Set<AppLanguage> = [.tagalog, .cebuano, .waray]

    static func t(_ key: Key, _ language: AppLanguage) -> String {
        tables[language]?[key] ?? tables[.english]?[key] ?? key.rawValue
    }

    // Tagalog, Cebuano and Waray tables cover the highest-traffic strings;
    // missing keys fall back to English. Ilocano/Hiligaynon/Bikol fall back
    // entirely until a speaker contributes — visible, not silent.
    private static let tables: [AppLanguage: [Key: String]] = [
        .english: [
            .tabAlerts: "Alerts", .tabMap: "Map", .tabGlossary: "Meanings",
            .tabPlan: "My Plan", .tabSettings: "Settings",
            .alertsTitle: "Alerts", .noAlerts: "No alerts for your area right now.",
            .whatToDoNow: "What to do now", .moreDetail: "More detail",
            .issuedBy: "Issued by", .listen: "Listen", .stopListening: "Stop",
            .happeningNow: "HAPPENING NOW", .expectedSoon: "EXPECTED SOON",
            .prepare: "PREPARE", .allClear: "ALL CLEAR",
            .severityDanger: "DANGER", .severityWarning: "WARNING", .severityAdvisory: "ADVISORY",
            .glossaryTitle: "Meanings", .glossarySubtitle: "Hazard words explained in plain language.",
            .whatItIs: "What it is", .whatToDo: "What to do",
            .planTitle: "My Plan", .planSubtitle: "Prepare before a disaster. Tick what you have done.",
            .mapTitle: "Map", .youAreHere: "You are here",
            .locationOff: "Location is off",
            .locationOffBody: "Showing Tacloban City. Allow location access in Settings to see hazards near you.",
            .settingsTitle: "Settings", .language: "Language", .largerText: "Larger text",
            .speechRate: "Speech speed", .about: "About",
            .chooseLanguage: "Choose your language", .chooseLanguageBody: "You can change this anytime in Settings.",
            .continueButton: "Continue",
            .unverifiedChip: "Awaiting community verification",
            .untranslatedChip: "Not yet translated — shown in English",
            .supersededNotice: "This alert has been replaced by a newer one.",
            .listenHint: "Reads the text aloud",
            .doneStatus: "Done", .notDoneStatus: "Not done yet",
            .voiceUnavailableNote: "This iPhone has no Filipino voice installed, so read-aloud uses an English voice. The words are still in your language.",
            .searchPrompt: "Search a word, e.g. storm surge",
            .noSearchResults: "No match found. Try another word.",
        ],
        .tagalog: [
            .tabAlerts: "Mga Alerto", .tabMap: "Mapa", .tabGlossary: "Kahulugan",
            .tabPlan: "Plano Ko", .tabSettings: "Mga Setting",
            .alertsTitle: "Mga Alerto", .noAlerts: "Walang alerto sa inyong lugar ngayon.",
            .whatToDoNow: "Gawin ngayon", .moreDetail: "Karagdagang detalye",
            .issuedBy: "Mula sa", .listen: "Pakinggan", .stopListening: "Itigil",
            .happeningNow: "NANGYAYARI NA", .expectedSoon: "PAPARATING",
            .prepare: "MAGHANDA", .allClear: "LIGTAS NA",
            .severityDanger: "DELIKADO", .severityWarning: "BABALA", .severityAdvisory: "PAALALA",
            .glossaryTitle: "Kahulugan", .glossarySubtitle: "Mga salitang pang-sakuna, ipinaliwanag nang simple.",
            .whatItIs: "Ano ito", .whatToDo: "Ano ang gagawin",
            .planTitle: "Plano Ko", .planSubtitle: "Maghanda bago ang sakuna. Lagyan ng tsek ang nagawa na.",
            .mapTitle: "Mapa", .youAreHere: "Nandito ka",
            .locationOff: "Nakapatay ang lokasyon",
            .locationOffBody: "Ipinapakita ang Tacloban City. Payagan ang lokasyon sa Settings para makita ang panganib malapit sa inyo.",
            .settingsTitle: "Mga Setting", .language: "Wika", .largerText: "Mas malaking titik",
            .speechRate: "Bilis ng pagsasalita", .about: "Tungkol dito",
            .chooseLanguage: "Piliin ang inyong wika", .chooseLanguageBody: "Maaari itong palitan anumang oras sa Settings.",
            .continueButton: "Magpatuloy",
            .unverifiedChip: "Hinihintay ang beripikasyon ng komunidad",
            .untranslatedChip: "Hindi pa naisalin — ipinapakita sa Ingles",
            .supersededNotice: "May mas bagong alerto na pumalit dito.",
            .listenHint: "Binabasa nang malakas ang teksto",
            .doneStatus: "Tapos na", .notDoneStatus: "Hindi pa tapos",
            .voiceUnavailableNote: "Walang boses na Filipino ang iPhone na ito, kaya boses na Ingles ang gagamitin sa pagbasa. Nasa wika mo pa rin ang mga salita.",
            .searchPrompt: "Maghanap ng salita, hal. daluyong",
            .noSearchResults: "Walang nahanap. Subukan ang ibang salita.",
        ],
        .cebuano: [
            .tabAlerts: "Mga Alerto", .tabMap: "Mapa", .tabGlossary: "Kahulogan",
            .tabPlan: "Akong Plano", .tabSettings: "Mga Setting",
            .alertsTitle: "Mga Alerto", .noAlerts: "Walay alerto sa inyong lugar karon.",
            .glossaryTitle: "Kahulogan", .glossarySubtitle: "Mga pulong bahin sa katalagman, gipasabot sa yano nga pinulongan.",
            .planTitle: "Akong Plano", .planSubtitle: "Pangandam sa dili pa ang katalagman. Markahi ang nahuman na.",
            .mapTitle: "Mapa", .settingsTitle: "Mga Setting",
            .language: "Pinulongan", .largerText: "Mas dako nga letra", .speechRate: "Kapaspason sa pagsulti",
            .whatToDoNow: "Buhaton karon", .moreDetail: "Dugang detalye",
            .issuedBy: "Gikan sa", .listen: "Paminawa", .stopListening: "Hunong",
            .happeningNow: "NAGAKAHITABO NA", .expectedSoon: "UMAABOT NA",
            .prepare: "PANGANDAM", .allClear: "LUWAS NA",
            .severityDanger: "PELIGRO", .severityWarning: "PASIDAAN", .severityAdvisory: "PAHINUMDOM",
            .whatItIs: "Unsa kini", .whatToDo: "Unsay buhaton",
            .youAreHere: "Ania ka dinhi",
            .chooseLanguage: "Pilia ang imong pinulongan",
            .continueButton: "Padayon",
            .unverifiedChip: "Naghulat sa beripikasyon sa komunidad",
        ],
        .waray: [
            .tabAlerts: "Mga Alerto", .tabMap: "Mapa", .tabGlossary: "Kahulogan",
            .tabPlan: "Akon Plano", .tabSettings: "Mga Setting",
            .alertsTitle: "Mga Alerto", .noAlerts: "Waray alerto ha iyo lugar yana.",
            .glossaryTitle: "Kahulogan", .glossarySubtitle: "Mga pulong mahitungod han kalamidad, ginsaysay hin simple nga yinaknan.",
            .planTitle: "Akon Plano", .planSubtitle: "Pangandam antes han kalamidad. Markahi an nahuman na.",
            .mapTitle: "Mapa", .settingsTitle: "Mga Setting",
            .language: "Yinaknan", .largerText: "Mas dako nga letra", .speechRate: "Kapaspason han pagyakan",
            .whatToDoNow: "Buhata yana", .moreDetail: "Dugang nga detalye",
            .issuedBy: "Tikang ha", .listen: "Pamatia", .stopListening: "Undang",
            .happeningNow: "NAHITATABO NA", .expectedSoon: "TIARABOT NA",
            .prepare: "PANGANDAM", .allClear: "TALWAS NA",
            .severityDanger: "PELIGRO", .severityWarning: "PAHAMANGNO", .severityAdvisory: "PAHINUMDOM",
            .whatItIs: "Ano ini", .whatToDo: "Ano an bubuhaton",
            .youAreHere: "Aanhi ka dinhi",
            .chooseLanguage: "Pilia an imo yinaknan",
            .continueButton: "Padayon",
            .unverifiedChip: "Naghuhulat han beripikasyon han komunidad",
        ],
    ]
}
