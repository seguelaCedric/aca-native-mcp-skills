---
name: aca-icp-onboarding
description: "Turn a rough buyer or offer description into ACA product and ICP records. Use when the user says define my ICP, onboard this niche, set up targeting, create the buyer profile, or needs product ICP fit before campaigns."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA ICP onboarding

Create the minimum useful product and ICP context needed for lead sourcing, scoring, copywriting, and campaign personalization.

## Rules

- Use ACA MCP only.
- Do not over-model. The output should help campaigns launch.
- Confirm before creating or updating product/ICP records.
- Include negative filters and disqualifiers, not just ideal traits.

## Workflow

1. Inspect current setup with `list_products`, `list_icps`, and `list_brand_voices`.
2. Clarify missing details: offer, buyer role, industry, geography, company size, pain, desired outcome, objections, proof, and bad-fit criteria.
3. If needed, create or update:
   - `create_product`
   - `create_icp`
   - `set_product_icp_fit`
4. Save a working targeting note with `create_strategy_document`.
5. Route next:
   - Need an audience: `aca-find-leads`
   - Need positioning: `aca-campaign-strategy`
   - Ready to send: `aca-launch-outreach`

## Output format

```text
ICP onboarding complete.
Product: {product}
ICP: {icp}
Best-fit signals: {signals}
Disqualifiers: {disqualifiers}
Fit notes saved: {strategy_document_id}
Next: {skill}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Usually called by `aca-kickoff`, `aca-auto-research`, or `aca-campaign-strategy` when product/ICP context is missing.

**Auto-continue conditions**
- If the user asked to launch and ICP records are now ready -> continue to `aca-campaign-strategy`.
- If audience sourcing is the next blocker -> continue to `aca-find-leads`.
- If the offer needs an inbound asset -> continue to `aca-lead-magnet-brainstorm`.

**Stop before chaining when**
- Ask before creating or updating product/ICP records.

**Downstream skills**
- `aca-campaign-strategy` - turn the ICP into a campaign plan.
- `aca-find-leads` - source the ICP audience.
- `aca-lead-magnet-brainstorm` - create an offer/resource for the ICP.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_products`, `create_product`, `update_product`
- `list_icps`, `create_icp`, `update_icp`
- `list_brand_voices`
- `set_product_icp_fit`
- `create_strategy_document`
