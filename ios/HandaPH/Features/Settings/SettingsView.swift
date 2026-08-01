import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var speech: SpeechService
    @State private var showLanguagePicker = false

    var body: some View {
        let language = appState.language

        NavigationStack {
            Form {
                Section(L10n.t(.language, language)) {
                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack {
                            Text(language.nativeName)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: Theme.minTapTarget - 12)
                    }
                    if L10n.unverified.contains(language) {
                        TranslationStateChip(state: .machineAssisted, language: language)
                    }
                }

                Section {
                    Toggle(L10n.t(.largerText, language), isOn: $appState.largerText)
                        .frame(minHeight: Theme.minTapTarget - 12)

                    VStack(alignment: .leading) {
                        Text(L10n.t(.speechRate, language))
                        Slider(value: $speech.rate, in: 0.3...0.55)
                            .accessibilityLabel(L10n.t(.speechRate, language))
                            .accessibilityValue("\(Int(((speech.rate - 0.3) / 0.25) * 100))%")
                    }

                    if language != .english && !SpeechService.hasFilipinoVoice {
                        Label(L10n.t(.voiceUnavailableNote, language), systemImage: "speaker.badge.exclamationmark")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(L10n.t(.about, language)) {
                    LabeledContent("App", value: "Handa — UQ Tech for Change 2026")
                    LabeledContent("Team", value: "linkedin-larpers")
                    Text("Alert content comes from official sources (PAGASA, PHIVOLCS) via a human-verified template bank. No text in this app is written by AI at alert time. Your location never leaves this phone.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    // The app's own honesty rule applies to its own prose.
                    if language != .english {
                        TranslationStateChip(state: .untranslated, language: language)
                    }
                }
            }
            .navigationTitle(L10n.t(.settingsTitle, language))
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView(isFirstRun: false)
            }
        }
    }
}
