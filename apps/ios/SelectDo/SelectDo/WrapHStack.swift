import SwiftUI

/// A reliable wrapping layout for variable-width items (chips).
/// Works inside ScrollView; measures its own height so later content doesn't overlap.
struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var items: Data
    var spacing: CGFloat = 8
    var rowSpacing: CGFloat = 8
    @ViewBuilder var content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            generateContent(in: geo)
        }
        .frame(height: totalHeight) // <-- reserve the space we actually need
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .fixedSize() // measure intrinsic size
                    .alignmentGuide(.leading) { d in
                        if currentX + d.width > geo.size.width {
                            currentX = 0
                            currentY += rowHeight + rowSpacing
                            rowHeight = 0
                        }
                        let result = currentX
                        currentX += d.width + spacing
                        rowHeight = max(rowHeight, d.height)
                        return -result
                    }
                    .alignmentGuide(.top) { _ in
                        -currentY
                    }
            }
        }
        .background(
            GeometryReader { g in
                Color.clear.onAppear { totalHeight = g.size.height }
                    .onChange(of: g.size.height) { _, newValue in
                        totalHeight = newValue
                    }
            }
        )
    }
}
