import SwiftUI

@main
struct CivicsFlashcardsApp: App {
    @StateObject private var vm = DeckViewModel()
    @AppStorage("civics128.appearance") private var appearance = AppearanceSetting.system.rawValue

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(vm)
                .tint(Theme.accent)
                .preferredColorScheme(AppearanceSetting(rawValue: appearance)?.colorScheme)
        }
    }
}
