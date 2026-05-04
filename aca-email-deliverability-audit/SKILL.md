---
name: aca-email-deliverability-audit
description: "Audit ACA cold email readiness before launch. Use when the user asks about deliverability, inbox placement, warmup, mailbox health, sending limits, bounce risk, or whether a sequence is safe to start."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA email deliverability audit

Review whether ACA email outreach is ready to send without unnecessary risk.

## Rules

- Read-only unless the user explicitly approves changes.
- Do not promise inbox placement. Report risk levels and concrete blockers.
- Treat disconnected mailboxes, high bounce risk lists, aggressive volume, and spammy copy as blockers.

## Workflow

1. Inspect `list_email_mailboxes`, `list_sender_accounts` with `channel: "email"`, `list_email_sequences`, and active email campaigns from `list_campaigns`.
2. For relevant sequences, call `get_email_sequence`.
3. Review:
   - Connected mailbox count
   - Warmup and reputation fields if returned
   - Daily limits and send windows
   - Step count and spacing
   - Tracking settings
   - Lead list quality and email status
   - Copy risk using `aca-copy-spam-checker`
4. Report blockers, warnings, and launch-safe defaults.

## Output format

```text
Deliverability audit: {pass / caution / blocked}

Blockers:
- {blocker}

Warnings:
- {warning}

Recommended limits:
- Daily new leads: {n}
- Gap: {minutes}
- Tracking: {recommendation}
```

## ACA tools used

- `list_email_mailboxes`
- `list_sender_accounts`
- `list_email_sequences`, `get_email_sequence`
- `list_campaigns`, `get_campaign`
- `get_lead_list`
