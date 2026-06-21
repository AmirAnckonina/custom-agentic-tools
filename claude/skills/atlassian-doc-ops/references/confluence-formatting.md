# Confluence Formatting Reference

## Storage Format Rules

Confluence pages use **storage format** (XML-based). When creating or updating
pages via MCP, content must be valid storage format — not raw markdown.

Key rules:
- Headings: `<h1>`, `<h2>`, `<h3>` tags
- Paragraphs: `<p>` tags
- Bold: `<strong>`, italic: `<em>`
- Line breaks: `<br />` (self-closing)
- Lists: `<ul><li>...</li></ul>` or `<ol><li>...</li></ul>`
- Tables: standard HTML table tags (`<table><tbody><tr><td>`)

---

## Essential Macros

### Table of Contents
Always place at the top of the page body:
```xml
<ac:structured-macro ac:name="toc">
  <ac:parameter ac:name="maxLevel">3</ac:parameter>
</ac:structured-macro>
```

### Info / Note / Warning Panels
```xml
<ac:structured-macro ac:name="info">
  <ac:rich-text-body><p>Info text here.</p></ac:rich-text-body>
</ac:structured-macro>

<ac:structured-macro ac:name="note">
  <ac:rich-text-body><p>Note text here.</p></ac:rich-text-body>
</ac:structured-macro>

<ac:structured-macro ac:name="warning">
  <ac:rich-text-body><p>Warning text here.</p></ac:rich-text-body>
</ac:structured-macro>
```

### Status Badge
```xml
<ac:structured-macro ac:name="status">
  <ac:parameter ac:name="colour">Green</ac:parameter>
  <ac:parameter ac:name="title">Active</ac:parameter>
</ac:structured-macro>
```
Colour options: `Green`, `Yellow`, `Red`, `Blue`, `Grey`

### Code Block (generic)
```xml
<ac:structured-macro ac:name="code">
  <ac:parameter ac:name="language">json</ac:parameter>
  <ac:plain-text-body><![CDATA[
{ "key": "value" }
  ]]></ac:plain-text-body>
</ac:structured-macro>
```

### Mermaid Diagram
```xml
<ac:structured-macro ac:name="code">
  <ac:parameter ac:name="language">mermaid</ac:parameter>
  <ac:plain-text-body><![CDATA[
graph TD
  A[Start] --> B[Process]
  B --> C[End]
  ]]></ac:plain-text-body>
</ac:structured-macro>
```

### Swagger / OpenAPI
```xml
<ac:structured-macro ac:name="open-api">
  <ac:parameter ac:name="url">https://example.com/api/swagger.json</ac:parameter>
</ac:structured-macro>
```
Use only when the user provides a real Swagger spec URL.
Fallback: render as a Mermaid sequence diagram.

### Expand (collapsible section)
```xml
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">Click to expand</ac:parameter>
  <ac:rich-text-body>
    <p>Hidden content here.</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

---

## Colored Table Cells

To color a table cell (e.g. in test plan priority rows):
```xml
<td style="background-color: #FFEBE6;">
  <p>🔴 P0</p>
</td>
```

Suggested palette:
| Priority | Background |
|---|---|
| P0 | `#FFEBE6` (light red) |
| P1 | `#FFF0E0` (light orange) |
| P2 | `#FFFAE6` (light yellow) |
| P3 | `#E6FFE6` (light green) |

---

## Mentions

```xml
<ac:link>
  <ri:user ri:account-id="[accountId]" />
</ac:link>
```
Obtain accountId via `atlassianUserInfo` or `lookupJiraAccountId`.

---

## Smart Links (Lucid, external tools)

```xml
<ac:link>
  <ri:url ri:value="https://lucid.app/lucidchart/[id]/view" />
</ac:link>
```
Only embed when the user provides the URL. Never fabricate.

---

## Update Safety Checklist

Before calling `updateConfluencePage`, verify:
- [ ] Fetched current page with `getConfluencePage`
- [ ] Used `version + 1` from the fetched page metadata
- [ ] Only modified the target section
- [ ] All macros outside the edit scope are preserved verbatim
- [ ] Table column count and structure unchanged if editing a table
- [ ] No raw markdown leaked into storage format content
