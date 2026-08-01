import Foundation
import CoreLocation

/// Everything Gabay may use to personalise an answer. Assembled on device;
/// only the coarse summary strings are sent with an online request —
/// never raw coordinates.
struct UserSituation {
    let areaName: String
    let riskSummary: String
    let householdSummary: String
    let nearestEvac: String?
    let inSurgeZone: Bool

    @MainActor
    static func current(profile: HouseholdProfile, at location: CLLocationCoordinate2D, language: AppLanguage) -> UserSituation {
        let risk = RiskEngine.assess(alerts: FixtureStore.alerts, profile: profile, at: location)
        let riskText: String
        if let alert = risk.drivingAlert {
            riskText = "\(risk.severity.rawValue.uppercased()) — \(alert.hazard.rawValue), \(alert.phase.rawValue), \(alert.areaName)"
        } else {
            riskText = "no active alert nearby"
        }
        var household: [String] = []
        if profile.hasElderly { household.append("elderly member") }
        if profile.hasYoungChildren { household.append("young children") }
        if profile.hasLimitedMobility { household.append("limited mobility") }
        if profile.nearCoastOrRiver { household.append("home near coast/river") }
        if profile.singleStorey { household.append("single-storey house") }

        let here = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let evac = FixtureStore.allLandmarks
            .filter { $0.kind == .evacuationCenter }
            .map { lm -> (Landmark, CLLocationDistance) in
                (lm, here.distance(from: CLLocation(latitude: lm.coordinate.latitude, longitude: lm.coordinate.longitude)))
            }
            .min { $0.1 < $1.1 }
        let evacText = evac.map { "\($0.0.name), \(Int($0.1)) m away (~\(max(1, Int($0.1) / 80)) min walk)" }

        return UserSituation(
            areaName: "Tacloban City area",
            riskSummary: riskText,
            householdSummary: household.isEmpty ? "no special factors recorded" : household.joined(separator: ", "),
            nearestEvac: evacText,
            inSurgeZone: RiskEngine.contains(polygon: FixtureStore.surgeZone, point: location)
        )
    }
}

/// One question → answer exchange, including the visible trace — the Flux
/// pattern from Modulo Flow: the user watches route → retrieve → answer
/// happen, so "answers come from verified content" is shown, not claimed.
struct AssistantTurn: Identifiable {
    struct TraceStep: Identifiable {
        let id = UUID()
        let key: String     // mono label: route / retrieve / answer
        let value: String
    }

    let id = UUID()
    let question: String
    /// Kept for logging/debugging; no longer rendered in the UI.
    var trace: [TraceStep] = []
    var answer: String = ""
    /// Names of the verified entries that grounded the answer.
    var groundedOn: [String] = []
    /// IDs of the glossary entries behind the answer — rendered as
    /// tappable learn-more cards under it.
    var groundedTermIDs: [String] = []
    /// True when the answer came from the on-device corpus (offline path).
    var isLocal = false
}

/// Gabay ("guide") — the app's assistant. Two paths, same grounding:
///
/// - **Online + API key:** Claude answers, but ONLY from the verified
///   glossary/alert content we inject, in the user's language, and is
///   instructed to never invent warnings. It explains and navigates; the
///   alert pipeline remains human-authored end to end.
/// - **Offline / no key:** deterministic retrieval over the same corpus —
///   the matched glossary entry IS the answer.
@MainActor
final class AssistantEngine: ObservableObject {
    @Published private(set) var turns: [AssistantTurn] = []
    @Published private(set) var isWorking = false

    private let client = AnthropicClient()

    func ask(_ question: String, language: AppLanguage, situation: UserSituation? = nil) async {
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !isWorking else { return }
        isWorking = true
        defer { isWorking = false }

        var turn = AssistantTurn(question: q)
        let matches = Self.retrieve(q, language: language)
        turn.groundedOn = matches.map { $0.term.resolved(for: language).text }
        turn.groundedTermIDs = matches.map(\.id)
        turn.trace.append(.init(key: "route", value: matches.isEmpty ? "navigate · app" : "explain · hazard term"))
        turn.trace.append(.init(key: "retrieve", value: matches.isEmpty ? "no glossary match" : turn.groundedOn.joined(separator: ", ")))

        // -forceOfflineAssistant 1 (UI tests) pins the deterministic path
        // even when a key is configured.
        let forceOffline = UserDefaults.standard.bool(forKey: "forceOfflineAssistant")
        if AnthropicClient.hasKey, !forceOffline {
            do {
                let context = Self.contextBlock(matches: matches, language: language)
                let text = try await client.complete(
                    system: Self.systemPrompt(language: language, context: context, situation: situation),
                    user: q
                )
                turn.answer = text
                turn.trace.append(.init(key: "answer", value: "Claude · grounded on verified content"))
                turns.append(turn)
                return
            } catch {
                turn.trace.append(.init(key: "fallback", value: "network unavailable"))
            }
        }

        // Offline / no-key path: the verified corpus answers directly.
        turn.isLocal = true
        if let best = matches.first {
            let meaning = best.meaning.resolved(for: language).text
            let action = best.action.resolved(for: language).text
            turn.answer = "\(meaning)\n\n\(action)"
        } else if let evac = situation?.nearestEvac,
                  Self.isWhereToGoQuestion(q) {
            // Deterministic location-aware answer: nearest evacuation centre.
            turn.answer = "\(L10n.t(.legendEvacuation, language)): \(evac)"
        } else {
            turn.answer = L10n.t(.assistantNoMatch, language)
        }
        turn.trace.append(.init(key: "answer", value: "offline · verified corpus"))
        turns.append(turn)
    }

    /// Keyword retrieval over the glossary, matching in the user's language
    /// AND English (same behaviour as the Meanings tab search).
    static func retrieve(_ question: String, language: AppLanguage) -> [GlossaryTerm] {
        let words = question.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 3 }
        guard !words.isEmpty else { return [] }
        return FixtureStore.glossary.filter { term in
            let haystack = [
                term.term.resolved(for: language).text,
                term.term.values[.english] ?? "",
                term.meaning.resolved(for: language).text,
                term.meaning.values[.english] ?? "",
            ].joined(separator: " ").lowercased()
            return words.contains { haystack.contains($0) }
        }
    }

    private static func contextBlock(matches: [GlossaryTerm], language: AppLanguage) -> String {
        var parts: [String] = []
        for term in matches.prefix(3) {
            let name = term.term.resolved(for: language).text
            let meaning = term.meaning.resolved(for: language).text
            let action = term.action.resolved(for: language).text
            parts.append("TERM: \(name)\nMEANING: \(meaning)\nACTION: \(action)")
        }
        for alert in FixtureStore.alerts where alert.phase != .allClear {
            let headline = alert.headline.resolved(for: language).text
            parts.append("ACTIVE ALERT (\(alert.severity.rawValue), \(alert.areaName)): \(headline)")
        }
        return parts.joined(separator: "\n\n")
    }

    /// "Where do I go / where is it safe" in the supported languages.
    static func isWhereToGoQuestion(_ q: String) -> Bool {
        let needles = ["where", "evac", "saan", "ligtas", "diin", "asa", "makadto", "pupunta", "talwas", "safe"]
        let lower = q.lowercased()
        return needles.contains { lower.contains($0) }
    }

    private static func systemPrompt(language: AppLanguage, context: String, situation: UserSituation?) -> String {
        var situationBlock = ""
        if let s = situation {
            situationBlock = """

            USER SITUATION (use this to personalise; recommend the nearest \
            evacuation centre by name when relevant):
            - Location: \(s.areaName)\(s.inSurgeZone ? " — currently INSIDE the storm-surge hazard zone" : "")
            - Current personal risk: \(s.riskSummary)
            - Household: \(s.householdSummary)
            - Nearest evacuation centre: \(s.nearestEvac ?? "unknown")
            """
        }
        return basePrompt(language: language, context: context) + situationBlock
    }

    private static func basePrompt(language: AppLanguage, context: String) -> String {
        """
        You are Gabay, the in-app guide of HandaPH, a disaster-preparedness app \
        for the Philippines. You help users understand hazard terms and find \
        things in the app (tabs: Alerts, Map, Meanings, My Plan, Settings; the \
        Map holds evacuation centres and the household profile).

        Rules, in order:
        1. NEVER compose, predict, or embellish a warning. If asked about \
        current danger, repeat only the ACTIVE ALERT lines given below and \
        direct the user to the Alerts tab.
        2. Answer ONLY from the VERIFIED CONTENT below plus app navigation. \
        If it does not cover the question, say so and point to the barangay \
        officials or the Alerts tab. Do not draw on outside knowledge about \
        current events.
        3. Answer in the user's language: \(language.nativeName). Use short, \
        plain sentences a stressed reader can follow. No jargon.
        4. Keep answers under 120 words.
        5. Plain text only — no markdown, no asterisks, no bullet symbols, \
        no headers. The app renders your words verbatim.

        VERIFIED CONTENT:
        \(context.isEmpty ? "(none matched)" : context)
        """
    }
}

/// Minimal Anthropic Messages API client. The key comes from
/// Config/Secrets.local.xcconfig via Info.plist — see ios/README.md.
/// Demo-grade: shipping a key inside an app binary is not a production
/// pattern; the production path proxies through the backend.
struct AnthropicClient {
    static var apiKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String,
              !key.isEmpty else { return nil }
        return key
    }

    static var hasKey: Bool { apiKey != nil }

    func complete(system: String, user: String) async throws -> String {
        guard let key = Self.apiKey else { throw URLError(.userAuthenticationRequired) }
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        let body: [String: Any] = [
            "model": "claude-haiku-4-5-20251001",  // fast + cheap; fits a chat guide
            "max_tokens": 400,
            "system": system,
            "messages": [["role": "user", "content": user]],
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        return text
    }
}
