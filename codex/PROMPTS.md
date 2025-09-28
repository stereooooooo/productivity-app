# Codex Prompts

## Boot-up
You have full access to the workspace. First, read these:
- codex/CONTEXT.md
- codex/WEB_REFERENCE.md
- codex/MAPPING.md
- codex/PARITY_CHECKLIST.md
- codex/web_ref/index.html (authoritative UI/behavior reference)

Aims:
- Keep SwiftUI architecture intact (AppStore.swift, RootView.swift, AddTaskView.swift, FindTaskView.swift, ReviewView.swift, Theme.swift).
- iOS 17+, SwiftUI only. Combine for @Published. SwiftData later.
- Match the web reference visually/behaviorally where appropriate for iOS.

Rules:
- Before editing, state: files you’ll touch, a short plan, and acceptance criteria.
- Produce diffs or full-file replacements as needed.
- Don’t edit .xcodeproj directly—create files via Xcode or provide the Swift code for me to add.

## Example task prompt
Task: Implement “Find a Task” parity:
- Add Work/Personal toggle, minute chips (5,10,15,20,25,30,45,60), Priority Only, Reset, Reshuffle.
- Use SectionHeaderView + Card styling from Theme.swift.
- Follow layout in codex/web_ref/index.html → sections “What Mode Are You In?” and “How Much Time…”.

Acceptance:
- Tapping Work/Personal filters visible tasks.
- Minute chips filter tasks by minutes.
- Priority toggle filters correctly.
- Reset returns to Work + 20m + Priority off.
- Reshuffle changes order without losing filters.