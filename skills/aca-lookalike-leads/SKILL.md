---
name: aca-lookalike-leads
description: "Build lookalike lead lists in ACA from a winning customer, lead list, campaign, or contact segment. Use when the user asks for more leads like these, clones of a customer profile, or lookalike prospecting."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA lookalike leads

Use an existing winning segment in ACA to define a new prospect audience. The connector reads the seed; the search for new lookalikes runs in the ACA app.

## Rules

- Use the ACA connector only. Never invent people, companies, or counts.
- Derive traits only from data ACA returns or the user provides. State which traits are copied and which are excluded.
- The connector cannot search ACA's lead database or run imports. Turn the traits into a search spec, then send the user to `/list-building` or `/leads/import`.
- Ask before creating lists or adding contacts.
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.

## Workflow

### 1. Read the workspace

Call `get_started` (fallback: `get_workspace`, `list_lead_lists`, `list_campaigns`).

### 2. Identify the seed

- A lead list: `list_lead_lists`, then `get_lead_list`
- A set of contacts (customers, tagged winners, replied leads): `search_contacts`, then `get_contact` for detail on a sample
- A winning campaign: `list_campaigns`, `get_campaign`, and `get_campaign_metrics` to confirm it actually performed; then use the lead list it targets if the result shows one

Work from a sample of 20 to 50 seed contacts. If the seed is under 10 people, say the traits are directional.

### 3. Extract shared traits

Look for what most of the seed has in common:

- Role and seniority
- Industry and keywords
- Geography
- Company size
- Channel availability (email, LinkedIn)
- Tags and stage

Separate **copied traits** (shared by most of the seed) from **excluded traits** (noise, one-offs, or things the user wants to avoid, such as current customers or competitors).

### 4. Write the lookalike spec

```text
Lookalike spec: {list name}
Seed: {list or segment, n contacts}
Where: /list-building (database) | /leads/import (LinkedIn)
Copied traits: {roles, seniority, industry, geo, size, channel}
Excluded: {traits, existing customers, seed companies}
Target count: {n}
```

Send the user to `/list-building` first; use `/leads/import` with a LinkedIn search when the database is thin or the seed is LinkedIn-native. Remind them to exclude seed companies so the new list is net new.

### 5. Pick up and verify

When the user says the list is built, find it with `list_lead_lists` and check it with `get_lead_list`. Compare the sample against the copied traits, then route to `aca-lead-quality`.

## Output format

```text
Lookalike list plan:
Seed: {seed} ({n} contacts reviewed)
Copied traits: {traits}
Excluded traits: {exclusions}
Build at: {app page}
Built list: {list_id, count | pending}
Next: {aca-lead-quality | wait for build}
```

## Skill chaining

Preserve the workspace, seed IDs, the lookalike spec, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue automatically; otherwise end with the handoff block.

**Upstream**
- Called when `aca-find-leads`, `aca-positive-reply-scoring`, or `aca-weekly-rhythm` finds a winning segment.

**Auto-continue conditions**
- Lookalike list exists in ACA: continue to `aca-lead-quality`.
- Lookalike is based on reply winners: continue to `aca-experiment-design` after quality scoring.

**Stop before chaining when**
- The build or import still has to run in the ACA app.
- Creating lists the user has not approved.

**Downstream skills**
- `aca-lead-quality` - validate lookalike quality.
- `aca-experiment-design` - test the lookalike against the control audience.
- `aca-launch-outreach` - launch when ready.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, seed lead_list_id or campaign_id, lookalike spec, new lead_list_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`, `get_lead_list`
- `search_contacts`, `get_contact`
- `list_campaigns`, `get_campaign`, `get_campaign_metrics`

## ACA app pages

- Database search: `https://www.automatedclientacquisition.com/list-building`
- LinkedIn or CSV import: `https://www.automatedclientacquisition.com/leads/import`
