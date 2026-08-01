import SwiftUI

/// App-wide user state. Persisted bits use AppStorage-backed keys so they
/// survive relaunch; everything else is session state.
@MainActor
final class AppState: ObservableObject {
    // NOTE: @AppStorage does not publish from inside an ObservableObject,
    // so persisted settings are @Published properties mirrored to
    // UserDefaults by hand.

    /// Extra text-size boost on top of the system Dynamic Type setting,
    /// for elderly users who have not found the iOS setting.
    @Published var largerText: Bool {
        didSet { UserDefaults.standard.set(largerText, forKey: "largerText") }
    }

    /// Audio-first mode: alert details read themselves aloud on open —
    /// for low-literacy and elderly users, voice is the primary medium.
    @Published var autoRead: Bool {
        didSet { UserDefaults.standard.set(autoRead, forKey: "autoRead") }
    }

    /// Age band from onboarding ("u40" / "a40" / "s60"); 60+ turns on the
    /// larger-text and read-aloud accessibility defaults automatically.
    @Published var ageGroup: String {
        didSet { UserDefaults.standard.set(ageGroup, forKey: "ageGroup") }
    }

    @Published private var storedLanguage: String {
        didSet { UserDefaults.standard.set(storedLanguage, forKey: "appLanguage") }
    }

    /// Alert opened via SMS deep link; RootView presents it when set.
    @Published var deepLinkedAlert: HazardAlert?

    /// False until the first-launch language screen has been completed.
    @Published var hasChosenLanguage: Bool

    var language: AppLanguage {
        get { AppLanguage(rawValue: storedLanguage) ?? .english }
        set {
            storedLanguage = newValue.rawValue
            hasChosenLanguage = true
        }
    }

    private let api = APIClient()

    init() {
        let stored = UserDefaults.standard.string(forKey: "appLanguage") ?? ""
        largerText = UserDefaults.standard.bool(forKey: "largerText")
        autoRead = UserDefaults.standard.bool(forKey: "autoRead")
        ageGroup = UserDefaults.standard.string(forKey: "ageGroup") ?? ""
        storedLanguage = stored
        hasChosenLanguage = !stored.isEmpty
    }

    /// Handles handaph://a/{token} (demo) and https://rdy.ph/a/{token}
    /// (Universal Link, once the AASA file is served). Scheme and host are
    /// case-insensitive; www. is accepted on the https form.
    /// An unknown token lands the user on the alerts list rather than a
    /// dead end — the app opening at all is still the right outcome.
    func handle(url: URL) {
        let scheme = url.scheme?.lowercased()
        let host = url.host()?.lowercased()
        let token: String?
        if scheme == "handaph", host == "a" {
            token = url.pathComponents.dropFirst().first
        } else if host == "rdy.ph" || host == "www.rdy.ph",
                  url.pathComponents.count >= 3, url.pathComponents[1] == "a" {
            token = url.pathComponents[2]
        } else {
            token = nil
        }
        guard let token, let alert = FixtureStore.alert(forToken: token) else { return }
        deepLinkedAlert = alert
        // Receipt telemetry — fire-and-forget, expected to fail offline.
        Task { await api.postOpenReceipt(token: token) }
    }
}
