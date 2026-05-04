---
name: aca-content-week
description: Generate a week of on-brand content for an ACA org. Use when the user says "generate this week's content", "I need [N] LinkedIn posts about [topic]", "write a content batch", "fill the content queue", "make ad creatives for [product]", or asks for multi-piece content tied to a brand voice. Uses ACA blueprints and publishing tools through one native ACA MCP connection.
license: MIT
compatibility: Requires the ACA MCP server connected with a valid bearer token. The ACA org should have at least one brand voice and one blueprint configured for the requested format.
metadata:
  author: ACA
  version: "1.0"
  homepage: https://aca.so/product/content
---

# Generate a week of content in ACA

ACA's content engine produces on-brand assets through blueprints. This skill creates an idea batch, triggers generation jobs, tracks them, and optionally schedules completed outputs.

## Rules

- Use ACA MCP only.
- Do not publish or schedule content without approval.
- Match the requested format to an actual blueprint. Do not silently use the wrong pipeline.
- For long-running video jobs, set expectations and poll no faster than every 30 seconds.

## Workflow

### 1. Clarify the brief

Capture:

- Format: LinkedIn posts, tweets, carousels, videos, ads, articles
- Topic/theme
- Count (default 5 for a week)
- Product/ICP context
- Brand voice
- Whether to auto-approve generation stages

### 2. Select library context

Call:

- `list_brand_voices`
- `list_products`
- `list_icps`
- `list_blueprints`
- `list_publishing_accounts` if scheduling is requested

Pick the blueprint that actually matches the requested pipeline.

### 3. Create the idea pool

Call `bulk_create_ideas` with slightly more ideas than needed. Each idea should include:

- Short title
- Keywords
- Key talking points
- Emotional trigger or angle
- Product/ICP/brand voice IDs when available

If the user wants control, show the idea list and ask which to keep. If they asked for speed, proceed.

### 4. Trigger generation

Call `trigger_content_generation` with:

- `blueprint_id`
- `pipeline`
- `items`
- `library_elements`
- `output_config`
- `auto_approve`

Track jobs with `list_generation_jobs` and `get_generation_job`. Valid status buckets include queued, processing, review, completed, and failed.

### 5. Optional scheduling

After jobs complete, ask before scheduling. Then call `push_to_ghl` with account IDs from `list_publishing_accounts`.

Suggested defaults if the user does not specify:

- LinkedIn: Tue-Thu, 8am or 12pm user-local
- X/Twitter: Mon-Fri, 9am or 3pm user-local
- Instagram: Wed-Sun, 11am or 7pm user-local

## Output format

```text
Content batch started: {theme}
Format: {format}
Brand voice: {brand_voice}
Blueprint: {blueprint}

Jobs:
- {job_id}: {idea_title} - {status}

Next: {track / approve / schedule}
```

## Skill chaining

This skill participates in the ACA chain. Preserve the selected ACA org, relevant IDs, user brief, approval state, and any generated artifacts when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill automatically; otherwise end with the handoff block.

**Upstream**
- Called by `aca-kickoff`, `aca-weekly-rhythm`, `aca-auto-research`, or content-support campaign plans.

**Auto-continue conditions**
- No brand/product/ICP context -> continue to `aca-icp-onboarding`.
- Jobs are launched -> continue to `aca-pipeline-status` for tracking.
- Content supports outbound offer -> continue to `aca-campaign-strategy`.

**Stop before chaining when**
- Ask before publishing or scheduling content.

**Downstream skills**
- `aca-icp-onboarding` - create missing content context.
- `aca-pipeline-status` - track generation jobs.
- `aca-campaign-strategy` - use content as campaign support.
- `aca-weekly-rhythm` - add content into the operating cadence.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {org_id/name, product_id, icp_id, lead_list_id, campaign_id, sequence_id, job_id, approvals, constraints}
```

## ACA tools used

- `list_brand_voices`, `list_products`, `list_icps`
- `list_blueprints`, `get_blueprint`
- `bulk_create_ideas`
- `trigger_content_generation`, `list_generation_jobs`, `get_generation_job`
- `list_publishing_accounts`, `push_to_ghl`
