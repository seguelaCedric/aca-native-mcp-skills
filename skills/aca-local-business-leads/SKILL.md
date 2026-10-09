---
name: aca-local-business-leads
description: "Build local business lead lists in ACA by geography, vertical, SIC code, company keyword, size, and owner/manager seniority. Use for plumbers, roofers, med spas, dentists, contractors, agencies, restaurants, and other local niches."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA local business leads

Define a tight local-niche audience, send the user to ACA to build it, then verify and segment what landed.

## Rules

- Always include geography.
- Prefer SIC codes for known local verticals; add keywords for niches SIC lumps together (for example "med spa" inside a broader health category).
- Never invent businesses, owners, emails, or counts.
- The connector cannot search ACA's lead database or run imports. Write the spec in chat, then send the user to `/list-building` or `/leads/import`.
- Ask before creating lists or adding contacts.
- Segment by channel readiness after the list is built.
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.

## Workflow

### 1. Read the workspace

Call `get_started` (fallback: `get_workspace`, `list_lead_lists`). Check `list_lead_lists` for an existing list in the same niche and geography.

### 2. Clarify the niche

Ask once for anything missing: vertical, city/state/country (or radius), owner or manager role, company size, desired count, and required channel (email, phone, LinkedIn). Local owners often have weak LinkedIn presence, so default to email or phone unless the user says otherwise.

### 3. Write the local spec

```text
Local spec: {vertical} in {geo}
Where: /list-building (database) | /leads/import (LinkedIn or CSV)
SIC codes / keywords: {codes, keywords}
Geography: {country, state, city}
Roles: {owner, founder, general manager, practice manager}
Company size: {employees range}
Channel requirements: {has email, email status, has phone}
Exclude: {franchises, chains, national brands, keywords}
Target count: {n}
```

Start at `/list-building`. If the database is thin for that niche or geography, suggest a LinkedIn search import or a CSV the user already has at `/leads/import`. If the user pastes businesses in chat, confirm the fields and add them with `bulk_create_contacts` (100 per call) after approval.

### 4. Verify and split by channel

When the user says the list is built, find it with `list_lead_lists` and check it with `get_lead_list`. Report how much of the sample has email, phone, and LinkedIn so the user can pick the channel. Then route to `aca-lead-quality`.

## Output format

```text
Local list: {vertical} in {geo}
Source: {database search / LinkedIn import / CSV / pasted}
Built list: {list_id, count | pending}
Channel readiness (sample): {email x/n, phone x/n, LinkedIn x/n}
Next: aca-lead-quality
```

## Skill chaining

Preserve the workspace, the local spec, relevant IDs, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue automatically; otherwise end with the handoff block.

**Upstream**
- Called directly for local SMB niches or delegated by `aca-find-leads`.

**Auto-continue conditions**
- List exists in ACA: continue to `aca-lead-quality`.
- User has an offer but no strategy: continue to `aca-campaign-strategy` after quality scoring.

**Stop before chaining when**
- The build or import still has to run in the ACA app.
- Creating lists or contacts the user has not approved.

**Downstream skills**
- `aca-lead-quality` - score local list quality.
- `aca-campaign-strategy` - build the local-market campaign angle.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, local spec, lead_list_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`, `get_lead_list`
- `bulk_create_contacts`

## ACA app pages

- Database search: `https://www.automatedclientacquisition.com/list-building`
- LinkedIn or CSV import: `https://www.automatedclientacquisition.com/leads/import`
