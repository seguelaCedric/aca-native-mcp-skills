---
name: aca-copy-spam-checker
description: "Review ACA email, LinkedIn, and campaign copy for spam risk, weak claims, fake personalization, compliance issues, and formatting problems. Use before launch or when deliverability is questionable."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token when reviewing existing ACA assets.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA copy spam checker

Review copy before it goes into campaigns or email sequences.

## Rules

- Be concrete. Point to exact phrases and safer replacements.
- Flag unverifiable claims, fake familiarity, urgency tricks, excessive links, image-heavy emails, and spammy formatting.
- For LinkedIn, also flag pitch-heavy connection requests and long first DMs.
- Do not rewrite unless the user asks or the copy is clearly risky.

## Workflow

1. If copy is pasted by the user, review it directly.
2. If copy lives in ACA, inspect `list_campaigns` / `get_campaign` or `list_email_sequences` / `get_email_sequence`.
3. Grade the copy:
   - Deliverability risk
   - Human credibility
   - Personalization quality
   - CTA clarity
   - Channel fit
4. Provide replacements for risky phrases.
5. If the user approves, apply to draft/paused assets with `update_campaign` or `update_email_sequence`.

## Output format

```text
Copy risk: {low/medium/high}

Issues:
- "{phrase}" - {reason} - replace with "{replacement}"

Keep:
- {strong element}

Recommended rewrite:
{copy}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by any skill that creates or changes outbound copy.

**Auto-continue conditions**
- Copy is high risk -> continue to `aca-campaign-copywriting` for rewrite.
- Copy needs variants -> continue to `aca-copy-variants`.
- Copy passes and launch prerequisites exist -> continue to `aca-launch-outreach`.

**Stop before chaining when**
- Ask before applying rewrites.

**Downstream skills**
- `aca-campaign-copywriting` - rewrite weak/risky copy.
- `aca-copy-variants` - create safer variants.
- `aca-launch-outreach` - use approved copy in campaign.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_campaigns`, `get_campaign`, `update_campaign`
- `list_email_sequences`, `get_email_sequence`, `update_email_sequence`
