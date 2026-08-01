import SwiftUI

/// The screen the SMS link opens. Order of information is deliberate:
/// severity+phase first, then the actions (what to do NOW), then detail —
/// receive → understand → act, in reading order.
struct AlertDetailView: View {
    @EnvironmentObject private var appState: AppState
    let alert: HazardAlert

    var body: some View {
        let language = appState.language
        let headline = alert.headline.resolved(for: language)
        let details = alert.details.resolved(for: language)
        let hazardName = alert.hazard.name.resolved(for: language)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SeverityBanner(severity: alert.severity, phase: alert.phase, language: language)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

                if alert.supersededByID != nil {
                    Label(L10n.t(.supersededNotice, language), systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.yellow.opacity(0.25), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(alert.hazard.emoji).accessibilityHidden(true)
                        Text(hazardName.text)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Text(headline.text)
                        .font(.title2.weight(.bold))
                    Text(alert.areaName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TranslationStateChip(state: headline.state, language: language)
                }

                SpeakButton(text: spokenSummary(language: language), language: headline.language)

                // What to do now — numbered, imperative, large.
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.t(.whatToDoNow, language))
                        .font(.headline)
                    ForEach(Array(alert.actions.enumerated()), id: \.offset) { index, action in
                        let resolved = action.resolved(for: language)
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.title3.weight(.bold))
                                .frame(width: 32, height: 32)
                                .background(Theme.color(for: alert.severity).opacity(0.2), in: Circle())
                            Text(resolved.text)
                                .font(.body.weight(.medium))
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding(Theme.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t(.moreDetail, language))
                        .font(.headline)
                    Text(details.text)
                        .font(.body)
                    TranslationStateChip(state: details.state, language: language)
                }

                // Provenance, verbatim — trust is the binding constraint.
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t(.issuedBy, language))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Label(alert.issuedBy, systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding()
        }
        .navigationTitle(hazardName.text)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Everything TTS reads out, in order: headline then actions.
    private func spokenSummary(language: AppLanguage) -> String {
        var parts = [alert.headline.resolved(for: language).text]
        parts.append(contentsOf: alert.actions.map { $0.resolved(for: language).text })
        return parts.joined(separator: ". ")
    }
}
