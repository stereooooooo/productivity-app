# Web Reference: Select + Do (Web App)

## Source of Truth
- The complete working web version of this app is in:
  - `codex/web_ref/index.html`
- This single file contains **all HTML, CSS, and JavaScript** as originally built.
- Codex should reference this file as the **authoritative spec** for layout, styling, and interactivity when generating SwiftUI code.

## Visual References
Screenshots are located in `codex/web_ref/images/`:
- `home.png` – Home screen layout
- `find-a-task.png` – Find Task filters + task list
- `advanced-filters.png` – Advanced filtering
- `plan-your-day.png` – Daily planner view
- `task-review.png` – Task Review drawer
- `focus-timer.png` – Focus timer overlay
- `settings.png` – Settings drawer
- (additional images as needed)

## Key Features (from web app)
- **Sidebar**: Projects list with add button.
- **Top Utility Bar**: Search/command input, menu button (mobile), task review button, logout.
- **Find a Task**:
  - Mode selection (Work / Personal)
  - Time selection (5–60 min + Custom)
  - Priority toggle, Reset, Reshuffle
  - Task cards with context, type, time, and priority badge
- **Task Review Drawer**: Weekly review insights.
- **Settings Drawer**: Toggles such as “Show daily planner”.
- **Focus Overlay**: Countdown timer with pause/stop/complete.
- **Completed Tasks**: List of tasks completed today.

## Purpose of This Reference
- Codex should use this file (`index.html`) + screenshots as the **baseline behavior and appearance**.  
- When building the SwiftUI iOS version:
  - Match layout, spacing, and style (within iOS conventions).
  - Replicate functionality (filters, drawers, timer, review).
  - Ensure parity before extending features.