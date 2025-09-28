import Combine
import SwiftData
import SwiftUI

@main
struct SelectDoApp: App {
    @StateObject private var store = AppStore()
    @State private var tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.preferredColorScheme) // ← from Settings
                .onReceive(tick) { _ in store.tickFocus() }
        }
        .modelContainer(for: TaskModel.self) // ← SwiftData container
    }
}
