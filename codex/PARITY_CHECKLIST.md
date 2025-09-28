# Parity Checklist (Web → SwiftUI)

## Find a Task
- [ ] Mode chips (Work / Personal) bound to `store.activeContext`
- [ ] Minute chips (5,10,15,20,25,30,45,60) bound to `store.selectedMinutes`
- [ ] “Custom” minutes (sheet or inline field) — optional v2
- [ ] Priority Only toggle (`store.priorityOnly`)
- [ ] Reset (sets Work + 20m + Priority off)
- [ ] Reshuffle (updates `store.reshuffleID`, reorders but keeps filters)
- [ ] Task cards show: title, kind, context, minutes, priority badge
- [ ] Start opens `FocusSheet` with selected task
- [x] Advanced filters sheet (energy / projects / tags)

**Definition of Done (Find)**
- Filters/chips immediately update list
- Reset always restores default state (Work + 20m + Priority off)
- Reshuffle reorders while preserving filters
- Haptics: light on chip tap, success on start (optional)

## Add Task
- [ ] Form fields: title, context (Work/Personal), kind (Atomic/Standard/Progress), minutes (picker), Priority
- [ ] Large primary Add button with safe spacing
- [ ] Successful add clears title and haptics light
- [ ] Newly added task appears in Find when filters match

## Focus
- [ ] FocusSheet appears when `store.activeSession != nil`
- [ ] Timer ticks per second; pause/resume toggles label
- [ ] Stop dismisses sheet and clears session
- [ ] Complete sets `completedAt = .now` and (later) persists via SwiftData
- [ ] Optional: radial progress ring

## Review (Task Review)
- [ ] Completed Today list matches tasks completed since midnight
- [ ] Weekly Insights card(s) (counts/time brackets)
- [ ] Visual parity: section headers + cards

## Settings (later)
- [ ] SettingsView with “Show daily planner” (boolean in `AppStore`)
- [ ] Toggle persists with SwiftData (later)

## Visual/UX
- [ ] Section rhythm: ~32pt between blocks, ~12pt internal
- [ ] Chips: active = accent bg + white text; inactive = outline
- [ ] Cards: rounded, soft shadow, system background
- [ ] App logo in nav title (already added), adjustable size/leading alignment

## Persistence (SwiftData) — Phase 2
- [ ] `TaskModel` @Model (title, context, kind, minutes, isPriority, completedAt, updatedAt)
- [ ] Replace in-memory `tasks` with @Query-backed lists
- [ ] Add/Update/Delete write to SwiftData
- [ ] Completing a task sets `completedAt` and saves

## QA Pass
- [ ] Build succeeds on iOS 17 simulator
- [ ] Find/Add/Focus/Review flows tested end-to-end
- [ ] No crashes; state behaves after mode/time filter changes
