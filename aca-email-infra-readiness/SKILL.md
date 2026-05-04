---
name: aca-email-infra-readiness
description: "Review ACA email infrastructure readiness. Use when the user asks about domain setup, BYO email infrastructure, mailbox provisioning, DNS readiness, warmup readiness, or whether email infra is ready for cold outreach."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. Some infra fixes may require ACA dashboard actions outside MCP.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA email infrastructure readiness

Review whether the email foundation is ready before sequences scale.

## Rules

- Be clear when a fix must happen in the ACA dashboard or DNS provider rather than through MCP.
- Do not claim DNS/SPF/DKIM/DMARC status unless ACA MCP returns that data.
- Prefer a readiness checklist over speculative diagnosis.

## Workflow

1. Inspect `list_email_mailboxes`, `list_sender_accounts`, `list_email_sequences`, and active email campaigns.
2. Check for:
   - Connected mailboxes
   - Sender accounts attached to campaigns
   - Warmup/reputation fields if returned
   - Reasonable sequence limits
   - Missing mailbox capacity
3. Ask the user for domain/DNS details only if ACA MCP does not expose them and the review depends on them.
4. Produce a readiness checklist and route to:
   - `aca-email-deliverability-audit`
   - `aca-deliverability-test`
   - `aca-sender-health`

## Output format

```text
Email infra readiness: {ready/caution/not ready}

Known from ACA:
- {fact}

Needs dashboard/DNS check:
- {item}

Next: {skill/action}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-sender-health`, `aca-email-deliverability-audit`, or setup workflows.

**Auto-continue conditions**
- Mailboxes/senders exist -> continue to `aca-sender-health`.
- Infrastructure appears ready but cold-email risk is unknown -> continue to `aca-email-deliverability-audit`.
- A small proof is needed -> continue to `aca-deliverability-test`.

**Stop before chaining when**
- Stop when DNS/dashboard actions are required outside MCP and tell the user exactly what to check.

**Downstream skills**
- `aca-sender-health` - inspect actual connected sender state.
- `aca-email-deliverability-audit` - audit sequence readiness.
- `aca-deliverability-test` - verify with a controlled preflight.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_email_mailboxes`
- `list_sender_accounts`
- `list_email_sequences`
- `list_campaigns`
