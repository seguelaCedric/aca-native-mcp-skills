---
name: aca-campaign-copywriting
description: "Write ACA outbound campaign copy for LinkedIn, email, WhatsApp, and multi-channel sequences. Use when the user asks for cold email copy, LinkedIn DMs, campaign prompts, follow-ups, or to rewrite campaign messaging. Works in chat and produces copy and prompt-mode instructions ready to paste into the ACA builders."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA campaign copywriting

Write usable campaign copy and prompt-mode instructions that fit ACA's campaign and sequence builders. The writing happens in chat. ACA context is optional and read-only; the user pastes the final copy into the app.

## Rules

- No fake familiarity, fake stats, hype, or unverifiable claims. Proof comes from the user.
- Short messages with one CTA.
- For scalable personalization, write prompt-mode instructions (the builder's AI message mode) instead of hardcoded per-lead messages.
- The connector cannot edit campaigns or sequences. Never say copy was applied; give the page where the user pastes it.
- The connection is bound to one workspace. If the user wants a different one, they switch their active workspace in ACA and reconnect.

## Workflow

### 1. Gather context

Ask for what is not already in the conversation, in one message: offer, audience, pain, proof the user can stand behind, CTA, channel, and tone.

ACA context, only when useful:

- `get_started` to see which channels are connected (`counts.sender_accounts`, `counts.mailboxes`) so the copy targets a channel the user can actually send from.
- `list_campaigns` or `list_sequences` to find the asset being rewritten, then `get_campaign` or `get_sequence` to confirm its name, status, and step count. The connector does not return step copy, so ask the user to paste the current messages.
- `get_contact` on one or two list members to see which fields exist for merge variables and prompts.

### 2. Draft

Write each piece the channel needs:

- Connection request (under 250 characters, peer tone, no pitch)
- First DM (2 to 3 sentences: one observation, one question)
- Email 1 (subject 2 to 4 words, lowercase; body under 90 words; one soft question)
- Follow-up (new angle, same thread, shorter)
- Breakup or fallback message (one or two lines, easy to say no)

For WhatsApp, keep it to the length of a text from a colleague and only for contacts who have opted in or have an existing relationship.

### 3. Convert to prompt mode where it should vary by lead

For each step where personalization should differ per contact, write an instruction the builder's AI step can follow. Constrain:

- Length (characters or sentences)
- Tone (peer, plain, no emojis)
- What to reference (role, company, industry, analysis data)
- What not to do (no invented facts, no compliments about posts it has not seen, no pricing)
- The single CTA

Hand off to `aca-personalization-pattern` when the user wants sample QA against real contacts.

### 4. QA

Run the output through `aca-copy-spam-checker`.

### 5. Hand off

- LinkedIn copy: the user pastes it into the campaign steps at `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`. If there is no campaign yet, continue to `aca-launch-outreach`.
- Email copy: the user pastes it at `https://www.automatedclientacquisition.com/email/sequences`.
- To keep the copy as a reference, the user can save it at `https://www.automatedclientacquisition.com/assets?tab=strategies`.

## Output format

```text
Campaign copy draft: {campaign_or_plan}

Connection request:
{copy}

First DM:
{copy}

Email 1:
Subject: {subject}
{body}

Follow-up:
{copy}

Breakup:
{copy}

Prompt-mode instructions:
{step}: {prompt}

Paste into: {app link}
Recommended next: {skill or action}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the drafted copy when continuing into another ACA skill.

**Upstream**
- Usually called by `aca-campaign-strategy`, `aca-launch-outreach`, or `aca-experiment-design`.

**Auto-continue conditions**
- After drafting copy: continue to `aca-copy-spam-checker`.
- Scalable personalization required: continue to `aca-personalization-pattern`.
- Variants requested: continue to `aca-copy-variants`.
- Copy passes QA and campaign prerequisites exist: continue to `aca-launch-outreach`.

**Stop before chaining when**
- The user has not approved the copy.
- The next step is pasting into a campaign or sequence in the ACA app.

**Downstream skills**
- `aca-copy-spam-checker`: QA deliverability and credibility.
- `aca-personalization-pattern`: turn copy into prompt-mode personalization.
- `aca-copy-variants`: create controlled variants.
- `aca-launch-outreach`: set up the campaign.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, lead_list_id, campaign_id, sequence_id, drafted copy, approvals, constraints}
```

## ACA tools used

- `get_started`
- `list_campaigns`, `get_campaign`
- `list_sequences`, `get_sequence`
- `get_contact`

## ACA app pages

- LinkedIn campaign steps: `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`
- Email sequences: `https://www.automatedclientacquisition.com/email/sequences`
- Save copy as a reference: `https://www.automatedclientacquisition.com/assets?tab=strategies`
