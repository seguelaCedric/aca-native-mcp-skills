# Writing skills for the ACA connector

Skills in this plugin run against the ACA OAuth connector
(`https://mcp.automatedclientacquisition.com/mcp`). It serves a curated set of
35 tools, listed in `scripts/v1-tools.json`. The older API-key server has ~150
tools; none of those extra tools exist for plugin users. `scripts/check-tools.mjs`
fails if a skill names one.

## Rules every skill follows

1. **Start with `get_started`.** It returns the workspace stage, counts
   (ICPs, products, contacts, lead lists, campaigns, active campaigns, connected
   LinkedIn accounts, mailboxes), plan, and up to three next steps. If the tool
   is missing (older server), fall back to `get_workspace` plus the relevant
   `list_*` tools.
2. **One workspace per connection.** There is no org switching. To work in a
   different workspace, the user changes their active workspace in ACA and
   reconnects.
3. **Never invent data.** People, emails, companies and metrics come from the
   user or from ACA. Report counts exactly as returned.
4. **Ask before any write.** Campaigns and lead magnets are created as inactive
   drafts. Sending, activation, enrollment and imports happen in the ACA app.
5. **When the connector can't do it, hand off cleanly.** Do the thinking in chat
   (copy, ICP, criteria, plan), then give the exact ACA page to finish it.
   Never pretend an action happened.
6. **Mention plans only when a tool result includes `plan_note` or
   `plan.upgrade`.**

App base URL: `https://www.automatedclientacquisition.com`

## Legacy tool → what to do now

| Need | Legacy tools | Now |
| --- | --- | --- |
| Workspace / help | `get_help`, org listing and switching | `get_started`, `get_workspace` |
| Offer, ICP, brand voice, characters | `list_/create_/update_` products, ICPs, brand voices, characters; fit scoring | Draft in chat; user saves at `/assets?tab=products`, `/assets?tab=icps`, `/assets?tab=brands`. `get_started` reports whether ICPs/products exist |
| Strategy / plan docs, knowledge | strategy and knowledge document tools | Write the plan in chat; user can save it at `/assets?tab=strategies` or `/assets?tab=knowledge` |
| Find contacts already in ACA | `list_leads`, `search_contacts_and_leads`, `get_lead` | `search_contacts`, `get_contact` |
| Add people the user provides | `create_lead`, `bulk_create_leads` | `create_contact`, `bulk_create_contacts` (≤100, user-supplied data only) |
| Tags, notes, stage | tag add/remove, `add_contact_note`, pipelines | `list_tags`; `update_contact` (replaces the whole `tags` array, so read first); `list_pipeline_stages` then `update_contact_stage`; notes at `/contacts/{id}` |
| Lead lists | list/get/create/add | `list_lead_lists`, `get_lead_list`, `create_lead_list`, `add_contacts_to_list`. Edit/remove/delete at `/leads/lists` |
| Discover new prospects | lead pool search/build, LinkedIn and Apify imports and their jobs, lead processing setup | Help define criteria in chat; user runs it at `/list-building` (database search) or `/leads/import` (LinkedIn/CSV). Then `search_contacts` / `list_lead_lists` to pick up results |
| Email sequences | list/get | `list_sequences`, `get_sequence` |
| Write/edit/enroll sequences | create/update/duplicate/toggle sequences, enrollments, `enroll_leads` | Write the copy in chat; user builds and enrolls at `/email/sequences` |
| LinkedIn campaigns | `list_campaigns`, `get_campaign` | Same, plus `get_campaign_metrics` |
| Create a campaign | `create_campaign` | `create_linkedin_campaign_draft` (needs `lead_list_id`; inactive, no steps). Steps, settings, activation at `/campaigns/{id}` |
| Change/pause/delete campaigns, campaign leads | update, status, delete, campaign leads | `/campaigns/{id}` |
| Senders and mailboxes | sender accounts, LinkedIn connections, mailboxes, publishing accounts | `list_connected_accounts` (LinkedIn and social accounts, with ids); mailbox count from `get_started`; manage at `/accounts` and `/email/mailboxes`; deliverability at `/email/analytics` |
| Replies | `list_conversations`, `get_conversation` | `search_conversations` (`has_inbound_message: true` for replies), `get_conversation` |
| Send a reply | `send_conversation_reply` | Draft in chat; user sends from `/inbox` |
| Content ideas | idea tools | `list_content_ideas`, `create_content_ideas` (≤25) |
| Blueprints | list/get/create/update/delete | `list_blueprints`, `get_blueprint`, `create_blueprint` (inactive draft); edit and activate at `/blueprints/{id}` |
| Generate content | `trigger_content_generation`, generation jobs | `start_content_generation` (active blueprint only; billable, confirm first), `list_content_generation_jobs` |
| Autopilots, publishing, GHL | autopilot, pool, publishing, GHL tools | `/autopilots`, `/publish-queue` |
| Lead magnets | list/get/create | `list_lead_magnets`, `get_lead_magnet`, `create_lead_magnet_draft` (needs a connected `account_id`, inactive). Edit/activate at `/lead-magnets` |
| AI reply agents | agent profile list/create | `list_agent_profiles`, `create_agent_profile`; edit in the app |
| Signals | `push_public_signal` | `/signals` |

## Skill frontmatter

```yaml
compatibility: Requires the ACA connector (OAuth sign-in, no API key).
```

End each skill with an `## ACA tools used` section listing only connector tools,
and an `## ACA app pages` section for handoffs, when it uses any.
