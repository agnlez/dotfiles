# Setup defaults

When starting a greenfield JS/TS project — no existing `package.json`, or an explicit request to start from scratch — use the following defaults unless the user specifies otherwise. In existing projects, follow what the project already uses; don't migrate established choices to match these defaults.

If a higher-priority instruction (managed CLAUDE.md, project conventions, explicit user request) overrides any pick here, follow the override and flag the substitution to the user.

## Package manager and Node

- **Package manager**: pnpm via Corepack. Run `corepack enable && corepack use pnpm@latest` — this writes a `"packageManager"` field (e.g. `"packageManager": "pnpm@11.0.6"`) to `package.json` that pins the package manager version for every clone. Commit `pnpm-lock.yaml`.
- **Node version**: latest LTS, pinned in `.node-version` (portable across fnm, volta, asdf — preferred over `.nvmrc`).
- **Version manager**: fnm — install/switch with `fnm install --lts` and `fnm use`. With `--use-on-cd` set, `.node-version` is honored automatically on directory entry.
- **`pnpm-workspace.yaml` for every project** (including single-package repos): canonical home for pnpm settings. Set `savePrefix: ""` so `pnpm add` writes exact versions to `package.json`. Exact pinning across the board — no caret or tilde ranges.
- **`"type": "module"` in `package.json`**: ESM by default. Avoids the "why is this `.js` running as CommonJS?" surprise.

## Lint, format, git hooks

- **`.editorconfig`** at the repo root: 2-space indent, LF line endings, UTF-8, trim trailing whitespace, final newline. Foundational — every other tool defers to this.
- **Linter**: oxlint with default rules (`.oxlintrc.json` starts as just the `$schema` reference — only customize when a real need emerges).
- **Framework-specific lint plugins**: when scaffolding a Next.js (or other framework) project, add the relevant native plugins to `.oxlintrc.json`'s `plugins` array. A Next.js app, for example, typically uses `"plugins": ["nextjs", "typescript", "unicorn"]`. Two cautions: (1) the `plugins` array **overwrites** oxlint's defaults (`unicorn`, `oxc`, `typescript`), so re-add what you want to keep; (2) verify current plugin names, the available plugin list, and config syntax against oxlint docs before applying — oxlint is under active development and the config shape changes between releases. ESLint-ecosystem plugins go in `jsPlugins` (alpha, not subject to semver).
- **Formatter**: oxfmt with `proseWrap: "preserve"` and `printWidth: 80` (`oxfmt.json`).
- **Git hooks**: prek (`@j178/prek`), wired via `"prepare": "prek install"` in `package.json` so `pnpm install` auto-installs hooks for every clone.
- **`.pre-commit-config.yaml` baseline**: oxfmt (with `types_or: [javascript, jsx, ts, tsx, markdown, json, yaml, toml, css]` so it fires on the right files), oxlint, plus `trailing-whitespace`, `end-of-file-fixer`, and `check-merge-conflict` from `pre-commit-hooks`. Set `exclude: ^(pnpm-lock\.yaml)$` so formatters leave the lockfile alone.

## Tests

- **Vitest** as the default runner.
- Colocate `*.test.ts` next to the code they cover. Add a `vitest.config.ts` only when defaults aren't enough (custom resolve, jsdom environment, coverage thresholds).

## When this rule does not apply

- The project already has tooling — follow the project's lockfile, scripts, and config. Don't migrate.
- The project pins Node via `.nvmrc` instead of `.node-version` — read from `.nvmrc`, don't add a duplicate `.node-version` file. Drive with fnm either way (it reads both).
- The user asks for a specific tool — the user wins.
- A higher-priority instruction overrides a pick here — follow the override and surface the change to the user.
