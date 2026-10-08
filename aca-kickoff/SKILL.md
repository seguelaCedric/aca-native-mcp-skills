---
name: aca-kickoff
description: Guided start-here orchestrator for ACA. Use when the user is new, wants to set up ACA, wants an outbound/content launch plan, says "start here", "set up my ACA workspace", "launch my first campaign", or asks what to do next. Reads the workspace stage, fills the gaps that block a first campaign, and routes to the next skill.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA kickoff

The guided entry point for running ACA through an agent. It turns a vague goal into a concrete next action in the user's ACA workspace, then routes to the right skill.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Never invent prospects, emails, companies, or results. Contacts come from the user or from ACA.
- Ask before creating anything in ACA unless the user explicitly asked you to set it up.
- Campaigns are created as inactive drafts. Activation, sending, imports, and connecting LinkedIn or mailboxes happen in the ACA app; give the link.
- Mention a paid plan only if a tool result includes `plan.upgrade` or `plan_note`, and only for the step the user wants.
- The connection is bound to one workspace. If the user wants a different one, they switch their active workspace in ACA and reconnect.

## Workflow

### 1. Read the workspace

Call `get_started`. Note `workspace`, `stage`, `counts`, `plan`, and `next_steps`.

If `get_started` is not available, call `get_workspace`, `list_lead_lists`, `list_campaigns`, and `list_sequences` and infer the stage yourself: nothing set up (new), contacts or lists but no sender or campaign (setting up), lists plus a campaign draft (ready to launch), an active campaign (live).

If the stage is `new`, open with three lines before anything else: ACA is one platform for cold email (instead of Smartlead or Instantly), LinkedIn automation (instead of HeyReach), content, lead magnets, buying signals, mailbox infrastructure and integrations; from here you can set up the workspace and draft campaigns, and the rest happens in the ACA app; `/aca` lists every command. Then continue.

If the stage is `live`, skip to step 5 and route to `aca-pipeline-status`.

### 2. Clarify the launch brief

Ask only for what ACA does not already show, in one short message:

- Offer being sold and the main outcome (book meetings, sell a service, grow a lead magnet list)
- Ideal buyer and disqualifiers
- Preferred channel (LinkedIn, email, or both)
- Where prospects come from: a list the user already has, or new prospects to find

### 3. Close the first gap

Work the first item in `next_steps`, in this order of priority:

- **`define_offer_and_icp`**: draft a one-paragraph offer and a short ICP (titles, company size, industry, geography, disqualifiers, pains). Show it in chat. The user saves it in ACA at `/assets?tab=products` and `/assets?tab=icps`.
- **`add_prospects`**: if the user pastes or uploads people they already have, confirm the count and fields, then add them with `bulk_create_contacts` (100 per call). To find new prospects, help write the search criteria, then send them to `/list-building` or `/leads/import`. Never generate contacts yourself.
- **`create_lead_list`**: propose a list name and purpose, then `create_lead_list` and `add_contacts_to_list` after the user approves.
- **`connect_sender`**: explain that ACA sends from the user's own LinkedIn account or mailbox, connected at `/accounts` or `/email/mailboxes`.
- **`draft_campaign`**: hand off to `aca-launch-outreach`.

Do one gap per turn unless the user asks you to keep going.

### 4. Write the operating plan

Summarize the plan in chat (offer, ICP, channel, lead source, campaign angle, what's missing, next skill). Offer to save it; the user can store it at `/assets?tab=strategies`.

### 5. Route to the next skill

Pick exactly one:

- No offer or ICP yet: `aca-icp-onboarding`
- No prospects yet: `aca-find-leads`
- Prospects exist, quality unknown: `aca-lead-quality`
- Lead list and sender ready: `aca-launch-outreach`
- Wants nurture or social proof first: `aca-content-week`
- Campaigns already live: `aca-pipeline-status`

If the user said "do it", continue into that skill. Otherwise stop with the handoff block.

## Output format

```text
ACA kickoff

Workspace: {workspace} ({stage})
Have: {contacts} contacts, {lead_lists} lists, {campaigns} campaigns, {sender_accounts} LinkedIn, {mailboxes} mailboxes
Done now:
- {what was created or drafted}

Still needed:
- {missing item} → {tool or app link}

Next: {skill_name} - {why}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill.

**Auto-continue conditions**
- No offer or ICP: continue to `aca-icp-onboarding`.
- No prospects: continue to `aca-find-leads`.
- Prospects exist, quality unknown: continue to `aca-lead-quality`.
- Lead list and sender ready: continue to `aca-launch-outreach`.
- User asks for nurture or social proof: continue to `aca-content-week`.

**Stop before chaining when**
- Creating records the user has not approved.
- The next step happens in the ACA app (connecting senders, imports, activation).

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, stage, lead_list_id, campaign_id, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`, `create_lead_list`, `add_contacts_to_list`
- `bulk_create_contacts`
- `list_campaigns`, `list_sequences`

## ACA app pages

- Offer and ICP: `https://www.automatedclientacquisition.com/assets?tab=products`, `?tab=icps`
- Find prospects: `https://www.automatedclientacquisition.com/list-building`, `/leads/import`
- Connect senders: `https://www.automatedclientacquisition.com/accounts`, `/email/mailboxes`
