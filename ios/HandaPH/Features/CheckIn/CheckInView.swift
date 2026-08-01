import SwiftUI
import MessageUI

/// LIGTAS ("safe") check-in: one tap composes an ordinary SMS to
/// pre-chosen family numbers — the receiving side needs no app, no
/// smartphone, no data. This is the upstream half of the feedback loop the
/// CFE-DM handbook says is missing.
struct CheckInView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userName") private var name = ""
    @AppStorage("checkInContacts") private var contactsRaw = ""
    @State private var showComposer = false

    private var contacts: [String] {
        contactsRaw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    private var message: String {
        let area = "Brgy San Jose, Tacloban City" // fixture area; production uses reverse-geocoded barangay
        return String(format: L10n.t(.ligtasBody, appState.language), name.isEmpty ? "—" : name, area)
    }

    var body: some View {
        let language = appState.language

        NavigationStack {
            Form {
                Section {
                    Label(L10n.t(.ligtasIntro, language), systemImage: "antenna.radiowaves.left.and.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Theme.card)

                Section {
                    TextField(L10n.t(.yourName, language), text: $name)
                        .frame(minHeight: Theme.minTapTarget - 12)
                    TextField(L10n.t(.familyNumbers, language), text: $contactsRaw)
                        .keyboardType(.phonePad)
                        .frame(minHeight: Theme.minTapTarget - 12)
                }
                .listRowBackground(Theme.card)

                Section {
                    Text(message)
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                } header: {
                    Text("SMS")
                }
                .listRowBackground(Theme.card)

                Section {
                    if MFMessageComposeViewController.canSendText() {
                        Button {
                            showComposer = true
                        } label: {
                            ligtasLabel(language)
                        }
                        .disabled(name.isEmpty || contacts.isEmpty)
                    } else {
                        // Simulator / no SMS capability: share sheet fallback.
                        ShareLink(item: message) {
                            ligtasLabel(language)
                        }
                        .disabled(name.isEmpty)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .themedScreen()
            .navigationTitle(L10n.t(.ligtasTitle, language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t(.continueButton, language)) { dismiss() }
                }
            }
            .sheet(isPresented: $showComposer) {
                MessageComposer(recipients: contacts, body: message)
            }
        }
    }

    private func ligtasLabel(_ language: AppLanguage) -> some View {
        Label(L10n.t(.ligtasSend, language), systemImage: "checkmark.shield.fill")
            .font(.title3.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                LinearGradient(colors: [.green, Color(red: 0.1, green: 0.55, blue: 0.35)],
                               startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: Theme.cornerRadius)
            )
    }
}

/// Thin wrapper over the system SMS composer.
private struct MessageComposer: UIViewControllerRepresentable {
    let recipients: [String]
    let body: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.recipients = recipients
        vc.body = body
        vc.messageComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: { dismiss() }) }

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let dismiss: () -> Void
        init(dismiss: @escaping () -> Void) { self.dismiss = dismiss }
        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                          didFinishWith result: MessageComposeResult) {
            dismiss()
        }
    }
}
