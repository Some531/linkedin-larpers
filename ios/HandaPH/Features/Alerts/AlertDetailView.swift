import SwiftUI

/// The screen the SMS link opens. Order of information is deliberate:
/// severity+phase first, then the actions (what to do NOW), then detail —
/// receive → understand → act, in reading order.
struct AlertDetailView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var speech: SpeechService
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
                        HazardIcon(hazard: alert.hazard, tint: Theme.color(for: alert.severity), size: 32)
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
                .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

                // Wordless version of the same instruction.
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t(.pictureGuide, language))
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    PictogramStrip(hazard: alert.hazard)
                }

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

                // Trusted-messenger co-sign: a known local name vouching
                // for the alert — the best-evidenced believe-step lever.
                if let endorsedBy = alert.endorsedBy {
                    HStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.title2)
                            .foregroundStyle(Theme.brand)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(L10n.t(.endorsedByBarangay, language))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(endorsedBy)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.brand.opacity(0.1), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .accessibilityElement(children: .combine)
                }
            }
            .padding()
        }
        .themedScreen()
        .onAppear {
            // Audio-first mode: the alert reads itself out on open.
            if appState.autoRead {
                speech.speak(spokenSummary(language: language), language: headline.language)
            }
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
