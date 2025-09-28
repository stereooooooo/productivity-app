import SwiftUI

struct BottomModeBar: View {
    @Binding var selected: Mode
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 10) {
            Item(icon: "plus.circle.fill", label: "Add", mode: .add, selected: $selected, ns: ns)
            Item(icon: "bolt.fill", label: "Find", mode: .find, selected: $selected, ns: ns)
            Item(icon: "chart.bar.fill", label: "Review", mode: .review, selected: $selected, ns: ns)
        }
        .padding(.horizontal, 14)
        // 👇 lock the overall height of the glass bar
        .frame(height: 68, alignment: .center)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selected)
    }

    private struct Item: View {
        let icon: String
        let label: String
        let mode: Mode
        @Binding var selected: Mode
        let ns: Namespace.ID

        var isSelected: Bool { selected == mode }

        var body: some View {
            Button {
                selected = mode
                Haptics.light()
            } label: {
                ZStack {
                    if isSelected {
                        // 👇 lock the selection pill height so it can’t stretch
                        Capsule()
                            .fill(Color.accentColor)
                            .matchedGeometryEffect(id: "selection", in: ns)
                            .frame(height: 44)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: icon).imageScale(.large)
                        Text(label).font(.subheadline.weight(.semibold))
                    }
                    // 👇 make the tap target chunky but still fit the bar
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
