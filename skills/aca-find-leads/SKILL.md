---
name: aca-find-leads
description: Plan and build a target list of leads in ACA. Use when the user says "find leads", "build a list of [role] in [industry]", "import [N] [persona]", "search LinkedIn for [criteria]", "populate the audience for [campaign]", or asks to source prospects. Turns a vague audience into precise search criteria, sends the user to the right ACA sourcing page, then picks up and verifies the resulting list.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# Find leads in ACA

ACA stores prospects as contacts grouped into lead lists. This skill turns a brief into a campaign-ready lead list. The search itself runs in the ACA app; this skill does the targeting work, then checks what landed.

## Rules

- Use the ACA connector only. Never ask for LinkedIn, Apify, Prospeo, or other provider API keys; ACA owns those integrations.
- Never invent people, emails, companies, or counts. Prospects come from ACA searches the user runs, or from data the user pastes.
- The connector cannot search ACA's lead database or run LinkedIn imports. Define the criteria in chat, then send the user to `/list-building` (database search) or `/leads/import` (LinkedIn search URL or CSV).
- Ask before any write: creating a list, adding contacts, or adding pasted people.
- If a brief is too broad, narrow by industry or SIC category, keyword, geography, company size, seniority, email status, or LinkedIn presence.
- Mention a paid plan only if a tool result includes `plan.upgrade` or `plan_note`.

## Workflow

### 1. Read the workspace

Call `get_started` to see counts (contacts, lead lists, ICPs) and next steps. If it is not available, call `get_workspace` and `list_lead_lists`.

Check whether a suitable list already exists with `list_lead_lists`, and whether matching contacts are already in ACA with `search_contacts`. Reuse before sourcing.

### 2. Clarify the audience

If the brief is vague, ask one short question. Extract:

- Buyer role and seniority
- Industry or SIC category
- Geography
- Company size
- Desired count
- Required channels (email, LinkedIn, phone)
- Disqualifiers

If the user references a saved ICP, ask them to paste its key traits; `get_started` only tells you whether ICPs exist.

### 3. Write the search spec

Produce a precise spec the user can enter in ACA:

```text
Search spec: {list name, e.g. "US HVAC Owners - May 2026"}
Where: /list-building (database) | /leads/import (LinkedIn)
Roles / seniority: {titles, seniority levels}
Industry: {SIC codes or keywords}
Geography: {country / state / city}
Company size: {min-max employees}
Channel requirements: {has email, email status, has LinkedIn, has phone}
Exclude: {titles, industries, keywords}
Target count: {n}
```

Pick the source:

- **Database search at `/list-building`** first. It is the fastest route for most B2B and local briefs.
- **LinkedIn import at `/leads/import`** when the database is thin, the user wants LinkedIn-first outreach, or the brief depends on LinkedIn-only filters. Describe the LinkedIn or Sales Navigator search to build (keywords, title, geography, industry, company headcount), and remind the user to check for an already running import before starting another.
- **CSV at `/leads/import`** when the user has a file.

If the user pastes people directly in chat (names, companies, emails, LinkedIn URLs), confirm the count and fields, then add them with `bulk_create_contacts` (100 per call) after approval. Never fill in missing fields yourself.

### 4. Pick up the results

When the user says the build or import is done, call `list_lead_lists` to find the new list, then `get_lead_list` to confirm size and sample rows. If contacts were imported without a list, find them with `search_contacts`, then offer to `create_lead_list` and `add_contacts_to_list`.

Compare the sample against the spec. If titles, geography, or size drift, tighten the spec and send the user back to the same page.

### 5. Hand off

If the list needs grading or cleanup, route to `aca-lead-quality`. If it is already clean, route to `aca-launch-outreach`.

## Output format

```text
Lead list: {list_name}
List ID: {list_id}
Source: {ACA database search / LinkedIn import / CSV / pasted}
Contacts: {count from get_lead_list}
Sample:
- {name} - {title}, {company}

Spec fit: {matches / drift on ...}
Next: {aca-lead-quality or aca-launch-outreach}
```

Before the list exists, output the search spec and the page link instead, and stop.

## Skill chaining

Preserve the workspace, relevant IDs, the search spec, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-kickoff`, `aca-campaign-strategy`, `aca-auto-research`, or any sourcing-specific skill.

**Auto-continue conditions**
- Local vertical or geography brief: continue to `aca-local-business-leads` if not already there.
- Seed customer or lookalike brief: continue to `aca-lookalike-leads` if not already there.
- Domain or account list brief: continue to `aca-domain-list-builder` if not already there.
- Competitor or category brief: continue to `aca-competitor-engagers` if not already there.
- List exists in ACA: continue to `aca-lead-quality`.

**Stop before chaining when**
- The search or import still has to run in the ACA app.
- Creating lists or adding contacts the user has not approved.

**Downstream skills**
- `aca-local-business-leads` - geo and vertical local list.
- `aca-lookalike-leads` - lookalike audience.
- `aca-domain-list-builder` - account or domain based list.
- `aca-competitor-engagers` - competitor or category audience.
- `aca-lead-quality` - grade and segment the resulting list.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, search spec, lead_list_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `search_contacts`, `bulk_create_contacts`
- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`

## ACA app pages

- Database search: `https://www.automatedclientacquisition.com/list-building`
- LinkedIn or CSV import: `https://www.automatedclientacquisition.com/leads/import`
- Lead lists: `https://www.automatedclientacquisition.com/leads/lists`
