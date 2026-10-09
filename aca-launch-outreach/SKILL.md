---
name: aca-launch-outreach
description: Plan and set up a LinkedIn or email outreach campaign in ACA. Use when the user says "launch a campaign", "start outreach", "send LinkedIn DMs to [list]", "email sequence for [audience]", "enroll leads", or asks to begin contacting a list. Checks the workspace, writes the full sequence, creates an inactive LinkedIn campaign draft on approval, and hands off step building, enrollment, and activation to the ACA app.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# Launch outreach in ACA

ACA runs LinkedIn campaigns and native email sequences from the user's own connected accounts. Through the connector, this skill checks readiness, writes the whole sequence, and creates an inactive LinkedIn campaign draft linked to a lead list. Adding steps, assigning senders, enrolling leads, and activating all happen in the ACA app.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Never invent prospects, emails, companies, or results. Report counts exactly as ACA returns them.
- Ask before creating anything in ACA. The only write here is `create_linkedin_campaign_draft`, and only after the user approves the name and list.
- A draft created through the connector is inactive and has no outreach steps. It cannot send. Never say a campaign is live, scheduled, or sending.
- Email sequences are read-only through the connector. Write the copy in chat; the user builds it and enrolls leads at `/email/sequences`.
- Stop and hand off if there is no lead list or no connected sender for the chosen channel.
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.
- The connection is bound to one workspace. If the user wants a different one, they switch their active workspace in ACA and reconnect.

## Workflow

### 1. Confirm the brief

Restate in one short message:

- Lead list
- Channel path (LinkedIn, email, or both)
- Goal (meetings, replies, lead magnet opt-ins)
- Offer and main outcome
- Tone or brand voice
- Number of touches

Ask one question only if the launch would otherwise be ambiguous.

### 2. Check readiness

Call `get_started`. Note `counts.lead_lists`, `counts.sender_accounts` (connected LinkedIn accounts), `counts.mailboxes`, `counts.campaigns`, `counts.icps`, `counts.products`, and `plan`.

If `get_started` is not available, call `get_workspace`, `list_lead_lists`, `list_campaigns`, and `list_sequences`.

Then:

- `list_lead_lists` and `get_lead_list` (with `include_members: false` unless you need a sample) to confirm the target list and its `lead_count`.
- `list_campaigns` with `search` set to the planned name to avoid collisions.
- `list_sequences` for email, to see whether a sequence already exists that the user may want to reuse.

Blockers and handoffs:

- No lead list: route to `aca-find-leads`.
- LinkedIn chosen and `sender_accounts` is 0: the user connects LinkedIn at `/accounts`.
- Email chosen and `mailboxes` is 0: the user connects a mailbox at `/email/mailboxes`.
- No offer or ICP saved (`icps` or `products` is 0): draft them in chat so the copy has a source, and point to `/assets?tab=products` and `/assets?tab=icps`.

### 3. Write the sequence

Write every touch in full in chat, in the format the ACA builder expects. Keep the judgment below; it is what makes the sequence work.

**LinkedIn-only (default)**

1. Analyze contact (AI research step, continue on failure). Gives later prompt-mode steps company and role context.
2. Connection request, prompt mode: "Write a short LinkedIn connection request under 250 characters. Sound like a peer. Mention one specific business reason this person is relevant. No pitch, no emojis."
3. Delay 3 days.
4. If connected:
   - Accepted: Message, prompt mode: "Write a 2 sentence LinkedIn DM. Reference the contact's likely role or company context. Give one useful observation, then ask a low-pressure question. No pitch."
   - Not accepted: End.
5. Optional: Delay 4 days, then a short follow-up message with a different angle and a yes/no question.

**Email-only**

1. Email 1. Subject: lowercase, 2 to 4 words (for example "quick question"). Body: reference the contact's likely situation, connect it to the offer, end with one soft question. No hype, no fake familiarity. HTML paragraphs.
2. Wait 3 days.
3. Email 2 (same thread). A different angle and one practical proof point the user has supplied. End with a yes/no question.
4. Wait 4 days.
5. Email 3, the breakup. One or two lines, easy to say no to.

**Multi-channel**

Start on LinkedIn, then move to email when available: analyze contact, connection request, delay, if connected, switch channel, email, if reply received, end. Note for the user that the connector creates LinkedIn drafts only, so the email leg is configured in the app.

For every message, give the literal copy or the prompt-mode instruction, the delay before it, and the stop condition (stop on reply is on by default for connector drafts). Use only merge variables the user's ACA data actually has (`get_contact` on one member shows the fields). Run the copy through `aca-copy-spam-checker` before handing off if it has not been checked.

### 4. Create the LinkedIn draft (with approval)

For LinkedIn or multi-channel, propose:

- `name` (3 to 255 characters, not already used)
- `lead_list_id`
- `description` (one line: offer, angle, touches)

After the user approves, call `create_linkedin_campaign_draft`. To attach senders, call `list_connected_accounts` with `provider: LINKEDIN`, let the user pick active accounts, and pass their ids as `sender_account_ids`; otherwise leave it out and senders are assigned in the app.

From the result, report `campaign.id`, `campaign.status`, and the `note`. If `plan_note` is present, show it as returned and do not add claims beyond it.

Then hand off: open `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`, add the steps from step 3, assign senders, review, and activate there.

### 5. Hand off email

For email, give the paste-ready sequence and send the user to `https://www.automatedclientacquisition.com/email/sequences` to create it, attach mailboxes, enroll the lead list, and turn it on. If a matching sequence already exists, name it with its ID from `list_sequences` so they can edit that one instead.

### 6. Confirm

If a draft was created, call `get_campaign` to confirm `status` and `sequence_step_count`. After the user says they activated it, route to `aca-pipeline-status`, which reads `get_campaign_metrics`.

## Output format

```text
ACA outreach setup

Lead list: {list_name} ({lead_count} leads)
Channel path: {path}
Senders: {sender_accounts} LinkedIn, {mailboxes} mailboxes (from get_started)

Sequence:
1. {step} - {copy or prompt}
2. {delay}
...

Created: {campaign_name} ({campaign_id}), status {status}, {sequence_step_count} steps
Plan note: {plan_note, only if returned}

Finish in ACA:
- Add steps, assign senders, activate: https://www.automatedclientacquisition.com/campaigns/{campaign_id}
- Build and enroll email: https://www.automatedclientacquisition.com/email/sequences
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the written sequence when continuing into another ACA skill.

**Upstream**
- Called by `aca-kickoff`, `aca-campaign-strategy`, `aca-campaign-copywriting`, `aca-lead-quality`, or `aca-email-sequence-manager`.

**Auto-continue conditions**
- No lead list: continue to `aca-find-leads`.
- Lead list quality unknown: continue to `aca-lead-quality`.
- No connected sender for the channel: continue to `aca-sender-health`.
- Email chosen and readiness unknown: continue to `aca-email-deliverability-audit`.
- Copy missing or weak: continue to `aca-campaign-copywriting`.
- User confirms the campaign is active: continue to `aca-pipeline-status`.

**Stop before chaining when**
- Creating a campaign draft the user has not approved.
- The next step happens in the ACA app (adding steps, assigning senders, enrollment, activation).

**Downstream skills**
- `aca-find-leads`: source a missing audience.
- `aca-lead-quality`: clean the list before launch.
- `aca-sender-health`: resolve sender blockers.
- `aca-email-deliverability-audit`: preflight email risk.
- `aca-campaign-copywriting`: write missing copy.
- `aca-pipeline-status`: track the campaign once live.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, lead_list_id, campaign_id, sequence_id, written sequence, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`, `get_lead_list`, `get_contact`
- `list_sequences`
- `list_campaigns`, `get_campaign`, `create_linkedin_campaign_draft`
- `list_connected_accounts`

## ACA app pages

- Campaign steps, senders, activation: `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`
- Email sequences and enrollment: `https://www.automatedclientacquisition.com/email/sequences`
- Connect senders: `https://www.automatedclientacquisition.com/accounts`, `/email/mailboxes`
- Offer and ICP: `https://www.automatedclientacquisition.com/assets?tab=products`, `?tab=icps`
