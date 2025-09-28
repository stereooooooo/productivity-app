// auth.js — authentication handling

import * as D from "./dom.js";
import * as S from "./state.js";
import { showMainApp, showLogin } from "./dom.js";
import { renderTasks, renderCompleted } from "./ui-render.js";
import {
    auth,
    GoogleAuthProvider,
    signInWithPopup,
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
    signOut,
    onAuthStateChanged
} from "./firebase.js";

// --- guest mode ---
export function showGuestMode() {
    S.loadExampleData();
    showMainApp();
    renderTasks(S.state.tasks);
    renderCompleted(S.state.tasks.filter(t => t.completedAt));
}

// --- error helper ---
function showError(msg) {
    const errBox = document.getElementById("authError");
    if (errBox) {
        errBox.textContent = msg;
        errBox.classList.remove("hidden");
    }
}

// --- Google login ---
export function handleGoogleLogin() {
    const provider = new GoogleAuthProvider();
    signInWithPopup(auth, provider).catch(err => {
        console.error("Google login failed:", err);
        showError(err.message);
    });
}

// --- Email login/signup ---
export function handleEmailSignIn(email, pw) {
    signInWithEmailAndPassword(auth, email, pw).catch(err => {
        console.error("Email login failed:", err);
        showError(err.message);
    });
}

export function handleEmailSignUp(email, pw) {
    createUserWithEmailAndPassword(auth, email, pw).catch(err => {
        console.error("Signup failed:", err);
        showError(err.message);
    });
}

// --- Logout ---
export function handleLogout() {
    signOut(auth).catch(err => {
        console.error("Logout failed:", err);
    });
}

// --- wire login buttons ---
export function initAuthUI() {
    const gbtn = document.getElementById("googleLoginBtn");
    const signInBtn = document.getElementById("signInBtn");
    const signUpBtn = document.getElementById("signUpBtn");
    const guestBtn = document.getElementById("guestModeBtn");
    const logoutBtn = D.logoutBtn;

    gbtn?.addEventListener("click", handleGoogleLogin);
    signInBtn?.addEventListener("click", () => {
        const email = document.getElementById("emailInput")?.value || "";
        const pw = document.getElementById("passwordInput")?.value || "";
        handleEmailSignIn(email, pw);
    });
    signUpBtn?.addEventListener("click", () => {
        const email = document.getElementById("emailInput")?.value || "";
        const pw = document.getElementById("passwordInput")?.value || "";
        handleEmailSignUp(email, pw);
    });
    guestBtn?.addEventListener("click", showGuestMode);
    logoutBtn?.addEventListener("click", handleLogout);
}

// --- react to auth state changes ---
export function watchAuth() {
    if (!auth) {
        console.warn("⚠️ Firebase not configured — defaulting to guest mode");
        showGuestMode();
        return;
    }
    onAuthStateChanged(auth, (user) => {
        if (user) {
            console.log("✅ Logged in as", user.email);
            S.state.user = user;
            showMainApp();
            renderTasks(S.state.tasks);
            renderCompleted(S.state.tasks.filter(t => t.completedAt));
        } else {
            console.log("🚪 Logged out");
            S.state.user = null;
            showLogin();
        }
    });
}