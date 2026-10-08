---
name: aca-sender-health
description: "Check ACA sender account and mailbox health. Use when the user asks about connected senders, LinkedIn capacity, mailbox status, warmup, reputation, daily budget, or why outreach is not sending."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA sender health

Check sender readiness across email and LinkedIn. The connector reports how many mailboxes and LinkedIn accounts are connected, and which campaigns and sequences are running; per-account status, warmup, reputation and limits are shown in the ACA app.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Read-only. Reconnecting, warmup and limit changes happen in the ACA app.
- Do not infer capacity, health or reputation beyond what tools return or the user pastes.
- Report missing senders separately from unhealthy senders.
- The connection is bound to one workspace. To check another, the user switches their active workspace in ACA and reconnects.

## Workflow

### 1. Read the workspace

- `get_started`: connected LinkedIn account count and mailbox count. Zero of either for a channel the user wants is a "missing" blocker.
- `list_campaigns`, then `get_campaign` and `get_campaign_metrics` for active campaigns: which ones are consuming LinkedIn capacity and whether sends are moving.
- `list_sequences`: active email sequences consuming mailbox capacity.

If `get_started` is not available, use `get_workspace` plus the `list_*` tools above.

### 2. Get per-account state from the app

Ask the user to check and paste:

- `/accounts`: each LinkedIn (and other channel) account, connected or disconnected, and any restriction or checkpoint warnings
- `/email/mailboxes`: each mailbox, connected or not, warmup status and age, daily limit
- `/email/analytics`: recent bounce and complaint rates per mailbox

### 3. Assess

- **Missing**: no connected account for a channel the plan depends on.
- **Unhealthy**: disconnected, restricted, flagged, warming under 2 weeks, or bounces above 2%.
- **LinkedIn capacity**: as a rule of thumb, about 15 to 25 connection requests and 50 to 100 messages per account per day; several active campaigns on one account share that budget.
- **Email capacity**: roughly 30 to 50 cold emails per warmed mailbox per day.
- **Stalled sends**: a campaign is active but `get_campaign_metrics` shows no movement; usually a disconnected sender, no leads left, or outside the send window.
- **Next campaign channel**: recommend the channel with healthy, unused capacity.

## Output format

```text
Sender health
Email mailboxes: {count from get_started}{, connected/total from the user if given}
LinkedIn accounts: {count from get_started}{, connected/total from the user if given}
Active campaigns: {n}  Active sequences: {n}

Blockers:
- {missing or unhealthy sender} → {app page}

Capacity notes:
- {note}

Unknown (check in the app):
- {item}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and sender findings when continuing into another ACA skill.

**Upstream**
- Called by `aca-launch-outreach`, `aca-email-sequence-manager`, `aca-auto-research`, or `aca-pipeline-status` when senders are a blocker.

**Auto-continue conditions**
- No or weak email infrastructure: continue to `aca-email-infra-readiness`.
- Email senders exist but risk is unclear: continue to `aca-email-deliverability-audit`.
- Senders are healthy and a campaign is waiting: continue to `aca-launch-outreach`.

**Stop before chaining when**
- A sender needs connecting, reconnecting or a limit change in the ACA app.

**Downstream skills**
- `aca-email-infra-readiness`: check infrastructure readiness.
- `aca-email-deliverability-audit`: audit cold-email risk.
- `aca-launch-outreach`: resume launch when senders are ready.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, mailbox count, LinkedIn account count, campaign_id, sequence_id, blockers, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_campaigns`, `get_campaign`, `get_campaign_metrics`
- `list_sequences`

## ACA app pages

- LinkedIn and other senders: `https://www.automatedclientacquisition.com/accounts`
- Mailboxes, warmup, limits: `https://www.automatedclientacquisition.com/email/mailboxes`
- Bounce and complaint rates: `https://www.automatedclientacquisition.com/email/analytics`
