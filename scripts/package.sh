#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
name="$(node -p "require('$root/package.json').name")"
version="$(node -p "require('$root/package.json').version")"
dist="$root/dist"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

package_dir="$stage/$name"
mkdir -p "$package_dir"

cp "$root/README.md" "$package_dir/"
cp "$root/CHAINING.md" "$package_dir/"
cp "$root/LICENSE" "$package_dir/"
cp "$root/.mcp.example.json" "$package_dir/"
cp "$root/install.sh" "$package_dir/"
cp "$root/package.json" "$package_dir/"
cp -R "$root/.codex-plugin" "$package_dir/"
cp -R "$root/.claude-plugin" "$package_dir/"
cp -R "$root/scripts" "$package_dir/"

for skill_dir in "$root"/aca-*; do
  [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]] || continue
  cp -R "$skill_dir" "$package_dir/"
done

mkdir -p "$dist"
tarball="$dist/$name-$version.tar.gz"
zipfile="$dist/$name-$version.zip"

tar -czf "$tarball" -C "$stage" "$name"
if command -v zip >/dev/null 2>&1; then
  (cd "$stage" && zip -qr "$zipfile" "$name")
else
  echo "zip not found; skipped $zipfile" >&2
fi

echo "Created:"
echo "  $tarball"
if [[ -f "$zipfile" ]]; then
  echo "  $zipfile"
fi
