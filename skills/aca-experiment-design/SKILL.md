---
name: aca-experiment-design
description: "Design one controlled ACA experiment for outbound or content. Use when the user wants to improve reply rate, test an angle, split audiences, A/B test copy, compare channels, or plan experiments."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA experiment design

Create a clean experiment with one variable, one metric, and a stopping rule.

## Rules

- Do not change multiple variables at once.
- Prefer small tests before scaling.
- Save the experiment plan before applying changes.
- Mutations require approval.

## Workflow

1. Inspect current assets with `list_campaigns`, `list_email_sequences`, `list_lead_lists`, `list_generation_jobs`, and `list_autopilots`.
2. Pick experiment type:
   - Audience
   - Angle
   - CTA
   - Channel
   - Sequence timing
   - Content topic
3. Define control, variant, sample size, metric, decision threshold, and review date.
4. Save with `create_strategy_document`.
5. If approved, route to the right executor:
   - `aca-copy-variants`
   - `aca-find-leads`
   - `aca-launch-outreach`
   - `aca-content-week`

## Output format

```text
Experiment: {name}
Hypothesis: {hypothesis}
Control: {control}
Variant: {variant}
Metric: {metric}
Sample size: {n}
Decision rule: {rule}
Next action: {skill}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-weekly-rhythm`, `aca-positive-reply-scoring`, `aca-copy-variants`, or optimization requests.

**Auto-continue conditions**
- Copy variable -> continue to `aca-copy-variants`.
- Audience variable -> continue to `aca-find-leads` or `aca-lead-quality`.
- Content variable -> continue to `aca-content-week`.
- Launch-ready test -> continue to `aca-launch-outreach`.

**Stop before chaining when**
- Ask before applying experiment changes or launching tests.

**Downstream skills**
- `aca-copy-variants` - create message variants.
- `aca-find-leads` - build audience variant.
- `aca-lead-quality` - segment audience variant.
- `aca-content-week` - create content variant.
- `aca-launch-outreach` - launch approved experiment.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_campaigns`, `list_email_sequences`, `list_lead_lists`
- `list_generation_jobs`, `list_autopilots`
- `create_strategy_document`
