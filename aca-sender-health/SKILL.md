---
name: aca-sender-health
description: "Check ACA sender account and mailbox health. Use when the user asks about connected senders, LinkedIn capacity, mailbox status, warmup, reputation, daily budget, or why outreach is not sending."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA sender health

Inspect sender readiness across email, LinkedIn, and other ACA campaign channels.

## Rules

- Read-only.
- Do not infer capacity beyond fields returned by ACA MCP.
- Report missing senders separately from unhealthy senders.

## Workflow

1. Call `list_sender_accounts` for `linkedin`, `email`, `whatsapp`, `instagram`, and `telegram` as relevant.
2. Call `list_email_mailboxes`.
3. Call `list_campaigns` to see which senders are attached to live campaigns.
4. Report:
   - Connected accounts by channel
   - Disconnected or missing accounts
   - Mailbox warmup/reputation fields if available
   - Active campaigns that may consume capacity
   - Recommended channel for the next campaign

## Output format

```text
Sender health:
Email mailboxes: {n_connected}/{n_total}
LinkedIn senders: {n_connected}/{n_total}
Other channels: {summary}

Blockers:
- {blocker}

Capacity notes:
- {note}
```

## ACA tools used

- `list_sender_accounts`
- `list_email_mailboxes`
- `list_campaigns`, `get_campaign`
