# ACA Native MCP Skills

**One ACA MCP connection. 27 agent skills. Zero vendor API sprawl.**

ACA Native MCP Skills turns ACA (Automated Client Acquisition) into an agent-operable growth system for Claude, Codex, Cursor, Goose, and other skills-compatible runtimes.

Instead of wiring separate Smartlead, Prospeo, Zapmail, Apify, LinkedIn, GHL, and enrichment keys into every agent workflow, you connect ACA once. ACA handles auth, organization scoping, sender accounts, lead sources, content generation, publishing, and campaign execution through its native MCP server.

## What You Can Do

- Launch outbound campaigns from a plain-English brief.
- Build lead lists from ACA's native lead pool, LinkedIn imports, and account constraints.
- Grade and segment lists before sending.
- Create LinkedIn, email, and multi-channel ACA campaigns.
- Audit sender health and deliverability before launch.
- Generate weekly content through ACA blueprints.
- Score replies, design experiments, and run a weekly operating rhythm.

## Why This Exists

Most outbound agent stacks are a pile of brittle credentials and vendor-specific playbooks. ACA already centralizes the operational layer: CRM contacts, lead lists, campaigns, email sequences, sender accounts, content blueprints, autopilots, and publishing.

These skills give agents the procedural layer on top of ACA:

```text
User request -> Agent skill -> ACA MCP -> ACA workspace
```

No direct SQL. No separate vendor secrets in the skill bundle. No hardcoded workspace IDs.

## Skill Library

27 skills organized in 6 tracks.

### Strategy

- `aca-kickoff` - guided setup and routing: product, ICP, brand voice, channels, first plan
- `aca-icp-onboarding` - turn a rough buyer description into product, ICP, fit notes, and disqualifiers
- `aca-lead-magnet-brainstorm` - plan lead magnets and keyword-monitoring campaigns
- `aca-campaign-strategy` - design campaign angles, channel mix, list plan, and success metrics
- `aca-campaign-copywriting` - draft campaign prompts, emails, LinkedIn messages, and follow-ups

### Audience Building

- `aca-find-leads` - search the ACA lead pool first, then optionally import from LinkedIn
- `aca-lead-quality` - grade a lead list, segment it, and create campaign-ready sublists
- `aca-local-business-leads` - build geo/vertical local business lists from ACA-native lead sources
- `aca-lookalike-leads` - clone the shape of a winning list or customer segment
- `aca-domain-list-builder` - build account/contact lists from company keywords, domains, and account constraints
- `aca-competitor-engagers` - source people around competitors, alternatives, and category keywords

### Outreach Execution

- `aca-launch-outreach` - create and optionally activate LinkedIn, email, or multi-channel campaigns
- `aca-email-sequence-manager` - create, update, enroll, pause, and inspect email sequences
- `aca-personalization-pattern` - apply ACA campaign prompt-mode personalization with QA samples
- `aca-copy-variants` - create controlled copy variations for campaign experiments
- `aca-copy-spam-checker` - review email and DM copy for spammy language, weak claims, and formatting risks

### Deliverability and Sender Ops

- `aca-sender-health` - inspect connected senders, mailboxes, warmup, capacity, and obvious blockers
- `aca-email-deliverability-audit` - audit cold-email readiness and sequence risk before launch
- `aca-deliverability-test` - run a controlled preflight test plan for email sending
- `aca-deliverability-incident-response` - triage bounces, failed sends, reputation drops, and stalled campaigns
- `aca-email-infra-readiness` - checklist and readiness review for ACA-managed/BYO email infrastructure

### Content

- `aca-content-week` - generate a batch of posts, carousels, videos, ads, or other blueprint-driven content

### Operations and Iteration

- `aca-pipeline-status` - read-only status report across campaigns, imports, content jobs, and autopilots
- `aca-weekly-rhythm` - Monday/Wednesday/Friday operating cadence for experiments and cleanup
- `aca-positive-reply-scoring` - classify replies and surface campaign/list lessons
- `aca-experiment-design` - create one controlled outbound/content experiment with a clean metric
- `aca-auto-research` - autonomous research loop that finds gaps and routes to the next ACA workflow

## Quick Start

Clone the repo:

```bash
git clone https://github.com/seguelaCedric/aca-native-mcp-skills.git
cd aca-native-mcp-skills
```

Install into your runtime:

```bash
./install.sh codex
./install.sh claude
./install.sh cursor
```

Or install into all three local runtimes:

```bash
./install.sh all
```

For another skills-compatible runtime:

```bash
./install.sh --target ~/.your-agent/skills
```

Then configure ACA MCP once using `.mcp.example.json`.

## The One Required Connection

Create an ACA MCP API key in ACA under Settings -> MCP / API, then add the MCP server to your runtime:

```json
{
  "mcpServers": {
    "aca": {
      "url": "https://your-aca-domain.com/functions/v1/mcp",
      "headers": {
        "Authorization": "Bearer aca_mcp_sk_live_..."
      }
    }
  }
}
```

If you manage multiple client workspaces, the skills use `list_accessible_organizations` and `switch_organization` so the agent operates in the right ACA org.

## Recommended Paths

If you are new to ACA:

1. Run `aca-kickoff`
2. Follow the recommended next action: `aca-find-leads`, `aca-launch-outreach`, or `aca-content-week`
3. Run `aca-pipeline-status` after launch
4. Run `aca-weekly-rhythm` every week to review replies, experiments, and pipeline health

If you already have lead lists:

1. Run `aca-lead-quality`
2. Run `aca-launch-outreach`
3. Run `aca-pipeline-status`

If you already have campaigns running:

1. Run `aca-pipeline-status`
2. Run `aca-weekly-rhythm`
3. Use `aca-content-week` to keep social proof and nurture content moving

## Coverage Map

This project was inspired by the breadth of open cold-outbound skill bundles. In ACA, vendor-specific capabilities route through ACA MCP instead of separate API integrations.

| External-vendor workflow | ACA-native equivalent |
|---|---|
| Kickoff / starter kit | `aca-kickoff`, `aca-email-sequence-manager`, `aca-launch-outreach` |
| ICP onboarding and prompt building | `aca-icp-onboarding`, `aca-campaign-copywriting` |
| Campaign strategy and copywriting | `aca-campaign-strategy`, `aca-campaign-copywriting` |
| Prospeo-style lead search | `aca-find-leads`, `aca-local-business-leads`, `aca-domain-list-builder` |
| Domain-first contact discovery | `aca-domain-list-builder` |
| Google Maps style local lists | `aca-local-business-leads` |
| Lookalike company discovery | `aca-lookalike-leads` |
| Competitor/category audiences | `aca-competitor-engagers` |
| List scoring | `aca-lead-quality` |
| Smartlead-style sequence ops | `aca-email-sequence-manager`, `aca-launch-outreach` |
| Spintax / copy variants | `aca-copy-variants` |
| Spam phrase checking | `aca-copy-spam-checker` |
| Inbox/sender management | `aca-sender-health` |
| Deliverability audits/tests/incidents | `aca-email-deliverability-audit`, `aca-deliverability-test`, `aca-deliverability-incident-response` |
| Domain/infrastructure setup review | `aca-email-infra-readiness` |
| Positive reply scoring | `aca-positive-reply-scoring` |
| Weekly ops and experiments | `aca-weekly-rhythm`, `aca-experiment-design`, `aca-auto-research` |

## Package Metadata

This repo includes:

- `.codex-plugin/plugin.json` for Codex plugin discovery
- `.claude-plugin/plugin.json` for Claude Code plugin discovery
- `.claude-plugin/marketplace.json` as Claude-style marketplace metadata
- `package.json` for npm-style packaging and release scripts

Validate and build release artifacts:

```bash
npm run validate
npm run pack:release
```

Release artifacts are written to `dist/`:

```text
dist/aca-native-mcp-skills-1.0.0.tar.gz
dist/aca-native-mcp-skills-1.0.0.zip
```

## Guardrails

- Do not ask users for vendor API keys inside these skills. ACA stores provider credentials and exposes safe workflows through MCP.
- Do not use SQL, Supabase REST calls, or direct edge-function calls from a skill when an ACA MCP tool exists.
- Confirm before spending import budget, activating campaigns, publishing content, pausing live campaigns, or making bulk destructive changes.
- Keep workspace data scoped to the selected ACA organization. When switching orgs, switch back before finishing.

## Directory Layout

```text
aca-native-mcp-skills/
  README.md
  LICENSE
  .mcp.example.json
  package.json
  .codex-plugin/
    plugin.json
  .claude-plugin/
    plugin.json
    marketplace.json
  install.sh
  scripts/
    validate.sh
    package.sh
  aca-*/
    SKILL.md
```

## License

MIT.
