#!/usr/bin/env bash
# Root-level skill folders are copies of skills/ for runtimes that load skills
# from the repo root (Codex manifest uses "./"). skills/ is the source of truth.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for dir in "$root"/skills/*/; do
  name="$(basename "$dir")"
  [[ -d "$root/$name" ]] || continue
  cp "$dir/SKILL.md" "$root/$name/SKILL.md"
done
