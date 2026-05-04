---
name: aca-domain-list-builder
description: "Build ACA account and contact lists from company domains, company keywords, or account constraints. Use when the user has a target account list, company keyword list, domain list, or wants contacts at specific companies."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA domain list builder

Turn account constraints into a usable lead list.

## Rules

- If the user provides domains, do not invent contacts at those domains.
- Use existing CRM search first, then ACA import/search tools.
- Confirm before fresh imports.
- Keep source notes so list origin is clear.

## Workflow

1. Parse the source: domains, company names, company keywords, industries, size, roles, and geography.
2. Search existing contacts with `search_contacts_and_leads`.
3. Search lead pool with `search_lead_pool` using company keywords and account constraints.
4. If needed, use `start_apify_leads_import` with company keywords, role filters, and size/geography filters.
5. Create a destination list with `create_lead_list` and add existing contacts with `add_contacts_to_list`, or use the import job's list.
6. Verify with `get_lead_list` and route to `aca-lead-quality`.

## Output format

```text
Domain/account list:
Input accounts: {n}
Existing contacts found: {n}
New import needed: {yes/no}
List: {list_id}
Next: aca-lead-quality
```

## ACA tools used

- `search_contacts_and_leads`
- `search_lead_pool`, `build_lead_pool_list`, `get_lead_pool_build_job`
- `start_apify_leads_import`, `get_apify_leads_import_job`
- `create_lead_list`, `add_contacts_to_list`, `get_lead_list`
