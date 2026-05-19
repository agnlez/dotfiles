# Transient artifacts

Plans, scratch notes, MCP outputs, and other ephemeral artifacts must not land in the project working tree. Use a temporary directory outside the repo, so nothing transient can be accidentally staged, tracked, or shipped.

## Hard rule

Never write a file inside the current project (or any path that could be tracked by git) when its purpose is to support _your own_ working process rather than the codebase itself. If a file isn't going to be committed, it doesn't belong in the repo.

## Where transient files go

Use the system temp directory. Create a per-task subdirectory once and reuse it:

```bash
SCRATCH=$(mktemp -d)
echo "$SCRATCH"  # e.g. /var/folders/.../T/tmp.AbCdEf
```

Then write plans, intermediate notes, or downloaded artifacts under `$SCRATCH`. Mention the path to the user when it's useful (so they can inspect it). Don't try to keep these files around between sessions — they're scratch.

If a tool insists on a path (e.g. an MCP that writes to `./screenshots/`), pass it an absolute path under `$SCRATCH` rather than a relative one.

## What counts as transient

- **Plans and design notes you write to think** — `PLAN.md`, `NOTES.md`, `TODO.md`, scratch markdown drafts, brainstorm dumps.
- **MCP / tool outputs that aren't the deliverable** — Playwright screenshots, traces, videos, HAR files; Figma screenshots downloaded for reference; browser snapshots; generated diagrams used to reason about something.
- **Exploration artifacts** — `rg`/`fd` output dumps, schema introspections, dependency graphs you generated to read once.
- **Debug logs and intermediate dumps** — `output.log`, `debug.json`, copy-paste landing zones.
- **Agent intermediate outputs** — anything a subagent produces that doesn't need to be reviewed later.

## What is NOT transient

These belong in the repo and should be written there as normal:

- **ADRs** (`docs/adr/NNNN-*.md`) — see [`documentation-driven-development.md`](documentation-driven-development.md).
- **READMEs, CONTRIBUTING, project docs** under `docs/` or alongside code.
- **Test fixtures, snapshots, golden files** under `__fixtures__/`, `__snapshots__/`, `tests/fixtures/`, etc.
- **Project-tracked plan documents** — if the project already has `docs/plans/` or a similar convention, follow it.
- **Anything the user explicitly asks to be saved in the repo.**

## Before reporting completion

This fires alongside `superpowers:verification-before-completion`. Confirm nothing transient leaked into the working tree:

- `git status` — no unexpected untracked files in the repo.
- If you used MCP tools that write artifacts (Playwright, Figma screenshot downloads), confirm they landed under `$SCRATCH`, not the repo.
- If a transient file did land in the repo, move it to `$SCRATCH` (or delete it) before claiming done. Do _not_ "fix" it by adding to `.gitignore` — that hides the problem instead of solving it.

## When this rule does not apply

- The user **explicitly asks** for a plan or artifact to be saved in the repo (e.g. `docs/plans/feature-x.md`).
- The project has a **documented convention** for tracking plans or design notes in-tree (e.g. an RFC directory, a `decisions/` folder). Follow the project — flag the substitution if it's unusual.
- The artifact is a **deliverable of the task** — e.g. the user asked for a screenshot to include in a PR description, or asked you to generate a diagram for the docs. Then it belongs where the deliverable lives.

## Related

- [`documentation-driven-development.md`](documentation-driven-development.md) — distinguishes documentation that belongs in the repo (ADRs, READMEs) from transient working notes.
- [`secrets-handling.md`](secrets-handling.md) — sibling reasoning-level guardrail; same "don't let it leak into the tree" spirit.
- `github-pull-request` skill — staging discipline catches transient files at PR time, but this rule prevents them from being created in the repo in the first place.
- `superpowers:verification-before-completion` — the moment to confirm no transient artifacts are staged.
