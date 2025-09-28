import Combine
import SwiftUI

@main
struct SelectDoApp: App {
    @StateObject private var store = AppStore()
    // Drive focus ticking every second
    @State private var tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .onReceive(tick) { _ in
                    store.tickFocus()
                }
        }
    }
}
