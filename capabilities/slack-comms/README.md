# Slack Comms

Two structured Slack message types — ad-hoc channel requests and recurring daily status updates — both reviewed by you in DM before they ever hit a real channel.

## What it includes

| Component | Type | Role | Source |
|---|---|---|---|
| `channel-request` | Skill | One-off structured channel requests | [→](../../claude/skills/channel-request/SKILL.md) |
| `daily-update` | Skill | Standup-style status updates | [→](../../claude/skills/daily-update/SKILL.md) |

## How it works

**[`channel-request`](../../claude/skills/channel-request/SKILL.md)** — composes a concise, actionable message (Priority / Background / Request / References / FYI tags) for a target channel. Learns and remembers per-channel format presets the first time you use it against a new channel, so future requests there follow the established convention automatically.

**[`daily-update`](../../claude/skills/daily-update/SKILL.md)** — pulls relevant Jira tickets (via JQL), reads the channel's last message to match tone/format, and composes an emoji-sectioned update (Completed / In Progress / Blocked) with clickable ticket links and @mentions.

Both **always send to your own DM first** for review — nothing posts to a real channel without explicit approval.

## Install

```bash
./install.sh slack-comms
```

## Requires

Slack MCP. `daily-update` additionally needs the [`atlassian`](../atlassian/README.md) capability if you want it pulling ticket context automatically (it'll skip that step gracefully without it).
