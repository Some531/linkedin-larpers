import SwiftUI

/// Design constants. Severity colours use the system palette so they adapt to
/// dark mode and the system's increase-contrast setting; meaning is always
/// carried by symbol + words as well, never colour alone.
enum Theme {
    /// Minimum tappable square, per Apple HIG.
    static let minTapTarget: CGFloat = 44

    static let cornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16

    static func color(for severity: Severity) -> Color {
        switch severity {
        case .danger: .red
        case .warning: .orange
        case .advisory: .green
        }
    }

    /// Text colour that stays legible on the severity colour.
    static func textColor(on severity: Severity) -> Color {
        switch severity {
        case .danger: .white
        case .warning, .advisory: .black
        }
    }
}

// MARK: - Shared components

/// Severity + phase banner: colour, symbol, and words together.
struct SeverityBanner: View {
    let severity: Severity
    let phase: AlertPhase
    let language: AppLanguage

    private var severityLabel: String {
        switch severity {
        case .danger: L10n.t(.severityDanger, language)
        case .warning: L10n.t(.severityWarning, language)
        case .advisory: L10n.t(.severityAdvisory, language)
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .prepare: L10n.t(.prepare, language)
        case .expectedSoon: L10n.t(.expectedSoon, language)
        case .happeningNow: L10n.t(.happeningNow, language)
        case .allClear: L10n.t(.allClear, language)
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(severity.emoji)
            Text(severityLabel)
                .fontWeight(.heavy)
            Spacer()
            Text(phaseLabel)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
        }
        .font(.headline)
        .foregroundStyle(Theme.textColor(on: severity))
        .padding(Theme.cardPadding)
        .background(Theme.color(for: severity))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(severityLabel). \(phaseLabel)")
    }
}

/// Honest-translation chip (docs/architecture.md §4: verification_state).
struct TranslationStateChip: View {
    let state: TranslationState
    let language: AppLanguage

    var body: some View {
        switch state {
        case .humanVerified:
            EmptyView()
        case .machineAssisted:
            chip(text: L10n.t(.unverifiedChip, language), symbol: "exclamationmark.triangle")
        case .untranslated:
            chip(text: L10n.t(.untranslatedChip, language), symbol: "character.book.closed")
        }
    }

    private func chip(text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.quaternary, in: Capsule())
    }
}

/// Speak/stop button used beside any body of text.
struct SpeakButton: View {
    @EnvironmentObject private var speech: SpeechService
    let text: String
    let language: AppLanguage

    var body: some View {
        Button {
            if speech.isSpeaking {
                speech.stop()
            } else {
                speech.speak(text, language: language)
            }
        } label: {
            Label(
                speech.isSpeaking ? L10n.t(.stopListening, language) : L10n.t(.listen, language),
                systemImage: speech.isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill"
            )
            .font(.body.weight(.semibold))
            .frame(minHeight: Theme.minTapTarget)
        }
        .buttonStyle(.bordered)
        .accessibilityHint("Reads the text aloud")
    }
}
