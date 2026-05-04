---
name: aca-personalization-pattern
description: "Apply ACA prompt-mode personalization patterns to outbound campaigns. Use when the user wants scalable personalization, dynamic campaign prompts, first-line personalization, AI-written DMs, or QA samples before launch."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA personalization pattern

Use ACA's campaign `analyze_contact` step and prompt-mode messages to personalize at scale.

## Rules

- Use `analyze_contact` before personalized copy when possible.
- Write prompt instructions that constrain length, tone, CTA, and prohibited claims.
- QA samples before activating.
- Do not rely on non-existent per-lead injection tools.

## Workflow

1. Inspect target campaign/list with `get_campaign`, `get_lead_list`, and sampled `get_contact` calls.
2. Identify fields available for personalization: role, company, industry, lead score, tags, LinkedIn URL, prior notes, and analysis data.
3. Draft prompt-mode instructions for each step:
   - Connection request
   - LinkedIn DM
   - Email
   - Follow-up
4. Generate 3-5 sample outputs manually from sampled contact data and review for hallucination risk.
5. If approved, update a draft/paused campaign with `update_campaign`.

## Output format

```text
Personalization pattern:
Data available: {fields}
Risk: {low/medium/high}

Step prompt:
{prompt}

Sample QA:
- {contact}: {sample}
```

## ACA tools used

- `get_campaign`, `update_campaign`
- `get_lead_list`, `get_contact`
- `create_strategy_document`
