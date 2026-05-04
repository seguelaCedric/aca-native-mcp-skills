---
name: aca-lead-magnet-brainstorm
description: "Brainstorm and prepare ACA lead magnet campaigns. Use when the user wants lead magnet ideas, keyword monitoring, comment to DM campaigns, inbound capture, or a resource that attracts their ICP."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA lead magnet brainstorm

Plan lead magnets and optional keyword-monitoring campaigns that ACA can run through its lead magnet tools.

## Rules

- Use ACA MCP only.
- Do not activate a campaign without explicit approval.
- Tie every idea to an ICP pain and a follow-up conversation path.
- Prefer specific tools, calculators, teardown templates, checklists, and scripts over generic PDFs.

## Workflow

1. Gather context with `list_products`, `list_icps`, `list_brand_voices`, `list_agent_profiles`, and `list_knowledge_documents`.
2. Brainstorm 10 lead magnet concepts. For each include hook, promise, format, keyword trigger, and likely qualification signal.
3. Pick the top 3 by buyer intent, ease to produce, and follow-up relevance.
4. If the user approves, create support assets:
   - `create_knowledge_document` for the resource or sales context
   - `create_agent_profile` if reply handling needs a dedicated persona
   - `create_lead_magnet_campaign` in draft
5. Save the plan with `create_strategy_document`.

## Output format

```text
Lead magnet concepts:
1. {name} - {promise} - {keyword triggers}
2. {name} - {promise} - {keyword triggers}
3. {name} - {promise} - {keyword triggers}

Recommended: {name}
Why: {reason}
Draft campaign: {campaign_id or not created}
```

## ACA tools used

- `list_products`, `list_icps`, `list_brand_voices`
- `list_agent_profiles`, `create_agent_profile`
- `list_knowledge_documents`, `create_knowledge_document`
- `create_lead_magnet_campaign`
- `create_strategy_document`
