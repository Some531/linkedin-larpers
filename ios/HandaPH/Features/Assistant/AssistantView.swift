import SwiftUI

/// Gabay — the assistant sheet, visually adapted from the Flux card in
/// Modulo Flow: mono header with a BETA badge and live status, "You asked"
/// blocks, staged trace rows, then the answer. HandaPH palette throughout.
struct AssistantView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var engine = AssistantEngine()
    @StateObject private var voice = SpeechToText()
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        let language = appState.language

        NavigationStack {
        VStack(spacing: 0) {
            header(language)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        introCard(language)
                        ForEach(engine.turns) { turn in
                            TurnView(turn: turn, language: language)
                                .id(turn.id)
                        }
                        if engine.isWorking {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
                .onChange(of: engine.turns.count) {
                    if let last = engine.turns.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            inputBar(language)
        }
        .background(Theme.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: String.self) { termID in
            if let term = FixtureStore.glossary.first(where: { $0.id == termID }) {
                GlossaryDetailView(term: term)
            }
        }
        }
    }

    private func header(_ language: AppLanguage) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(.white)
            Text("Gabay · HandaPH")
                .font(.footnote.monospaced().weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.white)
            Text("BETA")
                .font(.caption2.monospaced().weight(.bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.white.opacity(0.18), in: Capsule())
                .foregroundStyle(.white)
            Spacer()
            Text(engine.isWorking
                 ? L10n.t(.assistantWorking, language)
                 : (AnthropicClient.hasKey ? "Claude" : L10n.t(.assistantOfflineBadge, language)))
                .font(.caption.monospaced())
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.brand)
    }

    private func introCard(_ language: AppLanguage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L10n.t(.assistantIntro, language), systemImage: "text.book.closed.fill")
                .font(.subheadline)
            if !AnthropicClient.hasKey {
                Label(L10n.t(.assistantOffline, language), systemImage: "wifi.slash")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Theme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    private func inputBar(_ language: AppLanguage) -> some View {
        HStack(spacing: 10) {
            TextField(
                voice.isRecording ? L10n.t(.listening, language) : L10n.t(.assistantPlaceholder, language),
                text: $draft, axis: .vertical
            )
                .lineLimit(1...3)
                .focused($inputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 22))
                .onSubmit(send)
                .onChange(of: voice.transcript) {
                    if !voice.transcript.isEmpty { draft = voice.transcript }
                }
            Button {
                voice.toggle(language: language)
            } label: {
                Image(systemName: voice.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(voice.isRecording ? Color.red : Theme.brand)
                    .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                    .symbolEffect(.pulse, isActive: voice.isRecording)
            }
            .accessibilityLabel(L10n.t(.speak, language))
            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(draft.isEmpty ? Color.secondary : Theme.brand)
                    .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
            }
            .disabled(draft.isEmpty || engine.isWorking)
            .accessibilityLabel(L10n.t(.send, language))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private func send() {
        voice.stop()
        let question = draft
        draft = ""
        Task { await engine.ask(question, language: appState.language) }
    }
}

/// One exchange, Flux-style: question header, mono trace rows, answer.
private struct TurnView: View {
    @EnvironmentObject private var appState: AppState
    let turn: AssistantTurn
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // You asked
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.t(.youAsked, language))
                    .font(.caption2.monospaced())
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Text(turn.question)
                    .font(.body.weight(.medium))
            }
            .padding(Theme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface2)

            // Answer — rendered through AttributedString so any markdown
            // the model emits (e.g. **bold**) displays properly instead of
            // showing raw asterisks.
            VStack(alignment: .leading, spacing: 10) {
                Text(attributedAnswer)
                    .font(.body)
                    .textSelection(.enabled)

                // Learn-more visuals: the verified entries behind this
                // answer, tappable through to the illustrated glossary page.
                if !turn.groundedTermIDs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(turn.groundedTermIDs, id: \.self) { id in
                                if let term = FixtureStore.glossary.first(where: { $0.id == id }) {
                                    NavigationLink(value: term.id) {
                                        HStack(spacing: 8) {
                                            HazardIcon(hazard: term.hazard, size: 30)
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(term.term.resolved(for: language).text)
                                                    .font(.footnote.weight(.semibold))
                                                    .foregroundStyle(.primary)
                                                Text(L10n.t(.whatItIs, language))
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Image(systemName: "chevron.right")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(Theme.surface2, in: RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }

                HStack {
                    SpeakButton(text: turn.answer, language: language)
                    Spacer()
                    if turn.isLocal {
                        Label(L10n.t(.assistantOfflineBadge, language), systemImage: "checkmark.seal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(Theme.cardPadding)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .strokeBorder(Theme.brand.opacity(0.15), lineWidth: 1)
        )
    }

    /// Markdown-aware rendering with a plain-text fallback.
    private var attributedAnswer: AttributedString {
        (try? AttributedString(
            markdown: turn.answer,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(turn.answer)
    }
}

/// The floating entry point, bottom-right above the tab bar.
struct AssistantButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "sparkles")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Theme.brand, in: Circle())
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
        }
        .accessibilityLabel("Gabay")
    }
}
