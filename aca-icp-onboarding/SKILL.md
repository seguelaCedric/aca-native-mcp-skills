---
name: aca-icp-onboarding
description: "Turn a rough buyer or offer description into a paste-ready offer and ICP to save in ACA. Use when the user says define my ICP, onboard this niche, set up targeting, create the buyer profile, or needs product ICP fit before campaigns."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA ICP onboarding

Produce the minimum useful product and ICP context needed for lead sourcing, scoring, copywriting, and campaign personalization. The drafting happens in chat; the user saves the records in ACA.

## Rules

- Use the ACA connector only.
- Do not over-model. The output should help a campaign launch.
- The connector cannot create or edit products, ICPs, brand voices, or strategy documents. Draft them in chat in a paste-ready shape, then send the user to the right `/assets` tab. Never say a record was saved.
- Include negative filters and disqualifiers, not just ideal traits.
- Never invent proof, metrics, or customer names. Use only what the user provides.
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.

## Workflow

### 1. Inspect current setup

Call `get_started` and read the ICP and product counts (fallback: `get_workspace`). If ICPs or products already exist, ask the user to paste the relevant one so you refine it rather than duplicate it.

### 2. Clarify missing details

Ask once, in one short message, for what is missing: offer, buyer role, industry, geography, company size, pain, desired outcome, objections, proof, and bad-fit criteria.

### 3. Draft the product

```text
Product: {name}
One-liner: {what it does, for whom, outcome}
Key outcome: {measurable result the user can stand behind}
Proof: {user-supplied proof only}
Common objections: {objection -> answer}
Price / offer shape: {if given}
```

### 4. Draft the ICP

```text
ICP: {name}
Titles / seniority: {list}
Industry: {SIC or keywords}
Geography: {list}
Company size: {employee range}
Pains: {top 3}
Buying triggers: {hiring, funding, new tool, growth signal}
Best-fit signals: {signals}
Disqualifiers: {titles, industries, sizes, situations to exclude}
Fit with product: {why this ICP needs this product, 1-2 lines}
```

Show both drafts and revise until the user approves. Then hand off: product at `/assets?tab=products`, ICP at `/assets?tab=icps`, and brand voice at `/assets?tab=brands` if the user wants tone set too.

### 5. Save the targeting note

Write a short targeting note (best-fit signals, disqualifiers, lead-source suggestion, first campaign angle). The user can save it at `/assets?tab=strategies`.

### 6. Route next

- Need an audience: `aca-find-leads`
- Need positioning: `aca-campaign-strategy`
- Ready to send: `aca-launch-outreach`

## Output format

```text
ICP onboarding drafted.
Product: {product}
ICP: {icp}
Best-fit signals: {signals}
Disqualifiers: {disqualifiers}
Save in ACA: /assets?tab=products, /assets?tab=icps{, /assets?tab=strategies}
Next: {skill}
```

## Skill chaining

Preserve the workspace, the approved product and ICP drafts, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue automatically; otherwise end with the handoff block.

**Upstream**
- Usually called by `aca-kickoff`, `aca-auto-research`, or `aca-campaign-strategy` when product or ICP context is missing.

**Auto-continue conditions**
- User asked to launch and the ICP draft is approved: continue to `aca-campaign-strategy`.
- Audience sourcing is the next blocker: continue to `aca-find-leads` with the ICP as the search spec.
- The offer needs an inbound asset: continue to `aca-lead-magnet-brainstorm`.

**Stop before chaining when**
- The user has not approved the product and ICP drafts.

**Downstream skills**
- `aca-campaign-strategy` - turn the ICP into a campaign plan.
- `aca-find-leads` - source the ICP audience.
- `aca-lead-magnet-brainstorm` - create an offer or resource for the ICP.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, product draft, ICP draft, disqualifiers, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`

## ACA app pages

- Products: `https://www.automatedclientacquisition.com/assets?tab=products`
- ICPs: `https://www.automatedclientacquisition.com/assets?tab=icps`
- Brand voices: `https://www.automatedclientacquisition.com/assets?tab=brands`
- Strategy notes: `https://www.automatedclientacquisition.com/assets?tab=strategies`
