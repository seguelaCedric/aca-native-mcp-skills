# Integrate into `aca-native-mcp-skills`

Copy these paths into the **existing repo root** so Claude (`.claude-plugin`) and Codex (`.codex-plugin`) packaging stay intact. Do **not** overwrite those directories.

## Source → destination

From this package (`aca-cursor-plugin/`) into repo root of  
`https://github.com/seguelaCedric/aca-native-mcp-skills`:

| Copy from (this package) | To (repo root) |
|--------------------------|----------------|
| `.cursor-plugin/plugin.json` | `.cursor-plugin/plugin.json` |
| `mcp.json` | `mcp.json` |
| `SUBMISSION.md` | `SUBMISSION.md` (optional but useful) |
| `INTEGRATE.md` | `INTEGRATE.md` (optional) |

## Do not overwrite blindly

- **Do not** replace `.claude-plugin/` or `.codex-plugin/`.
- **Do not** add a `skills/` directory for this MCP-first Cursor release.
- **LICENSE**: if the repo already has an MIT LICENSE with compatible copyright, leave it; otherwise merge/align to Copyright (c) 2026 ACA / Automated Client Acquisition.
- **README.md**: prefer merging a “Cursor marketplace” section into the existing README rather than replacing Claude/Codex install docs. Use this package’s `README.md` as the Cursor section source.
- **assets/**: skip unless you have a real brand logo; do not invent placeholder logos.

## Exact copy commands

Assuming you cloned the repo next to this package:

```bash
# Adjust REPO to your local clone of seguelaCedric/aca-native-mcp-skills
REPO="/path/to/aca-native-mcp-skills"
SRC="/workspace/aca-cursor-plugin"

mkdir -p "$REPO/.cursor-plugin"
cp "$SRC/.cursor-plugin/plugin.json" "$REPO/.cursor-plugin/plugin.json"
cp "$SRC/mcp.json" "$REPO/mcp.json"
cp "$SRC/SUBMISSION.md" "$REPO/SUBMISSION.md"
cp "$SRC/INTEGRATE.md" "$REPO/INTEGRATE.md"
# Optional: merge README / LICENSE manually — do not clobber without review
# cp "$SRC/README.md" "$REPO/README.cursor.md"
# cp "$SRC/LICENSE" "$REPO/LICENSE"   # only if aligning copyright is intentional
```

From inside the existing repo after copying:

```bash
# Sanity check
python3 -c "import json; json.load(open('.cursor-plugin/plugin.json')); json.load(open('mcp.json')); print('JSON OK')"
ls -la .cursor-plugin/plugin.json mcp.json
ls -la .claude-plugin .codex-plugin   # should still exist unchanged
```

## After merge

1. Commit and push to the public default branch.
2. Follow `SUBMISSION.md` to publish at https://cursor.com/marketplace/publish.
