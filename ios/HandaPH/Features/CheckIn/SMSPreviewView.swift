import SwiftUI

/// Demo-only, honestly labelled: a Messages-style rendering of the alert
/// SMS, because the iOS Simulator cannot display a real incoming text.
/// Tapping the link in the bubble opens the alert — the receive step,
/// visible. Triggered by handaph://sms-demo (see demo-sms.command).
struct SMSPreviewView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var alert: HazardAlert? { FixtureStore.alert(forToken: "7Kq2") }

    private var smsText: String {
        guard let alert else { return "" }
        let language = appState.language
        let severity = L10n.t(.severityDanger, language)
        let phase = L10n.t(.happeningNow, language)
        let headline = alert.headline.resolved(for: language).text
        return "\(alert.hazard.emoji)\(alert.severity.emoji) \(severity) — \(phase)\n\(headline)"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages-style header
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 52, height: 52)
                    Image(systemName: "megaphone.fill")
                        .foregroundStyle(.white)
                }
                Text("PAGASA-ALERT")
                    .font(.footnote.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 18)
            .padding(.bottom, 12)
            .background(.regularMaterial)
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: Theme.minTapTarget, height: Theme.minTapTarget)
                }
                .accessibilityLabel("Close")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Text Message · SMS")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)

                    // The incoming bubble; the link inside opens the alert.
                    Button {
                        if let alert {
                            dismiss()
                            appState.deepLinkedAlert = alert
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(smsText)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("rdy.ph/a/7Kq2")
                                .font(.body)
                                .foregroundStyle(.blue)
                                .underline()
                        }
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))
                        .frame(maxWidth: 300, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 12)
                    .accessibilityHint("Opens the alert")

                    Spacer(minLength: 40)

                    Label("Demo preview — the simulator cannot receive real SMS",
                          systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
            .background(Color(.systemBackground))
        }
    }
}
