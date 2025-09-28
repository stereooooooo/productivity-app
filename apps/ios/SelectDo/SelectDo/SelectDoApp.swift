import SwiftUI
import SwiftData

@main
struct SelectDoApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .onReceive(NotificationCenter.default.publisher(for: .focusTick)) { _ in
                    store.tickFocus()
                }
        }
        .modelContainer(for: TaskModel.self) // SwiftData persistence
    }
}