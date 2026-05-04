---
name: aca-pipeline-status
description: "Get a read-only status report on everything running in ACA right now: active campaigns, in-flight imports, content generation jobs, autopilots, email sequences, lead lists, and recent activity. Use when the user says \"what's running\", \"status report\", \"morning brief\", \"what's happening in ACA\", \"give me a summary\", or \"anything need attention\"."
license: MIT
compatibility: "Requires the ACA MCP server connected with a valid bearer token. Read-only: performs no mutations."
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA pipeline status report

This is a read-only operating brief across ACA. It should be short, specific, and useful.

## Rules

- Do not mutate state.
- Omit empty sections unless the workspace is completely empty.
- Surface genuine blockers plainly: disconnected senders, stalled imports, failed generation jobs, active campaigns with no leads, or paused sequences that the user expected to run.
- If a tool call fails, report the partial result and name the failed call.

## Workflow

Run independent reads:

1. `list_campaigns` with active and paused filters
2. `list_linkedin_import_jobs` for running and failed imports
3. `list_apify_leads_import_jobs` for running and failed imports
4. `list_generation_jobs` for queued, processing, review, and failed jobs
5. `list_autopilots`
6. `list_email_sequences`
7. `list_email_mailboxes`
8. `list_lead_lists`
9. Optional: `list_pool_entries` for content pool health

For each active campaign, call `get_campaign` or `list_campaign_leads` only when needed to explain a problem or identify recent activity.

## Output structure

```text
ACA Status - {timestamp}

CAMPAIGNS
- {N} active, {N} paused.
- Needs attention: {campaign} - {reason}

LEADS
- Imports running: {N}
- Recent list/build status: {summary}

EMAIL
- Mailboxes connected: {N}
- Active sequences: {N}

CONTENT
- Jobs in progress: {N}
- Jobs needing review: {N}
- Failed jobs: {N}

AUTOMATION
- Autopilots active: {N}

Nothing else needs attention.
```

## Edge cases

- Empty workspace: say "Nothing running" and route to `aca-kickoff`.
- User asks for a date range: adjust the filters where tools support it, otherwise say which sections are current-state only.
- Agency user asks for all clients: call `list_accessible_organizations`, loop with `switch_organization`, collect compact metrics, then switch back.

## ACA tools used

- `list_accessible_organizations`, `switch_organization`
- `list_campaigns`, `get_campaign`, `list_campaign_leads`
- `list_linkedin_import_jobs`, `list_apify_leads_import_jobs`
- `list_generation_jobs`, `get_generation_job`
- `list_autopilots`
- `list_email_sequences`, `list_email_mailboxes`
- `list_lead_lists`
- `list_pool_entries`
