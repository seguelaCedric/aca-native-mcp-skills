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

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-launch-outreach`, `aca-email-sequence-manager`, `aca-auto-research`, or `aca-pipeline-status` when senders are a blocker.

**Auto-continue conditions**
- No/weak email infrastructure -> continue to `aca-email-infra-readiness`.
- Email senders exist but risk is unclear -> continue to `aca-email-deliverability-audit`.
- Senders are healthy and campaign is waiting -> continue to `aca-launch-outreach`.

**Stop before chaining when**
- Read-only; ask before any changes are made in downstream skills.

**Downstream skills**
- `aca-email-infra-readiness` - inspect infrastructure readiness.
- `aca-email-deliverability-audit` - audit cold-email risk.
- `aca-launch-outreach` - resume launch when senders are ready.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_sender_accounts`
- `list_email_mailboxes`
- `list_campaigns`, `get_campaign`
