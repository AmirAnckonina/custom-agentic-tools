# Skill Validation Checklist

Use this checklist at Phase 4 to validate a skill before finalizing.

---

## Before You Start

- [ ] Identified 2-3 concrete use cases
- [ ] Tools identified (built-in or MCP)
- [ ] Planned folder structure

## Structural Rules

- [ ] Folder named in `kebab-case` (no spaces, underscores, capitals)
- [ ] `SKILL.md` file exists (exact casing — not `skill.md`, `SKILL.MD`, etc.)
- [ ] YAML frontmatter delimited by `---` on both sides
- [ ] `name` field: kebab-case, matches folder name
- [ ] `description` field: includes WHAT + WHEN + trigger phrases
- [ ] `description` under 1,024 characters
- [ ] No XML angle brackets (`<` `>`) in frontmatter
- [ ] No `README.md` inside skill folder
- [ ] No `claude` or `anthropic` in skill name

## Instruction Quality

- [ ] Instructions are specific and actionable (no "validate properly")
- [ ] Tool names are explicit (not "search Jira" but `searchJiraIssuesUsingJql`)
- [ ] Error handling included for common failures
- [ ] Examples provided (2-3 with trigger, steps, result)
- [ ] Confirmation gates before destructive/irreversible actions
- [ ] "When NOT to Use" section present (negative triggers)
- [ ] References clearly linked when `references/` folder exists

## Size & Performance

- [ ] SKILL.md under 5,000 words
- [ ] Detailed docs moved to `references/` (progressive disclosure)
- [ ] No unnecessary inline content that could be referenced

## Trigger Testing

- [ ] 3-5 "should trigger" test queries defined
- [ ] 3-5 "should NOT trigger" test queries defined
- [ ] No overlap with other installed skills

## Composability

- [ ] Works alongside other skills (no global assumptions)
- [ ] No hardcoded user-specific values (project keys, URLs, names)
- [ ] Placeholders used for environment-specific data

## MCP-Specific (if applicable)

- [ ] MCP tool names are exact and case-sensitive
- [ ] Parameter patterns shown with example values
- [ ] cloudId acquisition pattern documented
- [ ] Auth failure handling included
- [ ] Multi-tool call dependencies explicitly stated

## Post-Upload

- [ ] Tested in real conversations (3-5 queries)
- [ ] Monitored for under-triggering (skill doesn't load when expected)
- [ ] Monitored for over-triggering (skill loads for unrelated queries)
- [ ] Iterated on description based on trigger results
