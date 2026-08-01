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
                    row("person.badge.clock", .profileElderly, $profileStore.profile.hasElderly)
                    row("figure.and.child.holdinghands", .profileChildren, $profileStore.profile.hasYoungChildren)
                    row("figure.roll", .profileMobility, $profileStore.profile.hasLimitedMobility)
                    row("water.waves", .profileCoast, $profileStore.profile.nearCoastOrRiver)
                    row("house.fill", .profileSingleStorey, $profileStore.profile.singleStorey)
                } footer: {
                    Text(L10n.t(.profileSubtitle, language))
                }
                .listRowBackground(Theme.card)

                Section {
                    Label(L10n.t(.privacyNote, language), systemImage: "lock.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Theme.card)
            }
            .themedScreen()
            .navigationTitle(L10n.t(.profileTitle, language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t(.continueButton, language)) { dismiss() }
                }
            }
        }
    }

    private func row(_ symbol: String, _ key: L10n.Key, _ binding: Binding<Bool>) -> some View {
        Toggle(isOn: binding) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.brand)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                Text(L10n.t(key, appState.language))
                    .font(.body)
            }
        }
        .frame(minHeight: Theme.minTapTarget - 12)
    }
}
