---
name: aca-lead-quality
description: Grade, clean, and segment ACA lead lists before outreach. Use when the user says "grade this list", "quality check leads", "segment the list", "who should we contact first", "split by tier", "remove bad leads", or wants a campaign-ready sublist from existing ACA contacts.
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. This skill only uses ACA MCP contacts, lead lists, tags, and notes.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# Lead quality and segmentation

Use this skill to turn a raw ACA lead list into clean outreach segments.

## Rules

- Do not invent lead scores. Use existing `lead_score`, enrichment fields, tags, and visible contact data.
- If analysis data is missing, tag the contact for review or recommend an outreach campaign with `analyze_contact` as the first step.
- Do not delete contacts unless the user explicitly asks.
- Create new lists/tags for segmentation instead of mutating the source list destructively.

## Workflow

### 1. Pick the source audience

Find the list with `list_lead_lists`, then call `get_lead_list`.

If the user describes contacts instead of a list, use `search_contacts_and_leads` with filters such as tags, status, score range, company, or outreach status.

### 2. Pull contact details

For each sampled or selected contact, call `get_contact` when more detail is needed. Grade the list on:

- Data completeness: name, company, job title, email, LinkedIn URL
- Channel readiness: email available, LinkedIn available, phone/WhatsApp where relevant
- ICP fit: existing `lead_score`, role, industry, geography, company size, tags
- Risk: missing company, generic role, personal email, suppression/do-not-contact tags
- Freshness: last activity and outreach status

For large lists, sample first, report quality, then ask before processing the whole list.

### 3. Create segments

Use simple, operational segments:

- Tier 1: strong fit and ready on the requested channel
- Tier 2: plausible fit or partial data
- Needs enrichment: good account but missing channel data
- Suppress/review: poor fit, risky, or do-not-contact signals

Create destination lists with `create_lead_list`, then use `add_contacts_to_list`.

### 4. Tag and annotate

Use `add_contact_tag` for durable routing:

- `aca_tier1`
- `aca_tier2`
- `aca_needs_enrichment`
- `aca_suppress_review`

Use `add_contact_note` for important judgment calls, especially why a contact was suppressed or promoted to Tier 1.

### 5. Hand off

If Tier 1 is non-empty, route to `aca-launch-outreach`.

If too many contacts need enrichment, recommend a LinkedIn import or a campaign sequence that starts with `find_email` and `analyze_contact`.

## Output format

```text
Lead quality complete for "{source_list}".

Overall quality: {A/B/C/D}
Reviewed: {count}
Tier 1: {count} -> {list_id}
Tier 2: {count} -> {list_id}
Needs enrichment: {count}
Suppress/review: {count}

Main issue: {one-line diagnosis}
Next: {recommended skill/action}
```

## ACA tools used

- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`
- `search_contacts_and_leads`, `get_contact`
- `add_contact_tag`, `add_contact_note`
