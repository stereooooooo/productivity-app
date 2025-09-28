# Select + Do — Web Reference (for SwiftUI Port)

This folder mirrors the current web app in smaller, named modules so AI tools can map features 1:1 to SwiftUI.

- `index.html` – HTML skeleton + IDs used by JS
- `styles.css` – All CSS from `<style>` in the original
- `js/firebase.js` – Loads Firebase SDKs and initializes
- `js/config.example.js` – Placeholder for Firebase config (no secrets)
- `js/state.js` – Global state, constants, and timers
- `js/dom.js` – All DOM element lookups + small helpers
- `js/ui-render.js` – Rendering functions (tasks, filters, weekly review)
- `js/auth.js` – Sign-in, sign-up, logout flows
- `js/drawers-modals.js` – Task Review drawer, Settings drawer, generic modal helpers
- `js/focus.js` – Focus overlay logic (timer, progress ring)
- `js/main.js` – Bootstraps listeners and calls initial renders

> The content is copied from the original single-file app and regrouped by responsibility. Keep IDs and names stable for easy porting to SwiftUI views.