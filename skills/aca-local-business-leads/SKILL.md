---
name: aca-local-business-leads
description: "Build local business lead lists in ACA by geography, vertical, SIC code, company keyword, size, and owner/manager seniority. Use for plumbers, roofers, med spas, dentists, contractors, agencies, restaurants, and other local niches."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA local business leads

Build local business lists using ACA lead-pool and import tools.

## Rules

- Always include geography.
- Prefer SIC codes for known local verticals when available.
- Confirm before importing or building large lists.
- Segment by channel readiness after the list is built.

## Workflow

1. Clarify vertical, city/state/country, owner role, desired count, and required channel.
2. Preview ACA lead pool with `search_lead_pool` using `sic_code_in`, `keyword`, geography, seniority, and size.
3. If quality is good, call `build_lead_pool_list` and poll `get_lead_pool_build_job`.
4. If the pool is thin, use `start_apify_leads_import` with local role/industry/location filters or `start_linkedin_import`.
5. Verify with `get_lead_list`.
6. Route to `aca-lead-quality`.

## Output format

```text
Local list: {vertical} in {geo}
Source: {source}
Preview count: {count}
Built list: {list_id}
Next: aca-lead-quality
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called directly for local SMB niches or delegated by `aca-find-leads`.

**Auto-continue conditions**
- After building or importing the list -> continue to `aca-lead-quality`.
- If the user has an offer but no strategy -> continue to `aca-campaign-strategy` after quality scoring.

**Stop before chaining when**
- Ask before imports or large lead-pool builds.

**Downstream skills**
- `aca-lead-quality` - score local list quality.
- `aca-campaign-strategy` - build the local-market campaign angle.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `search_lead_pool`, `build_lead_pool_list`, `get_lead_pool_build_job`
- `start_apify_leads_import`, `get_apify_leads_import_job`
- `search_linkedin_parameters`, `start_linkedin_import`, `get_linkedin_import_job`
- `get_lead_list`
