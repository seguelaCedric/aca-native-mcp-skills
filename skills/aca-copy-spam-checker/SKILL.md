---
name: aca-copy-spam-checker
description: "Review ACA email, LinkedIn, and campaign copy for spam risk, weak claims, fake personalization, compliance issues, and formatting problems. Use before launch or when deliverability is questionable. Works on pasted copy in chat and points to where fixes are applied in the ACA app."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA copy spam checker

Review copy before it goes into campaigns or email sequences. The review happens in chat on copy the user pastes. ACA context is optional.

## Rules

- Be concrete. Quote the exact phrase and give a safer replacement.
- Flag unverifiable claims, fake familiarity, urgency tricks, excessive links, image-heavy emails, and spammy formatting.
- For LinkedIn, also flag pitch-heavy connection requests and long first DMs.
- Do not rewrite unless the user asks or the copy is clearly high risk.
- The connector cannot edit campaigns or sequences. Never say a fix was applied; give the page where the user applies it.

## Workflow

### 1. Get the copy

Review pasted copy directly. If the user refers to an ACA asset, find it with `list_campaigns` or `list_sequences` and confirm it with `get_campaign` or `get_sequence`. Those return name, status, and step count, not the message text, so ask the user to paste the steps.

### 2. Grade it

Score each dimension low, medium, or high risk:

- **Deliverability risk**
  - Spam trigger words and phrases: "free", "guarantee", "risk-free", "act now", "limited time", "urgent", "100%", "no obligation", "click here", "earn $", "cash", "winner", "congratulations", "double your", "best price", "special promotion".
  - ALL CAPS words, multiple exclamation marks, `$$$`, emojis in subject lines.
  - More than one link in a first email, link shorteners, tracking-heavy links, attachments, images in cold emails.
  - Subject lines that look like marketing ("Exclusive offer for {company}") rather than a colleague ("quick question").
  - Missing plain-text feel: heavy HTML, colored fonts, signatures with banners.
- **Human credibility**
  - Invented stats, unnamed "clients like you", superlatives ("the leading", "world-class").
  - Fake familiarity ("as we discussed", "following up on our call" when there was none, "Re:" on a first email).
- **Personalization quality**
  - Generic compliments ("loved your recent post") with no specifics.
  - Merge variables that might be empty, broken braces, or fields the contacts do not have (check one contact with `get_contact` if unsure).
- **CTA clarity**
  - More than one ask, calendar links in the first touch, vague asks ("let me know your thoughts").
- **Channel fit**
  - LinkedIn connection request over 250 characters or containing a pitch.
  - First DM longer than 3 sentences.
  - Email first touch over roughly 120 words.
- **Compliance**
  - No way to opt out on email sequences where the user's region expects one.
  - Claims about results the user cannot back up.

### 3. Report

List each issue with the phrase, reason, and replacement. List what is strong and should stay. Give an overall risk level (the highest single dimension, unless it is an isolated minor issue).

### 4. Rewrite (only if asked or high risk)

Provide a full rewrite that fixes every flagged issue and keeps the user's offer and voice.

### 5. Hand off

The user applies changes in the app:

- LinkedIn steps: `https://www.automatedclientacquisition.com/campaigns/{campaign_id}` (draft or paused campaigns).
- Email steps: `https://www.automatedclientacquisition.com/email/sequences`.
- Live deliverability signals: `https://www.automatedclientacquisition.com/email/analytics`.

## Output format

```text
Copy risk: {low/medium/high}

Scores:
Deliverability {l/m/h} | Credibility {l/m/h} | Personalization {l/m/h} | CTA {l/m/h} | Channel fit {l/m/h}

Issues:
- "{phrase}" - {reason} - replace with "{replacement}"

Keep:
- {strong element}

Recommended rewrite:
{copy}

Apply in: {app link}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the reviewed copy when continuing into another ACA skill.

**Upstream**
- Called by any skill that creates or changes outbound copy.

**Auto-continue conditions**
- Copy is high risk: continue to `aca-campaign-copywriting` for a rewrite.
- Copy needs variants: continue to `aca-copy-variants`.
- Copy passes and launch prerequisites exist: continue to `aca-launch-outreach`.

**Stop before chaining when**
- The user has not approved the rewrite.
- The next step is applying the copy in the ACA app.

**Downstream skills**
- `aca-campaign-copywriting`: rewrite weak or risky copy.
- `aca-copy-variants`: create safer variants.
- `aca-launch-outreach`: use approved copy in a campaign.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, campaign_id, sequence_id, reviewed copy, risk level, approvals, constraints}
```

## ACA tools used

- `list_campaigns`, `get_campaign`
- `list_sequences`, `get_sequence`
- `get_contact`

## ACA app pages

- LinkedIn steps: `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`
- Email steps: `https://www.automatedclientacquisition.com/email/sequences`
- Deliverability: `https://www.automatedclientacquisition.com/email/analytics`
