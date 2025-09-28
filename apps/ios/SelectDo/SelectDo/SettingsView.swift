import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Toggle("Haptics", isOn: $store.hapticsEnabled)
                }
                Section("Appearance") {
                    Picker("Theme", selection: $store.themeChoice) {
                        Text("System").tag(AppStore.ThemeChoice.system)
                        Text("Light").tag(AppStore.ThemeChoice.light)
                        Text("Dark").tag(AppStore.ThemeChoice.dark)
                    }
                }
                Section {
                    Link(destination: URL(string: "https://selectdo.example/")!) {
                        Label("Learn more", systemImage: "link")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
