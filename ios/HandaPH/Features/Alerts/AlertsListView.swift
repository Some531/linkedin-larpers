import SwiftUI
import CoreLocation

struct AlertsListView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var location: LocationProvider
    @State private var showCheckIn = false

    private var here: CLLocationCoordinate2D {
        location.lastCoordinate ?? FixtureStore.fallbackCenter
    }

    /// Hazards near you first, then by severity — the radius decides what
    /// "near" means (RiskEngine.relevanceRadius).
    private var alerts: [HazardAlert] {
        FixtureStore.alerts.sorted { a, b in
            let ra = RiskEngine.isRelevant(a, at: here)
            let rb = RiskEngine.isRelevant(b, at: here)
            if ra != rb { return ra }
            return a.severity > b.severity
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if alerts.isEmpty {
                    ContentUnavailableView(
                        L10n.t(.noAlerts, appState.language),
                        systemImage: "checkmark.shield"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(alerts) { alert in
                                NavigationLink(value: alert.id) {
                                    AlertCard(
                                        alert: alert,
                                        language: appState.language,
                                        isNearby: RiskEngine.isRelevant(alert, at: here) && alert.coordinate != nil
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .themedScreen()
            .navigationTitle(L10n.t(.alertsTitle, appState.language))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCheckIn = true
                    } label: {
                        Label("LIGTAS", systemImage: "checkmark.shield.fill")
                            .labelStyle(.titleAndIcon)
                            .font(.subheadline.weight(.bold))
                    }
                }
            }
            .sheet(isPresented: $showCheckIn) {
                CheckInView()
            }
            .navigationDestination(for: String.self) { id in
                if let alert = alerts.first(where: { $0.id == id }) {
                    AlertDetailView(alert: alert)
                }
            }
        }
    }
}

struct AlertCard: View {
    let alert: HazardAlert
    let language: AppLanguage
    var isNearby = false

    var body: some View {
        let headline = alert.headline.resolved(for: language)
        let hazardName = alert.hazard.name.resolved(for: language)

        VStack(alignment: .leading, spacing: 0) {
            SeverityBanner(severity: alert.severity, phase: alert.phase, language: language)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    HazardIcon(hazard: alert.hazard, tint: Theme.color(for: alert.severity), size: 28)
                    Text(hazardName.text)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    // .named presentation renders "25 minutes ago", not a
                    // bare "25 min" that could read as "in 25 minutes".
                    Text(alert.issuedAt, format: .relative(presentation: .named))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text(headline.text)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.leading)
                HStack(spacing: 8) {
                    Text(alert.areaName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if isNearby {
                        Label(L10n.t(.nearYou, language), systemImage: "location.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.brand)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.brand.opacity(0.12), in: Capsule())
                    }
                }
                TranslationStateChip(state: headline.state, language: language)
            }
            .padding(Theme.cardPadding)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .strokeBorder(Theme.color(for: alert.severity).opacity(0.5), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
