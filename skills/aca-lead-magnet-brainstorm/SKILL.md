---
name: aca-lead-magnet-brainstorm
description: "Brainstorm and prepare ACA lead magnet campaigns. Use when the user wants lead magnet ideas, keyword monitoring, comment to DM campaigns, inbound capture, or a resource that attracts their ICP."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA lead magnet brainstorm

Plan lead magnets and the comment-to-DM keyword campaigns that deliver them, then save the chosen one as an inactive ACA draft.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Tie every idea to an ICP pain and a follow-up conversation path.
- Prefer specific tools, calculators, teardown templates, checklists, and scripts over generic PDFs.
- Ask before any write. `create_lead_magnet_draft` creates an inactive draft. It cannot monitor posts, send DMs, or deliver a link until the user activates it at `/lead-magnets`.
- Never invent results or capture numbers. Report counts from `list_lead_magnets` and `get_lead_magnet` as returned.
- If a tool result includes `plan_note` or `plan.upgrade`, relay it plainly. Do not mention plans otherwise.

## Workflow

### 1. Gather context

Call `get_started` to see the workspace stage, whether ICPs and products exist, and how many LinkedIn accounts are connected.

Call `list_lead_magnets`, then `get_lead_magnet` on any existing ones, to see what already runs, which keywords are taken, and how captures and deliveries look.

Offer, ICP, and brand voice details are not readable through the connector. If the user has not described the offer and buyer, ask in one short message or route to `aca-icp-onboarding`.

Call `list_agent_profiles` if the user wants an AI agent to handle follow-up replies.

### 2. Brainstorm 10 concepts

For each: hook, promise, format, trigger keyword(s), and the qualification signal a request reveals.

### 3. Pick the top 3

Score each 1 to 5 on buyer intent, ease to produce, and follow-up relevance. Recommend one.

### 4. Draft the campaign in chat

For the chosen concept:

- Name
- Trigger keywords (lowercase, distinct from existing magnets, up to 20)
- Lead magnet title and URL (the user hosts the resource; if it does not exist yet, leave the URL blank)
- DM template that delivers the link and opens a conversation
- Whether a LinkedIn connection is required before the DM

### 5. Save as a draft (after approval)

`create_lead_magnet_draft` needs `account_id`, the ID of an account connected in this workspace.

- Call `list_connected_accounts` (filter `provider: LINKEDIN` or `INSTAGRAM` to match the post) and ask the user which active account to use.
- If it returns none, send them to `/accounts` to connect one first.
- If the tool is not available, reuse the `account_id` of an existing lead magnet from `get_lead_magnet`, or ask the user.

Call `create_lead_magnet_draft` with `account_id`, `name`, `trigger_keywords`, and, when available, `lead_magnet_title`, `lead_magnet_url`, `dm_template`, `require_connection_for_linkedin`. Report the returned ID and any `plan_note`. Activation happens at `/lead-magnets`.

If follow-up replies need a dedicated persona and none fits in `list_agent_profiles`, draft one and call `create_agent_profile` after approval. The user finishes editing it in the app.

The resource itself (copy, outline, checklist) is written in chat. The user can store supporting context at `/assets?tab=knowledge`.

## Output format

```text
Lead magnet concepts:
1. {name} - {promise} - {keyword triggers}
2. {name} - {promise} - {keyword triggers}
3. {name} - {promise} - {keyword triggers}

Recommended: {name}
Why: {reason}
Draft: {lead_magnet_id, inactive, activate at /lead-magnets | not created}
Plan note: {plan_note if returned}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill; otherwise end with the handoff block.

**Upstream**
- Usually called by `aca-kickoff`, `aca-icp-onboarding`, or `aca-campaign-strategy` when the campaign needs a free resource or inbound hook.

**Auto-continue conditions**
- A concept is selected: continue to `aca-campaign-strategy`.
- The user wants posts that promote the magnet: continue to `aca-content-week`.

**Stop before chaining when**
- Creating a draft or agent profile the user has not approved.
- The next step is activation (app only).

**Downstream skills**
- `aca-campaign-strategy`: turn the lead magnet into an outbound and inbound plan.
- `aca-content-week`: create posts that promote the lead magnet.
- `aca-launch-outreach`: launch outreach once the audience and copy are ready.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, lead_magnet_id, account_id, trigger_keywords, agent_profile_id, approvals, constraints}
```

## ACA tools used

- `list_connected_accounts`
- `get_started`
- `list_lead_magnets`, `get_lead_magnet`, `create_lead_magnet_draft`
- `list_agent_profiles`, `create_agent_profile`

## ACA app pages

- Activate and edit lead magnets: `https://www.automatedclientacquisition.com/lead-magnets`
- Connect a LinkedIn account: `https://www.automatedclientacquisition.com/accounts`
- Offer and ICP: `https://www.automatedclientacquisition.com/assets?tab=products`, `?tab=icps`
- Supporting knowledge: `https://www.automatedclientacquisition.com/assets?tab=knowledge`
