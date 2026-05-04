---
name: aca-campaign-copywriting
description: "Write ACA outbound campaign copy for LinkedIn, email, WhatsApp, and multi-channel sequences. Use when the user asks for cold email copy, LinkedIn DMs, campaign prompts, follow-ups, or rewrite campaign messaging."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA campaign copywriting

Write usable campaign copy and prompt-mode instructions that fit ACA's campaign builder.

## Rules

- No fake familiarity, fake stats, hype, or unverifiable claims.
- Use short messages with one CTA.
- For scalable personalization, write ACA `message_mode: "prompt"` instructions instead of hardcoded per-lead messages.
- Do not update a live campaign without approval.

## Workflow

1. Inspect context with `list_products`, `list_icps`, `list_brand_voices`, `list_campaigns`, and `list_lead_lists`.
2. If rewriting an existing campaign, call `get_campaign`.
3. Draft:
   - Connection request
   - First DM
   - Email 1
   - Follow-up
   - Breakup or fallback message
4. Convert the copy into ACA campaign step prompts where personalization should vary by lead.
5. Run the output through `aca-copy-spam-checker`.
6. Save final copy with `create_strategy_document`, or update a draft/paused campaign with `update_campaign` after approval.

## Output format

```text
Campaign copy draft: {campaign_or_plan}

Connection request:
{copy}

Email 1:
Subject: {subject}
{body}

Prompt-mode instructions:
{prompt}

Recommended next: {action}
```

## ACA tools used

- `list_products`, `list_icps`, `list_brand_voices`
- `list_campaigns`, `get_campaign`, `update_campaign`
- `list_lead_lists`
- `create_strategy_document`
