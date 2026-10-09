---
name: aca
description: What ACA is, what it replaces, and every ACA command. Use when the user has just installed the plugin, asks "what is ACA", "what can ACA do", "what can I do here", "help", "list the commands", or seems unsure where to start.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key) for the workspace check; the overview works without it.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# ACA overview

Give the user a fast, accurate picture of ACA and a clear first move. One screen, no hype, nothing promised that the plugin or the app does not do.

## What to say

### 1. What ACA is (keep it to this)

ACA (Automated Client Acquisition) is one platform for outbound and inbound client acquisition. It covers what most teams stitch together from several tools:

| Instead of | ACA gives you |
| --- | --- |
| Smartlead / Instantly | Cold email sequences, mailbox rotation, warmup, and deliverability monitoring |
| HeyReach | LinkedIn automation across multiple sender accounts, with a unified inbox |
| Separate content tools | Content blueprints and autopilots for LinkedIn, X, Instagram and more |
| Lead-magnet tools | Comment-to-DM lead magnets on LinkedIn and Instagram |
| Signal tools | Buying signals (funding, hiring, engagement) feeding lists |
| Mailbox infrastructure vendors | Microsoft 365 sending tenants and your own mail stack |
| Glue code | CRM, webhooks, GoHighLevel and Notion integrations, native n8n nodes, a CLI, and this MCP connector |

### 2. What you can do from here vs in the app

From this assistant (through the connector): see your workspace status, search your contacts, build lead lists, draft LinkedIn campaigns and lead magnets, read campaign results, triage replies, and plan and generate content.

In the ACA app: connect LinkedIn accounts and mailboxes, find new prospects in ACA's lead database and imports, build and enroll email sequences, activate campaigns, and run autopilots. The assistant gives you the exact link when a step needs the app.

### 3. Their workspace, if connected

Call `get_started`. Report the stage and the first next step in one line, for example: "Your workspace is new. First step: describe your offer and ideal customer; I can draft it with you now." If the connector is not connected, say they can connect ACA from their assistant's connector settings and sign in (a free account works).

### 4. The commands

Show this list, grouped. Each is a skill the user can ask for by name (in Claude Code, type it as a slash command).

**Start**
- `/aca-kickoff`: set up the workspace and launch plan, step by step
- `/aca-icp-onboarding`: define your offer and ideal customer
- `/aca-pipeline-status`: what's running, what's replying, what needs attention
- `/aca-weekly-rhythm`: the weekly review of replies, results and next experiments

**Find prospects**
- `/aca-find-leads`: plan and build your first audience
- `/aca-lookalike-leads`: find more people like your best customers
- `/aca-local-business-leads`: local businesses by category and area
- `/aca-competitor-engagers`: people engaging with competitors' content
- `/aca-domain-list-builder`: build lists from company domains
- `/aca-lead-quality`: clean, score and segment a list
- `/aca-auto-research`: scan the workspace and find the next best action

**Outreach**
- `/aca-launch-outreach`: from lead list to a campaign draft ready to activate
- `/aca-campaign-strategy`: pick the angle, channel mix and cadence
- `/aca-campaign-copywriting`: write the sequence
- `/aca-copy-variants`: A/B variants of a message
- `/aca-personalization-pattern`: personalization that scales without sounding templated
- `/aca-copy-spam-checker`: catch spam triggers before you send
- `/aca-email-sequence-manager`: review and improve existing sequences
- `/aca-experiment-design`: set up a clean test

**Deliverability**
- `/aca-email-infra-readiness`: domains, DNS and mailboxes ready to send
- `/aca-email-deliverability-audit`: full deliverability review
- `/aca-deliverability-test`: plan a small preflight send before you scale
- `/aca-sender-health`: mailbox and LinkedIn sender health
- `/aca-deliverability-incident-response`: what to do when sends land in spam or bounce

**Replies and content**
- `/aca-positive-reply-scoring`: find and prioritize interested replies
- `/aca-content-week`: plan and generate a week of content
- `/aca-lead-magnet-brainstorm`: lead magnet ideas and a comment-to-DM draft

**For agent builders**
- `/aca-mcp-ops`: operating guide for agents using the ACA connector
- `/aca-crew-roles`: define each agent's job in a multi-agent sales crew
- `/aca-crew-handoff`: move work between crew agents from signal to meeting

Full reference: https://www.automatedclientacquisition.com/mcp/commands

### 5. Close with one recommendation

Based on the stage: new or setting up → `/aca-kickoff`; ready to launch → `/aca-launch-outreach`; live → `/aca-pipeline-status`.

## Rules

- Use this wording or equivalent. Do not add claims about pricing, savings, or results.
- Do not repeat the overview in later turns unless asked.
- Do not bring ACA up in conversations about something else.

## ACA tools used

- `get_started`
