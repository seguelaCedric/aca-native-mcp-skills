# ACA — Automated Client Acquisition (Cursor plugin)

Official **MCP-first** Cursor marketplace connector for [Automated Client Acquisition](https://aca.so/product/integrations/mcp). Connect Cursor agents to ACA’s MCP so they can help manage leads, lists, sequences, and outreach.

Agent skills (deeper playbooks) ship in a **follow-up release**. This package focuses on the MCP connection.

## Install

### Cursor Marketplace

1. Open Cursor → Marketplace (or install from the listing once published).
2. Install the **ACA** plugin.
3. When the ACA server first connects, sign in to ACA in the browser window Cursor opens (OAuth).

### Local / development

1. Clone or copy this plugin into a folder Cursor can load as a local plugin.
2. Ensure `.cursor-plugin/plugin.json` and `mcp.json` are present at the package root.
3. Enable the **aca** MCP server and sign in when prompted.

## Authentication

ACA uses OAuth. Cursor opens an ACA sign-in the first time the `aca` server connects; no API key is needed or stored.

## What the MCP connection does

This plugin registers the **aca** MCP server:

- **URL:** `https://mcp.automatedclientacquisition.com/mcp`
- **Auth:** OAuth (sign in to ACA when prompted)

Once connected, Cursor agents can use ACA MCP tools (subject to your account permissions) for outbound and CRM-adjacent workflows—leads, lists, sequences, and outreach—without embedding secrets in the repo.

## Skills

Cursor discovers skills under `skills/`:

- Crew orchestration: `aca-crew-handoff`, `aca-crew-roles`, `aca-mcp-ops`
- Product workflows: the existing `aca-*` playbooks (also kept at repo root for Claude/Codex)

Connect ACA MCP first, then use these skills for outbound and multi-agent crew handoffs.

## Links

- Homepage: [https://aca.so/product/integrations/mcp](https://aca.so/product/integrations/mcp)
- Repository: [https://github.com/seguelaCedric/aca-native-mcp-skills](https://github.com/seguelaCedric/aca-native-mcp-skills)
- License: MIT

## License

MIT © 2026 ACA / Automated Client Acquisition
