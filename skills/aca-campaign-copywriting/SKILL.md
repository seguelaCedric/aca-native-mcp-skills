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

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Usually called by `aca-campaign-strategy`, `aca-launch-outreach`, or `aca-experiment-design`.

**Auto-continue conditions**
- After drafting copy -> continue to `aca-copy-spam-checker`.
- If scalable personalization is required -> continue to `aca-personalization-pattern`.
- If variants are requested -> continue to `aca-copy-variants`.
- If copy passes QA and campaign prerequisites exist -> continue to `aca-launch-outreach`.

**Stop before chaining when**
- Ask before updating draft/paused campaigns or sequences.

**Downstream skills**
- `aca-copy-spam-checker` - QA deliverability and credibility.
- `aca-personalization-pattern` - convert copy into prompt-mode personalization.
- `aca-copy-variants` - create controlled variants.
- `aca-launch-outreach` - build the campaign.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_products`, `list_icps`, `list_brand_voices`
- `list_campaigns`, `get_campaign`, `update_campaign`
- `list_lead_lists`
- `create_strategy_document`
