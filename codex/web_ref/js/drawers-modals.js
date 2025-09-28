// drawers-modals.js — slide-in panels for Task Review + Settings

import * as D from "./dom.js";
import { renderWeeklyInsights } from "./ui-render.js";

// --- Task Review drawer ---
export function openTaskReviewDrawer() {
    if (!D.taskReviewDrawerOverlay || !D.taskReviewDrawerPanel) return;
    renderWeeklyInsights();
    D.showOverlay(D.taskReviewDrawerOverlay, D.taskReviewDrawerPanel);
}

export function closeTaskReviewDrawer() {
    if (!D.taskReviewDrawerOverlay || !D.taskReviewDrawerPanel) return;
    D.hideOverlay(D.taskReviewDrawerOverlay, D.taskReviewDrawerPanel);
}

// --- Settings drawer ---
export function openSettingsDrawer() {
    if (!D.settingsDrawerOverlay || !D.settingsDrawerPanel) return;
    D.showOverlay(D.settingsDrawerOverlay, D.settingsDrawerPanel);
}

export function closeSettingsDrawer() {
    if (!D.settingsDrawerOverlay || !D.settingsDrawerPanel) return;
    D.hideOverlay(D.settingsDrawerOverlay, D.settingsDrawerPanel);
}

// --- wire close buttons ---
export function initDrawerUI() {
    D.closeTaskReviewDrawerBtn?.addEventListener("click", closeTaskReviewDrawer);
    D.closeSettingsDrawerBtn?.addEventListener("click", closeSettingsDrawer);

    // also close on clicking overlay background
    D.taskReviewDrawerOverlay?.addEventListener("click", (e) => {
        if (e.target === D.taskReviewDrawerOverlay) closeTaskReviewDrawer();
    });
    D.settingsDrawerOverlay?.addEventListener("click", (e) => {
        if (e.target === D.settingsDrawerOverlay) closeSettingsDrawer();
    });
}