# Knowledge freshness

Assume your internal knowledge is outdated. The JS/TS ecosystem moves fast enough that "I remember this works like X" is frequently wrong by the time someone asks. Verify current sources before stating facts or writing code that depends on them.

## Hard rule

Never claim a library, framework, tool, or API does or does not behave a certain way without checking first. This applies during exploration and planning, not just when writing code. "Let me check" is always cheaper than debugging stale information.

## What to verify

- APIs, config options, defaults, and recommended patterns for any framework, library, or tool
- CLI flags, command syntax, and tooling behavior (bundlers, package managers, linters, test runners)
- Version status — don't call something "the latest", "stable", or "experimental" without checking
- Time-sensitive guidance — security patterns, deployment flows, RFC-driven changes (RSC, Server Actions, hydration model)

## How to verify

| Source                     | Use for                                                                                      |
| -------------------------- | -------------------------------------------------------------------------------------------- |
| Context7 (`mcp__context7`) | Library / framework / SDK / API docs — version-specific                                      |
| `WebFetch`                 | A known URL (release notes, RFCs, migration guides) — skips the search                       |
| `gh` CLI                   | GitHub artifacts — releases, issues, PRs, source; `gh api` for raw REST                      |
| `pnpm info <pkg>`          | Package metadata — versions, peer deps, exports, deprecation status                          |
| `pnpm why <pkg>`           | Lockfile inspection — where a transitive dep comes from and at what version                  |
| Reading source             | Undocumented behavior, exact type signatures — `rg` in `node_modules/<pkg>/dist` or `gh api` |
| CLI `--help`               | Tooling / CLI questions — the binary is often the most current source                        |
| Web search                 | Blog posts, comparisons, "is X still maintained", time-sensitive content                     |

State the version or source you checked when it matters ("Next.js 16 docs say…", not "Next.js says…").

## When verified info contradicts internal knowledge

Trust the verified source. Don't hedge or split the difference. Update or remove memory entries that turn out to be wrong.

## When to skip verification

- Stable language fundamentals (JS/TS syntax, long-standing browser APIs, CSS basics)
- Project-internal questions where the codebase is the source of truth
- Conceptual explanations that don't depend on a specific version

If you're unsure whether something has changed, check.
