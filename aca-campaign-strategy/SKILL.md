---
name: aca-campaign-strategy
description: "Design an ACA campaign strategy before copy or launch. Use when the user asks for campaign strategy, outbound angle, channel mix, offer framing, target list plan, or success metrics. Reads the workspace, writes the plan in chat, and routes to the next skill."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA campaign strategy

Turn the offer, ICP, and available channels into a practical outbound plan that routes to concrete ACA actions: a list, a campaign, a sequence, or content.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- This skill is read-only in ACA. The plan lives in chat; the user can save it at `/assets?tab=strategies`.
- Never invent metrics, benchmarks presented as the user's data, or proof points. Report ACA counts exactly as returned.
- Prefer one primary angle and one backup angle.
- The connection is bound to one workspace. If the user wants a different one, they switch their active workspace in ACA and reconnect.

## Workflow

### 1. Read the workspace

Call `get_started`. Note `stage`, `counts` (icps, products, contacts, lead_lists, campaigns, active_campaigns, sender_accounts, mailboxes), and `next_steps`. If it is not available, call `get_workspace`, `list_lead_lists`, `list_campaigns`, and `list_sequences`.

Then, as relevant:

- `list_lead_lists` for candidate audiences and their sizes.
- `list_campaigns` and `list_sequences` to see what has already run.
- `get_campaign_metrics` on one or two past campaigns if the user wants the plan to learn from them. Use the counts as returned; do not compute rates without the matching denominator.

The connector reports whether ICPs and products exist, not their content. Ask the user for the offer and ICP in one message if they are not in the conversation already.

### 2. Pick the campaign path

- LinkedIn-first: a connected LinkedIn account and a list of people with LinkedIn profiles.
- Email-first: a connected mailbox and contacts with verified emails.
- Multi-channel: both, LinkedIn connection first, email as the follow-up channel.
- Lead magnet or inbound: a resource worth opting into; route to `aca-lead-magnet-brainstorm`.
- Content-supported nurture: the audience needs trust before outreach; route to `aca-content-week`.

Base the choice on what `get_started` shows is connected, not on preference alone.

### 3. Define the plan

- Audience: titles, company size, industry, geography, disqualifiers.
- Offer: what is being sold and the one outcome it produces.
- Pain: the specific problem the audience already feels.
- Proof: only proof the user supplies (customers, results, credentials).
- CTA: one low-friction ask.
- Sequence length and spacing per channel.
- Suppression rules: existing customers, open deals, competitors, people already in active campaigns.
- Primary angle and backup angle.

### 4. Define success metrics

Reply rate, positive reply rate, booking rate, list quality (valid emails, ICP fit), and sender health. Set a target and a stop rule for each (for example, "pause and rewrite if positive replies stay at zero after 150 contacted"). Make clear these are targets, not results.

### 5. Hand off

Show the plan in chat. Offer to keep it as a strategy document; the user saves it at `https://www.automatedclientacquisition.com/assets?tab=strategies`. If the offer or ICP is not saved yet, point to `/assets?tab=products` and `/assets?tab=icps`.

## Output format

```text
Campaign strategy: {name}
Workspace: {workspace} ({stage})
Audience: {audience}
Primary angle: {angle}
Backup angle: {angle}
Channel path: {path}
Sequence: {touches and spacing}
Primary metric: {metric and target}
Have: {lead_lists} lists, {sender_accounts} LinkedIn, {mailboxes} mailboxes
Needed before launch: {missing_items with app link}
Next: {aca-find-leads | aca-campaign-copywriting | aca-launch-outreach}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the plan when continuing into another ACA skill.

**Upstream**
- Called after `aca-kickoff`, `aca-icp-onboarding`, `aca-lead-quality`, or `aca-auto-research`.

**Auto-continue conditions**
- No audience or list exists: continue to `aca-find-leads`.
- Audience exists but quality is unclear: continue to `aca-lead-quality`.
- Strategy approved and copy missing: continue to `aca-campaign-copywriting`.
- Strategy, copy, senders, and audience ready: continue to `aca-launch-outreach`.

**Stop before chaining when**
- The user has not approved the plan.
- Changes to existing live campaigns are needed; those happen at `/campaigns/{id}`.

**Downstream skills**
- `aca-find-leads`: build the audience for this strategy.
- `aca-campaign-copywriting`: write the message sequence.
- `aca-email-deliverability-audit`: check email readiness before launch.
- `aca-launch-outreach`: set up the ACA campaign.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, stage, lead_list_id, campaign_id, sequence_id, plan, approvals, constraints}
```

## ACA tools used

- `get_started`, `get_workspace`
- `list_lead_lists`
- `list_campaigns`, `get_campaign_metrics`
- `list_sequences`

## ACA app pages

- Save the plan: `https://www.automatedclientacquisition.com/assets?tab=strategies`
- Offer and ICP: `https://www.automatedclientacquisition.com/assets?tab=products`, `?tab=icps`
- Existing campaigns: `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`
