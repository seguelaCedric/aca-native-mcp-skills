---
name: aca-copy-variants
description: "Create controlled ACA copy variants for outbound experiments. Use when the user asks for spintax, subject line variants, DM variations, A/B tests, or alternate angles for a campaign."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA copy variants

Create variations that isolate one variable at a time.

## Rules

- Change one thing per experiment: pain, proof, CTA, subject, or opening hook.
- Do not create many random variants.
- For ACA campaigns, prefer `message_variations`, `subject_variations`, `body_variations`, or prompt variations.
- For email sequences, use A/B test steps only when the existing schema supports the desired split.

## Workflow

1. Inspect the target with `get_campaign` or `get_email_sequence`.
2. Identify the hypothesis and metric.
3. Create 2-4 variants:
   - Control
   - Alternate pain
   - Alternate proof
   - Alternate CTA
4. Run variants through `aca-copy-spam-checker`.
5. If approved, apply to draft/paused campaign or sequence with `update_campaign` or `update_email_sequence`.
6. Save the experiment note with `create_strategy_document`.

## Output format

```text
Variant plan:
Hypothesis: {hypothesis}
Metric: {metric}

A: {control}
B: {variant}
C: {optional}

Apply now: {yes/no}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-campaign-copywriting`, `aca-experiment-design`, or `aca-weekly-rhythm`.

**Auto-continue conditions**
- After variants are drafted -> continue to `aca-copy-spam-checker`.
- If the experiment needs tracking -> continue to `aca-experiment-design`.

**Stop before chaining when**
- Ask before applying variants to draft/paused assets.

**Downstream skills**
- `aca-copy-spam-checker` - validate variants.
- `aca-experiment-design` - define the single-variable test.
- `aca-launch-outreach` - apply approved variants.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_campaigns`, `get_campaign`, `update_campaign`
- `list_email_sequences`, `get_email_sequence`, `update_email_sequence`
- `create_strategy_document`
