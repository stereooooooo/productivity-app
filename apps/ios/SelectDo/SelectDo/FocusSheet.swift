import SwiftUI

struct FocusSheet: View {
    var session: FocusSession
    var onDone: () -> Void
    @EnvironmentObject private var store: AppStore
    @State private var isPaused = false

    var body: some View {
        VStack(spacing: 16) {
            Text(session.task.title)
                .font(.headline)
            HStack(spacing: 8) {
                TagPill(text: "Focus Session")
                TagPill(text: "\(session.task.minutes) min session")
            }

            ZStack {
                Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(elapsedString)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .padding(.top, 2)
            }
            .frame(width: 180, height: 180)
            .padding(.vertical, 12)

            HStack(spacing: 12) {
                Button(isPaused ? "Resume" : "Pause") { isPaused.toggle() }
                    .buttonStyle(.bordered)
                Button("Stop & Discard", role: .destructive) {
                    store.activeSession = nil
                }
                .buttonStyle(.borderedProminent)
            }

            Button {
                store.finishFocus()
                onDone()
            } label: {
                Label("Mark as Complete", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(24)
        .background(AppTheme.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding()
    }

    private var progress: CGFloat {
        let total = CGFloat(session.task.minutes * 60)
        let done = CGFloat(max(0, (session.task.minutes * 60) - session.remaining))
        return total == 0 ? 0 : (done / total)
    }

    private var elapsedString: String {
        let elapsed = (session.task.minutes * 60) - session.remaining
        let m = max(0, elapsed) / 60
        let s = max(0, elapsed) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
