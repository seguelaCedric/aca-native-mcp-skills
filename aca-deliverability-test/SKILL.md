---
name: aca-deliverability-test
description: "Plan and run a controlled ACA email preflight test. Use before launching a new sequence, new mailbox, new domain, or high-volume campaign."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. Sending changes require approval.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA deliverability test

Create a low-risk preflight plan for email sending.

## Rules

- Do not send test traffic without approval.
- Keep tests small.
- Test infrastructure, copy, tracking, and enrollment separately where possible.

## Workflow

1. Inspect `list_email_mailboxes`, `list_email_sequences`, `list_sender_accounts`, and `list_lead_lists`.
2. Choose the asset to test: mailbox, sequence, campaign, or list.
3. Review copy with `aca-copy-spam-checker`.
4. Build a test plan:
   - Test list size
   - Mailboxes included
   - Daily cap
   - Send window
   - Pass/fail criteria
5. If approved, create or update a draft sequence with `create_email_sequence` or `update_email_sequence`, enroll test leads with `enroll_leads`, and activate with `toggle_email_sequence`.
6. Record the test plan with `create_strategy_document`.

## Output format

```text
Deliverability test plan:
Asset: {sequence/campaign/mailbox}
Sample size: {n}
Mailboxes: {mailboxes}
Pass criteria: {criteria}
Risk: {low/medium/high}
Approval needed before sending: yes
```

## ACA tools used

- `list_email_mailboxes`, `list_sender_accounts`
- `list_email_sequences`, `get_email_sequence`, `create_email_sequence`, `update_email_sequence`, `toggle_email_sequence`, `enroll_leads`
- `list_lead_lists`, `get_lead_list`
- `create_strategy_document`
