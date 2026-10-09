---
name: aca-content-week
description: Generate a week of on-brand content in ACA. Use when the user says "generate this week's content", "I need [N] LinkedIn posts about [topic]", "write a content batch", "fill the content queue", "make ad creatives for [product]", or asks for multi-piece content tied to a brand voice. Plans ideas, matches them to an ACA blueprint, and starts generation through the ACA connector.
license: MIT
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
metadata:
  author: ACA
  version: "1.1"
  homepage: https://www.automatedclientacquisition.com/mcp
---

# Generate a week of content in ACA

ACA's content engine produces on-brand assets through blueprints. This skill plans an idea batch, saves it, starts generation on a matching active blueprint, and tracks the jobs. Scheduling and publishing happen in the ACA app.

## Rules

- Use the ACA connector only. Never ask for vendor API keys or run SQL/API calls.
- Ask before any write. Show the idea batch before `create_content_ideas`.
- Match the requested format to a real blueprint and its pipeline. Never silently use the wrong one.
- `start_content_generation` only runs on an active blueprint, sends prompts to AI providers, and consumes billable credits that cannot be undone. Confirm the blueprint, pipeline, item count, and that it costs credits before every call.
- A blueprint created here with `create_blueprint` is an inactive draft. The user reviews and activates it at `/blueprints/{id}` before it can generate.
- Generated content stays unapproved and unpublished. Approval, autopilots, scheduling, and publishing happen at `/autopilots` and `/publish-queue`.
- For long-running video jobs, set expectations and check `list_content_generation_jobs` no faster than every 30 seconds.
- If a tool result includes `plan_note` or `plan.limitation`, relay it as a plain fact. Never promote plans, pricing, or upgrades.

## Workflow

### 1. Clarify the brief

Capture:

- Format: LinkedIn posts, tweets, carousels, videos, ads, articles
- Topic or theme
- Count (default 5 for a week)
- Offer and buyer context
- Brand voice to match

Call `get_started` to see whether the workspace has products and ICPs. Brand voice and product details are not readable through the connector; if the user has not described them, ask for a short summary or route to `aca-icp-onboarding`.

### 2. Pick the blueprint

Call `list_blueprints` (use `active_only: true` when you only want ones that can generate now), then `get_blueprint` on the likely match to confirm its pipeline and purpose.

Connector pipelines: `social_media_post`, `rich_article`, `instagram_carousel`, `image_only`, `ugc_video`, `generative_video_oneshot`, `video_script`, `storyboard_video_longform`.

- Active blueprint matches: use it.
- Only an inactive match exists: tell the user to activate it at `/blueprints/{id}`.
- No match: draft a blueprint in chat (name, description, pipeline, master prompt). After approval, call `create_blueprint`; it lands as an inactive draft for the user to review and activate.

### 3. Build the idea batch

Call `list_content_ideas` to avoid duplicating existing ideas. Draft slightly more ideas than needed. Each idea has:

- Short title
- Keywords
- Content framework (for example: contrarian take, story, how-to, teardown, listicle)
- Emotional triggers or angle

Show the batch and ask which to keep. After approval, call `create_content_ideas` (up to 25 per call).

### 4. Start generation

Confirm cost first: "This starts {N} items on {blueprint} ({pipeline}) and uses billable credits. Go?"

After a clear yes, call `start_content_generation` with `blueprint_id`, `pipeline`, and `items` (up to 10 per call; each item carries an `idea_id` or `idea_title`).

Track progress with `list_content_generation_jobs`. Report statuses as returned.

### 5. Review and schedule in the app

Generated pieces are unapproved and unpublished. Send the user to review them, then schedule or publish at `/publish-queue`, or set up a recurring autopilot at `/autopilots`.

Suggested posting slots if the user asks:

- LinkedIn: Tue to Thu, 8am or 12pm user-local
- X/Twitter: Mon to Fri, 9am or 3pm user-local
- Instagram: Wed to Sun, 11am or 7pm user-local

## Output format

```text
Content batch: {theme}
Format: {format} ({pipeline})
Blueprint: {blueprint} ({active|draft, activate at /blueprints/{id}})
Ideas saved: {N}

Jobs:
- {job_id}: {idea_title} - {status}

Next: {track | review and schedule at /publish-queue | activate blueprint}
```

## Skill chaining

Preserve the workspace, relevant IDs, the user's brief, and approval state when continuing into another ACA skill. If the user asked for execution and a downstream condition is met, continue into the next skill; otherwise end with the handoff block.

**Upstream**
- Called by `aca-kickoff`, `aca-weekly-rhythm`, `aca-auto-research`, `aca-lead-magnet-brainstorm`, or campaign plans that need supporting content.

**Auto-continue conditions**
- No offer, ICP, or brand context: continue to `aca-icp-onboarding`.
- Jobs started: continue to `aca-pipeline-status` for tracking.
- Content supports an outbound offer: continue to `aca-campaign-strategy`.

**Stop before chaining when**
- Saving ideas or creating a blueprint the user has not approved.
- Starting billable generation without a confirmed yes.
- The next step is approval, scheduling, or publishing (app only).

**Downstream skills**
- `aca-icp-onboarding`: create missing context.
- `aca-pipeline-status`: track generation jobs.
- `aca-campaign-strategy`: use content as campaign support.
- `aca-weekly-rhythm`: add content into the operating cadence.

**Handoff block**

```text
Chain state: {continue|needs_approval|blocked|complete}
Next skill: {aca-skill-name|none}
Reason: {why this handoff is or is not needed}
Carry forward: {workspace, blueprint_id, pipeline, idea_ids, job_id, approvals, constraints}
```

## ACA tools used

- `get_started`
- `list_blueprints`, `get_blueprint`, `create_blueprint`
- `list_content_ideas`, `create_content_ideas`
- `start_content_generation`, `list_content_generation_jobs`

## ACA app pages

- Edit or activate a blueprint: `https://www.automatedclientacquisition.com/blueprints/{id}`
- Review, schedule, publish: `https://www.automatedclientacquisition.com/publish-queue`
- Autopilots: `https://www.automatedclientacquisition.com/autopilots`
- Brand voice and products: `https://www.automatedclientacquisition.com/assets?tab=brands`, `?tab=products`
