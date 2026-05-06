---
alwaysApply: true
---

# Dependency Management

When exploring, evaluating, bumping, or migrating dependencies, always verify claims against current documentation. Never rely on training data alone.

## Hard rule

Never state that a library does or does not support a feature without checking first. Use Context7 or official docs to verify before making any capability claim. This applies during exploration and planning, not just when writing code.

## Before making changes

1. **Fetch current documentation** — use Context7 to get up-to-date docs for every dependency being touched
2. **Read changelogs and release notes** — identify breaking changes, deprecations, and required code modifications between the current and target versions
3. **Check peer dependency compatibility** — verify that the target version's peer requirements are satisfied by the rest of the dependency tree

## Migrations (major and minor bumps)

Before writing any custom migration steps:

1. Search for official migration guides, FAQs, or upgrade documentation
2. Check if official codemods or migration scripts exist (e.g., `npx @next/codemod`, `npx react-codemod`)
3. Run official codemods when available instead of manually rewriting code
4. Only write custom migration steps for gaps not covered by official resources

| Source to check | Examples |
|---|---|
| Migration guides | Next.js upgrade guide, React blog posts, library UPGRADING.md |
| Codemods | `@next/codemod`, `react-codemod`, `jscodeshift` transforms |
| Release notes | GitHub releases page, CHANGELOG.md |
| Community resources | GitHub issues, discussions tagged with the target version |

## After making changes

- Run existing tests to catch regressions
- Verify the application builds and starts correctly
- Flag any deprecation warnings introduced by the update
