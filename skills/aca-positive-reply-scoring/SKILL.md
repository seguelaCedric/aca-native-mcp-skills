---
name: aca-positive-reply-scoring
description: "Review and score ACA campaign replies. Use when the user asks which replies are positive, who to follow up with, campaign reply quality, booking intent, objections, or what the replies teach us."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA positive reply scoring

Turn reply activity into follow-up priorities and campaign lessons.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Classify only from message text you actually read with `get_conversation`. Never guess intent from a name or a subject line.
- Separate positive intent, neutral questions, objections, referrals, not now, out-of-office, and negative replies.
- Surface a next action for each positive or ambiguous reply.
- Ask before tagging or changing a stage. Show the full list of changes first.
- `update_contact` replaces the whole `tags` array. Always read the contact with `get_contact`, merge the new tag into its existing tags, and send the merged array.
- Do not mark contacts do-not-contact unless the user clearly asks.
- Draft follow-up replies in chat. The user sends them from `/inbox`.

## Workflow

### 1. Find the replies

Call `search_conversations` with `has_inbound_message: true` (up to 100 per page; follow `cursor` if the user wants more). To focus on one campaign, call `list_campaigns` and `get_campaign`, and use the campaign's contacts as context. To focus on one person, pass `contact_id`.

### 2. Read and classify

Call `get_conversation` for each reply in scope (it returns the 50 most recent messages). Classify the latest inbound message:

| Class | Signal | Score |
| --- | --- | --- |
| Positive | Asks for a call, time, price, or next step | 5 |
| Question | Neutral question about the offer or fit | 4 |
| Referral | Points to someone else | 3 |
| Not now | Interested but wrong timing | 2 |
| Objection | Pushes back on price, need, or trust | 2 |
| Out-of-office | Auto-reply | 1 |
| Negative | Not interested, remove me | 0 |

For each Positive, Question, or Referral, write the next action and a short draft reply.

### 3. Tag and stage (after approval)

Proposed tags:

- `aca_positive_reply`
- `aca_objection`
- `aca_referral`
- `aca_not_now`
- `aca_negative_reply`

Call `list_tags` to reuse existing tag names where they match. For each approved contact:

1. `get_contact` to read current tags.
2. `update_contact` with `tags` set to the existing tags plus the new one.
3. If the user wants a stage move, call `list_pipeline_stages`, confirm the target stage with the user, then `update_contact_stage` with its `stage_id`. If that tool is not available, have the user move the stage at `/contacts/{id}`.

Notes go on the contact at `/contacts/{id}`.

### 4. Write the lesson

Summarize what replies teach about audience, angle, and copy. Offer to let the user save it at `/assets?tab=strategies`.

## Output format

```text
Reply scoring ({N} conversations read)
Positive: {n}
Questions: {n}
Referrals: {n}
Objections: {n}
Not now: {n}
Out-of-office: {n}
Negative: {n}

Top follow-ups:
- {contact} ({class}): {next_action}
  Draft: {reply text}  → send from /inbox

Changes applied: {tags and stages updated, or none}

Campaign lesson:
{lesson}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill; otherwise end with the handoff block.

**Upstream**
- Called by `aca-pipeline-status`, `aca-weekly-rhythm`, or after a campaign has had time to collect replies.

**Auto-continue conditions**
- A winning audience pattern appears: continue to `aca-lookalike-leads`.
- A copy lesson appears: continue to `aca-campaign-copywriting` or `aca-copy-variants`.
- An experiment is needed: continue to `aca-experiment-design`.

**Stop before chaining when**
- Tagging contacts or changing stages the user has not approved.
- Sending a reply (the user sends from `/inbox`).

**Downstream skills**
- `aca-lookalike-leads`: find more prospects like the winners.
- `aca-campaign-copywriting`: apply reply lessons to copy.
- `aca-copy-variants`: test improved message variants.
- `aca-experiment-design`: formalize the next test.
- `aca-weekly-rhythm`: record learnings.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, campaign_id, conversation_ids, contact_ids by class, approvals, constraints}
```

## ACA tools used

- `list_pipeline_stages`
- `search_conversations`, `get_conversation`
- `list_campaigns`, `get_campaign`
- `get_contact`, `update_contact`, `update_contact_stage`
- `list_tags`

## ACA app pages

- Send replies: `https://www.automatedclientacquisition.com/inbox`
- Contact notes and stage: `https://www.automatedclientacquisition.com/contacts/{id}`
- Save lessons: `https://www.automatedclientacquisition.com/assets?tab=strategies`
