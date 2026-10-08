---
name: ACA MCP ops
description: >-
  Use this when connecting to or operating ACA via MCP for leads, lists,
  sequences, campaigns, and replies.
---
# ACA MCP ops

Use this whenever an agent needs to operate Automated Client Acquisition through MCP.

## The rule for bots
One agent, one job, narrow scope. Prefer deterministic tool calls and scripts for structured ACA ops; use the model for unstructured judgment only. Keep a human on irreversible actions (activate campaign, bulk enroll, send at scale, spend) until the error rate earns autonomy. Support a morning drift check on org, ICP, sequences, and mailbox health.

## Connect
- Prefer the installed ACA connector when available.
- Production MCP URL: `https://mcp.automatedclientacquisition.com/mcp`
- Auth: OAuth. The runtime prompts the user to sign in to ACA on first use; never ask for, commit, or paste API keys or tokens.
- Lead enrichment: MoltSets or QuickEnrich API key required when enriching contacts.

## Before mutating
1. Call `get_help` (or list tools) if unsure of the current schema.
2. `list_accessible_organizations` and `switch_organization` when the user has more than one org.
3. Prefer idempotent creates (`create_lead`) and check existing lists/sequences before duplicating.

## Safe defaults
- Create lists and sequences as **draft**; do not activate large campaigns without explicit user confirmation.
- Do not invent emails or phone numbers.
- Prefer tagging source/signal on leads when recording pipeline work.
- On bulk enroll or Apify import, confirm scope and cost first.

## Common jobs
- Leads/lists: `create_lead`, `bulk_create_leads`, `create_lead_list`, `list_leads`, `search_lead_pool`, `build_lead_pool_list`
- Sequences/campaigns: `create_email_sequence`, `create_campaign`, `enroll_leads`, `update_campaign_status`
- Inbox: `list_conversations`, `send_conversation_reply`
- Strategy context: `list_icps`, `list_products`

## Handoffs
When working inside a multi-agent crew, follow the ACA crew handoff skill and keep ACA as the system of record for lead state.
