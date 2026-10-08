---
name: aca-email-infra-readiness
description: "Review ACA email infrastructure readiness. Use when the user asks about domain setup, BYO email infrastructure, mailbox provisioning, DNS readiness (SPF, DKIM, DMARC), warmup readiness, or whether email infra is ready for cold outreach."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA email infrastructure readiness

Review whether the email foundation (domains, DNS, mailboxes, warmup, capacity) is ready before sequences scale. The connector reports only the mailbox count; domains, DNS, warmup and mailbox state come from the user, public DNS, or the ACA app.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Be clear when a fix happens at the DNS provider or in the ACA app rather than through the connector.
- Never claim SPF, DKIM or DMARC status you have not seen. Use records the user pastes or a public DNS lookup you actually ran.
- Never invent warmup progress or health scores.
- Prefer a readiness checklist over speculative diagnosis.
- The connection is bound to one workspace. To review another, the user switches their active workspace in ACA and reconnects.

## Workflow

### 1. Read the workspace

- `get_started`: mailbox count and active campaign count.
- `list_sequences`: how many sequences exist or are active, which sets the capacity needed.
- `list_campaigns`: active campaigns that may share senders.

If `get_started` is not available, use `get_workspace` plus the `list_*` tools above.

### 2. Gather infrastructure details

Ask in one message for what the connector does not expose:

- Sending domains, and whether they are separate from the main company domain
- Mailbox provider (Google Workspace, Microsoft 365, BYO SMTP) and mailboxes per domain
- Mailbox ages and warmup start dates, as shown at `/email/mailboxes`
- Planned daily volume

### 3. Check DNS per sending domain

Run a public DNS lookup if your tools allow it; otherwise ask the user to paste the records.

- **MX**: present and pointing at the mailbox provider.
- **SPF**: exactly one `v=spf1` TXT record, includes the provider, ends in `~all` or `-all`, under 10 DNS lookups.
- **DKIM**: provider selector published and signing enabled in the provider admin.
- **DMARC**: `_dmarc` TXT record exists; `p=none` with a `rua` address is a fine start, move to `quarantine` once stable.
- **Custom tracking domain** (if tracking is used): CNAME set, HTTPS working.
- **Domain redirect**: sending domains redirect to the main website.

### 4. Check capacity and warmup

- Mailboxes: 2 to 3 per sending domain; do not put many mailboxes on one domain.
- Warmup: 2 to 3 weeks before cold sends; keep warmup running alongside cold sends.
- Capacity: roughly 30 to 50 cold emails per mailbox per day. Planned daily volume divided by that gives the mailboxes needed; if the count from `get_started` is short, say how many more are needed.
- New domains: register 2 to 4 weeks ahead of launch where possible.

### 5. Produce the checklist and route

Mark each item ready, caution, or not ready, and say where it gets fixed: the DNS provider, the mailbox provider, or `/email/mailboxes`.

## Output format

```text
Email infra readiness: {ready/caution/not ready}

Known from ACA:
- Mailboxes: {count from get_started}
- Sequences/campaigns needing capacity: {counts}

Checked (DNS / user-provided):
- {domain}: MX {ok/missing}, SPF {ok/issue}, DKIM {ok/issue}, DMARC {ok/issue}

Needs a check in the app or DNS:
- {item} → {where}

Capacity: {mailboxes needed} vs {mailboxes connected}
Next: {skill/action}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the domain checklist when continuing into another ACA skill.

**Upstream**
- Called by `aca-sender-health`, `aca-email-deliverability-audit`, or setup workflows.

**Auto-continue conditions**
- Mailboxes exist: continue to `aca-sender-health`.
- Infrastructure looks ready but cold-email risk is unknown: continue to `aca-email-deliverability-audit`.
- A small proof is needed: continue to `aca-deliverability-test`.

**Stop before chaining when**
- DNS, mailbox provider or ACA app actions are required. Tell the user exactly what to set and where.

**Downstream skills**
- `aca-sender-health`: check connected sender state.
- `aca-email-deliverability-audit`: audit sequence readiness.
- `aca-deliverability-test`: verify with a controlled preflight.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, sending domains, DNS status, mailbox count, capacity gap, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_sequences`
- `list_campaigns`

## ACA app pages

- Connect and manage mailboxes, warmup, limits: `https://www.automatedclientacquisition.com/email/mailboxes`
- Sending results once live: `https://www.automatedclientacquisition.com/email/analytics`
