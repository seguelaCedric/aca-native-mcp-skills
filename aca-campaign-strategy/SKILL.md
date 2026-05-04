---
name: aca-campaign-strategy
description: "Design an ACA campaign strategy before copy or launch. Use when the user asks for campaign strategy, outbound angle, channel mix, offer framing, target list plan, or success metrics."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA campaign strategy

Turn product, ICP, and available channels into a practical outbound plan.

## Rules

- Start read-only.
- Strategy should route to concrete ACA actions: list, campaign, content, or sequence.
- Do not launch or mutate campaigns from this skill unless the user asks.
- Prefer one primary angle and one backup angle.

## Workflow

1. Inspect `list_products`, `list_icps`, `list_brand_voices`, `list_lead_lists`, `list_sender_accounts`, `list_email_mailboxes`, and `list_campaigns`.
2. Identify the campaign path:
   - LinkedIn-first
   - Email-first
   - Multi-channel
   - Lead magnet/inbound
   - Content-supported nurture
3. Define the audience, offer, pain, proof, CTA, sequence length, and suppression rules.
4. Define success metrics: reply rate, positive reply rate, booking rate, list quality, and sender health.
5. Save the plan with `create_strategy_document`.

## Output format

```text
Campaign strategy: {name}
Audience: {audience}
Primary angle: {angle}
Channel path: {path}
Sequence: {touches}
Metric: {primary_metric}
Needed before launch: {missing_items}
Next: {aca-find-leads / aca-campaign-copywriting / aca-launch-outreach}
```

## ACA tools used

- `list_products`, `list_icps`, `list_brand_voices`
- `list_lead_lists`, `list_sender_accounts`, `list_email_mailboxes`
- `list_campaigns`
- `create_strategy_document`
