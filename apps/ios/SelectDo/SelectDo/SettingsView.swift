import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var theme: AppTheme
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

                    Picker("Layout density", selection: $theme.density) {
                        Text("Standard").tag(UIModeDensity.standard)
                        Text("Compact").tag(UIModeDensity.compact)
                    }
                    .pickerStyle(.segmented)
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
