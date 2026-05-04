---
name: aca-kickoff
description: Guided start-here orchestrator for ACA. Use when the user is new, wants to set up ACA, wants an outbound/content launch plan, says "start here", "set up my ACA workspace", "launch my first campaign", or asks what to do next. Uses one native ACA MCP connection for product, ICP, brand voice, lead sourcing, outreach, content, and status routing.
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. All provider credentials and org scoping are handled by ACA MCP.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/integrations/mcp
---

# ACA kickoff

This is the guided entry point for running ACA through an agent. It turns a vague goal into a concrete ACA workspace plan and routes the user to the next skill.

## Rules

- Use ACA MCP only. Do not ask for vendor API keys or run direct SQL/API calls.
- Confirm before creating missing foundation records if the user did not explicitly ask you to set them up.
- Confirm before spending import budget, activating campaigns, or publishing content.
- If multiple organizations are available, ask the user which org to use, then call `switch_organization`.
- If you switch organizations, switch back to the original org before finishing unless the user asks to stay there.

## Workflow

### 1. Select org and current context

Call `list_accessible_organizations`.

If there is more than one org, ask which one to use and call `switch_organization`. Then inspect the current setup:

- `list_products`
- `list_icps`
- `list_brand_voices`
- `list_sender_accounts` for likely channels (`linkedin`, `email`, `whatsapp`, `instagram`)
- `list_email_mailboxes`
- `list_lead_lists`
- `list_blueprints`
- `list_publishing_accounts`

### 2. Clarify the launch brief

Get the missing pieces in one concise exchange:

- Offer/product being sold
- Ideal buyer and disqualifiers
- Main outcome or CTA (book meetings, sell service, drive lead magnet, grow audience)
- Preferred channels (LinkedIn, email, multi-channel, content, or all)
- Target list size and geography
- Brand voice/tone

Skip questions when the answer already exists in ACA and only confirm the selected record.

### 3. Create missing foundations

If the workspace lacks a needed product, ICP, or brand voice, create it through MCP:

- `create_product`
- `create_icp`
- `create_brand_voice`
- `set_product_icp_fit` when both product and ICP exist

Keep these records practical. Do not over-model. The first pass should be enough to launch, not a brand strategy dissertation.

### 4. Save the operating plan

Create a concise launch plan with `create_strategy_document`. Include:

- Product
- ICP
- Channel path
- Lead source plan
- Campaign angle
- Content support plan
- Risks / missing setup
- Next recommended skill

### 5. Route to the next skill

Choose exactly one primary next step:

- No audience yet: run `aca-find-leads`
- Audience exists but quality is uncertain: run `aca-lead-quality`
- Campaign-ready audience and senders exist: run `aca-launch-outreach`
- Need nurture/social proof first: run `aca-content-week`
- Already running campaigns: run `aca-pipeline-status`

If the user says "do it" or gives an explicit launch instruction, continue into the selected workflow. Otherwise, stop with the plan and next action.

## Output format

```text
ACA kickoff complete.

Org: {org_name}
Product: {product_name}
ICP: {icp_name}
Primary path: {LinkedIn/email/multi-channel/content}
Ready:
- {ready_item}

Needs setup:
- {missing_item}

Plan saved: {strategy_document_id}
Next: {skill_name} - {why}
```

## ACA tools used

- `list_accessible_organizations`, `switch_organization`
- `list_products`, `create_product`
- `list_icps`, `create_icp`, `set_product_icp_fit`
- `list_brand_voices`, `create_brand_voice`
- `list_sender_accounts`, `list_email_mailboxes`
- `list_lead_lists`, `list_blueprints`, `list_publishing_accounts`
- `create_strategy_document`
