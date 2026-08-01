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

    /// Vivid ocean blue — buttons, links, selected tabs, the assistant.
    static let brand = Color(red: 0.075, green: 0.44, blue: 0.66)

    /// Deep teal partner tone; with `brand` it forms the app's gradient.
    static let brandDeep = Color(red: 0.045, green: 0.31, blue: 0.37)

    /// Signature blue→teal gradient for hero surfaces (assistant header,
    /// floating button). Severity surfaces never use it.
    static let brandGradient = LinearGradient(
        colors: [brand, brandDeep],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

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

    /// Subtle blue-beige surface for chips and secondary panels.
    static var surface2: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.21, blue: 0.27, alpha: 1)
                : UIColor(red: 0.905, green: 0.895, blue: 0.845, alpha: 1)
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
/// Tappable: readers can suggest better wording — the community-verified
/// translation loop, where CALD users are authors, not just audience.
struct TranslationStateChip: View {
    let state: TranslationState
    let language: AppLanguage
    @State private var showSuggestion = false

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
        Button {
            showSuggestion = true
        } label: {
            HStack(spacing: 6) {
                Label(text, systemImage: symbol)
                Image(systemName: "pencil.line")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.surface2, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(text). \(L10n.t(.suggestWording, language))")
        .sheet(isPresented: $showSuggestion) {
            SuggestionSheet(language: language)
                .presentationDetents([.medium])
        }
    }
}

/// Community wording suggestions, queued locally; the backend reviewer
/// queue picks these up in production.
struct SuggestionSheet: View {
    let language: AppLanguage
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                if submitted {
                    Label(L10n.t(.suggestionThanks, language), systemImage: "checkmark.seal.fill")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Theme.brand)
                } else {
                    Text(L10n.t(.suggestionPlaceholder, language))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $text)
                        .frame(minHeight: 110)
                        .padding(8)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    Button {
                        var queue = UserDefaults.standard.stringArray(forKey: "translationSuggestions") ?? []
                        queue.append("[\(language.rawValue)] \(text)")
                        UserDefaults.standard.set(queue, forKey: "translationSuggestions")
                        submitted = true
                    } label: {
                        Text(L10n.t(.submit, language))
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: Theme.minTapTarget)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                Spacer()
            }
            .padding()
            .background(Theme.background)
            .navigationTitle(L10n.t(.suggestWording, language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    // Icon, not text: language-independent close affordance.
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: Theme.minTapTarget - 8, height: Theme.minTapTarget - 8)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}

/// Wordless what-to-do strip — meaning carried by pictograms where
/// language cannot (the brief's "use of symbols").
struct PictogramStrip: View {
    let hazard: HazardType

    private var sequence: [String] {
        switch hazard {
        case .stormSurge, .tsunami:
            ["water.waves", "figure.run", "arrow.up.right", "building.2.fill"]
        case .flashFlood:
            ["cloud.heavyrain.fill", "arrow.up.to.line", "figure.run", "building.2.fill"]
        case .earthquake:
            ["waveform.path.ecg", "arrow.down.circle.fill", "shield.lefthalf.filled", "hand.raised.fill"]
        case .typhoon, .tornado:
            ["hurricane", "figure.run", "house.fill", "checkmark.circle.fill"]
        case .landslide:
            ["mountain.2.fill", "figure.run", "arrow.left.arrow.right", "checkmark.circle.fill"]
        case .volcanicEruption:
            ["mountain.2.fill", "facemask.fill", "figure.run", "building.2.fill"]
        case .wildfire:
            ["flame.fill", "figure.run", "arrow.down.left", "checkmark.circle.fill"]
        case .drought:
            ["sun.max.fill", "drop.fill", "square.stack.3d.up.fill", "checkmark.circle.fill"]
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(sequence.enumerated()), id: \.offset) { index, symbol in
                Image(systemName: symbol)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Theme.brandGradient, in: RoundedRectangle(cornerRadius: 12))
                if index < sequence.count - 1 {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .accessibilityHidden(true) // decorative for VoiceOver; text carries meaning
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

    /// Forces the brand-blue bars with light content on this screen —
    /// belt-and-braces over the UIKit appearance, for hosts (like Map)
    /// that otherwise render their bars translucent/white.
    func brandBars() -> some View {
        self
            .toolbarBackground(Theme.brand, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.brand, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .tabBar)
    }

    /// Replaces the system back chevron (which inherits the brand accent
    /// and vanishes against the blue bar) with an explicit white one.
    func whiteBackButton() -> some View {
        modifier(WhiteBackButtonModifier())
    }
}

private struct WhiteBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: Theme.minTapTarget - 8, height: Theme.minTapTarget - 8)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Back")
                }
            }
    }
}
