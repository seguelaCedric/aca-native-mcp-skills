---
name: aca-experiment-design
description: "Design one controlled ACA experiment for outbound or content. Use when the user wants to improve reply rate, test an angle, split audiences, A/B test copy, compare channels, or plan experiments."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA experiment design

Design a clean experiment with one variable, one metric, and a stopping rule, grounded in the workspace's real baseline.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Change one variable at a time.
- Prefer small tests before scaling.
- Write the experiment plan before anything changes.
- Baselines come from stored counts as returned. `get_campaign_metrics` returns counts, never rates. Only compute a rate when the matching denominator came back too, and show both numbers. If there is no usable baseline, say so and make the first run the baseline.
- Never invent results.
- Ask before any write. Editing sequences, changing campaign settings, enrolling, and activating happen in the ACA app.

## Workflow

### 1. Read the current state

Call `get_started`, then:

- `list_campaigns` and `get_campaign_metrics` for the campaigns in scope
- `list_sequences` and `get_sequence` for email tests
- `search_conversations` with `has_inbound_message: true` for reply volume context
- `list_lead_lists` for audience size
- `list_content_generation_jobs` for content tests

### 2. Pick the experiment type

- Audience
- Angle
- CTA
- Channel
- Sequence timing
- Content topic

### 3. Define the test

- Hypothesis
- Control (what runs now, with its stored baseline counts)
- Variant (the one thing that changes)
- Metric (a count with its denominator, for example "replies of contacts messaged")
- Sample size per arm (a list size you can actually fill, from `list_lead_lists`)
- Decision rule (the difference that counts as a win, and what happens if it is a tie)
- Review date

### 4. Write the plan

Show it in chat. Offer to let the user save it at `/assets?tab=strategies`.

### 5. Route to the executor (after approval)

- Copy variable: `aca-copy-variants` (copy written in chat; built at `/email/sequences` or `/campaigns/{id}`)
- Audience variable: `aca-find-leads` or `aca-lead-quality` (variant list via `create_lead_list` and `add_contacts_to_list`)
- Channel or new LinkedIn arm: `aca-launch-outreach` (inactive draft via `create_linkedin_campaign_draft`)
- Content variable: `aca-content-week`

## Output format

```text
Experiment: {name}
Hypothesis: {hypothesis}
Control: {control} (baseline: {stored counts})
Variant: {variant}
Metric: {count} of {denominator}
Sample size: {n} per arm
Decision rule: {rule}
Review date: {date}
Next action: {skill} → {app link if the change is app-only}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill; otherwise end with the handoff block.

**Upstream**
- Called by `aca-weekly-rhythm`, `aca-positive-reply-scoring`, `aca-copy-variants`, or optimization requests.

**Auto-continue conditions**
- Copy variable: continue to `aca-copy-variants`.
- Audience variable: continue to `aca-find-leads` or `aca-lead-quality`.
- Content variable: continue to `aca-content-week`.
- Launch-ready test: continue to `aca-launch-outreach`.

**Stop before chaining when**
- Applying experiment changes or creating records the user has not approved.
- The change happens in the ACA app (sequence edits, enrollment, activation).

**Downstream skills**
- `aca-copy-variants`: create message variants.
- `aca-find-leads`: build the audience variant.
- `aca-lead-quality`: segment the audience variant.
- `aca-content-week`: create the content variant.
- `aca-launch-outreach`: launch the approved experiment.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, campaign_id, sequence_id, lead_list_id, baseline counts, experiment plan, approvals, constraints}
```

## ACA tools used

- `get_started`
- `list_campaigns`, `get_campaign_metrics`
- `list_sequences`, `get_sequence`
- `search_conversations`
- `list_lead_lists`
- `list_content_generation_jobs`

## ACA app pages

- Sequences: `https://www.automatedclientacquisition.com/email/sequences`
- Campaigns: `https://www.automatedclientacquisition.com/campaigns/{id}`
- Save the plan: `https://www.automatedclientacquisition.com/assets?tab=strategies`
