---
name: aca-weekly-rhythm
description: Weekly ACA operating cadence for outbound and content. Use when the user asks for a weekly review, operating rhythm, campaign optimization, experiment planning, Monday/Wednesday/Friday workflow, or "what should I do this week in ACA". Reads campaign, reply, list, lead magnet, and content status through the ACA connector and produces a weekly plan.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA weekly rhythm

This skill turns ACA from a launch tool into an operating system. It reviews the pipeline, picks one or two high-leverage changes, and writes the week's plan.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Start read-only. Ask before any write.
- Report counts exactly as returned. `get_campaign_metrics` returns stored counts, never rates. Only state a rate when the matching denominator came back too, and show both numbers.
- Never invent metrics, replies, or results.
- Pausing, resuming, or editing campaigns and sequences, running autopilots, and publishing happen in the ACA app. Recommend the change and give the link.
- Prefer one controlled experiment at a time.
- Keep the output operational: what changed, what to do next, and what is blocked.
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.

## Workflow

### 1. Run the brief

Call `get_started` first (fallback: `get_workspace`). Then read in parallel:

- `list_campaigns`, then `get_campaign_metrics` for each active campaign
- `search_conversations` with `has_inbound_message: true` for replies
- `list_sequences`
- `list_lead_lists`
- `list_lead_magnets`
- `list_content_ideas` and `list_content_generation_jobs`

Mailbox and sender health are not available through the connector. Use the mailbox and LinkedIn counts from `get_started` and point to `/email/mailboxes` and `/email/analytics` for health.

### 2. Diagnose by cadence

**Monday: plan and refill**

- Lead lists behind active campaigns that are small or exhausted
- Content queue light (few unused ideas, no recent generation jobs)
- Choose campaign, list, and content priorities for the week
- Route to `aca-find-leads` or `aca-content-week` when needed

**Wednesday: experiment and unblock**

- Active campaigns with little progression in their stored counts
- Replies waiting more than a day
- Pick one experiment: audience, hook, channel, offer, or timing
- Draft the change in chat; the user applies it at `/campaigns/{id}` or `/email/sequences`

**Friday: review and clean**

- Summarize wins, replies, failed generation jobs, and list quality problems
- Identify contacts to tag, re-stage, or suppress (route to `aca-positive-reply-scoring` for replies)
- Write the weekly note

### 3. Write the weekly note

Write it in chat with:

- Week and date
- Metrics snapshot (stored counts as returned)
- Decisions
- Experiment hypothesis
- Next actions with owner and link

Offer to let the user save it at `/assets?tab=strategies`.

### 4. Optional actions

Only after approval, through the owning skill:

- Refill a lead list: `aca-find-leads`
- Draft a new campaign: `aca-launch-outreach`
- Add ideas or generate content: `aca-content-week`
- Tag or re-stage replying contacts: `aca-positive-reply-scoring`

App-only, give the link:

- Pause or resume a campaign: `/campaigns/{id}`
- Turn a sequence on or off: `/email/sequences`
- Run or pause an autopilot: `/autopilots`

## Output format

```text
ACA Weekly Rhythm - {week}
Workspace: {workspace} ({stage})

Status:
- Campaigns: {summary with stored counts}
- Replies: {N with inbound messages, N waiting on you}
- Leads: {summary}
- Content: {ideas, jobs}
- Senders: {N LinkedIn, N mailboxes}; health at /email/analytics

This week's priority:
{one priority}

Experiment:
Hypothesis: {hypothesis}
Change: {change}
Metric: {metric, as a stored count with its denominator}

Actions:
1. {action} → {skill or app link}
2. {action} → {skill or app link}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill; otherwise end with the handoff block.

**Upstream**
- Called by the user on a weekly cadence or after `aca-pipeline-status`.

**Auto-continue conditions**
- Lead lists running low: continue to `aca-find-leads`.
- Content queue low: continue to `aca-content-week`.
- Replies need review: continue to `aca-positive-reply-scoring`.
- A test is needed: continue to `aca-experiment-design`.
- Campaign or sender issue: continue to `aca-deliverability-incident-response`.

**Stop before chaining when**
- The next step changes live campaigns, publishes, or imports. Those happen in the app.
- Creating records the user has not approved.

**Downstream skills**
- `aca-find-leads`: refill the audience.
- `aca-content-week`: refill content.
- `aca-positive-reply-scoring`: learn from replies.
- `aca-experiment-design`: plan the next test.
- `aca-deliverability-incident-response`: handle blockers.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, stage, campaign_id, lead_list_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_campaigns`, `get_campaign_metrics`
- `search_conversations`
- `list_sequences`
- `list_lead_lists`
- `list_lead_magnets`
- `list_content_ideas`, `list_content_generation_jobs`

## ACA app pages

- Campaigns: `https://www.automatedclientacquisition.com/campaigns/{id}`
- Sequences: `https://www.automatedclientacquisition.com/email/sequences`
- Mailbox health: `https://www.automatedclientacquisition.com/email/mailboxes`, `/email/analytics`
- Autopilots and publishing: `https://www.automatedclientacquisition.com/autopilots`, `/publish-queue`
- Save the weekly note: `https://www.automatedclientacquisition.com/assets?tab=strategies`
