// focus.js — focus timer overlay

import * as D from "./dom.js";

let timer = null;
let remaining = 0;
let isPaused = false;

// --- open overlay for a task ---
export function startFocus(task) {
    if (!task) return;
    remaining = (task.minutes || 25) * 60;
    isPaused = false;
    updateDisplay();
    D.focusTaskName.textContent = task.title || "Focus Session";

    // show overlay
    D.focusOverlay.classList.remove("hidden");

    // start ticking
    clearInterval(timer);
    timer = setInterval(tick, 1000);
}

// --- tick ---
function tick() {
    if (isPaused) return;
    if (remaining <= 0) {
        completeFocus();
        return;
    }
    remaining -= 1;
    updateDisplay();
}

// --- update display ---
function updateDisplay() {
    const mins = Math.floor(remaining / 60);
    const secs = remaining % 60;
    D.focusTimerDisplay.textContent =
        `${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`;
}

// --- controls ---
export function pauseFocus() {
    isPaused = !isPaused;
    D.focusPauseBtn.textContent = isPaused ? "Resume" : "Pause";
}

export function stopFocus() {
    clearInterval(timer);
    D.focusOverlay.classList.add("hidden");
}

export function completeFocus() {
    clearInterval(timer);
    D.focusOverlay.classList.add("hidden");
    console.log("✅ Focus session complete");
}

// --- wire buttons ---
export function initFocusUI() {
    D.focusPauseBtn?.addEventListener("click", pauseFocus);
    D.focusStopBtn?.addEventListener("click", stopFocus);
    D.focusCompleteBtn?.addEventListener("click", completeFocus);
}