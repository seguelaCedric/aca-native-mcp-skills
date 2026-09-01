# Cursor Marketplace submission checklist

Short checklist for publishing this ACA Cursor plugin.

## 1. Push to public GitHub

Prefer merging into the existing public repo so Claude/Codex packaging stays intact:

- Repo: [seguelaCedric/aca-native-mcp-skills](https://github.com/seguelaCedric/aca-native-mcp-skills)
- Keep existing `.claude-plugin/` and `.codex-plugin/` untouched.
- Add Cursor paths at the **repo root** (see `INTEGRATE.md`):
  - `.cursor-plugin/plugin.json`
  - `mcp.json`
  - Update root `README.md` / `LICENSE` only if you intentionally unify docs; otherwise keep Cursor-specific copy under clear sections or leave as-is per team preference.

Ensure the default branch is public and the plugin files are on the branch you will submit.

## 2. Verify package against Cursor docs

Before submit, confirm:

- [ ] `.cursor-plugin/plugin.json` is valid JSON and matches marketplace schema (name, version, description, author, license, keywords, variables).
- [ ] `mcp.json` declares `mcpServers.aca` with URL and `Authorization: Bearer ${ACA_API_KEY}`.
- [ ] Required variable `ACA_API_KEY` is declared in `plugin.json` `variables`.
- [ ] No real API keys, tokens, or secrets in the repo.
- [ ] `LICENSE` is MIT and matches `plugin.json`.
- [ ] README explains install, key setup, and MCP purpose at a high level.
- [ ] No invented logo under `assets/` unless you have a real brand asset.
- [ ] Do **not** ship a `skills/` directory in this MCP-first release.

Official docs: follow the current Cursor marketplace / plugin packaging docs linked from the publish flow.

## 3. Submit

1. Open [https://cursor.com/marketplace/publish](https://cursor.com/marketplace/publish).
2. Point the form at the public GitHub repo (and path/branch if asked).
3. Complete listing metadata (name, description, keywords) consistent with `plugin.json`.
4. Submit for review.

## 4. “Official partner” appearance

“Official partner” styling or badges come from **Cursor’s manual review**, not from a field you set in `plugin.json`. If you need partner branding beyond a standard listing, contact **hi@cursor.com** and reference this ACA MCP connector / marketplace submission.
