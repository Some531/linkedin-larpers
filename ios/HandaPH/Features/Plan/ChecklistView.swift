import SwiftUI

/// Preparedness checklist. Ticked state persists locally — it is the user's
/// own plan, so it never syncs anywhere.
struct ChecklistView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("checklistDone") private var doneRaw: String = ""

    private var doneIDs: Set<String> {
        Set(doneRaw.split(separator: ",").map(String.init))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FixtureStore.checklist) { item in
                        Button {
                            toggle(item.id)
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: doneIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundStyle(doneIDs.contains(item.id) ? .green : .secondary)
                                Text(item.text.resolved(for: appState.language).text)
                                    .font(.body)
                                    .strikethrough(doneIDs.contains(item.id), color: .secondary)
                                    .foregroundStyle(doneIDs.contains(item.id) ? .secondary : .primary)
                            }
                            .frame(minHeight: Theme.minTapTarget)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(doneIDs.contains(item.id) ? .isSelected : [])
                        .accessibilityHint("Double tap to mark as done")
                    }
                } header: {
                    Text(L10n.t(.planSubtitle, appState.language))
                        .font(.subheadline)
                        .textCase(nil)
                }
            }
            .navigationTitle(L10n.t(.planTitle, appState.language))
        }
    }

    private func toggle(_ id: String) {
        var ids = doneIDs
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        doneRaw = ids.sorted().joined(separator: ",")
    }
}
