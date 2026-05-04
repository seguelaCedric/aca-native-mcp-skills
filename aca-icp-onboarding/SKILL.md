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

## ACA tools used

- `list_products`, `create_product`, `update_product`
- `list_icps`, `create_icp`, `update_icp`
- `list_brand_voices`
- `set_product_icp_fit`
- `create_strategy_document`
