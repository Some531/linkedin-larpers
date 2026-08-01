import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showAssistant = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            tabs
            // Gabay — reachable from every tab, bottom right (Flux pattern).
            AssistantButton { showAssistant = true }
                .padding(.trailing, 16)
                .padding(.bottom, 64)
        }
        .tint(Theme.brand)
        .sheet(isPresented: $showAssistant) {
            AssistantView()
                .presentationDetents([.large, .medium])
        }
    }

    private var tabs: some View {
        TabView {
            AlertsListView()
                .tabItem { Label(L10n.t(.tabAlerts, appState.language), systemImage: "bell.badge.fill") }
            HazardMapView()
                .tabItem { Label(L10n.t(.tabMap, appState.language), systemImage: "map.fill") }
            GlossaryView()
                .tabItem { Label(L10n.t(.tabGlossary, appState.language), systemImage: "text.book.closed.fill") }
            ChecklistView()
                .tabItem { Label(L10n.t(.tabPlan, appState.language), systemImage: "checklist") }
            SettingsView()
                .tabItem { Label(L10n.t(.tabSettings, appState.language), systemImage: "gearshape.fill") }
        }
        // First launch: choose a language before anything else. Full screen,
        // cannot be swiped away — the choice is the app's entry contract.
        // Derived binding: dismissal happens by choosing a language, and a
        // deep-linked alert queued during first run presents right after.
        .fullScreenCover(isPresented: Binding(
            get: { !appState.hasChosenLanguage },
            set: { _ in }
        )) {
            LanguagePickerView(isFirstRun: true)
        }
        // SMS deep link lands here regardless of which tab is open.
        .sheet(item: $appState.deepLinkedAlert) { alert in
            NavigationStack {
                AlertDetailView(alert: alert)
            }
        }
    }
}

/// First-launch language selection. Each language is named in itself, in a
/// large tap target — the screen a Waray-speaking lola must get right
/// unassisted.
struct LanguagePickerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let isFirstRun: Bool
    @State private var selection: AppLanguage?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.brand)
                    .accessibilityHidden(true)
                Text(L10n.t(.chooseLanguage, selection ?? appState.language))
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(L10n.t(.chooseLanguageBody, selection ?? appState.language))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button {
                            selection = lang
                        } label: {
                            HStack {
                                Text(lang.nativeName)
                                    .font(.title3.weight(.semibold))
                                Spacer()
                                if selection == lang {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .frame(minHeight: 56)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                    .fill(selection == lang ? Theme.brand.opacity(0.15) : Theme.card)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selection == lang ? .isSelected : [])
                    }
                }
                .padding(.horizontal)
            }

            Button {
                if let selection { appState.language = selection }
                dismiss()
            } label: {
                Text(L10n.t(.continueButton, selection ?? appState.language))
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: Theme.minTapTarget)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selection == nil)
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Theme.background)
        .interactiveDismissDisabled(isFirstRun)
        .onAppear { if !isFirstRun { selection = appState.language } }
    }
}
