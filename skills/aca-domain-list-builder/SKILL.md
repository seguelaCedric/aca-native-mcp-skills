---
name: aca-domain-list-builder
description: "Build ACA account and contact lists from company domains, company keywords, or account constraints. Use when the user has a target account list, company keyword list, domain list, or wants contacts at specific companies."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA domain list builder

Turn a target account list into a usable lead list: first by collecting contacts already in ACA, then by sending the user to source the gaps.

## Rules

- If the user provides domains, never invent contacts at those domains.
- Search existing ACA contacts first, then source what is missing.
- The connector cannot search ACA's lead database or run imports. Write the spec for the missing accounts and send the user to `/list-building` or `/leads/import`.
- Ask before creating lists or adding contacts.
- Keep source notes so the list's origin is clear (list name and description).
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.

## Workflow

### 1. Read the workspace

Call `get_started` (fallback: `get_workspace`, `list_lead_lists`).

### 2. Parse the account source

Normalize the input into a clean table: domain, company name, and any constraints given (industry, size, geography), plus the target roles per account. Strip `www.`, protocols, and paths from domains, and dedupe.

### 3. Match existing contacts

For each account, call `search_contacts` by company name or domain. Record per account: contacts found, and whether they match the target roles. Use `get_contact` when the role or channel is unclear.

Split accounts into **covered** (at least one target-role contact) and **gaps** (none).

### 4. Build the destination list

Propose a list name and description that records the source (for example "Q3 target accounts - from Sales domain list"). After approval, `create_lead_list` and `add_contacts_to_list` with the matching contacts.

### 5. Source the gaps

For gap accounts, write a spec:

```text
Account sourcing spec: {list name}
Where: /list-building (database) | /leads/import (LinkedIn or CSV)
Companies / domains: {gap accounts}
Roles: {titles, seniority}
Contacts per account: {n}
Exclude: {roles, already-covered accounts}
```

If the user later pastes contacts for these accounts, confirm and add them with `bulk_create_contacts` (100 per call), then `add_contacts_to_list`.

### 6. Verify

Check the final list with `get_lead_list` and route to `aca-lead-quality`.

## Output format

```text
Domain/account list:
Input accounts: {n}
Covered by existing contacts: {n} ({contacts} contacts)
Gaps to source: {n} -> {app page}
List: {list_id, count}
Next: aca-lead-quality
```

## Skill chaining

Preserve the workspace, the account table, relevant IDs, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue automatically; otherwise end with the handoff block.

**Upstream**
- Called when `aca-find-leads` detects account or domain constraints, or the user provides company or domain lists.

**Auto-continue conditions**
- List exists in ACA: continue to `aca-lead-quality`.
- Contacts are missing channel data: continue to `aca-launch-outreach`, noting that email finding or enrichment steps are set up in the campaign at `/campaigns/{id}`.

**Stop before chaining when**
- Gap accounts still have to be sourced in the ACA app.
- Creating lists or adding contacts the user has not approved.

**Downstream skills**
- `aca-lead-quality` - grade account and contact fit.
- `aca-campaign-strategy` - create account-based messaging.
- `aca-launch-outreach` - launch once sender and copy are ready.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, account table, gap accounts, lead_list_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `search_contacts`, `get_contact`, `bulk_create_contacts`
- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`

## ACA app pages

- Database search: `https://www.automatedclientacquisition.com/list-building`
- LinkedIn or CSV import: `https://www.automatedclientacquisition.com/leads/import`
