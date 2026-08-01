import SwiftUI

struct AlertsListView: View {
    @EnvironmentObject private var appState: AppState

    private var alerts: [HazardAlert] {
        FixtureStore.alerts.sorted { $0.severity > $1.severity }
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
                                    AlertCard(alert: alert, language: appState.language)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(L10n.t(.alertsTitle, appState.language))
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

    var body: some View {
        let headline = alert.headline.resolved(for: language)
        let hazardName = alert.hazard.name.resolved(for: language)

        VStack(alignment: .leading, spacing: 0) {
            SeverityBanner(severity: alert.severity, phase: alert.phase, language: language)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(alert.hazard.emoji)
                        .accessibilityHidden(true)
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
                Text(alert.areaName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TranslationStateChip(state: headline.state, language: language)
            }
            .padding(Theme.cardPadding)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .strokeBorder(Theme.color(for: alert.severity).opacity(0.5), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
