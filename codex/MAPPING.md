# Web → SwiftUI mapping

Web “Mode chips” → SwiftUI `FlowLayout + Chip`
Web “Time chips + Custom” → `FlowLayout + Chip (+ Button)`
Web “Task card” → `TaskCard` (RoundedRectangle 16, 1px border .quaternary, soft shadow)
Web “Reset / Reshuffle / Priority Only row” → `HStack` (footnote)
Web “Focus modal” → `.sheet` with `FocusSheet`
Web “Review right drawer” → Full-screen `ReviewView` (or sheet) with stacked cards
Web “Settings drawer” → iOS `SettingsView` (later)

Storage:
- Web local (mock) → iOS in-memory now; **SwiftData** next.
- Later cloud sync optional.

Theming:
- CSS tokens → `AppTheme` constants (spacing, radii, colors).