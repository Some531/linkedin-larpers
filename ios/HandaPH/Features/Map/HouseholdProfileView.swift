import SwiftUI

/// Household profile sheet, per the Figma spec: five toggles that feed the
/// RiskEngine, and a privacy note. The profile is the app's only demographic
/// data and it never leaves the device.
struct HouseholdProfileView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileStore: HouseholdProfileStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let language = appState.language

        NavigationStack {
            Form {
                Section {
                    row("👵", .profileElderly, $profileStore.profile.hasElderly)
                    row("🧒", .profileChildren, $profileStore.profile.hasYoungChildren)
                    row("♿", .profileMobility, $profileStore.profile.hasLimitedMobility)
                    row("🌊", .profileCoast, $profileStore.profile.nearCoastOrRiver)
                    row("🏠", .profileSingleStorey, $profileStore.profile.singleStorey)
                } footer: {
                    Text(L10n.t(.profileSubtitle, language))
                }

                Section {
                    Label(L10n.t(.privacyNote, language), systemImage: "lock.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(L10n.t(.profileTitle, language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t(.continueButton, language)) { dismiss() }
                }
            }
        }
    }

    private func row(_ emoji: String, _ key: L10n.Key, _ binding: Binding<Bool>) -> some View {
        Toggle(isOn: binding) {
            HStack(spacing: 10) {
                Text(emoji)
                    .font(.title3)
                    .accessibilityHidden(true)
                Text(L10n.t(key, appState.language))
                    .font(.body)
            }
        }
        .frame(minHeight: Theme.minTapTarget - 12)
    }
}
