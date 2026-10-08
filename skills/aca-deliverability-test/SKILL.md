---
name: aca-deliverability-test
description: "Plan a controlled ACA email preflight test. Use before launching a new sequence, new mailbox, new domain, or high-volume campaign, or when the user asks how to test deliverability safely."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA deliverability test

Design a small, low-risk preflight for email sending, set up the test list, and hand off the sequence build and sending to the ACA app. The connector cannot create, enroll or activate sequences, and it cannot read mailbox health or send logs.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Never send test traffic or tell the user it was sent. Building, enrolling and activating the test sequence happen at `/email/sequences`.
- Keep tests small. Test infrastructure, copy, tracking and enrollment separately where possible.
- Never invent test contacts. Seed or test addresses come from the user.
- Ask before creating a lead list or adding contacts.
- The connection is bound to one workspace. To test in another, the user switches their active workspace in ACA and reconnects.

## Workflow

### 1. Read the workspace

- `get_started`: mailbox count. If it is zero, stop and route to `aca-email-infra-readiness`.
- `list_sequences` and `get_sequence` for the sequence being tested.
- `list_lead_lists` and `get_lead_list` for the candidate list.

If `get_started` is not available, use `get_workspace` plus the `list_*` tools above.

### 2. Choose what to test

One of: a new mailbox or domain, a new sequence's copy, tracking settings, or a new list source. Ask the user which mailboxes will be used; the connector does not list them, so they check `/email/mailboxes`.

### 3. Review copy

Run the sequence copy through `aca-copy-spam-checker` before any send.

### 4. Build the test plan

- **Sample size**: 20 to 50 real prospects from the target list, or a seed list of 5 to 10 addresses the user owns across Gmail, Outlook and one other provider.
- **Mailboxes**: 1 to 2, already warmed for at least 2 to 3 weeks.
- **Daily cap**: 10 to 20 per mailbox for the test.
- **Send window**: recipients' business hours, weekdays.
- **Tracking**: plain text, no open pixel, at most one link, for the first test.
- **Pass criteria**: hard bounces under 2%, no spam complaints, seed messages land in Primary or Inbox, at least one human reply or no negative signals within 3 to 5 business days.
- **Fail criteria**: bounces at or above 5%, any complaint, seeds in spam, or mailbox flagged.

### 5. Set up the test list (with approval)

If the user approves, `create_lead_list` for the test and `add_contacts_to_list` with contacts found via `search_contacts`. If they supply seed addresses, add them with `bulk_create_contacts` (up to 100 per call, user-supplied data only) first.

### 6. Hand off to the app

The user builds or duplicates the test sequence, enrolls the test list, sets the daily cap, and activates it at `/email/sequences`. Mailbox caps are set at `/email/mailboxes`.

### 7. Read results

After the test window, ask the user to paste bounce and complaint numbers from `/email/analytics`. Check replies with `search_conversations` (`has_inbound_message: true`) and `get_conversation`. Judge pass or fail against the criteria above; do not estimate numbers you were not given.

## Output format

```text
Deliverability test plan
Asset: {sequence/mailbox/domain/list}
Sample size: {n}
Mailboxes: {as named by the user}
Daily cap: {n per mailbox}
Pass criteria: {criteria}
Risk: {low/medium/high}
Set up in ACA: {test list id, if created}
Next in the app: build and activate at /email/sequences (approval required before sending)
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the test plan when continuing into another ACA skill.

**Upstream**
- Called by `aca-email-deliverability-audit`, `aca-email-infra-readiness`, or before a high-risk launch.

**Auto-continue conditions**
- Test needs sequence copy: continue to `aca-email-sequence-manager`.
- Test passes and a campaign is waiting: continue to `aca-launch-outreach`.
- Test fails: continue to `aca-deliverability-incident-response`.

**Stop before chaining when**
- Creating the test list or adding contacts has not been approved.
- The next step is building, enrolling or activating in the ACA app.

**Downstream skills**
- `aca-email-sequence-manager`: write the test sequence copy.
- `aca-launch-outreach`: proceed after passing.
- `aca-deliverability-incident-response`: triage failures.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, sequence_id, lead_list_id, mailboxes, test plan, results, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_sequences`, `get_sequence`
- `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`
- `search_contacts`, `bulk_create_contacts`
- `search_conversations`, `get_conversation`

## ACA app pages

- Build, enroll and activate the test sequence: `https://www.automatedclientacquisition.com/email/sequences`
- Mailbox caps and warmup: `https://www.automatedclientacquisition.com/email/mailboxes`
- Bounce and complaint results: `https://www.automatedclientacquisition.com/email/analytics`
