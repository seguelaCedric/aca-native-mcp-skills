# ACA Skill Chaining

The skills in this repo are designed to operate as a chain, not as isolated prompts.

Each `SKILL.md` includes a `Skill chaining` section with:

- Upstream skills that commonly call it
- Auto-continue conditions
- Stop-before-chaining conditions
- Downstream skills
- A handoff block to preserve context

## Chain Contract

When a skill finishes a step and another ACA skill is needed:

1. Preserve the selected ACA organization.
2. Carry forward relevant IDs: product, ICP, lead list, campaign, sequence, generation job, sender account, and strategy document.
3. Preserve approval state. Do not silently turn a draft into a live campaign unless the user already approved that action.
4. Continue automatically only when the user asked for execution and the next step does not require new approval.
5. If approval is needed, stop with a handoff block.

Every skill should end complex work with:

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## Primary Chain

```mermaid
flowchart TD
  kickoff["aca-kickoff"]
  icp["aca-icp-onboarding"]
  strategy["aca-campaign-strategy"]
  leads["aca-find-leads"]
  quality["aca-lead-quality"]
  copy["aca-campaign-copywriting"]
  spam["aca-copy-spam-checker"]
  personalize["aca-personalization-pattern"]
  sender["aca-sender-health"]
  audit["aca-email-deliverability-audit"]
  launch["aca-launch-outreach"]
  status["aca-pipeline-status"]
  weekly["aca-weekly-rhythm"]
  replies["aca-positive-reply-scoring"]
  experiment["aca-experiment-design"]

  kickoff --> icp
  kickoff --> leads
  kickoff --> strategy
  icp --> strategy
  strategy --> leads
  leads --> quality
  quality --> strategy
  strategy --> copy
  copy --> spam
  copy --> personalize
  spam --> launch
  personalize --> launch
  strategy --> sender
  sender --> audit
  audit --> launch
  launch --> status
  status --> weekly
  weekly --> replies
  replies --> experiment
  experiment --> copy
```

## Audience Chain

```mermaid
flowchart TD
  find["aca-find-leads"]
  local["aca-local-business-leads"]
  lookalike["aca-lookalike-leads"]
  domain["aca-domain-list-builder"]
  competitor["aca-competitor-engagers"]
  quality["aca-lead-quality"]
  strategy["aca-campaign-strategy"]
  launch["aca-launch-outreach"]

  find --> local
  find --> lookalike
  find --> domain
  find --> competitor
  local --> quality
  lookalike --> quality
  domain --> quality
  competitor --> quality
  quality --> strategy
  strategy --> launch
```

## Deliverability Chain

```mermaid
flowchart TD
  sender["aca-sender-health"]
  infra["aca-email-infra-readiness"]
  audit["aca-email-deliverability-audit"]
  test["aca-deliverability-test"]
  incident["aca-deliverability-incident-response"]
  spam["aca-copy-spam-checker"]
  quality["aca-lead-quality"]
  launch["aca-launch-outreach"]

  sender --> infra
  sender --> audit
  infra --> audit
  audit --> spam
  audit --> test
  test --> launch
  test --> incident
  incident --> sender
  incident --> spam
  incident --> quality
```

## Operating Chain

```mermaid
flowchart TD
  status["aca-pipeline-status"]
  auto["aca-auto-research"]
  weekly["aca-weekly-rhythm"]
  replies["aca-positive-reply-scoring"]
  experiment["aca-experiment-design"]
  content["aca-content-week"]
  leads["aca-find-leads"]
  incident["aca-deliverability-incident-response"]

  status --> auto
  status --> weekly
  status --> replies
  status --> incident
  weekly --> leads
  weekly --> content
  weekly --> replies
  weekly --> experiment
  replies --> experiment
  auto --> leads
  auto --> content
  auto --> incident
```
