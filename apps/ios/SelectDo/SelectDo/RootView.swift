import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                switch store.mode {
                case .tasks:
                    // ⚠️ Do NOT wrap a Form in a ScrollView.
                    AddTaskView()
                        .padding(.bottom, 90) // keep content above the floating bar
                        .background(Color(.systemGroupedBackground))
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .find:
                    wrapScrollable(FindTaskView())
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .review:
                    wrapScrollable(ReviewView())
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: store.mode)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .accessibilityLabel("Select + Do")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .toolbarBackground(.thinMaterial, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                BottomModeBar(selected: $store.mode)
                    .background(.clear)
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showSettings) {
            SettingsView().environmentObject(store)
        }
        .preferredColorScheme(store.preferredColorScheme)
    }

    // Wrap only non-Form screens so content can underlap the glass bar
    @ViewBuilder
    private func wrapScrollable(_ content: some View) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                content
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(Color(.systemGroupedBackground))
                Color.clear.frame(height: 90) // spacer above floating bar
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
