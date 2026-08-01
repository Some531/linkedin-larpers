import SwiftUI

/// First-run flow, two steps, with a back button:
///   1. Language — each option shows a greeting in the language itself, so
///      speakers recognise theirs even without reading its formal name.
///      From the moment one is selected, EVERYTHING renders in it.
///   2. Age band — 60+ switches on larger text, read-aloud alerts and a
///      slower voice automatically. Adaptation, not a settings hunt.
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var speech: SpeechService
    @State private var step = 0
    @State private var selectedLanguage: AppLanguage?
    @State private var selectedAge: String?

    /// Forms render in the picked language immediately, English before that.
    private var language: AppLanguage { selectedLanguage ?? .english }

    var body: some View {
        VStack(spacing: 0) {
            if step == 1 {
                HStack {
                    Button {
                        step = 0
                    } label: {
                        Label(L10n.t(.back, language), systemImage: "chevron.left")
                            .font(.body.weight(.semibold))
                            .frame(minHeight: Theme.minTapTarget)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }

            if step == 0 { languageStep } else { ageStep }
        }
        .background(Theme.background)
        .interactiveDismissDisabled()
    }

    // MARK: Step 1 — language

    private var languageStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.brand)
                    .accessibilityHidden(true)
                Text(L10n.t(.chooseLanguage, language))
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button {
                            selectedLanguage = lang
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(lang.nativeName)
                                        .font(.title3.weight(.semibold))
                                    // Recognition helper: a greeting in the
                                    // language itself.
                                    Text(lang.sampleGreeting)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedLanguage == lang {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.brand)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .frame(minHeight: 64)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                    .fill(selectedLanguage == lang ? Theme.brand.opacity(0.15) : Theme.card)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(lang.nativeName)
                        .accessibilityHint(lang.sampleGreeting)
                        .accessibilityAddTraits(selectedLanguage == lang ? .isSelected : [])
                        .id(lang)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.visible)
            // Elders may not notice a thin scroll bar: an explicit, large
            // "more below" arrow scrolls the remaining languages into view.
            .overlay(alignment: .bottomTrailing) {
                Button {
                    withAnimation { proxy.scrollTo(AppLanguage.allCases.last, anchor: .bottom) }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white, Theme.brand)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .padding(.trailing, 18)
                .padding(.bottom, 6)
                .accessibilityLabel("More languages")
            }
            }

            continueButton(enabled: selectedLanguage != nil) { step = 1 }
        }
    }

    // MARK: Step 2 — age

    private var ageStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(Theme.brand)
                    .accessibilityHidden(true)
                Text(L10n.t(.chooseAge, language))
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(L10n.t(.chooseAgeBody, language))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)
            .padding(.horizontal)

            VStack(spacing: 12) {
                ageOption("u40", label: L10n.t(.ageUnder40, language))
                ageOption("a40", label: L10n.t(.age40to59, language))
                ageOption("s60", label: L10n.t(.age60plus, language))
            }
            .padding(.horizontal)

            Spacer()

            continueButton(enabled: selectedAge != nil) { finish() }
        }
    }

    private func ageOption(_ id: String, label: String) -> some View {
        Button {
            selectedAge = id
        } label: {
            HStack {
                Text(label)
                    .font(.title3.weight(.semibold))
                Spacer()
                if selectedAge == id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.brand)
                        .font(.title3)
                }
            }
            .padding()
            .frame(minHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(selectedAge == id ? Theme.brand.opacity(0.15) : Theme.card)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedAge == id ? .isSelected : [])
    }

    private func continueButton(enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(L10n.t(.continueButton, language))
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, minHeight: Theme.minTapTarget)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!enabled)
        .padding(.horizontal)
        .padding(.bottom, 24)
    }

    private func finish() {
        guard let selectedLanguage, let selectedAge else { return }
        appState.ageGroup = selectedAge
        if selectedAge == "s60" {
            // Elderly defaults: bigger text, alerts read aloud, slower voice.
            appState.largerText = true
            appState.autoRead = true
            speech.rate = min(speech.rate, 0.38)
        }
        // Setting the language last flips hasChosenLanguage -> dismisses.
        appState.language = selectedLanguage
    }
}
