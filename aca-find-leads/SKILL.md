---
name: aca-find-leads
description: Find and import a target list of leads into ACA. Use when the user says "find leads", "build a list of [role] in [industry]", "import [N] [persona]", "search LinkedIn for [criteria]", "populate the audience for [campaign]", or asks to source prospects. Searches ACA's native lead pool first, then optionally imports fresh LinkedIn results through ACA MCP.
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. Provider credentials and LinkedIn accounts are managed inside ACA.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# Find leads in ACA

ACA stores prospects in lead lists and CRM contacts. This skill builds a campaign-ready lead list using one ACA MCP connection.

## Rules

- Search ACA's native lead pool before importing from LinkedIn.
- Confirm before running a fresh LinkedIn import or a large lead-pool materialization.
- Do not ask for LinkedIn, Apify, Prospeo, or other provider API keys. ACA MCP owns those integrations.
- If a search is too broad, narrow by industry/SIC, keyword, geography, company size, seniority, email status, or LinkedIn presence.

## Workflow

### 1. Clarify the audience

If the brief is vague, ask one short question. Try to extract:

- Buyer role / seniority
- Industry or SIC category
- Geography
- Company size
- Desired count
- Required channels (email, LinkedIn, phone)

Use `list_icps` when the user references an existing ICP.

### 2. Search the ACA lead pool first

Call `search_lead_pool` with the narrowest safe filter:

- `sic_code_in` for known verticals
- `keyword` for role/company/industry text
- `state`, `country`, or `city`
- `employees_min` / `employees_max`
- `seniority_in`
- `email_status`
- `has_linkedin`
- `has_phone`

Review the count and sample rows. If the sample matches the brief and the count is reasonable, ask for approval to materialize the list.

### 3. Build a lead-pool list

Call `build_lead_pool_list` with the same filter and a descriptive `list_name`, for example:

```text
US HVAC Owners - May 2026
```

Poll `get_lead_pool_build_job` every 30 seconds until the job completes, fails, or the user asks you to stop.

### 4. Import from LinkedIn only when needed

Use LinkedIn import when the pool is thin, the user needs LinkedIn-first outreach, or the brief depends on LinkedIn filters.

1. Resolve unusual filters with `search_linkedin_parameters`.
2. Build the URL with `build_linkedin_search_url`.
3. Check `list_linkedin_import_jobs` to avoid duplicate running imports.
4. Ask for approval before spending import budget.
5. Call `start_linkedin_import` with the URL or structured parameters.
6. Poll `get_linkedin_import_job` every 30 seconds.

### 5. Verify and hand off

Use `get_lead_list` to confirm final list size and sample quality.

If the list needs cleanup, route to `aca-lead-quality`. If it is ready, route to `aca-launch-outreach`.

## Output format

```text
Built lead list: {list_name}
List ID: {list_id}
Source: {ACA lead pool / LinkedIn import}
Matched: {count}
Sample:
- {name} - {title}, {company}

Next: {aca-lead-quality or aca-launch-outreach}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-kickoff`, `aca-campaign-strategy`, `aca-auto-research`, or any sourcing-specific skill.

**Auto-continue conditions**
- Local vertical/geography brief -> continue to `aca-local-business-leads` if not already there.
- Seed/customer lookalike brief -> continue to `aca-lookalike-leads` if not already there.
- Domain/account list brief -> continue to `aca-domain-list-builder` if not already there.
- Competitor/category brief -> continue to `aca-competitor-engagers` if not already there.
- List is built -> continue to `aca-lead-quality`.

**Stop before chaining when**
- Ask before materializing large lead-pool lists or starting fresh imports.

**Downstream skills**
- `aca-local-business-leads` - geo/vertical local list.
- `aca-lookalike-leads` - lookalike audience.
- `aca-domain-list-builder` - account/domain-based list.
- `aca-competitor-engagers` - competitor/category audience.
- `aca-lead-quality` - grade and segment the resulting list.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_icps`
- `search_lead_pool`, `build_lead_pool_list`, `get_lead_pool_build_job`
- `search_linkedin_parameters`, `build_linkedin_search_url`
- `list_linkedin_import_jobs`, `start_linkedin_import`, `get_linkedin_import_job`
- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`
