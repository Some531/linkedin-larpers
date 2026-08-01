import SwiftUI

/// The Haiyan intervention: hazard words explained in plain language, in the
/// user's language, offline, with text-to-speech. "What is a storm surge?"
/// must be answerable with the radio off.
struct GlossaryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var query = ""

    /// The brief's "chatbot", implemented as retrieval over a verified
    /// corpus — matches the user's words against terms and explanations in
    /// their language AND English, so "daluyong", "balod" and "storm surge"
    /// all find the same entry. Works fully offline; cannot hallucinate.
    private var results: [GlossaryTerm] {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !needle.isEmpty else { return FixtureStore.glossary }
        return FixtureStore.glossary.filter { term in
            let haystacks = [
                term.term.resolved(for: appState.language).text,
                term.term.values[.english] ?? "",
                term.meaning.resolved(for: appState.language).text,
                term.meaning.values[.english] ?? "",
            ]
            return haystacks.contains { $0.lowercased().contains(needle) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if results.isEmpty {
                        Text(L10n.t(.noSearchResults, appState.language))
                            .foregroundStyle(.secondary)
                    }
                    ForEach(results) { term in
                        NavigationLink(value: term.id) {
                            HStack(spacing: 12) {
                                Text(term.hazard.emoji)
                                    .font(.title2)
                                    .accessibilityHidden(true)
                                Text(term.term.resolved(for: appState.language).text)
                                    .font(.body.weight(.semibold))
                            }
                            .frame(minHeight: Theme.minTapTarget)
                        }
                    }
                } header: {
                    Text(L10n.t(.glossarySubtitle, appState.language))
                        .font(.subheadline)
                        .textCase(nil)
                }
            }
            .navigationTitle(L10n.t(.glossaryTitle, appState.language))
            .searchable(text: $query, prompt: L10n.t(.searchPrompt, appState.language))
            .navigationDestination(for: String.self) { id in
                if let term = FixtureStore.glossary.first(where: { $0.id == id }) {
                    GlossaryDetailView(term: term)
                }
            }
        }
    }
}

struct GlossaryDetailView: View {
    @EnvironmentObject private var appState: AppState
    let term: GlossaryTerm

    var body: some View {
        let language = appState.language
        let name = term.term.resolved(for: language)
        let meaning = term.meaning.resolved(for: language)
        let action = term.action.resolved(for: language)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Text(term.hazard.emoji)
                        .font(.system(size: 44))
                        .accessibilityHidden(true)
                    Text(name.text)
                        .font(.largeTitle.weight(.bold))
                }

                SpeakButton(
                    text: "\(name.text). \(meaning.text). \(action.text)",
                    language: meaning.language
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t(.whatItIs, language))
                        .font(.headline)
                    Text(meaning.text)
                        .font(.body)
                    TranslationStateChip(state: meaning.state, language: language)
                }
                .padding(Theme.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t(.whatToDo, language))
                        .font(.headline)
                    Text(action.text)
                        .font(.body.weight(.medium))
                    TranslationStateChip(state: action.state, language: language)
                }
                .padding(Theme.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
