# Agent output formats

**When invoking a dev tool ad hoc, prefer its machine/agent-oriented
output format.** Default formats are decorated for human terminals —
colors, boxes, code frames — which costs tokens without adding signal.
This fires when you run a linter, type-checker, or test runner to check
your own work (post-edit verification, confirming a fix, exploring
diagnostics) — not when you run the project's own scripts.

## Preference order

1. **Purpose-built agent format** — `oxlint --format agent`,
   `vitest --reporter=agent`.
2. **Compact text** — `pytest -q --tb=short`, `playwright --reporter=line`.
3. **Default format** — when neither exists.

Verbose JSON (`--format json` on most tools) is machine-readable but
token-hostile — reach for it only when post-processing the output
(piping to `jq`, diffing runs), not for reading diagnostics.

## Known-good flags

Try these first. All verified 2026-06 via `--help` on then-current
versions (oxlint 1.68.0); if a flag is rejected by an older tool, fall
back to the default format and continue — never fail the check over
formatting. For tools not listed, check `--help` once for a
format/reporter option before the first invocation in a session.

| Tool       | Flag               |
| ---------- | ------------------ |
| oxlint     | `--format agent`   |
| tsc        | `--pretty false`   |
| Vitest     | `--reporter=agent` |
| pytest     | `-q --tb=short`    |
| Playwright | `--reporter=line`  |

## Examples

### ✅ Ad-hoc check after an edit

```sh
pnpm exec oxlint --format agent src/components/Button.tsx
```

### ❌ Injecting the flag into project-facing config

```jsonc
// package.json — do NOT do this
"lint": "oxlint --format agent ."
```

Project `lint` scripts, pre-commit hooks, and CI invocations are
human/CI-facing — leave them on the project's chosen format, and run
them as defined (`pnpm lint`, prek hooks) without injecting flags.

## When this rule does not apply

- **Running the project's own scripts** (`pnpm lint`, pre-commit hooks,
  CI commands) — run them as defined.
- **The user asks for a specific format** (e.g. `json` to post-process,
  `github` for annotations).
- **Output is the deliverable** — if the user wants to see the report,
  give them the human format.

## Related

- [`knowledge-freshness.md`](knowledge-freshness.md) — verify flag
  support with `--help` when the installed version is in doubt.
- [`setup.md`](setup.md) — oxlint/Vitest are the greenfield defaults;
  this rule governs how Claude invokes them day-to-day.
