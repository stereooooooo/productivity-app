// firebase.js — safe stub for local reference / guest mode
// Replace with real Firebase imports + config when you're ready.

export const app = null;
export const auth = null;
export const db = null;

// Auth API stubs (so imports in auth.js succeed without real Firebase)
export class GoogleAuthProvider { }
export function signInWithPopup() { throw new Error("Firebase not configured"); }
export function signInWithRedirect() { throw new Error("Firebase not configured"); }
export async function getRedirectResult() { return null; }
export function signOut() { }
export function onAuthStateChanged(/*auth, cb*/) { /* no-op */ }
export async function createUserWithEmailAndPassword() { throw new Error("Firebase not configured"); }
export async function signInWithEmailAndPassword() { throw new Error("Firebase not configured"); }

// Firestore stubs
export function doc() { return null; }
export function onSnapshot() { return () => { }; }
export async function setDoc() { }