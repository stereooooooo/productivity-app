// main.js — entry point

import * as S from "./state.js";
import * as D from "./dom.js";
import { renderTasks, renderCompleted } from "./ui-render.js";
import { initAuthUI, watchAuth, showGuestMode } from "./auth.js";
import { initDrawerUI, openTaskReviewDrawer } from "./drawers-modals.js";
import { initFocusUI, startFocus } from "./focus.js";

// --- init ---
function init() {
    console.log("[main] init()");

    // Wire UI elements
    initAuthUI();
    initDrawerUI();
    initFocusUI();

    // Wire Task Review drawer button
    D.openTaskReviewDrawerIconBtn?.addEventListener("click", openTaskReviewDrawer);

    // Wire task start from contentArea (delegated)
    D.contentArea?.addEventListener("click", (e) => {
        const btn = e.target.closest("[data-start]");
        if (btn) {
            const id = btn.getAttribute("data-start");
            const t = S.state.tasks.find(x => x.id === id);
            if (t) startFocus(t);
        }
    });

    // Render initial state
    renderTasks(S.state.tasks);
    renderCompleted(S.state.tasks.filter(t => t.completedAt));

    // Watch auth (or default to guest mode if Firebase not set up)
    try {
        watchAuth();
    } catch (e) {
        console.warn("⚠️ Falling back to guest mode:", e);
        showGuestMode();
    }
}

document.addEventListener("DOMContentLoaded", init);