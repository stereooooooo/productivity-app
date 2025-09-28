import SwiftUI
import Combine

struct FocusSheet: View {
    let session: FocusSession
    var onDone: () -> Void

    @State private var timerCancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(Color.secondary.opacity(0.4)).frame(width: 40, height: 5).padding(.top, 8)

            Text(session.task.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Countdown(remaining: session.remaining)

            HStack(spacing: 12) {
                Button(role: .cancel) {
                    onDone()
                } label: {
                    Text("Finish")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onDone()
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear { startTimer() }
        .onDisappear { timerCancellable?.cancel() }
    }

    private func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // Use environment store to tick
                NotificationCenter.default.post(name: .focusTick, object: nil)
            }
    }
}

private struct Countdown: View {
    var remaining: Int
    var body: some View {
        let mins = remaining / 60
        let secs = remaining % 60
        Text(String(format: "%02d:%02d", mins, secs))
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension Notification.Name {
    static let focusTick = Notification.Name("focusTick")
}