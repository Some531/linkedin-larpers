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
        // Map & personalised risk
        case yourArea, noActiveRisk, directions, walkSuffix
        case legendHospital, legendEvacuation, legendBarangay
        case adviceLeaveEarlier, adviceChildren, adviceCoast, adviceSingleStorey
        // Household profile
        case profileTitle, profileSubtitle
        case profileElderly, profileChildren, profileMobility, profileCoast, profileSingleStorey
        case privacyNote
        // Assistant (Gabay)
        case assistantIntro, assistantOffline, assistantOfflineBadge
        case assistantPlaceholder, assistantWorking, assistantNoMatch
        case youAsked, send, speak, listening
        // Routing
        case showRoute, endRoute, routeUnavailable
        // Relevance
        case nearYou, adviceInSurgeZone
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
            .yourArea: "YOUR AREA", .noActiveRisk: "No active danger in your area. Prepare while it is calm.",
            .directions: "Directions", .walkSuffix: "min walk",
            .legendHospital: "Hospital", .legendEvacuation: "Evacuation", .legendBarangay: "Barangay hall",
            .adviceLeaveEarlier: "Someone in your household needs more time — leave EARLIER than the general advice.",
            .adviceChildren: "Bring water, food and medicine for the children. Carry them across moving water.",
            .adviceCoast: "Your home is near the coast or river — do not wait for the water to be visible.",
            .adviceSingleStorey: "Your house has one storey — going upstairs is not an option. Go to the evacuation centre.",
            .profileTitle: "My Household", .profileSubtitle: "Used only to personalise your risk and actions.",
            .profileElderly: "Elderly (60+) in household",
            .profileChildren: "Young children (under 5)",
            .profileMobility: "Someone with limited mobility",
            .profileCoast: "House near coast or river",
            .profileSingleStorey: "Single-storey house",
            .privacyNote: "This stays on your phone only. It is never sent anywhere.",
            .assistantIntro: "Ask me what a hazard word means, or where to find something in the app. I answer only from verified content.",
            .assistantOffline: "No connection needed — I answer from the glossary stored on this phone.",
            .assistantOfflineBadge: "verified · offline",
            .assistantPlaceholder: "Ask about a word, e.g. storm surge…",
            .assistantWorking: "working…",
            .assistantNoMatch: "I don't have verified content about that. Check the Alerts tab for current warnings, or ask your barangay officials.",
            .youAsked: "You asked",
            .send: "Send",
            .speak: "Speak", .listening: "Listening…",
            .showRoute: "Route", .endRoute: "End route",
            .routeUnavailable: "No route available offline — straight line shown.",
            .nearYou: "Near you",
            .adviceInSurgeZone: "You are INSIDE the storm-surge danger zone. Move out of it now — do not wait.",
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
            .yourArea: "ANG INYONG LUGAR", .noActiveRisk: "Walang aktibong panganib sa inyong lugar. Maghanda habang tahimik.",
            .directions: "Direksyon", .walkSuffix: "min na lakad",
            .legendHospital: "Ospital", .legendEvacuation: "Evacuation", .legendBarangay: "Barangay hall",
            .adviceLeaveEarlier: "May kasama kayong nangangailangan ng mas maraming oras — umalis nang MAS MAAGA kaysa sa pangkalahatang payo.",
            .adviceChildren: "Magdala ng tubig, pagkain at gamot para sa mga bata. Buhatin sila sa umaagos na tubig.",
            .adviceCoast: "Malapit sa dagat o ilog ang inyong bahay — huwag hintaying makita ang tubig.",
            .adviceSingleStorey: "Isang palapag lang ang inyong bahay — hindi puwedeng umakyat. Pumunta sa evacuation center.",
            .profileTitle: "Ang Aming Sambahayan", .profileSubtitle: "Ginagamit lamang para gawing personal ang panganib at payo.",
            .profileElderly: "May matanda (60+) sa bahay",
            .profileChildren: "May maliliit na bata (wala pang 5)",
            .profileMobility: "May hirap maglakad nang mabilis",
            .profileCoast: "Bahay malapit sa dagat o ilog",
            .profileSingleStorey: "Isang palapag lang ang bahay",
            .privacyNote: "Nananatili ito sa inyong telepono lamang. Hindi ito ipinapadala kahit saan.",
            .assistantIntro: "Itanong kung ano ang ibig sabihin ng isang salita, o kung saan makikita ang isang bahagi ng app. Sumasagot lamang ako mula sa beripikadong nilalaman.",
            .assistantOffline: "Hindi kailangan ng koneksyon — sumasagot ako mula sa glossary na nasa teleponong ito.",
            .assistantOfflineBadge: "beripikado · offline",
            .assistantPlaceholder: "Magtanong, hal. daluyong ng bagyo…",
            .assistantWorking: "gumagana…",
            .assistantNoMatch: "Wala akong beripikadong nilalaman tungkol diyan. Tingnan ang Mga Alerto para sa kasalukuyang babala, o magtanong sa barangay.",
            .youAsked: "Tinanong mo",
            .send: "Ipadala",
            .speak: "Magsalita", .listening: "Nakikinig…",
            .showRoute: "Ruta", .endRoute: "Tapusin ang ruta",
            .routeUnavailable: "Walang rutang makuha nang offline — tuwid na linya ang ipinapakita.",
            .nearYou: "Malapit sa inyo",
            .adviceInSurgeZone: "NASA LOOB kayo ng mapanganib na sona ng daluyong. Umalis na ngayon — huwag maghintay.",
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
            .yourArea: "AN IYO LUGAR", .noActiveRisk: "Waray aktibo nga peligro ha iyo lugar. Pangandam samtang mamingaw.",
            .directions: "Direksyon", .walkSuffix: "min nga paglakat",
            .legendHospital: "Ospital", .legendEvacuation: "Evacuation", .legendBarangay: "Barangay hall",
            .adviceLeaveEarlier: "May kaupod kamo nga nagkikinahanglan hin mas damo nga oras — paggawas hin MAS AGA kaysa han kabug-osan nga sagdon.",
            .adviceChildren: "Pagdara hin tubig, pagkaon ngan tambal para ha kabataan. Sakwata hira ha naga-agos nga tubig.",
            .adviceCoast: "Harani ha dagat o salog an iyo balay — ayaw hulata nga makita an tubig.",
            .adviceSingleStorey: "Usa la ka andana an iyo balay — diri puydi sumaka. Kadto ha evacuation center.",
            .profileTitle: "An Amon Panimalay", .profileSubtitle: "Gingagamit la para himuon nga personal an peligro ngan sagdon.",
            .profileElderly: "May edaran (60+) ha balay",
            .profileChildren: "May gudti nga kabataan (ubos 5)",
            .profileMobility: "May nakukurian maglakat hin madagmit",
            .profileCoast: "Balay harani ha dagat o salog",
            .profileSingleStorey: "Usa la ka andana an balay",
            .privacyNote: "Nagpapabilin ini ha imo telepono la. Diri ini iginpapadara bisan diin.",
            .assistantIntro: "Pakiana ako kon ano an kahulogan hin usa nga pulong, o diin makikit-an an usa nga bahin han app. Nabaton la ako tikang ha beripikado nga sulod.",
            .assistantOffline: "Diri kinahanglan hin koneksyon — nabaton ako tikang ha glossary nga aada hini nga telepono.",
            .assistantOfflineBadge: "beripikado · offline",
            .assistantPlaceholder: "Pakiana, sugad han dako nga balod…",
            .assistantWorking: "nagtatrabaho…",
            .assistantNoMatch: "Waray ako beripikado nga sulod mahitungod hito. Kitaa an Mga Alerto para han pahamangno yana, o pakiana ha barangay.",
            .youAsked: "Iginpakiana mo",
            .send: "Ipadara",
            .speak: "Pagyakan", .listening: "Namamati…",
            .showRoute: "Ruta", .endRoute: "Tapuson an ruta",
            .routeUnavailable: "Waray ruta nga makukuha hin offline — tul-id nga linya an iginpapakita.",
            .nearYou: "Harani ha imo",
            .adviceInSurgeZone: "AADA KA HA SULOD han peligroso nga sona han dako nga balod. Gawas na yana — ayaw paghulat.",
        ],
    ]
}
