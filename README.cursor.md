# ACA — Automated Client Acquisition (Cursor plugin)

Official **MCP-first** Cursor marketplace connector for [Automated Client Acquisition](https://aca.so/product/integrations/mcp). Connect Cursor agents to ACA’s MCP so they can help manage leads, lists, sequences, and outreach.

Agent skills (deeper playbooks) ship in a **follow-up release**. This package focuses on the MCP connection.

## Install

### Cursor Marketplace

1. Open Cursor → Marketplace (or install from the listing once published).
2. Install the **ACA** plugin.
3. When prompted, set **ACA MCP API key** (`ACA_API_KEY`).

### Local / development

1. Clone or copy this plugin into a folder Cursor can load as a local plugin.
2. Ensure `.cursor-plugin/plugin.json` and `mcp.json` are present at the package root.
3. Configure the `ACA_API_KEY` variable (see below).

## Configure `ACA_API_KEY`

1. In ACA, open **Settings → MCP / API**.
2. Create an API key (format: `aca_mcp_sk_live_…`).
3. Paste it into the plugin’s **ACA MCP API key** field when installing, or set the `ACA_API_KEY` variable in your Cursor plugin / MCP config.

Never commit real keys to git or paste them into docs.

## What the MCP connection does

This plugin registers the **aca** MCP server:

- **URL:** `https://www.automatedclientacquisition.com/api/mcp`
- **Auth:** `Authorization: Bearer ${ACA_API_KEY}`

Once connected, Cursor agents can use ACA MCP tools (subject to your account permissions) for outbound and CRM-adjacent workflows—leads, lists, sequences, and outreach—without embedding secrets in the repo.

## Skills note

This release is **MCP-only**. Dedicated agent skills / rules will arrive in a later version; Claude and Codex packaging in the sibling repo remain separate.

## Links

- Homepage: [https://aca.so/product/integrations/mcp](https://aca.so/product/integrations/mcp)
- Repository: [https://github.com/seguelaCedric/aca-native-mcp-skills](https://github.com/seguelaCedric/aca-native-mcp-skills)
- License: MIT

## License

MIT © 2026 ACA / Automated Client Acquisition
