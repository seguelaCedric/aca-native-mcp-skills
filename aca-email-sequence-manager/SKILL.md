---
name: aca-email-sequence-manager
description: "Manage ACA email sequences. Use when the user asks to create an email sequence, edit steps, enroll leads, pause or resume a sequence, inspect enrollments, or replace Smartlead-style sequence operations with ACA native email."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA email sequence manager

Operate ACA's native email sequence engine.

## Rules

- Do not activate or enroll live leads without approval.
- Use `list_email_mailboxes` before creating a sequence.
- Use HTML paragraphs for email bodies.
- Keep spacing conservative unless the user asks otherwise.

## Workflow

1. Inspect `list_email_sequences`, `list_email_mailboxes`, and `list_lead_lists`.
2. If editing, call `get_email_sequence`.
3. Create or update sequence steps:
   - Email
   - Delay
   - Condition
   - A/B test where appropriate
4. If enrolling, verify the list with `get_lead_list`, ensure leads exist with `create_lead` or `bulk_create_leads` when needed, then call `enroll_leads`.
5. Activate or pause with `toggle_email_sequence` after approval.
6. Inspect progress with `list_email_enrollments`.

## Output format

```text
Email sequence: {name}
Status: {status}
Steps: {n}
Mailboxes: {n}
Enrollments: {n}
Next action: {action}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-launch-outreach`, `aca-campaign-strategy`, or Smartlead-style sequence requests.

**Auto-continue conditions**
- No mailbox exists -> continue to `aca-sender-health`.
- Copy needs QA -> continue to `aca-copy-spam-checker`.
- Sequence is ready but deliverability is unknown -> continue to `aca-email-deliverability-audit`.
- Sequence is built and user wants campaign execution -> continue to `aca-launch-outreach`.

**Stop before chaining when**
- Ask before enrolling real leads or toggling a sequence active.

**Downstream skills**
- `aca-sender-health` - inspect mailbox readiness.
- `aca-copy-spam-checker` - QA sequence copy.
- `aca-email-deliverability-audit` - preflight sequence risk.
- `aca-launch-outreach` - connect the sequence to campaign execution.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_email_sequences`, `get_email_sequence`, `create_email_sequence`, `update_email_sequence`, `toggle_email_sequence`
- `list_email_mailboxes`
- `list_lead_lists`, `get_lead_list`
- `create_lead`, `bulk_create_leads`, `enroll_leads`, `list_email_enrollments`
