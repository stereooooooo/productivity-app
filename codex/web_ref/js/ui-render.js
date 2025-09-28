// ui-render.js
// Responsible for rendering the UI (sidebar, filters, tasks, review)

import { appState } from "./state.js";

// Utility to create DOM nodes
function el(tag, options = {}) {
    const node = document.createElement(tag);
    if (options.class) node.className = options.class;
    if (options.text) node.textContent = options.text;
    if (options.html) node.innerHTML = options.html;
    if (options.attrs) {
        for (const [k, v] of Object.entries(options.attrs)) {
            node.setAttribute(k, v);
        }
    }
    if (options.children) {
        options.children.forEach(c => node.appendChild(c));
    }
    return node;
}

/* ------------------------------
   SIDEBAR (Projects)
--------------------------------*/
export function renderSidebar() {
    const container = document.getElementById("projectsContainer");
    if (!container) return;

    container.innerHTML = "";
    appState.projects.forEach(project => {
        const item = el("div", {
            class: "p-2 rounded hover:bg-gray-50 cursor-pointer flex justify-between items-center"
        });
        item.appendChild(el("span", { text: project.name, class: "text-sm font-medium" }));
        if (project.tasks.length > 0) {
            item.appendChild(
                el("span", {
                    text: project.tasks.length,
                    class: "text-xs text-gray-500"
                })
            );
        }
        container.appendChild(item);
    });
}

/* ------------------------------
   FIND A TASK (Filters + Task list)
--------------------------------*/
export function renderFindTask() {
    const contentArea = document.getElementById("contentArea");
    if (!contentArea) return;

    contentArea.innerHTML = "";

    // 1) Mode (Work / Personal)
    const modeSection = el("section", { class: "mb-6" });
    modeSection.appendChild(el("h3", { text: "What Mode Are You In?", class: "font-semibold mb-2" }));

    const modeButtons = el("div", { class: "flex gap-2" });
    ["Work", "Personal"].forEach(mode => {
        const btn = el("button", {
            text: mode,
            class:
                "px-3 py-1 rounded-full border text-sm " +
                (appState.activeContext === mode
                    ? "bg-blue-500 text-white"
                    : "bg-white text-gray-700")
        });
        btn.addEventListener("click", () => {
            appState.activeContext = mode;
            renderFindTask();
        });
        modeButtons.appendChild(btn);
    });
    modeSection.appendChild(modeButtons);
    contentArea.appendChild(modeSection);

    // 2) Time (5–60 min + custom)
    const timeSection = el("section", { class: "mb-6" });
    timeSection.appendChild(el("h3", { text: "How Much Time Do You Have?", class: "font-semibold mb-2" }));

    const timeButtons = el("div", { class: "flex flex-wrap gap-2" });
    [5, 10, 15, 20, 25, 30, 45, 60].forEach(mins => {
        const btn = el("button", {
            text: `${mins} min`,
            class:
                "px-3 py-1 rounded-full border text-sm " +
                (appState.selectedMinutes === mins
                    ? "bg-blue-500 text-white"
                    : "bg-white text-gray-700")
        });
        btn.addEventListener("click", () => {
            appState.selectedMinutes = mins;
            renderFindTask();
        });
        timeButtons.appendChild(btn);
    });
    const customBtn = el("button", {
        text: "Custom",
        class: "px-3 py-1 rounded-full border text-sm text-gray-700"
    });
    timeButtons.appendChild(customBtn);
    timeSection.appendChild(timeButtons);
    contentArea.appendChild(timeSection);

    // 3) Priority toggle + actions
    const filterBar = el("div", { class: "flex items-center gap-4 mb-6 text-sm text-gray-600" });
    const priorityToggle = el("label", { class: "flex items-center gap-1 cursor-pointer" });
    const checkbox = el("input", { attrs: { type: "checkbox" } });
    checkbox.checked = appState.priorityOnly;
    checkbox.addEventListener("change", () => {
        appState.priorityOnly = checkbox.checked;
        renderFindTask();
    });
    priorityToggle.appendChild(checkbox);
    priorityToggle.appendChild(el("span", { text: "Priority Only" }));
    filterBar.appendChild(priorityToggle);

    const resetBtn = el("button", { text: "Reset", class: "hover:text-blue-600" });
    resetBtn.addEventListener("click", () => {
        appState.activeContext = "Work";
        appState.selectedMinutes = null;
        appState.priorityOnly = false;
        renderFindTask();
    });
    filterBar.appendChild(resetBtn);

    const reshuffleBtn = el("button", { text: "Reshuffle", class: "hover:text-blue-600" });
    reshuffleBtn.addEventListener("click", () => {
        appState.reshuffleID = Math.random().toString();
        renderFindTask();
    });
    filterBar.appendChild(reshuffleBtn);

    contentArea.appendChild(filterBar);

    // 4) Task list
    const list = el("div", { class: "space-y-4" });

    let tasks = [...appState.tasks];
    if (appState.activeContext) {
        tasks = tasks.filter(t => t.context === appState.activeContext);
    }
    if (appState.selectedMinutes) {
        tasks = tasks.filter(t => t.minutes === appState.selectedMinutes);
    }
    if (appState.priorityOnly) {
        tasks = tasks.filter(t => t.isPriority);
    }

    if (tasks.length === 0) {
        list.appendChild(
            el("p", { text: "No tasks match. Try a different time or context.", class: "text-gray-500 text-sm" })
        );
    } else {
        tasks.forEach(task => {
            const card = el("div", {
                class:
                    "p-4 bg-white shadow rounded-lg flex justify-between items-center hover:shadow-md transition cursor-pointer"
            });
            const left = el("div");
            left.appendChild(el("h4", { text: task.title, class: "font-medium" }));

            const tags = el("div", { class: "flex gap-2 mt-1 text-xs text-gray-500" });
            tags.appendChild(el("span", { text: task.kind }));
            tags.appendChild(el("span", { text: task.context }));
            tags.appendChild(el("span", { text: `${task.minutes} min` }));
            if (task.isPriority) {
                tags.appendChild(el("span", { text: "★ Priority", class: "text-yellow-500" }));
            }
            left.appendChild(tags);

            const startBtn = el("button", {
                text: "Start",
                class: "bg-blue-500 text-white px-3 py-1 rounded text-sm"
            });
            startBtn.addEventListener("click", () => {
                console.log("Start task:", task.title);
            });

            card.appendChild(left);
            card.appendChild(startBtn);
            list.appendChild(card);
        });
    }

    contentArea.appendChild(list);
}