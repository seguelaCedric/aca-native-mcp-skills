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

## ACA tools used

- `list_campaigns`, `list_email_sequences`, `list_lead_lists`
- `list_generation_jobs`, `list_autopilots`
- `create_strategy_document`
