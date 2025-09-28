# Web → SwiftUI Mapping

## Source of Truth (Web)
- **codex/web_ref/index.html** — complete working web app (HTML + CSS + JS).
- **codex/web_ref/images/** — visual references (home, find-a-task, advanced-filters, plan-your-day, task-review, focus-timer, settings).

Codex: mirror the behavior/visuals from the web reference; adapt only where iOS conventions require (safe areas, native controls, HIG spacing).

---

## SwiftUI App Structure (iOS)
- **App state**
  - `AppStore.swift` — `@Published` state: `mode`, `activeContext`, `selectedMinutes`, `priorityOnly`, `tasks`, `activeSession`, `reshuffleID`; actions: `addTask`, `togglePriority`, `delete`, `startFocus`, `tickFocus`, `finishFocus`, `normalizeContexts`.
  - (Later) SwiftData models: `TaskModel` persisted; `@Query` for lists.

- **Views**
  - `RootView.swift` — segmented header (Add | Find | Review), app logo/title, hosts screens.
  - `AddTaskView.swift` — form (title, context Work/Personal, kind Atomic/Standard/Progress, minutes, priority) + large primary button.
  - `FindTaskView.swift` — “Find a Task” experience: mode pills, minute chips, Priority Only, Reset, Reshuffle, task cards, start flow.
  - `ReviewView.swift` — Completed Today + Weekly Insights.
  - `FocusSheet.swift` — focus timer presentation (sheet) with pause/stop/complete.
  - `Theme.swift` — basic design tokens/components: `AppTheme`, `Card`, `SectionHeaderView`, `Chip/TagPill`.
  - `FlowLayout.swift` — wrapping chip layout (for minute chips).

---

## Feature Mapping (Web → SwiftUI)

### Top Utility / Navigation
- **Web:** Top utility bar (search/command), Task Review icon, Logout.
- **iOS:** `RootView` segmented control (Add | Find | Review) is primary nav. Search/command: defer. Task Review accessed via Review tab (or a toolbar button if desired).

### Sidebar (Projects)
- **Web:** Left sidebar list.
- **iOS:** Defer or surface via a future Settings/Projects screen; not required for MVP parity.

### Find a Task
- **Web elements:**
  - Mode: Work / Personal pills
  - Time: 5,10,15,20,25,30,45,60 (+ Custom)
  - Priority Only toggle
  - Reset / Reshuffle actions
  - Task cards: title, kind, context, minutes, priority badge; Start
- **SwiftUI:**
  - `FindTaskView` renders:
    - `SectionHeaderView("What Mode Are You In?")` with two `Chip` buttons bound to `store.activeContext`.
    - `SectionHeaderView("How Much Time Do You Have?")` with minute chips (FlowLayout) bound to `store.selectedMinutes`; “Custom” sheet later.
    - Row with `Toggle("Priority Only", $store.priorityOnly)`, `Button("Reset")`, `Button("Reshuffle") { store.reshuffleID = UUID() }`.
    - A filtered `ForEach(filteredTasks)` → `TaskCard` rows; Start triggers `store.startFocus(task)`.
  - **State:** `AppStore.activeContext`, `selectedMinutes`, `priorityOnly`, `reshuffleID`.

### Add Task
- **Web:** Inline form + primary Add button.
- **SwiftUI:** `AddTaskView` `Form` with fields; big `.buttonStyle(.borderedProminent)` add button; calls `store.addTask(...)`.

### Task Review (Drawer on web)
- **Web:** Right-side drawer with Weekly Insights + Completed Today.
- **SwiftUI:** `ReviewView` full screen:
  - `SectionHeaderView("Completed Today")` list of `store.completedToday`.
  - `SectionHeaderView("Weekly Insights")` card(s) summarizing counts/time brackets.
  - (Optional) Present as sheet if you want a drawer feel.

### Focus Timer Overlay
- **Web:** Full-screen overlay with circular progress, pause/stop/complete.
- **SwiftUI:** `FocusSheet` presented when `store.activeSession != nil`:
  - Timer label, radial progress (later), controls: pause/resume (local state), stop (dismiss), complete (sets `completedAt = .now` and saves).
  - Ticks via NotificationCenter `.focusTick` or `Timer` publisher.

### Settings Drawer
- **Web:** Drawer with toggles (e.g., Show daily planner).
- **SwiftUI:** `SettingsView` (later) accessible via toolbar; store booleans in `AppStore` (and persist with SwiftData later).

---

## Visual Mapping (tokens → components)
- **Section headers:** `SectionHeaderView(title:)` with subtle divider bars (match 32px rhythm).
- **Cards:** `Card { content }` with rounded corners, soft shadow, system background.
- **Chips:** `Chip(label:isActive:)` (Capsule) for mode/time; active uses accent background with white text.
- **Spacing rhythm:** outer sections 24–32pt; inner control spacing 8–12pt.

---

## Testing/Acceptance (per feature)
- **Find screen:** toggles/chips update the list in real time; Reset restores Work + 20m + Priority off; Reshuffle changes order but preserves filters.
- **Add:** adds to `store.tasks` and appears in Find list when filters match.
- **Review:** completing from focus moves item into Completed Today; insights refresh.
- **Focus:** pause/resume works; complete sets `completedAt` and clears `activeSession`.