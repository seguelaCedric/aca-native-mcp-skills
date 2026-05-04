---
name: aca-copy-spam-checker
description: "Review ACA email, LinkedIn, and campaign copy for spam risk, weak claims, fake personalization, compliance issues, and formatting problems. Use before launch or when deliverability is questionable."
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token when reviewing existing ACA assets.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/campaigns
---

# ACA copy spam checker

Review copy before it goes into campaigns or email sequences.

## Rules

- Be concrete. Point to exact phrases and safer replacements.
- Flag unverifiable claims, fake familiarity, urgency tricks, excessive links, image-heavy emails, and spammy formatting.
- For LinkedIn, also flag pitch-heavy connection requests and long first DMs.
- Do not rewrite unless the user asks or the copy is clearly risky.

## Workflow

1. If copy is pasted by the user, review it directly.
2. If copy lives in ACA, inspect `list_campaigns` / `get_campaign` or `list_email_sequences` / `get_email_sequence`.
3. Grade the copy:
   - Deliverability risk
   - Human credibility
   - Personalization quality
   - CTA clarity
   - Channel fit
4. Provide replacements for risky phrases.
5. If the user approves, apply to draft/paused assets with `update_campaign` or `update_email_sequence`.

## Output format

```text
Copy risk: {low/medium/high}

Issues:
- "{phrase}" - {reason} - replace with "{replacement}"

Keep:
- {strong element}

Recommended rewrite:
{copy}
```

## ACA tools used

- `list_campaigns`, `get_campaign`, `update_campaign`
- `list_email_sequences`, `get_email_sequence`, `update_email_sequence`
