# Commit messages

Use **Conventional Commits** format. Every commit subject follows `<type>(<scope>): <description>`, and the body explains the _why_, not the _what_.

## Subject format

```
<type>(<scope>): <description>
```

- **`<type>`** — one of `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `style`, `perf`.
- **`<scope>`** — optional. The area of the codebase touched (`auth`, `api`, `deps`, `tooling`). Omit when the change is repo-wide or hard to scope cleanly.
- **`<description>`** — imperative, lowercase, no trailing period. Reads like a command.

Subject ≤ 72 characters. Longer than that goes into the body.

For breaking changes, append `!` to the type/scope (e.g. `feat(api)!: drop legacy endpoint`) or include a `BREAKING CHANGE:` footer in the body.

### Type semantics

| Type       | When to use                                                            |
| ---------- | ---------------------------------------------------------------------- |
| `feat`     | New user-visible capability or behavior.                               |
| `fix`      | Bug fix — something was broken, now it isn't.                          |
| `chore`    | Maintenance: deps, config, CI, tooling that isn't documented behavior. |
| `docs`     | Documentation only (READMEs, comments, ADRs, rules).                   |
| `test`     | Test additions or fixes that don't change product behavior.            |
| `refactor` | Restructuring without behavior change.                                 |
| `style`    | Formatting, whitespace, no logic change.                               |
| `perf`     | Performance improvement without behavior change.                       |

If a change spans multiple types, pick the dominant one. Don't split commits just to satisfy the type taxonomy — split when the _changes_ are independent.

## Body discipline

The subject says _what_; the body says _why_: the motivation, the constraint, the trade-off, the alternative considered and rejected.

- **Required** for any non-trivial commit (any `feat`, any `refactor` with reasoning, any `fix` with non-obvious cause).
- **Optional** for trivial commits (typo, formatter run, dependency bump where the type+scope is self-evident).
- Wrap body lines at 72 columns.
- Mention what _broke_ (for `fix`), what _triggered_ the change (for `chore`/`docs`), or what _constraints_ shaped the design (for `feat`/`refactor`).

## Examples

### ✅ Subject + body that explains why

```
feat(auth): add SSO login flow

Replaces the password-only flow because the security review flagged
phishable credentials. SSO is provided by the existing IdP; users
without an IdP account fall back to magic-link email.

The fallback is temporary — the next milestone removes password
fields entirely.
```

### ✅ Trivial commit, body optional

```
chore(deps): bump @types/node to 24.6.1
```

### ❌ "What" without "why"

```
fix(api): change response handling
```

What was wrong? What's the change? The body needs to answer.

### ❌ Past tense or non-imperative subject

```
feat(auth): added SSO login flow
```

Use `add`, not `added`. Subject is a command.

### ❌ Mixed unrelated changes in one commit

```
feat(auth): add SSO login and rename DB column
```

Two unrelated changes — split into two commits.

## When to skip the format

Skip Conventional Commits only when:

- The project has a **documented or strictly-enforced** different convention (CONTRIBUTING.md specifies otherwise, semantic-release config dictates types, the team has a written rule).
- The user explicitly asks for a different format.

Casual variation in `git log` is not "established convention." When existing commits don't match this rule, the rule wins — drift is what we're correcting.

## Related

For the workflow around creating PRs (branch hygiene, rebasing, selective staging), see the `github-pull-request` skill — it handles those concerns at PR-creation time.
