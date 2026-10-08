---
name: aca-email-sequence-manager
description: "Plan, write, and review ACA email sequences. Use when the user asks to create an email sequence, edit steps, enroll leads, pause or resume a sequence, inspect sequences, or replace Smartlead-style sequence operations with ACA native email. Reads existing sequences, writes paste-ready sequence copy, and hands building, enrollment, and on/off to the ACA app."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA email sequence manager

Work with ACA's native email sequence engine. The connector can read sequences (name, status, step count). Creating, editing, enrolling, pausing, and resuming happen in the ACA app at `/email/sequences`, so this skill writes the full sequence in chat in a paste-ready format and gives the exact next click.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Never say a sequence was created, edited, enrolled, paused, or resumed. Those actions are done by the user in the app.
- Never invent prospects, emails, proof points, or metrics. Proof and claims come from the user.
- Ask before adding contacts to ACA. Only add people the user supplied, with `bulk_create_contacts` (100 per call).
- Use HTML paragraphs for email bodies. Keep spacing conservative (3 to 4 days between touches) unless the user asks otherwise.
- The connection is bound to one workspace. If the user wants a different one, they switch their active workspace in ACA and reconnect.

## Workflow

### 1. Read the workspace

Call `get_started`. Note `counts.mailboxes`, `counts.lead_lists`, and `counts.contacts`. If it is not available, call `get_workspace` and `list_lead_lists`.

If `mailboxes` is 0, stop and route to `aca-sender-health`: the user connects a mailbox at `/email/mailboxes` before any sequence can send.

### 2. Inspect existing sequences

Call `list_sequences` (filter by `status` if the user asked about active or paused ones). For a specific sequence, call `get_sequence` to confirm its name, status, and `step_count`.

The connector returns summaries, not step copy. If the user wants to edit or review existing copy, ask them to paste it.

### 3. Write or revise the sequence

Write the sequence in chat as a numbered block the user can paste step by step into the builder:

```text
Sequence: {name}
Goal: {goal}
Audience: {list or ICP}

Step 1 - Email
Subject: {subject}
Body:
<p>{paragraph}</p>
<p>{paragraph}</p>

Step 2 - Wait {n} days

Step 3 - Email (reply in thread)
Body:
<p>{paragraph}</p>

Step 4 - Condition: stop if replied

Step 5 - Wait {n} days

Step 6 - Email (breakup)
...
```

Step types to use, matching the builder: Email, Delay, Condition, and A/B test where a real single-variable split is wanted (hand variant work to `aca-copy-variants`).

Defaults that work:

- 3 to 4 emails. First email under 90 words, follow-ups shorter.
- Follow-ups reply in the same thread with a new angle, not "just bumping this".
- One CTA per email, usually a soft question.
- Merge variables only for fields the contacts actually have (check one with `get_contact`).

Run the copy through `aca-copy-spam-checker` before handoff.

### 4. Prepare the audience (optional)

If the user wants to enroll a list:

- `list_lead_lists` and `get_lead_list` to confirm the list and its `lead_count`.
- If the user pasted people who are not in ACA yet, confirm count and fields, then add them with `bulk_create_contacts` after approval, and put them on a list with `create_lead_list` and `add_contacts_to_list`.

### 5. Hand off to the app

Give the exact steps:

1. Open `https://www.automatedclientacquisition.com/email/sequences`.
2. Create the sequence (or open the existing one by name) and paste each step.
3. Attach mailboxes.
4. Enroll the lead list.
5. Turn the sequence on, or pause/resume it, from the same page.

For deliverability after launch, point to `https://www.automatedclientacquisition.com/email/analytics`.

## Output format

```text
Email sequence: {name}
Existing in ACA: {yes, id and status from list_sequences | no}
Steps written: {n}
Mailboxes connected: {mailboxes}
Lead list: {list_name} ({lead_count})

Finish in ACA:
- Build, enroll, turn on: https://www.automatedclientacquisition.com/email/sequences
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the written sequence when continuing into another ACA skill.

**Upstream**
- Called by `aca-launch-outreach`, `aca-campaign-strategy`, or Smartlead-style sequence requests.

**Auto-continue conditions**
- No mailbox connected: continue to `aca-sender-health`.
- Copy needs QA: continue to `aca-copy-spam-checker`.
- Sequence written but deliverability unknown: continue to `aca-email-deliverability-audit`.
- User also wants LinkedIn: continue to `aca-launch-outreach`.

**Stop before chaining when**
- Adding contacts or lists the user has not approved.
- The next step happens in the ACA app (building, enrollment, turning on or pausing).

**Downstream skills**
- `aca-sender-health`: mailbox readiness.
- `aca-copy-spam-checker`: QA sequence copy.
- `aca-email-deliverability-audit`: preflight sequence risk.
- `aca-launch-outreach`: add a LinkedIn leg.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, lead_list_id, sequence_id, written sequence, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_sequences`, `get_sequence`
- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`
- `bulk_create_contacts`, `get_contact`

## ACA app pages

- Build, enroll, turn on or pause: `https://www.automatedclientacquisition.com/email/sequences`
- Connect mailboxes: `https://www.automatedclientacquisition.com/email/mailboxes`
- Deliverability: `https://www.automatedclientacquisition.com/email/analytics`
