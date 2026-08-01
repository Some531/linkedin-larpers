import SwiftUI
import CoreLocation

/// Preparedness plan, personalised two ways: a scenario section driven by
/// the hazard currently threatening THIS location, and a household section
/// driven by the demographic profile. Ticked state persists locally — it is
/// the user's own plan, so it never syncs anywhere.
struct ChecklistView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var profileStore: HouseholdProfileStore
    @EnvironmentObject private var location: LocationProvider
    @AppStorage("checklistDone") private var doneRaw: String = ""

    private var here: CLLocationCoordinate2D {
        location.lastCoordinate ?? FixtureStore.fallbackCenter
    }

    private var risk: PersonalRisk {
        RiskEngine.assess(alerts: FixtureStore.alerts, profile: profileStore.profile, at: here)
    }

    private var scenarioItems: [ChecklistItem] {
        guard let hazard = risk.drivingAlert?.hazard else { return [] }
        return FixtureStore.hazardChecklist[hazard] ?? []
    }

    private var householdItems: [ChecklistItem] {
        FixtureStore.profileChecklist
            .filter { $0.applies(profileStore.profile) }
            .map(\.item)
    }

    private var doneIDs: Set<String> {
        Set(doneRaw.split(separator: ",").map(String.init))
    }

    var body: some View {
        let language = appState.language

        NavigationStack {
            List {
                if !scenarioItems.isEmpty, let alert = risk.drivingAlert {
                    Section {
                        ForEach(scenarioItems) { row($0) }
                    } header: {
                        Label {
                            Text("\(L10n.t(.planScenario, language)) · \(alert.hazard.name.resolved(for: language).text)")
                        } icon: {
                            Image(systemName: alert.hazard.symbolName)
                                .foregroundStyle(Theme.color(for: alert.severity))
                        }
                        .font(.subheadline.weight(.semibold))
                        .textCase(nil)
                    }
                    .listRowBackground(Theme.card)
                }

                if !householdItems.isEmpty {
                    Section {
                        ForEach(householdItems) { row($0) }
                    } header: {
                        Label(L10n.t(.planHousehold, language), systemImage: "person.2.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.brand)
                            .textCase(nil)
                    }
                    .listRowBackground(Theme.card)
                }

                Section {
                    ForEach(FixtureStore.checklist) { row($0) }
                } header: {
                    Text(householdItems.isEmpty && scenarioItems.isEmpty
                         ? L10n.t(.planSubtitle, language)
                         : L10n.t(.planGeneral, language))
                        .font(.subheadline)
                        .textCase(nil)
                }
                .listRowBackground(Theme.card)
            }
            .themedScreen()
            .navigationTitle(L10n.t(.planTitle, language))
        }
    }

    private func row(_ item: ChecklistItem) -> some View {
        let done = doneIDs.contains(item.id)
        return Button {
            toggle(item.id)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(done ? .green : .secondary)
                Text(item.text.resolved(for: appState.language).text)
                    .font(.body)
                    .strikethrough(done, color: .secondary)
                    .foregroundStyle(done ? .secondary : .primary)
            }
            .frame(minHeight: Theme.minTapTarget)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(done ? .isSelected : [])
        .accessibilityValue(L10n.t(done ? .doneStatus : .notDoneStatus, appState.language))
    }

    private func toggle(_ id: String) {
        var ids = doneIDs
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        doneRaw = ids.sorted().joined(separator: ",")
    }
}
