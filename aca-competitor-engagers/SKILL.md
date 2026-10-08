---
name: aca-competitor-engagers
description: "Source prospects around competitors, alternatives, and category keywords using ACA-native lead sources. Use when the user asks for competitor engagers, users of competitor tools, people talking about a competitor, or alternative-to campaigns."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA competitor engagers

Build an audience around competitor and category signals. This skill designs the targeting and the angle; the search or import runs in the ACA app.

## Rules

- Be explicit that the connector cannot scrape post engagers or run searches. Exact engager lists come from a LinkedIn import the user runs at `/leads/import`.
- Prefer category keywords, competitor company names, and role filters over vague interest signals.
- Never invent people, companies, or counts.
- Ask before creating lists or adding contacts.
- Avoid hostile competitor messaging. Position as an alternative, never as an attack.
- Mention a paid plan only if a tool result includes `plan.upgrade` or `plan_note`.

## Workflow

### 1. Read the workspace

Call `get_started` (fallback: `get_workspace`, `list_lead_lists`).

### 2. Clarify the competitive frame

Ask for competitor names, category terms, geography, target roles, and exclusion terms (the user's own customers, partners, competitor employees).

### 3. Pick the source path and write the spec

Offer the paths that fit, in order of precision:

- **Engagers on a competitor post or page**: the user brings the post or page URL to `/leads/import` and runs a LinkedIn import.
- **People at companies using the competitor**: a database search at `/list-building` with the competitor or tool name as a keyword plus role and size filters.
- **Category audience**: a database search or LinkedIn search import using category keywords ("CRM for agencies", "cold email tool") plus roles.

```text
Competitor audience spec: {list name}
Path: {engager import | tool users | category audience}
Where: /leads/import | /list-building
Competitors / category terms: {terms}
Roles: {titles}
Geography / size: {filters}
Exclude: {competitor employees, existing customers, partners}
Target count: {n}
```

### 4. Pick up and verify

When the user says the import or build is done, find the list with `list_lead_lists` and check it with `get_lead_list`. Use `search_contacts` to spot competitor employees or existing customers that slipped in, and flag them for exclusion.

### 5. Recommend the angle

Draft a respectful "alternative to" angle in chat: what the competitor does well, the gap the user fills, and a low-friction ask. Then route to `aca-lead-quality`, followed by `aca-campaign-strategy`.

## Output format

```text
Competitor audience:
Competitors/categories: {terms}
Source path: {engager import / tool users / category audience}
Build at: {app page}
List: {list_id, count | pending}
Recommended angle: {angle}
Next: {skill}
```

## Skill chaining

Preserve the workspace, the audience spec, the angle, relevant IDs, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-find-leads` or campaign planning for competitor or category audiences.

**Auto-continue conditions**
- Audience list exists in ACA: continue to `aca-lead-quality`.
- After quality scoring: continue to `aca-campaign-strategy` for a respectful alternative angle.

**Stop before chaining when**
- The import or build still has to run in the ACA app.
- Copy drifts toward hostile competitor messaging.

**Downstream skills**
- `aca-lead-quality` - clean the competitor or category audience.
- `aca-campaign-strategy` - build the alternative-to campaign.
- `aca-campaign-copywriting` - write non-hostile copy.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, audience spec, angle, lead_list_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`, `get_lead_list`
- `search_contacts`

## ACA app pages

- LinkedIn import (post engagers, searches): `https://www.automatedclientacquisition.com/leads/import`
- Database search: `https://www.automatedclientacquisition.com/list-building`
