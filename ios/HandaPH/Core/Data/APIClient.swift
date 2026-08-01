import Foundation

/// Stub for the FastAPI backend (OpenAPI 3.1 contract — docs/architecture.md §9).
/// The app is offline-first: `FixtureStore` is the source of truth for the UI,
/// and this client only *refreshes* it when a network is available. Nothing in
/// the UI may block on a network call.
///
/// Contract endpoints this maps to:
///   GET  /v1/alerts?area={barangayCode}&lang={code}
///   GET  /v1/alerts/{token}
///   GET  /v1/glossary?lang={code}
///   POST /v1/deliveries/{token}/receipt
struct APIClient {
    var baseURL = URL(string: "https://rdy.ph/api")!
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5   // fail fast; fixtures carry the UI
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }()

    /// Reports that an SMS deep link was opened — the "receive" step telemetry
    /// (docs/architecture.md §5). Fire-and-forget; failure is expected offline.
    /// Sends the opaque token only: no location, no phone number, no identity.
    func postOpenReceipt(token: String) async {
        var request = URLRequest(url: baseURL.appending(path: "v1/deliveries/\(token)/receipt"))
        request.httpMethod = "POST"
        _ = try? await session.data(for: request)
    }

    /// Placeholder for delta sync of alerts. Wire up once the mock server from
    /// the hour-1 contract session is running; merge into local store, never
    /// replace it while offline.
    func fetchAlerts(areaCode: String) async throws -> [HazardAlert] {
        throw URLError(.unsupportedURL) // not yet implemented — fixtures only
    }
}
