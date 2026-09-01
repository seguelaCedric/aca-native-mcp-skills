---
name: aca-auto-research
description: "Autonomous ACA research loop for finding the next best action. Use when the user asks the agent to research opportunities, find gaps, run the outbound research loop, or decide what ACA should do next."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA auto research

Review the workspace, identify the biggest bottleneck, and route to the right ACA workflow.

## Rules

- Start read-only.
- Do not launch, import, publish, or pause without approval.
- Prefer one recommendation over a long list.

## Workflow

1. Run an operating scan:
   - `list_campaigns`
   - `list_lead_lists`
   - `list_generation_jobs`
   - `list_autopilots`
   - `list_email_mailboxes`
   - `list_sender_accounts`
   - `list_products`
   - `list_icps`
2. Identify the bottleneck:
   - No ICP/product: `aca-icp-onboarding`
   - No audience: `aca-find-leads`
   - Low list quality: `aca-lead-quality`
   - No campaign: `aca-campaign-strategy`
   - Copy issue: `aca-campaign-copywriting`
   - Sender issue: `aca-sender-health`
   - Content gap: `aca-content-week`
3. Save the research note with `create_strategy_document`.
4. Continue into the selected workflow if the user asked for autonomous execution.

## Output format

```text
Auto research result:
Main bottleneck: {bottleneck}
Evidence: {evidence}
Recommended next skill: {skill}
Why now: {reason}
Plan saved: {strategy_document_id}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Entry point for autonomous “figure out what to do next” requests or called by `aca-pipeline-status`.

**Auto-continue conditions**
- No product/ICP -> continue to `aca-icp-onboarding`.
- No audience -> continue to `aca-find-leads`.
- Low list quality -> continue to `aca-lead-quality`.
- No campaign strategy -> continue to `aca-campaign-strategy`.
- Copy issue -> continue to `aca-campaign-copywriting`.
- Sender issue -> continue to `aca-sender-health`.
- Content gap -> continue to `aca-content-week`.

**Stop before chaining when**
- Ask before any downstream mutation unless the user explicitly requested autonomous execution.

**Downstream skills**
- `aca-icp-onboarding` - fix foundation.
- `aca-find-leads` - source leads.
- `aca-lead-quality` - fix list quality.
- `aca-campaign-strategy` - plan campaign.
- `aca-campaign-copywriting` - fix copy.
- `aca-sender-health` - fix sender blockers.
- `aca-content-week` - refill content.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_campaigns`, `list_lead_lists`, `list_generation_jobs`, `list_autopilots`
- `list_email_mailboxes`, `list_sender_accounts`
- `list_products`, `list_icps`
- `create_strategy_document`
