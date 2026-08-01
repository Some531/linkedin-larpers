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
                            // LIGTAS check-in: large, first, unmissable —
                            // the panic-moment action gets the top slot.
                            Button {
                                showCheckIn = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.title2)
                                    Text(L10n.t(.ligtasTitle, appState.language))
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.bold))
                                }
                                .foregroundStyle(.white)
                                .padding(Theme.cardPadding)
                                .frame(minHeight: 56)
                                .background(
                                    LinearGradient(colors: [.green, Color(red: 0.1, green: 0.55, blue: 0.35)],
                                                   startPoint: .top, endPoint: .bottom),
                                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                )
                            }
                            .accessibilityHint(L10n.t(.ligtasIntro, appState.language))

                            // Region-appropriate emergency numbers — one
                            // tap to call, no searching mid-disaster.
                            EmergencyContactsRow(contacts: FixtureStore.emergencyContacts(near: here))

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

/// Tappable call chips for the user's area (README/Settings note which
/// numbers are national vs LGU-configured).
struct EmergencyContactsRow: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openURL) private var openURL
    let contacts: [EmergencyContact]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.t(.emergencyContacts, appState.language))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(contacts) { contact in
                    Button {
                        if let url = URL(string: "tel://\(contact.number)") { openURL(url) }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text(contact.label)
                                .fontWeight(.bold)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(minHeight: Theme.minTapTarget)
                        .background(Color.red.gradient, in: Capsule())
                    }
                    .accessibilityLabel("\(contact.organisation), \(contact.label)")
                }
                Spacer()
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
