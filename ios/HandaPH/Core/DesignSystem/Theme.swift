import SwiftUI

/// Design system. Brand palette: deep teal chrome on a warm sand background
/// (dark mode: deep ocean). Severity colours stay reserved for actual risk —
/// the chrome never shouts, so red still means something.
/// Meaning is always carried by symbol + words as well, never colour alone.
enum Theme {
    /// Minimum tappable square, per Apple HIG.
    static let minTapTarget: CGFloat = 44

    static let cornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 16

    // MARK: Palette

    /// Deep teal — buttons, links, selected tabs, the assistant.
    static let brand = Color(red: 0.055, green: 0.35, blue: 0.39)

    /// Warm sand screen background (dark: deep ocean).
    static var background: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.051, green: 0.094, blue: 0.114, alpha: 1)
                : UIColor(red: 0.965, green: 0.945, blue: 0.906, alpha: 1)
        })
    }

    /// Card surface on top of `background`.
    static var card: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.16, blue: 0.19, alpha: 1)
                : UIColor.white
        })
    }

    /// Subtle surface for chips and secondary panels.
    static var surface2: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.21, blue: 0.25, alpha: 1)
                : UIColor(red: 0.93, green: 0.905, blue: 0.855, alpha: 1)
        })
    }

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

extension Severity {
    /// SF Symbol carrying the severity independent of colour.
    var symbolName: String {
        switch self {
        case .danger: "exclamationmark.octagon.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .advisory: "info.circle.fill"
        }
    }
}

// MARK: - Shared components

/// Hazard glyph in a tinted circle — SF Symbols, not emoji, so the icon
/// weight matches the rest of the UI and renders in any Dynamic Type size.
struct HazardIcon: View {
    let hazard: HazardType
    var tint: Color = Theme.brand
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: hazard.symbolName)
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(tint, in: Circle())
            .accessibilityHidden(true)
    }
}

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
            Image(systemName: severity.symbolName)
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
            .background(Theme.surface2, in: Capsule())
    }
}

/// Speak/stop button used beside any body of text.
struct SpeakButton: View {
    @EnvironmentObject private var speech: SpeechService
    let text: String
    let language: AppLanguage

    var body: some View {
        let speakingThis = speech.isSpeaking(text)
        Button {
            if speakingThis {
                speech.stop()
            } else {
                speech.speak(text, language: language)
            }
        } label: {
            Label(
                speakingThis ? L10n.t(.stopListening, language) : L10n.t(.listen, language),
                systemImage: speakingThis ? "stop.circle.fill" : "speaker.wave.2.fill"
            )
            .font(.body.weight(.semibold))
            .frame(minHeight: Theme.minTapTarget)
        }
        .buttonStyle(.bordered)
        .accessibilityHint(L10n.t(.listenHint, language))
    }
}

// MARK: - Screen scaffolding

extension View {
    /// Applies the app background behind any screen's content, including
    /// Lists and Forms (whose own background is hidden).
    func themedScreen() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Theme.background)
    }
}
