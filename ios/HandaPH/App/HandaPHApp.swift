import SwiftUI

@main
struct HandaPHApp: App {
    init() {
        // Blue-beige identity, made unmissable: brand-blue navigation bars
        // with white titles, deep-blue tab bar. Content stays on sand.
        let brand = UIColor(red: 0.075, green: 0.44, blue: 0.66, alpha: 1)
        let deep = UIColor(red: 0.045, green: 0.28, blue: 0.42, alpha: 1)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = brand
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = .white

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = deep
        for item in [tab.stackedLayoutAppearance, tab.inlineLayoutAppearance, tab.compactInlineLayoutAppearance] {
            item.selected.iconColor = .white
            item.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            item.normal.iconColor = UIColor.white.withAlphaComponent(0.55)
            item.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.55)]
        }
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }

    @StateObject private var appState = AppState()
    @StateObject private var speech = SpeechService()
    @StateObject private var profileStore = HouseholdProfileStore()
    @StateObject private var location = LocationProvider()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(speech)
                .environmentObject(profileStore)
                .environmentObject(location)
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
