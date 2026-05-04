---
name: aca-weekly-rhythm
description: Weekly ACA operating cadence for outbound and content. Use when the user asks for a weekly review, operating rhythm, campaign optimization, experiment planning, Monday/Wednesday/Friday workflow, or "what should I do this week in ACA". Uses ACA MCP status, campaign, content, and strategy tools.
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. Mutations require explicit user approval.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA weekly rhythm

This skill turns ACA from a launch tool into an operating system. It reviews the pipeline, identifies one or two high-leverage changes, and records the plan.

## Rules

- Start read-only.
- Do not pause campaigns, activate campaigns, publish content, or change sequences without approval.
- Prefer one controlled experiment at a time.
- Keep the output operational: what changed, what to do next, and who/what is blocked.

## Workflow

### 1. Run the brief

Collect:

- `list_campaigns`
- `list_campaign_leads` for active campaigns when needed
- `list_email_sequences` and `list_email_enrollments` for email performance
- `list_email_mailboxes`
- `list_linkedin_import_jobs` and `list_apify_leads_import_jobs`
- `list_generation_jobs`
- `list_autopilots`
- `list_pool_entries`

### 2. Diagnose by cadence

**Monday - plan and refill**

- Check if lead lists are low
- Check if content queue is light
- Choose campaign/list/content priorities for the week
- Route to `aca-find-leads` or `aca-content-week` when needed

**Wednesday - experiment and unblock**

- Check campaigns with low activity or stalled sends
- Pick one experiment: audience, hook, channel, offer, or timing
- Draft the change, then ask before applying it

**Friday - review and clean**

- Summarize wins, replies, failed jobs, and list quality problems
- Identify contacts/lists to suppress or enrich
- Save learnings to a strategy document

### 3. Save the weekly note

Use `create_strategy_document` to record:

- Week/date
- Metrics snapshot
- Decisions
- Experiment hypothesis
- Next actions

### 4. Optional actions

Only after approval:

- Create/refill a lead list through `aca-find-leads`
- Create a campaign through `aca-launch-outreach`
- Generate content through `aca-content-week`
- Pause/resume campaigns with `update_campaign_status`
- Trigger an autopilot with `trigger_autopilot`

## Output format

```text
ACA Weekly Rhythm - {week}

Status:
- Campaigns: {summary}
- Leads: {summary}
- Content: {summary}
- Automation: {summary}

This week's priority:
{one priority}

Experiment:
Hypothesis: {hypothesis}
Change: {change}
Metric: {metric}

Actions:
1. {action}
2. {action}

Saved note: {strategy_document_id}
```

## ACA tools used

- `list_campaigns`, `list_campaign_leads`, `update_campaign_status`
- `list_email_sequences`, `list_email_enrollments`, `list_email_mailboxes`
- `list_linkedin_import_jobs`, `list_apify_leads_import_jobs`
- `list_generation_jobs`, `list_autopilots`, `trigger_autopilot`
- `list_pool_entries`
- `create_strategy_document`
