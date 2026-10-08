---
name: aca-auto-research
description: "Autonomous ACA research loop for finding the next best action. Use when the user asks the agent to research opportunities, find gaps, run the outbound research loop, or decide what ACA should do next."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA auto research

Review the connected workspace, name the single biggest bottleneck with evidence, and route to the ACA skill that fixes it.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Start read-only. Do not create anything without approval, unless the user explicitly asked for autonomous execution and the downstream skill allows it.
- Launching, importing, activating, pausing, and publishing happen in the ACA app. Give the link.
- Never invent data. Evidence is counts and records exactly as returned. `get_campaign_metrics` returns stored counts, never rates.
- Prefer one recommendation over a long list.
- Mention a paid plan only if a tool result includes `plan_note` or `plan.upgrade`.

## Workflow

### 1. Operating scan

Call `get_started` first. Its `stage`, `counts`, and `next_steps` usually point straight at the bottleneck. If it is unavailable, call `get_workspace` and infer the stage from the list calls.

Then read what the stage calls for:

- `list_lead_lists`
- `list_campaigns`, plus `get_campaign_metrics` for active campaigns
- `list_sequences`
- `search_conversations` with `has_inbound_message: true`
- `list_lead_magnets`
- `list_content_ideas`, `list_content_generation_jobs`

### 2. Identify the bottleneck

Work down this order and stop at the first that applies:

| Evidence | Bottleneck | Route |
| --- | --- | --- |
| `get_started` shows 0 ICPs or 0 products | No foundation | `aca-icp-onboarding` |
| 0 contacts or no lead list | No audience | `aca-find-leads` |
| Lists exist but contacts lack emails, titles, or fit | Low list quality | `aca-lead-quality` |
| 0 connected LinkedIn accounts and 0 mailboxes | No sender | `aca-sender-health` (connect at `/accounts`, `/email/mailboxes`) |
| Lists and sender ready, no campaign | No campaign | `aca-campaign-strategy` |
| Active campaigns progressing but few inbound conversations | Copy issue | `aca-campaign-copywriting` |
| Active campaigns with little or no progression in stored counts | Sender or send issue | `aca-sender-health` |
| Replies waiting unanswered | Reply backlog | `aca-positive-reply-scoring` |
| Few ideas and no recent generation jobs | Content gap | `aca-content-week` |

Mailbox and sender health details are not available through the connector. When the evidence points there, say so and send the user to `/email/analytics` alongside the skill.

### 3. Write the research note

Write it in chat: bottleneck, evidence (with the exact counts), recommended skill, why now. Offer to let the user save it at `/assets?tab=strategies`.

### 4. Continue

If the user asked for autonomous execution, continue into the selected skill. Otherwise end with the handoff block.

## Output format

```text
Auto research result
Workspace: {workspace} ({stage})
Main bottleneck: {bottleneck}
Evidence: {counts and records as returned}
Recommended next skill: {skill}
Why now: {reason}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill; otherwise end with the handoff block.

**Upstream**
- Entry point for "figure out what to do next" requests, or called by `aca-pipeline-status`.

**Auto-continue conditions**
- No product or ICP: continue to `aca-icp-onboarding`.
- No audience: continue to `aca-find-leads`.
- Low list quality: continue to `aca-lead-quality`.
- No campaign strategy: continue to `aca-campaign-strategy`.
- Copy issue: continue to `aca-campaign-copywriting`.
- Sender issue: continue to `aca-sender-health`.
- Content gap: continue to `aca-content-week`.

**Stop before chaining when**
- The downstream skill would create records and the user did not ask for autonomous execution.
- The fix happens in the ACA app (connecting senders, imports, activation).

**Downstream skills**
- `aca-icp-onboarding`: fix the foundation.
- `aca-find-leads`: source leads.
- `aca-lead-quality`: fix list quality.
- `aca-campaign-strategy`: plan the campaign.
- `aca-campaign-copywriting`: fix copy.
- `aca-sender-health`: fix sender blockers.
- `aca-content-week`: refill content.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, stage, counts, lead_list_id, campaign_id, sequence_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`
- `list_campaigns`, `get_campaign_metrics`
- `list_sequences`
- `search_conversations`
- `list_lead_magnets`
- `list_content_ideas`, `list_content_generation_jobs`

## ACA app pages

- Connect senders: `https://www.automatedclientacquisition.com/accounts`, `/email/mailboxes`
- Deliverability: `https://www.automatedclientacquisition.com/email/analytics`
- Save the research note: `https://www.automatedclientacquisition.com/assets?tab=strategies`
