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

## ACA tools used

- `list_campaigns`, `list_lead_lists`, `list_generation_jobs`, `list_autopilots`
- `list_email_mailboxes`, `list_sender_accounts`
- `list_products`, `list_icps`
- `create_strategy_document`
