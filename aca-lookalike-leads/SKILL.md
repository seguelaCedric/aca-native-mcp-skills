---
name: aca-lookalike-leads
description: "Build lookalike lead lists in ACA from a winning customer, lead list, campaign, or contact segment. Use when the user asks for more leads like these, clones of a customer profile, or lookalike prospecting."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA lookalike leads

Use an existing winning segment to create a new prospect list.

## Rules

- Search ACA's lead pool before running paid/fresh imports.
- Confirm before materializing large lists or starting imports.
- State what traits are being copied and what traits are excluded.

## Workflow

1. Identify the seed source:
   - `get_lead_list`
   - `search_contacts_and_leads`
   - `get_campaign` / `list_campaign_leads`
2. Extract shared traits: role, seniority, industry, geography, size, keywords, channel availability, score, and tags.
3. Build a filter and preview with `search_lead_pool`.
4. If pool results fit, create the list with `build_lead_pool_list` and poll `get_lead_pool_build_job`.
5. If pool is thin, use `start_apify_leads_import` or `start_linkedin_import` after approval.
6. Verify with `get_lead_list` and route to `aca-lead-quality`.

## Output format

```text
Lookalike list plan:
Seed: {seed}
Copied traits: {traits}
Excluded traits: {exclusions}
Preview count: {count}
Next: {build/poll/quality}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called when `aca-find-leads`, `aca-positive-reply-scoring`, or `aca-weekly-rhythm` finds a winning segment.

**Auto-continue conditions**
- After creating a lookalike list -> continue to `aca-lead-quality`.
- If the lookalike is based on reply winners -> continue to `aca-experiment-design` after scoring.

**Stop before chaining when**
- Ask before large builds or fresh imports.

**Downstream skills**
- `aca-lead-quality` - validate lookalike quality.
- `aca-experiment-design` - test the lookalike against the control audience.
- `aca-launch-outreach` - launch when ready.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `get_lead_list`, `search_contacts_and_leads`, `get_contact`
- `get_campaign`, `list_campaign_leads`
- `search_lead_pool`, `build_lead_pool_list`, `get_lead_pool_build_job`
- `start_apify_leads_import`, `start_linkedin_import`
