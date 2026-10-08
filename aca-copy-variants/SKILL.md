---
name: aca-copy-variants
description: "Create controlled ACA copy variants for outbound experiments. Use when the user asks for spintax, subject line variants, DM variations, A/B tests, or alternate angles for a campaign. Writes single-variable variants in chat, ready to paste into the ACA campaign or sequence builder."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA copy variants

Create variations that isolate one variable at a time, so the result tells the user something. The work happens in chat; the user applies approved variants in the ACA app.

## Rules

- Change one thing per experiment: pain, proof, CTA, subject, or opening hook.
- Do not create many random variants. 2 to 4 is enough.
- For LinkedIn campaigns, write variants as message variations or prompt variations for the builder's steps.
- For email sequences, use an A/B test step only for a real single-variable split. Subject and body variations go in the same step.
- Spintax: keep each option a natural alternative of the same meaning, no more than 2 to 3 options per slot, never inside merge variables.
- The connector cannot edit campaigns or sequences. Never say variants were applied.
- Never invent past results. If the user wants to base a test on performance, use the counts ACA returns.

## Workflow

### 1. Identify the target

If the user names an ACA asset, find it with `list_campaigns` or `list_sequences`, then confirm with `get_campaign` or `get_sequence` (name, status, step count). The connector does not return step copy; ask the user to paste the control message.

For a LinkedIn campaign that has been running, `get_campaign_metrics` gives counts (contacted, replied, connection rate) to anchor the hypothesis. Report them as returned.

### 2. Set the hypothesis and metric

One sentence: "Changing {variable} from {control} to {variant} will raise {metric} because {reason}." Pick one metric: open rate (subject tests only), reply rate, positive reply rate, or connection acceptance.

Rough sample guidance: each variant needs enough sends to tell apart (a few hundred per arm for reply rate). Say so if the list is too small, using the list's `lead_count` from `get_lead_list` when available.

### 3. Write 2 to 4 variants

- A: Control (unchanged)
- B: Alternate pain, proof, CTA, subject, or hook (only the chosen variable changes)
- C: Optional second alternative of the same variable

Keep length, tone, and everything else identical across variants.

### 4. QA

Run the variants through `aca-copy-spam-checker`.

### 5. Hand off

- LinkedIn: add the variants to the step in `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`. Campaigns should be draft or paused before editing.
- Email: add an A/B test step or subject/body variations at `https://www.automatedclientacquisition.com/email/sequences`.
- Experiment note: the user can save the hypothesis, metric, and stop rule at `https://www.automatedclientacquisition.com/assets?tab=strategies`.

## Output format

```text
Variant plan: {campaign_or_sequence}
Hypothesis: {hypothesis}
Variable: {pain|proof|CTA|subject|hook}
Metric: {metric}
Sample needed: {per arm}

A (control): {copy}
B: {copy}
C: {optional}

Apply in: {app link}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the variants when continuing into another ACA skill.

**Upstream**
- Called by `aca-campaign-copywriting`, `aca-experiment-design`, or `aca-weekly-rhythm`.

**Auto-continue conditions**
- After variants are drafted: continue to `aca-copy-spam-checker`.
- The experiment needs a tracking plan: continue to `aca-experiment-design`.

**Stop before chaining when**
- The user has not approved the variants.
- The next step is applying them in the ACA app.

**Downstream skills**
- `aca-copy-spam-checker`: validate variants.
- `aca-experiment-design`: define the single-variable test.
- `aca-launch-outreach`: use approved variants in a new campaign.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, campaign_id, sequence_id, hypothesis, variants, approvals, constraints}
```

## ACA tools used

- `list_campaigns`, `get_campaign`, `get_campaign_metrics`
- `list_sequences`, `get_sequence`
- `get_lead_list`

## ACA app pages

- LinkedIn variants: `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`
- Email variants and A/B steps: `https://www.automatedclientacquisition.com/email/sequences`
- Experiment note: `https://www.automatedclientacquisition.com/assets?tab=strategies`
