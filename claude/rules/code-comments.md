# Code comments

**Good code has few comments. Write code that explains itself, and comment
only what the code cannot say.** AI-generated changes tend to narrate
themselves — a comment per block explaining what the next lines do, or why
the change is correct. That's the author talking to the reviewer; it's
noise the moment the change merges. Explanation belongs in documentation,
commit bodies, and PR descriptions — not in the source.

## The only comments worth writing

- **Decision context the code can't show** — a constraint, a trade-off, a
  workaround for an external limitation. State the constraint itself, not
  the story of how it was found. If the reasoning is architectural or
  shapes future work, it belongs in an ADR or doc instead — assess that
  first (see
  [`documentation-driven-development.md`](documentation-driven-development.md)).
- **Warnings about non-obvious invariants** — "order matters here because
  X", "this must stay in sync with Y".
- **Required directives** — `eslint-disable`, `@ts-expect-error`,
  `biome-ignore` — always with the reason inline.
- **Public API docs where the project convention requires them** —
  JSDoc/docstrings on exported contracts, matching the surrounding style.

Match the surrounding code's comment density — a sparsely commented file
should stay that way after your edit.

## Never write

- Comments that **narrate what the next line does** — the code already
  says it.
- Comments that **explain or justify your change** ("changed this to fix
  the bug", "now handles null") — that's the commit body's job.
- Comments that **restate names or types** (`// the user id` above
  `userId: string`).
- **Commented-out code** — delete it; git remembers.
- **Section banners** (`// ---- helpers ----`) in code that doesn't
  already use them.

## No tool or ticket references

Never reference external software or trackers in code or comments —
vendor/tool names (Jira, Figma, Slack, Notion, …) or task IDs
(`PROJECT-123`, `#4521`) — unless the user explicitly allows it. They leak
internal context into what may be a public repo, rot when the team
migrates tools, and are useless to a reader without access. Describe the
constraint itself instead of pointing at a ticket.

## Examples

### ✅ Constraint the code can't show

```ts
// Safari < 18 fires `resize` before layout settles; rAF defers past it.
requestAnimationFrame(measure);
```

### ❌ Narration and change-justification

```ts
// Loop over the items and filter out inactive ones
const active = items.filter((i) => i.active);

// Fixed: now we handle the empty case (JIRA-4521)
if (active.length === 0) return null;
```

Both comments restate the code; the second also justifies the change to a
reviewer and leaks a ticket reference.

## When this rule does not apply

- The user **explicitly asks** for commented, walkthrough-style code
  (teaching context, onboarding examples).
- The project has a **documented convention** requiring doc comments
  (public library APIs, generated docs from JSDoc) — follow it.
- The user **explicitly allows** tool or ticket references (some teams
  mandate ticket IDs in TODOs) — then follow the team's format.

## Related

- [`test-restraint.md`](test-restraint.md) — sibling restraint rule; same
  "the diff should carry only what earns its place" spirit.
- [`documentation-driven-development.md`](documentation-driven-development.md)
  — where the "why" goes when it outgrows a comment (ADRs, READMEs).
- [`commit-messages.md`](commit-messages.md) — the commit body is where
  change-justification lives, not the source.
