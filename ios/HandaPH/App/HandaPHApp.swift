import SwiftUI

@main
struct HandaPHApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var speech = SpeechService()
    @StateObject private var profileStore = HouseholdProfileStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(speech)
                .environmentObject(profileStore)
                // "Larger text" raises the Dynamic Type floor to an
                // accessibility size without capping users set even higher.
                .dynamicTypeSize(
                    appState.largerText
                        ? DynamicTypeSize.accessibility1...DynamicTypeSize.accessibility5
                        : DynamicTypeSize.xSmall...DynamicTypeSize.accessibility5
                )
                .onOpenURL { appState.handle(url: $0) }
        }
    }
}
