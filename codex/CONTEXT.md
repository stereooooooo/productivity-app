# Select + Do (iOS – SwiftUI)
Project: apps/ios/SelectDo/SelectDo.xcodeproj (scheme: SelectDo)

Architecture
- AppStore.swift: ObservableObject state (mode, filters, tasks, focus session).
- Views: RootView (segmented mode bar), AddTaskView, FindTaskView, ReviewView.
- Shared UI: Theme.swift (AppTheme, Chip, TagPill, SectionHeaderView), FlowLayout.swift.
- Only two modes: Work, Personal.
- Task properties: title, context, kind (Atomic/Standard/Progress), minutes, isPriority, completedAt.

Conventions
- iOS 17+, SwiftUI, Combine for @Published.
- Use SectionHeaderView + Card for sections.
- Keep RootView’s segmented mode bar.
- Do not edit .xcodeproj manually (create/rename files in Xcode).

Known paths
- apps/ios/SelectDo/SelectDo/AppStore.swift
- apps/ios/SelectDo/SelectDo/RootView.swift
- apps/ios/SelectDo/SelectDo/AddTaskView.swift
- apps/ios/SelectDo/SelectDo/FindTaskView.swift
- apps/ios/SelectDo/SelectDo/ReviewView.swift
- apps/ios/SelectDo/SelectDo/Theme.swift
- apps/ios/SelectDo/SelectDo/FlowLayout.swift