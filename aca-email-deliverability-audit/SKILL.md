---
name: aca-email-deliverability-audit
description: "Audit ACA cold email readiness before launch. Use when the user asks about deliverability, inbox placement, warmup, mailbox health, sending limits, bounce risk, or whether a sequence is safe to start."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA email deliverability audit

Review whether ACA email outreach is ready to send without unnecessary risk. The connector shows sequences, campaigns, lists and the mailbox count; mailbox health, warmup state and bounce history live in the ACA app, so the audit combines both.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Read-only. Changes to sequences, limits or mailboxes happen in the ACA app; give the link.
- Do not promise inbox placement. Report risk levels and concrete blockers.
- Never invent health scores, warmup progress or bounce rates. Use what tools return or what the user pastes from the app, and mark the rest unknown.
- Treat zero or disconnected mailboxes, high bounce risk lists, aggressive volume, missing authentication, and spammy copy as blockers.
- The connection is bound to one workspace. To audit another, the user switches their active workspace in ACA and reconnects.

## Workflow

### 1. Read the workspace

- `get_started`: mailbox count, campaign counts.
- `list_sequences`, then `get_sequence` for the sequences about to launch: steps, spacing, and any limits, send window or tracking settings returned.
- `list_campaigns` and `get_campaign` for active campaigns that share senders.
- `get_lead_list` for the target list, plus `search_contacts` to sample contacts and their email fields.

If `get_started` is not available, use `get_workspace` plus the tools above.

### 2. Fill the gaps from the app

Ask the user for what the connector does not expose, from `/email/mailboxes` and `/email/analytics`:

- Connected vs total mailboxes, and how long each has been warming
- Current daily limit per mailbox
- Last 7 to 14 days of bounce and spam complaint rates, if any sending has happened
- Sending domains, so you can check SPF, DKIM and DMARC with a public DNS lookup if your tools allow it, or have the user paste the records

### 3. Review against these checks

- **Mailboxes**: at least one connected; ideally 2 to 3 per sending domain. Zero is a blocker.
- **Warmup**: new mailboxes warmed 2 to 3 weeks before cold sends. Under 2 weeks is a warning.
- **Volume**: roughly 30 to 50 cold emails per mailbox per day at most; start new mailboxes at 10 to 20 and ramp weekly.
- **Authentication**: SPF passes and includes the sending provider, DKIM signing on, DMARC published (`p=none` is fine to start). Missing SPF or DKIM is a blocker.
- **Sequence shape**: 3 to 5 steps, at least 2 to 3 business days between steps, a send window in recipients' business hours.
- **Tracking**: plain text and no open tracking for first sends on new domains; at most one link.
- **List quality**: verified emails, few role or catch-all addresses. Unknown verification status is a warning; route to `aca-lead-quality`.
- **Copy risk**: run through `aca-copy-spam-checker`.
- **History**: hard bounces above 2% or complaints above 0.1% in recent sending is a warning; above 5% bounces or 0.3% complaints is a blocker.

### 4. Report

Give a verdict, blockers, warnings, and launch-safe defaults, each pointing to the app page where it is fixed.

## Output format

```text
Deliverability audit: {pass / caution / blocked}

From ACA: {mailboxes count, sequences reviewed, list reviewed}
From the user: {pasted rates, mailbox states, DNS records}
Unknown: {items}

Blockers:
- {blocker} → {app page}

Warnings:
- {warning}

Recommended limits:
- Daily new leads per mailbox: {n}
- Gap between steps: {days}
- Tracking: {recommendation}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and audit findings when continuing into another ACA skill.

**Upstream**
- Called by `aca-launch-outreach`, `aca-sender-health`, `aca-email-sequence-manager`, or incident workflows.

**Auto-continue conditions**
- Infrastructure is not ready: continue to `aca-email-infra-readiness`.
- Copy risk exists: continue to `aca-copy-spam-checker`.
- A controlled test is needed: continue to `aca-deliverability-test`.
- Audit passes and a campaign is queued: continue to `aca-launch-outreach`.

**Stop before chaining when**
- The fix is a sequence, limit or mailbox change in the ACA app.

**Downstream skills**
- `aca-email-infra-readiness`: fix readiness gaps.
- `aca-copy-spam-checker`: reduce copy risk.
- `aca-deliverability-test`: run a small preflight.
- `aca-launch-outreach`: launch after passing.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, sequence_id, campaign_id, lead_list_id, sending domains, verdict, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_sequences`, `get_sequence`
- `list_campaigns`, `get_campaign`
- `get_lead_list`, `search_contacts`

## ACA app pages

- Mailbox status, limits, warmup: `https://www.automatedclientacquisition.com/email/mailboxes`
- Bounce and complaint rates: `https://www.automatedclientacquisition.com/email/analytics`
- Sequence settings: `https://www.automatedclientacquisition.com/email/sequences`
