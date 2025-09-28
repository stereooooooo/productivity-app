// codex/split_index_html.js
// Lossless splitter: pulls the first <style> into styles.css and each
// <script type="module">...</script> block into js/NN-<hash>.mjs
//
// Usage (from repo root):
//   node codex/split_index_html.js codex/index.html codex/web_ref
//
// If you omit args, it defaults to:
//   in:  codex/web_ref/index.html
//   out: codex/web_ref

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const inPath = process.argv[2] || path.join("codex", "web_ref", "index.html");
const outRoot = process.argv[3] || path.join("codex", "web_ref");

if (!fs.existsSync(inPath)) {
    console.error(`❌ Cannot find index.html at: ${inPath}`);
    process.exit(1);
}
if (!fs.existsSync(outRoot)) {
    fs.mkdirSync(outRoot, { recursive: true });
}
const jsOutDir = path.join(outRoot, "js");
if (!fs.existsSync(jsOutDir)) fs.mkdirSync(jsOutDir, { recursive: true });

const html = fs.readFileSync(inPath, "utf8");

// ---- extract <style> (first one only, as in your original) ----
const styleRe = /<style[^>]*>([\s\S]*?)<\/style>/i;
const styleMatch = html.match(styleRe);
if (styleMatch) {
    const css = styleMatch[1];
    const cssPath = path.join(outRoot, "styles.css");
    fs.writeFileSync(cssPath, css, "utf8");
    console.log(`✅ wrote ${path.relative(process.cwd(), cssPath)} (${css.length} bytes)`);
} else {
    console.log("ℹ️  No <style> block found.");
}

// ---- extract each <script type="module">…</script> in order ----
const scriptRe = /<script\s+type=["']module["'][^>]*>([\s\S]*?)<\/script>/gi;
let idx = 0;
let m;
const manifest = [];

while ((m = scriptRe.exec(html)) !== null) {
    idx += 1;
    const code = m[1];
    const hash = crypto.createHash("sha1").update(code).digest("hex").slice(0, 8);
    // number the files to preserve exact order; you can rename later
    const fname = `${String(idx).padStart(2, "0")}-${hash}.mjs`;
    const outPath = path.join(jsOutDir, fname);
    fs.writeFileSync(outPath, code, "utf8");
    manifest.push({ index: idx, file: `js/${fname}`, bytes: code.length });
}

if (manifest.length) {
    const mfPath = path.join(outRoot, "split-manifest.json");
    fs.writeFileSync(mfPath, JSON.stringify({ source: inPath, modules: manifest }, null, 2));
    console.log(`✅ wrote ${path.relative(process.cwd(), mfPath)} with ${manifest.length} modules`);
} else {
    console.log("ℹ️  No <script type=\"module\"> blocks found.");
}

console.log("\nNext steps:");
console.log("1) Open split-manifest.json to see the module order.");
console.log("2) Compare each js/NN-*.mjs to your target filenames (state.js, ui-render.js, etc.).");
console.log("   Move/rename each file to codex/web_ref/js/<name>.js keeping the contents EXACT.");
console.log("3) Ensure your codex/web_ref/index.html now references ./styles.css and ./js/*.js (as modules).");