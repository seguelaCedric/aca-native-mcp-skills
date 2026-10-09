---
name: aca-lead-quality
description: Grade, clean, and segment ACA lead lists before outreach. Use when the user says "grade this list", "quality check leads", "segment the list", "who should we contact first", "split by tier", "remove bad leads", or wants a campaign-ready sublist from existing ACA contacts.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# Lead quality and segmentation

Turn a raw ACA lead list into clean outreach segments, using only data ACA already holds.

## Rules

- Never invent lead scores. Use the existing score, enrichment fields, tags, and visible contact data.
- If analysis data is missing, put the contact in "Needs enrichment" rather than guessing.
- Never delete contacts or remove them from the source list. Segment into new lists and tags instead. Removing or deleting happens at `/leads/lists` if the user asks.
- Ask before tagging or creating lists, and confirm volume first on large lists.
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.

## Workflow

### 1. Pick the source audience

Call `get_started` if workspace context is not already known (fallback: `get_workspace`). Find the list with `list_lead_lists`, then call `get_lead_list`.

If the user describes contacts instead of a list, use `search_contacts` with the filters it supports (tags, status, company, text).

### 2. Pull contact details

Call `get_contact` when more detail is needed. Grade each contact on:

- Data completeness: name, company, job title, email, LinkedIn URL
- Channel readiness: email available, LinkedIn available, phone or WhatsApp where relevant
- ICP fit: existing score, role, industry, geography, company size, tags
- Risk: missing company, generic role, personal email, suppression or do-not-contact tags
- Freshness: last activity and outreach status

For large lists, grade a sample of 25 to 50 first, report quality, then ask before processing the whole list.

### 3. Create segments

Use simple, operational segments:

- **Tier 1**: strong fit and ready on the requested channel
- **Tier 2**: plausible fit or partial data
- **Needs enrichment**: good account but missing channel data
- **Suppress/review**: poor fit, risky, or do-not-contact signals

After approval, create destination lists with `create_lead_list` (for example "{source} - Tier 1") and fill them with `add_contacts_to_list`.

### 4. Tag for routing

Check existing tags with `list_tags` and reuse them where they exist:

- `aca_tier1`
- `aca_tier2`
- `aca_needs_enrichment`
- `aca_suppress_review`

`update_contact` replaces the whole `tags` array, so read the contact with `get_contact` first and send the existing tags plus the new one. For clear do-not-contact cases, `update_contact_stage` can move the contact out of the active pipeline if the user agrees.

Write the reasoning for important judgment calls (why a contact was suppressed or promoted) in your summary. Notes on the contact itself are added at `/contacts/{id}`.

### 5. Hand off

If Tier 1 is non-empty, route to `aca-launch-outreach`.

If too many contacts need enrichment, recommend a fresh LinkedIn import at `/leads/import`, or a campaign whose first steps find emails and analyze the contact, set up at `/campaigns/{id}`.

## Output format

```text
Lead quality complete for "{source_list}".

Overall quality: {A/B/C/D}
Reviewed: {count} of {list size}
Tier 1: {count} -> {list_id}
Tier 2: {count} -> {list_id}
Needs enrichment: {count}
Suppress/review: {count}

Main issue: {one-line diagnosis}
Next: {recommended skill/action}
```

## Skill chaining

Preserve the workspace, the source and segment list IDs, the grading criteria, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue automatically; otherwise end with the handoff block.

**Upstream**
- Called after any lead sourcing skill, or by `aca-kickoff` when an existing list needs validation.

**Auto-continue conditions**
- Tier 1 list exists and campaign strategy is missing: continue to `aca-campaign-strategy`.
- Tier 1 list and strategy or copy are ready: continue to `aca-launch-outreach`.
- Many contacts need better targeting: continue to `aca-find-leads` with corrected criteria.

**Stop before chaining when**
- Tagging large volumes or creating many derived lists the user did not request.

**Downstream skills**
- `aca-campaign-strategy` - plan messaging for the segment.
- `aca-launch-outreach` - launch to the campaign-ready segment.
- `aca-find-leads` - refill or correct the audience.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, source lead_list_id, tier list IDs, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`
- `search_contacts`, `get_contact`, `update_contact`, `update_contact_stage`
- `list_tags`

## ACA app pages

- Contact notes: `https://www.automatedclientacquisition.com/contacts/{id}`
- Edit or remove list members: `https://www.automatedclientacquisition.com/leads/lists`
- LinkedIn import for enrichment: `https://www.automatedclientacquisition.com/leads/import`
- Campaign steps: `https://www.automatedclientacquisition.com/campaigns/{id}`
