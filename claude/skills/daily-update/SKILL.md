---
name: daily-update
description: >
  Composes and sends structured daily status updates to Slack channels.
  Use when the user says "send daily update", "post standup", "daily update to [channel]",
  or "send update to [channel]". Searches Jira for relevant tickets, reads the channel's
  last message for tone/format, composes an emoji-sectioned message (Completed /
  In Progress / Blocked) with clickable ticket links and @mentions, sends to user DM
  for review, then posts to the target channel on approval.
  MCP required: Slack, Jira (Atlassian).
---

# Daily Update

## Overview

Composes and sends a structured daily status update to a Slack channel. Pulls context from Jira tickets and the channel's last message, drafts an emoji-sectioned update, reviews with the user via DM, then posts to the target channel.

## Keywords

daily update, standup, status update, send update, post update, daily standup, channel update, progress update

---

## Workflow

### Step 1: Identify Target Channel

- Resolve the channel name from the user's message.
- Use `slack_search_channels` (include `private_channel`) to find the channel ID.

### Step 2: Read Last Message

- Use `slack_read_channel` with `limit: 5` and `response_format: concise` to read recent messages.
- Note the tone, section structure, and any recurring people or ticket patterns.

### Step 3: Search Jira for Relevant Tickets

Run parallel JQL queries to gather context. Resolve the workspace's Jira `cloudId` first (via `getAccessibleAtlassianResources` or ask the user once, then remember it).

Suggested queries (adapt to the project key and keyword):
```
project = <PROJECT_KEY> AND text ~ "[project keyword]" AND updated >= -7d ORDER BY updated DESC
project = <PROJECT_KEY> AND assignee = currentUser() AND updated >= -7d ORDER BY updated DESC
```

Capture: ticket key, summary, status, assignee.

### Step 4: Resolve People Tags

- Use `slack_search_users` for any people to @mention.
- Format as `<@UXXXXXXX>` in the message body.

### Step 5: Compose the Update

Use this format exactly:

```
:clipboard: *[Channel/Project Name] Daily Update — {DD Mon YYYY}*

:white_check_mark: *Completed:*
• [item] (<url|TICKET-KEY>)

:arrows_counterclockwise: *In Progress:*
• [item] (<url|TICKET-KEY>)

:construction: *Blocked:*
• [item or person tag] — [reason] (<url|TICKET-KEY>)
```

Rules:
- All Jira links must use Slack clickable format: `<{JIRA_BASE_URL}/browse/TICKET-KEY|TICKET-KEY>`
- Tag people with `<@USERID>` not just names
- Keep bullets concise — one fact per line
- Only include sections that have content; omit empty sections
- Use today's date from the `currentDate` context variable

### Step 6: Send to User DM for Review

- Send to user's own DM first (resolve via `slack_get_profile` with no args) — never post directly to channel without review.
- Wait for approval or edits.

### Step 7: Apply Edits (if requested)

- Apply changes to the draft.
- If user asks to resend to DM, do so before posting to channel.

### Step 8: Post to Channel

- On explicit approval ("yes", "send it", "post it"), send to the target channel using `slack_send_message`.
- Return the message link.

---

## Examples

### Example 1: Standard daily update
```
User: "send daily update to #project-x"
Actions:
1. slack_search_channels → find channel ID
2. slack_read_channel → read last 5 messages for format
3. searchJiraIssuesUsingJql × 2 → gather recent tickets
4. Compose emoji-sectioned message with ticket links and @mentions
5. slack_send_message → DM to self for review
6. On approval → slack_send_message → channel
Result: Formatted update posted to #project-x
```

### Example 2: Update with inline edit
```
User: "also mention that X is done, and remove the last bullet"
Actions:
1. Apply edits to the last composed draft
2. Ask "Want me to resend to DM or post directly?"
3. Resend to DM / post to channel per user preference
Result: Revised message sent
```

---

## Edge Cases & Troubleshooting

### Channel not found
- Try `slack_search_channels` with partial name
- Ask user to confirm exact channel name

### Jira cloud ID error
- Use the workspace's domain-style `cloudId` (e.g. `yourcompany.atlassian.net`), not the UUID

### Slack read channel fails
- Retry with smaller `limit` (3) and `response_format: concise`

### User wants to skip DM review
- Only skip if user explicitly says "post directly" — default is always DM first

---

## When NOT to Use This Skill

- One-off Slack messages or DMs (not a daily update)
- Structured DevOps requests → use `channel-request` skill instead
- Replying to an existing Slack thread
- Messages with no Jira context needed

---

## Quick Reference

| Tool | Purpose |
|------|---------|
| `slack_search_channels` | Find channel ID by name |
| `slack_read_channel` | Read last messages for tone/format |
| `slack_search_users` | Resolve @mention user IDs |
| `slack_send_message` | Send to DM (review) or channel (final) |
| `searchJiraIssuesUsingJql` | Fetch relevant tickets |

**User DM:** resolve via `slack_get_profile`
**Jira cloudId:** resolve via `getAccessibleAtlassianResources` (or ask once and remember)
**Jira base URL:** `https://<your-workspace>.atlassian.net/browse/`
