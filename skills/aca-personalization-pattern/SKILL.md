---
name: aca-personalization-pattern
description: "Apply ACA prompt-mode personalization patterns to outbound campaigns. Use when the user wants scalable personalization, dynamic campaign prompts, first-line personalization, AI-written DMs, or QA samples before launch. Reads real contact fields, writes step prompts, and QAs samples in chat before the user pastes them into the ACA builder."
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA personalization pattern

Personalize at scale with the ACA builder's Analyze contact step followed by prompt-mode messages. This skill checks which fields the contacts really have, writes tightly constrained prompts, and QAs sample outputs against real contacts before the user puts the prompts into a campaign.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Put an Analyze contact step before personalized messages when possible, so prompts have company and role context.
- Prompts must constrain length, tone, CTA, and prohibited claims.
- Samples use only fields ACA returns for real contacts. Never invent details about a person or company to make a sample look better.
- The connector cannot edit campaigns. Never say prompts were applied; give the page where the user pastes them.
- QA samples before the user activates anything.

## Workflow

### 1. Inspect the target

- Campaign: `list_campaigns`, then `get_campaign` for its `lead_list_id`, status, and step count.
- List: `get_lead_list` with a small `limit` to get member `contact_id`s and the `lead_count`.
- Sample 3 to 5 members with `get_contact`.

If the user has no list yet, use `search_contacts` to find a few representative contacts, or route to `aca-find-leads`.

### 2. Map available data

From the sampled contacts, record which fields are filled and how often: first name, job title, company, lead score, tags, stage, custom fields, recent activity. Analysis data from the Analyze contact step is only available at send time inside the campaign, so treat it as optional context in prompts, never as guaranteed.

Set risk:

- Low: title and company present on nearly every contact.
- Medium: gaps in title or company; prompts need fallbacks.
- High: mostly names only; personalization will be guesswork. Recommend enrichment or a simpler, non-personalized message.

### 3. Write step prompts

For each step (connection request, LinkedIn DM, email, follow-up), write a prompt that states:

- Length limit (for example under 250 characters, or 2 sentences)
- Tone (peer, plain, no emojis, no flattery)
- What to reference, in priority order, with a fallback when a field is missing
- What never to do: invent facts, mention posts or news it has not been given, claim familiarity, quote prices
- The single CTA

Example connection request prompt: "Write a LinkedIn connection request under 250 characters. Use the contact's job title and company if present; if not, refer to their industry in general terms. One specific business reason to connect. No pitch, no emojis, no compliments."

### 4. QA samples

For each sampled contact, write the message the prompt would produce using only that contact's real fields. Mark any sample where the prompt pushed toward an unsupported claim, and tighten the prompt.

### 5. Hand off

After the user approves:

- Paste the prompts into the steps at `https://www.automatedclientacquisition.com/campaigns/{campaign_id}` (draft or paused campaigns), with Analyze contact as the first step.
- If there is no campaign yet, continue to `aca-launch-outreach`.
- To keep the pattern as a reference, the user can save it at `https://www.automatedclientacquisition.com/assets?tab=strategies`.

## Output format

```text
Personalization pattern: {campaign_or_list}
Sampled: {n} contacts from {list_name}
Data available: {field: filled x of n}
Risk: {low/medium/high}

Step prompt ({step}):
{prompt}

Sample QA:
- {contact display_name}: {sample} ({ok | issue})

Paste into: {app link}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, approval state, and the prompts when continuing into another ACA skill.

**Upstream**
- Called by `aca-campaign-copywriting`, `aca-launch-outreach`, or `aca-experiment-design` when scalable personalization is needed.

**Auto-continue conditions**
- After prompts are drafted: continue to `aca-copy-spam-checker`.
- QA samples are acceptable and no campaign exists yet: continue to `aca-launch-outreach`.
- Data is too thin to personalize: continue to `aca-lead-quality`.

**Stop before chaining when**
- The user has not approved the prompts.
- The next step is pasting prompts into the ACA app.

**Downstream skills**
- `aca-copy-spam-checker`: check generated message risk.
- `aca-launch-outreach`: set up the campaign.
- `aca-experiment-design`: test personalization against a control.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why}
Carry forward: {workspace, lead_list_id, campaign_id, sampled contact_ids, prompts, approvals, constraints}
```

## ACA tools used

- `list_campaigns`, `get_campaign`
- `get_lead_list`
- `get_contact`, `search_contacts`

## ACA app pages

- Campaign steps: `https://www.automatedclientacquisition.com/campaigns/{campaign_id}`
- Save the pattern: `https://www.automatedclientacquisition.com/assets?tab=strategies`
