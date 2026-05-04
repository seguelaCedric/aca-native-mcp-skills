#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./install.sh codex
  ./install.sh claude
  ./install.sh cursor
  ./install.sh all
  ./install.sh --target /path/to/skills

Options:
  --target DIR   Install into a custom skills directory.
  --dry-run      Print what would be installed without copying files.
  -h, --help     Show this help.

After installing skills, configure the ACA MCP server once using .mcp.example.json.
EOF
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
runtime=""
target=""
dry_run=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    codex|claude|cursor|all)
      if [[ -n "$runtime" ]]; then
        echo "Only one runtime can be selected." >&2
        exit 1
      fi
      runtime="$1"
      shift
      ;;
    --target)
      if [[ $# -lt 2 ]]; then
        echo "--target requires a directory." >&2
        exit 1
      fi
      target="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$runtime" && -z "$target" ]]; then
  usage >&2
  exit 1
fi

if [[ "$runtime" == "all" && -n "$target" ]]; then
  echo "--target cannot be combined with all." >&2
  exit 1
fi

skill_dirs=()
for skill_file in "$script_dir"/aca-*/SKILL.md; do
  [[ -e "$skill_file" ]] || continue
  skill_dirs+=("$(dirname -- "$skill_file")")
done

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "No aca-* skill folders found next to install.sh." >&2
  exit 1
fi

default_target_for() {
  case "$1" in
    codex) echo "$HOME/.codex/skills" ;;
    claude) echo "$HOME/.claude/skills" ;;
    cursor) echo "$HOME/.cursor/skills" ;;
    *)
      echo "Unsupported runtime: $1" >&2
      exit 1
      ;;
  esac
}

install_into() {
  local dest_root="$1"
  local label="$2"

  echo "Installing ACA skills for $label into $dest_root"
  if [[ "$dry_run" -eq 0 ]]; then
    mkdir -p "$dest_root"
  fi

  for skill_dir in "${skill_dirs[@]}"; do
    local name
    name="$(basename -- "$skill_dir")"
    local dest="$dest_root/$name"
    echo "  - $name"
    if [[ "$dry_run" -eq 0 ]]; then
      rm -rf "$dest"
      cp -R "$skill_dir" "$dest"
    fi
  done
}

if [[ -n "$target" ]]; then
  install_into "$target" "custom runtime"
elif [[ "$runtime" == "all" ]]; then
  install_into "$(default_target_for codex)" "codex"
  install_into "$(default_target_for claude)" "claude"
  install_into "$(default_target_for cursor)" "cursor"
else
  install_into "$(default_target_for "$runtime")" "$runtime"
fi

cat <<EOF

Installed ${#skill_dirs[@]} ACA skills.

Next:
  1. Add the ACA MCP server using .mcp.example.json
  2. Restart your agent runtime
  3. Run aca-kickoff
EOF
