---
name: aca-positive-reply-scoring
description: "Review and score ACA campaign replies. Use when the user asks which replies are positive, who to follow up with, campaign reply quality, booking intent, objections, or what the replies teach us."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA positive reply scoring

Turn reply activity into follow-up priorities and campaign lessons.

## Rules

- Do not mark contacts as do-not-contact unless clearly requested.
- Separate positive intent, neutral questions, objections, referrals, out-of-office, and negative replies.
- Surface next action for each positive or ambiguous reply.

## Workflow

1. Inspect active campaigns with `list_campaigns`.
2. For selected campaigns, call `list_campaign_leads` and `get_campaign`.
3. Inspect email sequences with `list_email_sequences` and `list_email_enrollments` when email is involved.
4. For contacts needing detail, call `get_contact`.
5. Classify replies and add durable notes/tags after approval:
   - `aca_positive_reply`
   - `aca_objection`
   - `aca_referral`
   - `aca_not_now`
   - `aca_negative_reply`
6. Save summary learnings with `create_strategy_document`.

## Output format

```text
Reply scoring:
Positive: {n}
Questions: {n}
Objections: {n}
Not now: {n}
Negative: {n}

Top follow-ups:
- {contact}: {next_action}

Campaign lesson:
{lesson}
```

## ACA tools used

- `list_campaigns`, `get_campaign`, `list_campaign_leads`
- `list_email_sequences`, `list_email_enrollments`
- `get_contact`, `add_contact_tag`, `add_contact_note`
- `create_strategy_document`
