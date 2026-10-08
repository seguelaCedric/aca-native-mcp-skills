---
name: aca-mcp-ops
description: >-
  Operating guide for agents using the ACA connector. Use when connecting to or
  operating ACA through MCP for contacts, lead lists, sequences, campaigns,
  replies, content, and lead magnets, or when unsure which ACA tool to call or
  what needs the ACA app.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA MCP ops

How an agent should operate Automated Client Acquisition through the ACA connector: what it can read and write, what needs the ACA app, and the safe defaults.

## The rule for bots

One agent, one job, narrow scope. Prefer deterministic tool calls for structured ACA work; use the model for judgment (copy, ICP, triage). Keep a human on anything irreversible. The connector already enforces this: writes create drafts, and sending, activation, enrollment and imports happen in the app.

## Connect

- URL: `https://mcp.automatedclientacquisition.com/mcp`
- Auth: OAuth. The client prompts the user to sign in to ACA on first use. Never ask for, paste or store API keys or tokens.
- One workspace per connection. There is no workspace switching through the connector. To work in another workspace, the user changes their active workspace in ACA and reconnects.

## Start every session

1. Call `get_started`. It returns the workspace, stage, counts (ICPs, products, contacts, lead lists, campaigns, active campaigns, connected LinkedIn accounts, mailboxes), plan, and up to three next steps.
2. If it is not available, call `get_workspace` and the relevant `list_*` tools.
3. Read before writing: check existing lists, campaigns and blueprints before creating near-duplicates.

## Connector tools by area

- **Workspace**: `get_started`, `get_workspace`, `list_connected_accounts` (LinkedIn and social account ids)
- **Contacts**: `search_contacts`, `get_contact`, `create_contact`, `bulk_create_contacts` (100 per call, user-supplied data only), `update_contact` (replaces the whole `tags` array, so read the contact first), `list_pipeline_stages` then `update_contact_stage`, `list_tags`
- **Lead lists**: `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`
- **Email sequences** (read-only): `list_sequences`, `get_sequence`
- **LinkedIn campaigns**: `list_campaigns`, `get_campaign`, `get_campaign_metrics`, `create_linkedin_campaign_draft` (needs a `lead_list_id`; created inactive with no steps)
- **Replies**: `search_conversations` (`has_inbound_message: true` for replies), `get_conversation`
- **Content**: `list_content_ideas`, `create_content_ideas` (25 per call), `list_blueprints`, `get_blueprint`, `create_blueprint` (inactive draft), `start_content_generation` (active blueprint only; billable, confirm first), `list_content_generation_jobs`
- **Lead magnets**: `list_lead_magnets`, `get_lead_magnet`, `create_lead_magnet_draft` (needs an `account_id` from `list_connected_accounts`; inactive)
- **AI reply agents**: `list_agent_profiles`, `create_agent_profile`

## What needs the ACA app

Do the thinking in chat, then give the exact page. Never say an app-only action happened.

- Offer, ICP, brand voice: `/assets?tab=products`, `/assets?tab=icps`, `/assets?tab=brands`; strategy notes at `/assets?tab=strategies`
- Finding new prospects: `/list-building` (database search) or `/leads/import` (LinkedIn, CSV)
- Editing or removing list members, deleting lists: `/leads/lists`
- Contact notes: `/contacts/{id}`
- Writing, enrolling, pausing email sequences: `/email/sequences`
- Campaign steps, settings, activation, pausing: `/campaigns/{id}`
- Sending a reply: `/inbox`
- LinkedIn and other senders: `/accounts`; mailboxes, warmup, limits: `/email/mailboxes`; deliverability: `/email/analytics`
- Editing and activating blueprints: `/blueprints/{id}`; autopilots and publishing: `/autopilots`, `/publish-queue`
- Editing and activating lead magnets: `/lead-magnets`
- Signals: `/signals`

App base URL: `https://www.automatedclientacquisition.com`

## Safe defaults

- Ask before any write, unless the user explicitly asked you to set it up.
- Campaigns, blueprints and lead magnets are created as inactive drafts. Do not tell the user anything is live.
- Batch caps: up to 100 contacts per `bulk_create_contacts` or `add_contacts_to_list` call, up to 25 ideas per `create_content_ideas` call. Split larger jobs and confirm the total first.
- Never invent people, emails, phone numbers, companies, metrics or results. Contacts come from the user or from ACA; report counts exactly as returned.
- Confirm cost before `start_content_generation`.
- Mention a paid plan only if a tool result includes `plan_note` or `plan.upgrade`.
- Tag the source or signal on contacts when recording pipeline work (read the contact first, then `update_contact` with the full tag set).

## Handoffs

In a multi-agent crew, follow `aca-crew-handoff` and keep ACA as the system of record for contact and campaign state. Pass the workspace, IDs and approval state, not copies of the data.

## ACA tools used

- `get_started`, `get_workspace`, `list_connected_accounts`
- `search_contacts`, `get_contact`, `create_contact`, `bulk_create_contacts`, `update_contact`, `list_pipeline_stages`, `update_contact_stage`, `list_tags`
- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`
- `list_sequences`, `get_sequence`
- `list_campaigns`, `get_campaign`, `get_campaign_metrics`, `create_linkedin_campaign_draft`
- `search_conversations`, `get_conversation`
- `list_content_ideas`, `create_content_ideas`, `list_blueprints`, `get_blueprint`, `create_blueprint`, `start_content_generation`, `list_content_generation_jobs`
- `list_lead_magnets`, `get_lead_magnet`, `create_lead_magnet_draft`
- `list_agent_profiles`, `create_agent_profile`

## ACA app pages

- Assets: `https://www.automatedclientacquisition.com/assets?tab=products`, `?tab=icps`, `?tab=brands`, `?tab=strategies`
- Prospects: `https://www.automatedclientacquisition.com/list-building`, `/leads/import`, `/leads/lists`
- Sequences and campaigns: `https://www.automatedclientacquisition.com/email/sequences`, `/campaigns/{id}`
- Inbox: `https://www.automatedclientacquisition.com/inbox`
- Senders: `https://www.automatedclientacquisition.com/accounts`, `/email/mailboxes`, `/email/analytics`
- Content: `https://www.automatedclientacquisition.com/blueprints/{id}`, `/autopilots`, `/publish-queue`, `/lead-magnets`
