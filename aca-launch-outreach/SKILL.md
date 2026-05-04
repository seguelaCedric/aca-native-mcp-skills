---
name: aca-launch-outreach
description: Build and launch a multi-channel outreach campaign in ACA. Use when the user says "launch a campaign", "start outreach", "send LinkedIn DMs to [list]", "email sequence for [audience]", "enroll leads", or asks to begin contacting a list. Uses ACA campaign prompt-mode steps, analyze_contact, sender accounts, and lead lists through one native ACA MCP connection.
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. The ACA org needs a lead list and at least one connected sender for the chosen channel.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# Launch outreach campaign in ACA

ACA campaigns can run LinkedIn, email, WhatsApp, Instagram, Telegram, and multi-channel sequences. This skill creates a campaign from a lead list and sender account, using ACA's built-in campaign steps for personalization and delivery.

## Rules

- Keep campaigns in `draft` unless the user explicitly says to launch/start/activate.
- Use ACA campaign prompt-mode steps for personalization. Do not reference non-existent per-lead injection tools.
- Prefer `analyze_contact` before personalized messages when the list has enough company/profile data.
- Confirm before activating a campaign, spending import budget, or contacting leads.
- Stop if no sender account exists for the chosen channel.

## Workflow

### 1. Confirm the brief

Restate:

- Lead list
- Channel path
- Goal
- Offer/product
- Tone/brand voice
- Number of touches

Ask one question if the launch would otherwise be ambiguous.

### 2. Verify prerequisites

Call:

- `list_lead_lists` and `get_lead_list`
- `list_products` and `list_icps` when the campaign should reference a specific offer
- `list_sender_accounts` filtered by chosen channel
- `list_email_mailboxes` for email-heavy campaigns
- `list_campaigns` to avoid name collisions

### 3. Build the sequence

Use the `steps` array on `create_campaign`. Default patterns:

**LinkedIn-only**

```json
[
  { "type": "analyze_contact", "product_id": "<product_id>", "continue_on_failure": true },
  {
    "type": "connection_request",
    "message_mode": "prompt",
    "prompt": "Write a short LinkedIn connection request under 250 characters. Sound like a peer. Mention one specific business reason this person is relevant. No pitch, no emojis."
  },
  { "type": "delay", "days": 3 },
  {
    "type": "if_connected",
    "branches": {
      "accepted": [
        {
          "type": "message",
          "message_mode": "prompt",
          "prompt": "Write a 2 sentence LinkedIn DM. Reference the contact's likely role or company context. Give one useful observation, then ask a low-pressure question. No pitch."
        }
      ],
      "not_accepted": [{ "type": "end" }]
    }
  }
]
```

**Email-only campaign**

```json
[
  { "type": "find_email", "provider": "auto", "skip_if_has_email": true, "continue_on_failure": true },
  { "type": "analyze_contact", "product_id": "<product_id>", "continue_on_failure": true },
  {
    "type": "email",
    "message_mode": "prompt",
    "subject": "quick question",
    "prompt": "Write a concise cold email in HTML paragraphs. Reference the contact's likely situation, connect it to the offer, and end with one soft question. No hype, no fake familiarity."
  },
  { "type": "delay", "days": 3 },
  {
    "type": "email",
    "message_mode": "prompt",
    "subject": "worth looking at?",
    "prompt": "Write a short follow-up with a different angle and one practical proof point. End with a yes/no question."
  }
]
```

**Multi-channel**

Start LinkedIn, wait for acceptance, then switch to email when available:

- `analyze_contact`
- `connection_request`
- `delay`
- `if_connected`
- `switch_channel`
- `email`
- `if_reply_received`
- `end`

### 4. Create the campaign

Call `create_campaign` with:

- `name`
- `description`
- `lead_list_id`
- `sender_account_ids`
- `campaign_type`
- `primary_channel`
- `steps`
- `stop_on_reply: true`

Keep the campaign in draft unless the user asked to launch.

### 5. Activate only with approval

If the user explicitly asked to start sending, call `update_campaign_status` with `status: "active"`.

Then call `get_campaign` to confirm status and lead summary.

## Output format

```text
Campaign created: {campaign_name}
Campaign ID: {campaign_id}
Status: {draft/active}
Channel path: {path}
Lead list: {list_name} ({lead_count} leads)
Senders: {sender_count}

First sends: {when_or_draft_note}
Track: {campaign_url_if_available}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-kickoff`, `aca-campaign-strategy`, `aca-campaign-copywriting`, `aca-lead-quality`, or `aca-email-sequence-manager`.

**Auto-continue conditions**
- No lead list -> continue to `aca-find-leads`.
- Lead list unscored -> continue to `aca-lead-quality`.
- Missing sender -> continue to `aca-sender-health`.
- Email channel selected and readiness unknown -> continue to `aca-email-deliverability-audit`.
- Copy missing or weak -> continue to `aca-campaign-copywriting`.
- Campaign created -> continue to `aca-pipeline-status`.

**Stop before chaining when**
- Ask before activating campaigns or contacting leads.

**Downstream skills**
- `aca-find-leads` - source missing audience.
- `aca-lead-quality` - clean list before launch.
- `aca-sender-health` - resolve sender blockers.
- `aca-email-deliverability-audit` - preflight email risk.
- `aca-campaign-copywriting` - create missing copy.
- `aca-pipeline-status` - confirm launch state.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_lead_lists`, `get_lead_list`
- `list_products`, `list_icps`, `list_brand_voices`
- `list_sender_accounts`, `list_email_mailboxes`
- `list_campaigns`, `create_campaign`, `get_campaign`, `update_campaign_status`
