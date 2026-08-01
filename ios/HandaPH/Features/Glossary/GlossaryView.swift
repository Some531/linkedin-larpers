import SwiftUI

/// The Haiyan intervention: hazard words explained in plain language, in the
/// user's language, offline, with text-to-speech. "What is a storm surge?"
/// must be answerable with the radio off.
struct GlossaryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FixtureStore.glossary) { term in
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
