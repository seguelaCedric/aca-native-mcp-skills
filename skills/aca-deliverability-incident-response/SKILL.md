---
name: aca-deliverability-incident-response
description: "Triage ACA email deliverability incidents. Use when the user reports bounces, spam placement, failed sends, reputation drops, disconnected mailboxes, throttling, or campaigns and sequences that suddenly stopped sending."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA deliverability incident response

Diagnose a sending incident, classify the likely cause, and propose the smallest safe intervention. The connector can show workspace counts, sequences, campaigns and replies; it cannot read mailbox health, send logs or bounce rates, and it cannot pause anything. Those happen in the ACA app.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Start read-only. Never invent bounce rates, health scores, or send counts. Use only what tools return or what the user pastes from the app.
- Pausing a sequence or campaign, lowering limits, and reconnecting mailboxes happen in the ACA app. Give the exact page and say what to click; never say it was done.
- Preserve evidence: name the sequence, campaign, mailbox or domain, and the symptom, with the time it started.
- Do not recommend aggressive retries or volume increases while an incident is open.
- The connection is bound to one workspace. If the incident is in a different workspace, the user switches their active workspace in ACA and reconnects.

## Workflow

### 1. Read what the connector can see

- `get_started`: mailbox count and connected LinkedIn account count. Zero mailboxes while sequences exist is itself a finding (disconnected or removed mailboxes).
- `list_sequences`, then `get_sequence` for the affected sequence: status, steps, spacing, and any settings it returns.
- `list_campaigns`, then `get_campaign` and `get_campaign_metrics` for affected campaigns: status and the metrics returned.
- `search_conversations` with `has_inbound_message: true`, then `get_conversation` on recent threads, to look for indirect signals: mailer-daemon bounces, "wrong person" or "unsubscribe" replies, spam complaints, or auto-replies. This is a sample, not a rate.

If `get_started` is not available, use `get_workspace` plus the `list_*` tools above.

### 2. Get the numbers from the app

Ask the user to open `/email/analytics` and `/email/mailboxes` and paste or describe:

- Bounce rate and spam complaint rate for the last 7 days, per mailbox or domain if shown
- Which mailboxes show as disconnected, paused, or flagged
- Daily send volume per mailbox before and after the incident
- When the change started and what changed around then (new list, new copy, new domain, volume increase)

If the user cannot get them, continue with what is known and mark the rest as unknown.

### 3. Classify the incident

Pick the most likely cause and list the evidence for it:

- **Mailbox disconnected**: mailbox shows disconnected in `/email/mailboxes`, or mailbox count dropped. Sends stop rather than bounce.
- **Reputation or warmup issue**: new domain or mailbox, rising spam placement, opens collapsing across all sequences at once.
- **Bounce spike**: hard bounces above 2% (above 5% is severe). Usually list quality or unverified emails.
- **Bad list quality**: bounces concentrated in one lead list or source, many role or catch-all addresses.
- **Copy or content issue**: one sequence affected while others on the same mailboxes are fine; spammy wording, links, images or attachments.
- **Volume or rate issue**: per-mailbox volume ramped quickly, or above roughly 30 to 50 cold emails per mailbox per day.
- **DNS or authentication issue**: SPF, DKIM or DMARC missing or broken after a DNS change. Check with a public DNS lookup if your tools allow it, or ask the user to paste the records.
- **Processor or campaign stalled**: nothing sends, no bounces, mailboxes connected. Sequence or campaign may be paused, out of leads, or outside its send window.

Severity: **high** if complaints are above 0.3%, hard bounces above 5%, or a domain is blocklisted; **medium** if bounces are 2 to 5% or one mailbox is affected; **low** if it is a single sequence with a clear copy or list cause.

### 4. Recommend actions in order

1. Pause the affected sequence at `/email/sequences` or campaign at `/campaigns/{id}` (ask first; the user does it in the app).
2. Reduce per-mailbox daily volume at `/email/mailboxes`.
3. Clean the list: route to `aca-lead-quality`.
4. Rewrite risky copy: route to `aca-copy-spam-checker`.
5. Reconnect or replace the sender at `/email/mailboxes` or `/accounts`.
6. Split traffic across more mailboxes or domains once the cause is fixed, ramping slowly.

### 5. Record the incident

Write the incident note in chat using the output format. The user can save it at `/assets?tab=strategies` for the weekly review.

## Output format

```text
Incident: {summary}
Severity: {low / medium / high}
Likely cause: {cause}
Evidence:
- From ACA: {sequence/campaign status, counts, reply samples}
- From the user: {pasted bounce/complaint rates, mailbox states}
- Unknown: {what we could not see}
Recommended action: {action} → {app page}
Approval needed: {yes/no}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the incident evidence when continuing into another ACA skill.

**Upstream**
- Called by `aca-pipeline-status`, `aca-weekly-rhythm`, `aca-deliverability-test`, or user-reported failures.

**Auto-continue conditions**
- Sender issue: continue to `aca-sender-health`.
- Copy issue: continue to `aca-copy-spam-checker`.
- List issue: continue to `aca-lead-quality`.
- Reply quality issue: continue to `aca-positive-reply-scoring`.

**Stop before chaining when**
- The fix is a pause, limit change, or reconnect. Those happen in the ACA app; give the link and wait.

**Downstream skills**
- `aca-sender-health`: check senders and mailboxes.
- `aca-copy-spam-checker`: fix risky copy.
- `aca-lead-quality`: clean bad lists.
- `aca-positive-reply-scoring`: separate deliverability from market response.
- `aca-weekly-rhythm`: record incident follow-up.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, sequence_id, campaign_id, lead_list_id, affected mailboxes/domains, evidence, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_sequences`, `get_sequence`
- `list_campaigns`, `get_campaign`, `get_campaign_metrics`
- `search_conversations`, `get_conversation`

## ACA app pages

- Bounce and complaint rates: `https://www.automatedclientacquisition.com/email/analytics`
- Mailbox status, limits, warmup, reconnect: `https://www.automatedclientacquisition.com/email/mailboxes`
- Pause or edit sequences: `https://www.automatedclientacquisition.com/email/sequences`
- Pause or edit campaigns: `https://www.automatedclientacquisition.com/campaigns/{id}`
- LinkedIn and other senders: `https://www.automatedclientacquisition.com/accounts`
- Save the incident note: `https://www.automatedclientacquisition.com/assets?tab=strategies`
