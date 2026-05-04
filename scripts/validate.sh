#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Checking shell scripts..."
bash -n "$root/install.sh"
bash -n "$root/scripts/validate.sh"
bash -n "$root/scripts/package.sh"

echo "Checking JSON manifests..."
node - <<'NODE' "$root"
const fs = require("fs");
const path = require("path");
const root = process.argv[2];
for (const file of [
  "package.json",
  ".mcp.example.json",
  ".codex-plugin/plugin.json",
  ".claude-plugin/plugin.json",
  ".claude-plugin/marketplace.json",
]) {
  JSON.parse(fs.readFileSync(path.join(root, file), "utf8"));
  console.log(`  valid JSON: ${file}`);
}
NODE

echo "Validating skills..."
count=0
for skill_file in "$root"/aca-*/SKILL.md; do
  [[ -e "$skill_file" ]] || continue
  npx --yes skills-ref validate "$(dirname -- "$skill_file")" >/dev/null
  count=$((count + 1))
done

if [[ "$count" -eq 0 ]]; then
  echo "No skills found." >&2
  exit 1
fi

echo "Checking installer discovery..."
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
"$root/install.sh" --target "$tmp_dir" >/dev/null
installed_count="$(find "$tmp_dir" -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
if [[ "$installed_count" != "$count" ]]; then
  echo "Installer copied $installed_count skills, expected $count." >&2
  exit 1
fi

echo "Validated $count ACA skills and package manifests."
