// dom.js — central DOM lookups and helpers

// Screen containers
export const loginScreen = document.getElementById("loginScreen");
export const mainApp = document.getElementById("mainApp");

// Utility bar
export const unifiedCommandInput = document.getElementById("unifiedCommandInput");
export const openTaskReviewDrawerIconBtn = document.getElementById("openTaskReviewDrawerIconBtn");
export const logoutBtn = document.getElementById("logoutBtn");

// Sidebars
export const projectsContainer = document.getElementById("projectsContainer");

// Main content
export const contentArea = document.getElementById("contentArea");
export const contentEmptyState = document.getElementById("contentEmptyState");
export const contentEmptyStateTitle = document.getElementById("contentEmptyStateTitle");
export const contentEmptyStateBody = document.getElementById("contentEmptyStateBody");

// Task suggestions & completed
export const taskSuggestionsSection = document.getElementById("taskSuggestionsSection");
export const completedTaskList = document.getElementById("completedTaskList");

// Drawers
export const taskReviewDrawerOverlay = document.getElementById("taskReviewDrawerOverlay");
export const taskReviewDrawerPanel = document.getElementById("taskReviewDrawerPanel");
export const closeTaskReviewDrawerBtn = document.getElementById("closeTaskReviewDrawerBtn");

export const settingsDrawerOverlay = document.getElementById("settingsDrawerOverlay");
export const settingsDrawerPanel = document.getElementById("settingsDrawerPanel");
export const closeSettingsDrawerBtn = document.getElementById("closeSettingsDrawerBtn");

// Focus overlay
export const focusOverlay = document.getElementById("focusOverlay");
export const focusTaskName = document.getElementById("focusTaskName");
export const focusTimerDisplay = document.getElementById("focusTimerDisplay");
export const focusPauseBtn = document.getElementById("focusPauseBtn");
export const focusStopBtn = document.getElementById("focusStopBtn");
export const focusCompleteBtn = document.getElementById("focusCompleteBtn");

// Command suggestions
export const commandSuggestions = document.getElementById("commandSuggestions");

// --- helpers ---

export function showMainApp() {
    loginScreen.classList.add("hidden");
    mainApp.classList.remove("hidden");
}

export function showLogin() {
    loginScreen.classList.remove("hidden");
    mainApp.classList.add("hidden");
}

export function updateContentArea(html) {
    if (contentArea) contentArea.innerHTML = html;
}

export function clearContentArea() {
    if (contentArea) contentArea.innerHTML = "";
}

export function showOverlay(overlay, panel) {
    overlay.classList.remove("hidden");
    setTimeout(() => {
        overlay.classList.add("active");
        panel.classList.add("active");
    }, 10);
}

export function hideOverlay(overlay, panel) {
    overlay.classList.remove("active");
    panel.classList.remove("active");
    setTimeout(() => {
        overlay.classList.add("hidden");
    }, 200);
}