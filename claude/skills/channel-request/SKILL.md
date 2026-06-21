---
name: channel-request
description: "Compose and send structured requests to Slack channels. Use when: 'send request to [channel]', '/channel-request', 'compose request'. Supports per-channel format presets (added per workspace as you use it) so requests follow consistent conventions. Ensures concise, clear, actionable messages. Sends to self for review first, then to target channel."
---

# Channel Request

Compose and send structured, concise request messages to Slack channels. Always sends to user's DM first for review before posting to the target channel.

## Keywords

channel request, send request, compose request, slack request

## Workflow

### Step 1: Identify Target Channel

- If the user specifies a channel (e.g., "devops request"), resolve to the preset.
- If ambiguous, ask: "Which channel should this go to?"
- Use `slack_search_channels` to find the channel ID.

### Step 2: Gather Input

Collect from the user (or infer from conversation context):

1. **Priority** — P1 / P2 / P3 / P4 (required for channels that use priority)
2. **Background** — Why this request exists. 1-3 sentences max.
3. **Request** — The specific, actionable ask. Include code blocks if relevant.
4. **References** — Links (MRs, docs, Confluence). Make all links clickable using Slack `<url|label>` format.
5. **FYI tags** — People to tag. Use `slack_search_users` to resolve Slack IDs.

If context is available from the current conversation, compose directly and confirm — don't re-ask what's already known.

### Step 3: Compose Message

Apply these rules:
- **Concise** — no filler, no over-explanation. Every sentence earns its place.
- **Clear** — one request per message. If multiple asks, number them.
- **Actionable** — the reader knows exactly what to do after reading.
- **Scannable** — use bold labels, code blocks, bullet points.
- **Links must be clickable** — use `<url|display text>` Slack format.

### Step 4: Review

Send the composed message to the user's own DM first (use `slack_get_profile` with no args to resolve the invoking user's ID). Wait for approval or edits before sending to the target channel.

### Step 5: Send

Once approved, send to the target channel. Return the message link.

---

## Default Format (no preset yet)

When no channel preset exists yet, use this default structure:

```
[P{1-4}]  (omit if the channel doesn't use priority)
Hey Team,

{priority explanation — required for P1/P2, optional for P3/P4}

*Background:*
{1-3 sentences of context}

*Request:*
{specific ask, code blocks if needed}

*References:*
- <url|label>

FYI <@user1> <@user2>

Thanks!
```

Rules:
- Code blocks for any config/YAML changes
- Tag relevant stakeholders at the end
- If priority isn't applicable, drop the `[P{n}]` line entirely

---

## Adding Channel Presets

The first time you send a request to a given channel, no preset exists. After that send:

1. Ask the user if this channel has its own format conventions (or infer from how others post there).
2. After the user approves a format, save it as a memory (or a note in this file under a new "Channel Presets" section) keyed by channel name, so future requests to that channel reuse it without re-asking.
3. Follow the same review-before-send flow every time, preset or not.

---

## Examples

### Example 1: Request from conversation context
User: "send a request to #infra for adding the ca-bundle label to our namespace"
Actions:
1. Infer context from conversation (priority, root cause, what's blocked)
2. Compose message using the default format (or #infra's saved preset, if one exists)
3. Send to user DM for review
4. On approval, send to #infra
Result: Formatted request posted in channel

### Example 2: Explicit request with details
User: "/channel-request #platform P3 — need a new secret store for staging"
Actions:
1. Parse priority (P3) and channel (#platform)
2. Ask for any missing details (references, FYI tags)
3. Compose, review, send
Result: Formatted P3 request in channel

---

## When NOT to Use This Skill

- General Slack messages or DMs (not structured requests)
- Status updates or announcements (different format)
- Replying to existing threads
- Messages that don't target a request channel
