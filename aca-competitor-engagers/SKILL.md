---
name: aca-competitor-engagers
description: "Source prospects around competitors, alternatives, and category keywords using ACA-native lead sources. Use when the user asks for competitor engagers, users of competitor tools, people talking about a competitor, or alternative-to campaigns."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA competitor engagers

Build an audience around competitor signals without requiring separate scraping credentials in the skill.

## Rules

- Be explicit when exact post-engager scraping is unavailable through the current ACA MCP toolset.
- Prefer category keywords, competitor company names, role filters, and LinkedIn imports.
- Confirm before fresh imports.
- Avoid hostile competitor messaging.

## Workflow

1. Clarify competitor names, category terms, geography, target roles, and exclusion terms.
2. Search ACA lead pool with competitor/category `keyword` and relevant filters.
3. If needed, use:
   - `search_linkedin_parameters`
   - `build_linkedin_search_url`
   - `start_linkedin_import`
   - `start_apify_leads_import`
4. Create or verify the list.
5. Route to `aca-campaign-strategy` for a respectful "alternative to" angle.

## Output format

```text
Competitor audience:
Competitors/categories: {terms}
Source path: {lead_pool/linkedin/apify}
Preview: {count}
List: {list_id}
Recommended angle: {angle}
```

## ACA tools used

- `search_lead_pool`, `build_lead_pool_list`, `get_lead_pool_build_job`
- `search_linkedin_parameters`, `build_linkedin_search_url`, `start_linkedin_import`, `get_linkedin_import_job`
- `start_apify_leads_import`, `get_apify_leads_import_job`
- `get_lead_list`
