// state.js — application state and demo data

// Global state
export const state = {
    projects: [],
    tasks: [],
    user: null,
    activeContext: "Work",
    selectedMinutes: 20,
    priorityOnly: false,
    reshuffleID: crypto.randomUUID()
};

// Example data loader (for guest mode)
export function loadExampleData() {
    console.log("📚 Loading example data for guest mode");

    state.projects = [
        { id: "inbox", name: "Inbox" },
        { id: "work", name: "Work Projects" },
        { id: "personal", name: "Personal" },
        { id: "learning", name: "Learning" }
    ];

    state.tasks = [
        // Atomic tasks
        {
            id: "task_1",
            title: "Send project update email",
            minutes: 15,
            kind: "Atomic",
            context: "Work",
            isPriority: false
        },
        {
            id: "task_2",
            title: "Review meeting notes",
            minutes: 10,
            kind: "Atomic",
            context: "Work",
            isPriority: false
        },
        {
            id: "task_3",
            title: "Quick workout",
            minutes: 15,
            kind: "Atomic",
            context: "Personal",
            isPriority: false
        },

        // Progress tasks
        {
            id: "task_4",
            title: "Read industry article",
            minutes: 15,
            kind: "Progress",
            context: "Work",
            isPriority: false
        },
        {
            id: "task_5",
            title: "Draft project proposal",
            minutes: 30,
            kind: "Progress",
            context: "Work",
            isPriority: true
        },
        {
            id: "task_6",
            title: "Learn new programming concept",
            minutes: 45,
            kind: "Progress",
            context: "Personal",
            isPriority: false
        }
    ];
}