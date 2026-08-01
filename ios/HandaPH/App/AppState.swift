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
        storedLanguage = stored
        hasChosenLanguage = !stored.isEmpty
    }

    /// Handles handaph://a/{token} (demo) and https://rdy.ph/a/{token}
    /// (Universal Link, once the AASA file is served).
    func handle(url: URL) {
        let token: String?
        if url.scheme == "handaph", url.host == "a" {
            token = url.pathComponents.dropFirst().first
        } else if url.host == "rdy.ph", url.pathComponents.count >= 3, url.pathComponents[1] == "a" {
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
