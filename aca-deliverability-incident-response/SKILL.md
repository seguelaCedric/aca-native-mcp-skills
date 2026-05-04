---
name: aca-deliverability-incident-response
description: "Triage ACA email deliverability incidents. Use when the user reports bounces, spam placement, failed sends, reputation drops, disconnected mailboxes, throttling, or campaigns that suddenly stopped sending."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. Mutations require approval.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA deliverability incident response

Diagnose sending incidents and propose the smallest safe intervention.

## Rules

- Start read-only.
- Pause campaigns or sequences only after approval.
- Preserve evidence: name the campaign, sequence, mailbox, and symptom.
- Do not retry aggressively after failures.

## Workflow

1. Inspect `list_email_mailboxes`, `list_sender_accounts`, `list_email_sequences`, and `list_campaigns`.
2. For affected assets, call `get_email_sequence`, `list_email_enrollments`, `get_campaign`, and `list_campaign_leads` where relevant.
3. Classify the incident:
   - Mailbox disconnected
   - Reputation/warmup issue
   - Bounce spike
   - Bad list quality
   - Copy/content issue
   - Volume/rate issue
   - Processor/campaign stalled
4. Recommend actions in order: pause, reduce volume, clean list, rewrite copy, reconnect sender, or split traffic.
5. If approved, use `toggle_email_sequence`, `update_campaign_status`, or `update_email_sequence`.
6. Save the incident note with `create_strategy_document`.

## Output format

```text
Incident: {summary}
Severity: {low / medium / high}
Likely cause: {cause}
Evidence: {evidence}
Recommended action: {action}
Approval needed: {yes/no}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-pipeline-status`, `aca-weekly-rhythm`, `aca-deliverability-test`, or user-reported failures.

**Auto-continue conditions**
- Sender issue -> continue to `aca-sender-health`.
- Copy issue -> continue to `aca-copy-spam-checker`.
- List issue -> continue to `aca-lead-quality`.
- Reply quality issue -> continue to `aca-positive-reply-scoring`.

**Stop before chaining when**
- Ask before pausing campaigns/sequences or changing limits.

**Downstream skills**
- `aca-sender-health` - inspect accounts/mailboxes.
- `aca-copy-spam-checker` - fix risky copy.
- `aca-lead-quality` - clean bad lists.
- `aca-positive-reply-scoring` - separate deliverability from market response.
- `aca-weekly-rhythm` - record incident follow-up.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_email_mailboxes`, `list_sender_accounts`
- `list_email_sequences`, `get_email_sequence`, `list_email_enrollments`, `toggle_email_sequence`, `update_email_sequence`
- `list_campaigns`, `get_campaign`, `list_campaign_leads`, `update_campaign_status`
- `create_strategy_document`
