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

## ACA tools used

- `list_email_mailboxes`
- `list_sender_accounts`
- `list_email_sequences`
- `list_campaigns`
