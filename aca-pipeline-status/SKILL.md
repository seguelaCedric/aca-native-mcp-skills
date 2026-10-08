---
name: aca-pipeline-status
description: "Get a read-only status report on everything running in ACA right now: active campaigns, replies waiting, email sequences, lead lists, lead magnets, and content generation jobs. Use when the user says \"what's running\", \"status report\", \"morning brief\", \"what's happening in ACA\", \"give me a summary\", or \"anything need attention\"."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA pipeline status report

A read-only operating brief across the connected ACA workspace. It should be short, specific, and built only from what the connector returns.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Read-only. This skill creates and changes nothing.
- Report counts exactly as returned. `get_campaign_metrics` returns stored counts, never rates. Only show a rate when both the numerator and its matching denominator came back in the same result, and label it with both numbers (for example "12 replies of 140 messaged").
- Never invent data. If a tool call fails, report the partial result and name the failed call.
- Omit empty sections unless the workspace is completely empty.
- Surface genuine blockers plainly: active campaigns with no leads or no progression, lead lists with zero members behind a live campaign, failed generation jobs, replies nobody has answered, zero connected senders or mailboxes.
- Mailbox and sender health (bounces, warmup, disconnects, deliverability) is not available through the connector. Report the counts from `get_started` and link to the app pages.
- The connection is bound to one workspace. To report on another workspace (for example an agency client), the user switches their active workspace in ACA and reconnects, then runs this skill again.

## Workflow

### 1. Read the workspace

Call `get_started`. Note `workspace`, `stage`, `counts` (contacts, lead lists, campaigns, active campaigns, connected LinkedIn accounts, mailboxes), `plan`, and `next_steps`.

If `get_started` is not available, call `get_workspace` and rely on the list calls below.

If the stage is `new` or every count is zero, say "Nothing running yet" and route to `aca-kickoff`.

### 2. Run independent reads

Run these in parallel:

1. `list_campaigns` (all statuses, so active and paused both show)
2. `search_conversations` with `has_inbound_message: true` for recent replies
3. `list_sequences`
4. `list_lead_lists`
5. `list_lead_magnets`
6. `list_content_generation_jobs`

### 3. Drill in only where needed

- For each active campaign that looks stalled or is the user's focus, call `get_campaign_metrics` (and `get_campaign` if you need the sequence summary or lead list).
- For replies, call `get_conversation` only on the few that look unanswered or high-intent, to say who replied and what they asked. Do not summarize every thread.
- For a lead list behind an active campaign that looks empty, the count from `list_lead_lists` is enough; do not page through members.

## Output structure

```text
ACA Status - {timestamp}
Workspace: {workspace} ({stage})

CAMPAIGNS
- {N} active, {N} paused, {N} draft.
- Needs attention: {campaign} - {reason, with the stored counts that show it}

REPLIES
- Conversations with an inbound message: {N} (from this page of results)
- Waiting on you: {contact} - {one-line ask}

EMAIL
- Mailboxes connected: {N} (from get_started)
- Sequences: {N} total, {N} active
- Health: not available here; check /email/mailboxes and /email/analytics

LEADS
- Lead lists: {N}; behind active campaigns: {list} ({members})

LEAD MAGNETS
- {N} active; captures {N}, delivered {N} (as returned)

CONTENT
- Generation jobs: {N} in progress, {N} completed, {N} failed

Nothing else needs attention.
```

## Edge cases

- Empty workspace: say "Nothing running yet" and route to `aca-kickoff`.
- User asks for a date range: the connector reports current state and recent items. Say which sections are current-state only rather than estimating a period.
- Agency user asks for all clients: explain the connection covers one workspace. They switch the active workspace in ACA, reconnect, and rerun the report per client.
- User asks to pause, resume, or fix a campaign: that happens at `/campaigns/{id}`. Give the link.

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill; otherwise end with the handoff block.

**Upstream**
- Called after launches, during daily checks, or by `aca-weekly-rhythm`.

**Auto-continue conditions**
- Workspace empty: continue to `aca-kickoff`.
- Main bottleneck unclear: continue to `aca-auto-research`.
- Deliverability or sender blocker: continue to `aca-deliverability-incident-response` or `aca-sender-health`.
- Replies need review: continue to `aca-positive-reply-scoring`.

**Stop before chaining when**
- The downstream skill would write anything; this skill stays read-only.

**Downstream skills**
- `aca-kickoff`: start an empty workspace.
- `aca-auto-research`: choose the next best action.
- `aca-deliverability-incident-response`: triage campaign or send problems.
- `aca-positive-reply-scoring`: review replies.
- `aca-weekly-rhythm`: turn status into an operating plan.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, stage, campaign_id, lead_list_id, sequence_id, conversation_ids, job_id, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_campaigns`, `get_campaign`, `get_campaign_metrics`
- `search_conversations`, `get_conversation`
- `list_sequences`
- `list_lead_lists`
- `list_lead_magnets`
- `list_content_generation_jobs`

## ACA app pages

- Campaigns (pause, resume, edit): `https://www.automatedclientacquisition.com/campaigns/{id}`
- Inbox: `https://www.automatedclientacquisition.com/inbox`
- Mailbox health: `https://www.automatedclientacquisition.com/email/mailboxes`, `/email/analytics`
- Senders: `https://www.automatedclientacquisition.com/accounts`
- Autopilots and publishing: `https://www.automatedclientacquisition.com/autopilots`, `/publish-queue`
