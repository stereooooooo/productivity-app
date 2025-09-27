import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SegmentedModeBar(selected: $store.mode)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(.ultraThinMaterial)

                Divider()

                Group {
                    switch store.mode {
                    case .add: AddTaskView()
                    case .find: FindTaskView()
                    case .review: ReviewView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Select + Do")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SegmentedModeBar: View {
    @Binding var selected: Mode

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Mode.allCases, id: \.self) { mode in
                Button {
                    selected = mode
                    Haptics.light()
                } label: {
                    Text(mode.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selected == mode ? Color.accentColor : .clear)
                        .foregroundStyle(selected == mode ? Color.white : Color.primary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().strokeBorder(Color.secondary.opacity(selected == mode ? 0 : 0.25))
                        )
                }
            }
        }
    }
}