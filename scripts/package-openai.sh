#!/usr/bin/env bash
# Builds the ChatGPT/OpenAI plugin ZIP (Codex format) from skills/ and openai/.
# Output: dist/aca-openai-<version>.zip. Never put credentials in openai/.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
node "$root/scripts/check-tools.mjs"
version="$(node -p "require('$root/openai/plugin.json').version")"
stage="$(mktemp -d)/aca"
mkdir -p "$stage/.codex-plugin" "$stage/assets"
cp "$root/openai/plugin.json" "$stage/.codex-plugin/plugin.json"
cp "$root/openai/.mcp.json" "$stage/.mcp.json"
cp "$root/assets/logo.png" "$stage/assets/logo.png"
cp -R "$root/skills" "$stage/skills"
cp "$root/LICENSE" "$stage/LICENSE"
node - "$stage" <<'NODE'
const fs = require("fs"), path = require("path");
const dir = process.argv[2];
const m = JSON.parse(fs.readFileSync(path.join(dir, ".codex-plugin/plugin.json"), "utf8"));
const i = m.interface, errors = [];
if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(m.name) || m.name.length > 64) errors.push("name");
if (!/^\d+\.\d+\.\d+$/.test(m.version)) errors.push("version");
if (i.shortDescription.length > 30) errors.push("shortDescription > 30");
if (i.longDescription.length > 4000) errors.push("longDescription > 4000");
if (i.capabilities.length > 20 || i.capabilities.some((c) => c.length > 120)) errors.push("capabilities");
if ([].concat(i.defaultPrompt).length > 3 || [].concat(i.defaultPrompt).some((p) => p.length > 128)) errors.push("defaultPrompt");
for (const k of ["websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL"]) if (!/^https:\/\//.test(i[k] || "")) errors.push(k);
for (const p of [i.logo, i.composerIcon, m.skills, m.mcpServers, m.extensions["com.openai"].onboardingSkill]) if (!fs.existsSync(path.join(dir, p))) errors.push(`missing ${p}`);
const t = m.extensions["com.openai"].review.test_cases;
if (t.positive.length !== 5 || t.negative.length !== 3) errors.push("review cases must be 5 positive, 3 negative");
if (errors.length) { console.error("Invalid OpenAI package:", errors.join(", ")); process.exit(1); }
NODE
mkdir -p "$root/dist"
out="$root/dist/aca-openai-$version.zip"
rm -f "$out"
(cd "$stage" && zip -qr -X "$out" . -x '*.DS_Store')
echo "Wrote $out"
