# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `claude/rules/agent-output-formats.md`: rule preferring machine/agent-oriented output formats when Claude invokes dev tools ad hoc (post-edit verification, confirming a fix) — preference order of purpose-built agent format > compact text > default, with verbose JSON reserved for post-processing; verified flag table (`oxlint --format agent`, `tsc --pretty false`, `vitest --reporter=agent`, `pytest -q --tb=short`, `playwright --reporter=line`); explicitly forbids injecting these flags into project scripts, pre-commit hooks, or CI, and carves out user-requested formats and output-as-deliverable
- `claude/settings.json`: set `model: "claude-opus-4-8"` to pin Opus 4.8 as the default model for every session
- `claude/settings.json`: enable `security-guidance@claude-plugins-official` plugin
- `bin/zfzf` + `install.sh` + `zellij/config.kdl`: floating fzf file picker for zellij. New `bin/` directory in the repo (each entry is symlinked into `~/.local/bin/` by `install.sh`); `zfzf` runs `fd | fzf --preview 'bat'`, then `zellij action toggle-floating-panes` + `write-chars` to insert the selection at the underlying pane's cursor. Bound to `Alt+T` in zellij's `shared_except "locked"` block via `Run "zfzf" { floating true; close_on_exit true }`. The zsh-side `Alt+T → fzf-file-widget` binding stays for shells outside zellij (Ghostty without a session, SSH, etc.)
- `claude/rules/transient-artifacts.md`: reasoning-level guardrail keeping plans, scratch notes, and MCP tool outputs (Playwright traces, Figma screenshots, exploration dumps) out of the project tree — directs ephemeral artifacts to `mktemp -d` under `$TMPDIR`, with explicit carve-outs for ADRs, READMEs, test fixtures, project-tracked plan documents, and artifacts that are themselves the deliverable; includes a `git status` check at completion time and forbids using `.gitignore` to paper over leaks
- `claude/CLAUDE.md`: `## User profile` section at the top — senior FE engineer (12y), React/Next App Router + RSC + TS, Tailwind + shadcn, dashboards/data-viz/GIS domain, with library defaults (Recharts or Visx/D3 for charts, Mapbox GL or MapLibre for maps, deck.gl for map data layers). Promoted from project-scoped auto-memory so it loads globally for every Claude Code session
- `claude/settings.json`: allow `Bash(eza:*)`, `Bash(rg:*)`, and `Bash(fd:*)` so the preferred `ls`/`grep`/`find` replacements (already declared in `claude/CLAUDE.md`'s tool preferences) run without permission prompts
- `zellij/config.kdl`: minimal zellij config — `theme "catppuccin-macchiato"` to match Ghostty, `default_shell "zsh"`; rest left at zellij defaults
- `zsh/.zshrc`: zellij auto-start block — exports `ZELLIJ_AUTO_EXIT=true` and runs `zellij setup --generate-auto-start zsh`; guarded with `$ZELLIJ` (no nesting), `$CLAUDECODE` (no wrapping inside Claude Code agent shells), and `$+commands[zellij]` (no error if zellij is uninstalled)
- `install.sh`: symlink `~/.config/zellij/config.kdl` → `zellij/config.kdl`
- `git/.gitconfig`: enable GPG signing for commits (`commit.gpgsign = true`) and rebases (`rebase.gpgsign = true`)
- `claude/settings.json`: enable `figma@claude-plugins-official` plugin
- `claude/settings.json`: set `skipAutoPermissionPrompt: true` to suppress the auto-permission prompt at session start
- `claude/skills/`: symlinks for `grill-me`, `grill-with-docs`, `improve-codebase-architecture`, `setup-matt-pocock-skills`, and `triage` pointing into the gitignored `.agents/skills/` directory so the skills source remains AI-managed while still being discoverable from `~/.claude/skills/` — `write-a-skill` discarded in favor of `superpowers:writing-skills`, which covers the same ground in greater depth (TDD-for-skills, CSO, token efficiency, rationalization closures)
- `zsh/.zshenv`: default `TERM` to `xterm-256color` when unset so non-interactive shells (e.g. agent/tool invocations) get a sane terminal type
- `claude/rules/knowledge-freshness.md`: rule consolidating verification of current sources before stating facts about libraries, frameworks, tools, or APIs — covers what to verify, how (Context7, WebFetch, `gh`, `pnpm info`/`why`, source reading, CLI `--help`, web search), conflict resolution when verified info disagrees with internal knowledge, and explicit carve-outs for stable fundamentals
- `claude/rules/barrel-files.md`: rule preferring direct imports over barrel files (`index.ts` re-exports) for app code, with carve-outs for library entry points and deliberately curated facades; covers dev-server cost, test isolation, tree-shaking reliability, and refactor friction
- `claude/rules/setup.md`: greenfield JS/TS defaults — pnpm via Corepack with `"packageManager"` pinning, fnm + `.node-version` for Node LTS, `pnpm-workspace.yaml` (with `savePrefix: ""` for exact pinning) even in single-package repos, `"type": "module"`, `.editorconfig` baseline, oxlint + oxfmt + prek with concrete config and hook wiring, framework-specific oxlint plugin guidance (Next.js example with overwrite-defaults caution and verification mandate), Vitest as the test runner; defers to higher-priority instructions and existing project tooling
- `claude/templates/adr.md`: lightweight ADR (Architectural Decision Record) template — Status/Date front-matter, Context, Decision, Alternatives Considered, Consequences. Lives at `~/.claude/templates/adr.md` after install for cross-project reuse
- `claude/templates/rule.md`: scaffold for new entries in `claude/rules/` — captures the canonical shape (optional `paths:` frontmatter, bold imperative lead with optional `## Hard rule` follow-up for reasoning-level guardrails, body sections, ✅/❌ examples, explicit "When this rule does not apply" skip clause, optional Related cross-references) with inline guidance on which shape fits which kind of rule
- `claude/templates/README.md`: index of the templates directory — table of templates with purpose and referenced-by columns, maintenance notes, and links to sibling directories
- `install.sh`: symlink `~/.claude/templates` → `claude/templates/`

### Changed

- `claude/settings.json`: switch the default model from Opus 4.8 to Fable 5 with the 1M-token context window (`claude-fable-5[1m]`)
- `claude/settings.json`: set `tui: "fullscreen"` to opt into the flicker-free alt-screen renderer with virtualized scrollback
- `zsh/.zshrc` + `bin/zfzf`: extend `FZF_DEFAULT_OPTS --bind` with preview-scroll keys — `ctrl-u`/`ctrl-d` for half-page, `shift-up`/`shift-down` for line-by-line. Same binds are also passed explicitly inside `zfzf` because zellij's `Run` inherits the server's env (captured at startup), so the global var doesn't propagate to floating panes after a `source ~/.zshrc`
- `zellij/config.kdl`: set `mouse_mode false` so the terminal (Ghostty) handles mouse events directly — restores clickable links and native text selection that zellij's mouse capture was intercepting
- `zellij/config.kdl` + `zsh/.zshrc`: stop unbinding `Ctrl+t` in zellij and move fzf's file-picker widget to `Alt+T` instead. `Ctrl+t` is back as zellij's Tab-mode entry; the zshrc snippet rebinds `fzf-file-widget` to `^[t` across `emacs`/`viins`/`vicmd` after sourcing `fzf --zsh`. `Ctrl+Shift+T` was the original ask but is indistinguishable from `Ctrl+T` in zsh without enabling the Kitty Keyboard Protocol + CSI-u bindings, so `Alt+T` was chosen as the portable equivalent
- `ghostty/config`: pin `command = /bin/zsh` so Ghostty spawns zsh directly instead of inheriting the system login shell — keeps the shell consistent across machines regardless of `/etc/passwd`
- `ghostty/config`: drop `no-cursor` from `shell-integration-features` so the shell integration can manage cursor style (e.g. beam in insert mode); `cursor-style = underline` still sets the baseline
- `zsh/.zshrc`: stop exporting `ZELLIJ_AUTO_ATTACH=true` so each new shell gets a fresh zellij session instead of re-attaching to an existing one — keeps tabs and panes scoped per Ghostty tab. `ZELLIJ_AUTO_EXIT=true` still closes the session when the shell exits
- `claude/settings.json`: set `skillListingBudgetFraction: 0.03` so the full set of plugin-supplied skills (vercel, superpowers, figma, atlassian, etc.) fits in the per-session skill listing instead of being truncated at the implicit 1% budget — costs ~15k extra tokens/session in exchange for keeping every skill description visible
- `claude/settings.json`: drop the bare `mcp__atlassian` and `mcp__context7` permission entries (now stale after removing duplicate top-level MCP registrations from `~/.claude.json`); rename `mcp__atlassian__*` ask-list entries to `mcp__plugin_atlassian_atlassian__*` so the existing permission posture continues to apply to the plugin-supplied Atlassian MCP tools
- `claude/rules/dependency-management.md`: slim down to migrations (prefer official codemods) and peer dependency verification; general "fetch docs / read changelogs" guidance moved to `knowledge-freshness.md`, post-change verification deferred to `superpowers:verification-before-completion`
- `claude/rules/`: strip Cursor-only `alwaysApply: true` frontmatter (no-op in Claude Code, which auto-loads every `.md` in `~/.claude/rules/`); add `paths:` scoping to `esm-exports.md` so it only loads when working with JS/TS source files
- `claude/rules/esm-exports.md`: rewrite around a strong "prefer named exports" default with concrete ✅/❌ examples (multi-export utility, single React component, barrel re-export, default-exported component, mixed default+named); reasons now cover refactor safety, re-export chain reliability, `import type` / `export type` per-symbol elision, and DevTools naming; cross-references `barrel-files.md` for whether to create a barrel in the first place
- `claude/rules/documentation-driven-development.md`: rewrite around an explicit completion-time gate. Anchors to `superpowers:verification-before-completion` so the doc-update step runs at the same moment as test/lint verification. Splits into two checks (existing-docs via `rg` for changed identifiers, missing-docs for new concepts/conventions/architectural decisions). Requires explicit `Docs updated: <files>` or `No doc updates needed because <reason>` acknowledgment in the end-of-task summary — implicit skip is not acceptable. Adds an ADR section covering when to create one, where they live (`docs/adr/NNNN-kebab.md` with the bootstrap ADR-0001 convention), and a path reference to the shared template
- `claude/CLAUDE.md`: list `claude/templates/` in the symlink map alongside rules, skills, and hooks
- `claude/rules/setup.md`: cross-reference `knowledge-freshness.md` from the framework-specific oxlint plugin guidance, making the verification dependency explicit
- `claude/rules/commit-messages.md`: codify Conventional Commits format (`<type>(<scope>): <description>`) and body discipline (subject says _what_, body says _why_). Includes type semantics table, breaking-change notation, ✅/❌ examples (subject + body, trivial commit, what-without-why, past tense, mixed unrelated changes), and a strict skip clause that treats casual `git log` drift as drift to correct rather than convention to match. Defers PR-creation workflow (branch hygiene, rebasing, staging) to the `github-pull-request` skill
- `claude/skills/github-pull-request/SKILL.md`: rebuild around detection and project policy. Step 1 detects the default branch (instead of hardcoding `main`) and queries `gh repo view` for fork status and merge strategy. Step 5 renamed to "Reconcile with the integration branch" — rebase remains the default, but carve-outs cover squash-only repos, no-rebase project policies, and protected branches that forbid force-push. Step 4 defers to `commit-messages.md` for format details (eliminates duplication and drift risk). Step 7 honors `.github/PULL_REQUEST_TEMPLATE.md` if present, and documents `--draft` and `--head <user>:<branch>` for fork PRs. New step 8 watches the initial CI run via `gh pr checks --watch` so red checks block the "PR ready" claim. Common Mistakes table extended with the new failure modes; new Related section cross-references `commit-messages.md`, `documentation-driven-development.md`, and `superpowers:verification-before-completion`
- `claude/rules/README.md`: index of the personal ruleset — table with one row per rule (covers, when it fires, related), intro explaining the auto-loading mechanism and the `paths:` frontmatter, maintenance notes, and links to sibling directories (`skills/`, `templates/`, `CLAUDE.md`); maintenance section now points at `claude/templates/rule.md` as the scaffold for new rules
- `claude/settings.json`: enable the `modern-web-guidance@googlechrome` plugin and register the `GoogleChrome/modern-web-guidance` marketplace with `autoUpdate: true` so the Chrome-team-maintained skills (Chrome Extensions, modern browser APIs, performance guidance) load automatically and stay current without manual pulls. Also flips `autoUpdate: true` on the existing Vizzuality `claude-code-standards` marketplace for the same reason. Reformatting noise (multi-line `deny` array, key reorder) comes from oxfmt
- `claude/rules/secrets-handling.md`: reasoning-level secrets behavior to complement the tool-level `.env*` deny rules in `settings.json`. Covers discussing env vars and credentials by name without echoing values (with non-exposing verification commands like `printenv API_KEY | head -c 4`), recognizing secret-shaped strings outside `.env*` (API key prefixes, JWTs, private-key headers, connection-string credentials, high-entropy tokens), and recommending rotation when secrets are committed since removing from `HEAD` doesn't fix the leak. Carve-outs for example/fixture values, user-shown malformed values for debugging, and public credentials (OAuth client IDs, Stripe publishable keys). README updated with a row for the new rule

### Removed

- `claude/settings.json`: disable `vercel@claude-plugins-official` plugin
- `claude/skills/fix-vulnerabilities/`: superseded by the equivalent skill shipped via the Vizzuality `vizz-core` plugin — no need to maintain a local copy
- `claude/skills/grill-me/SKILL.md`: replaced by a symlink into `.agents/skills/grill-me`
- `claude/rules/context7.md`: superseded by `claude/rules/knowledge-freshness.md`, which covers Context7 alongside other verification sources
- `~/.oh-my-zsh`: uninstalled the framework — `zsh/.zshrc` uses zinit as the plugin manager and never sourced `oh-my-zsh.sh`, so the install was unused weight. Zinit still pulls the single `OMZP::git` snippet directly from oh-my-zsh's repo without needing a local install

### Fixed

- `claude/settings.json`: drop the dead `Write(.env*)` deny rule that Claude Code warned about at startup — permission checks for file-editing tools only match `Edit(path)` rules (which cover Write, NotebookEdit, etc.), so `Write(.env*)` never matched anything. The existing `Edit(.env*)` deny already provides the intended protection. `claude/rules/secrets-handling.md` updated to reference only the effective rules

## [2.3.0] - 2026-05-06

### Changed

- `zsh/.zshrc`: replace hardcoded user path with `$HOME` in `PNPM_HOME` for machine-agnostic portability
- `git/.gitignore_global`: ignore `CLAUDE.md`, `AGENTS.md`, `skills-lock.json`, `.claude/`, `.agents/`, `.mcp.json`, `.playwright-mcp/`, and Copilot instruction paths; widen `.claude/*.local.json` to the whole `.claude/` directory
- `claude/settings.json`: remove pinned `model` so the global default applies
- `git/.gitconfig`: move `[gpg "ssh"]` and `[commit] gpgsign` to `.gitconfig.local` so machine-specific paths and 1Password's signer program stay out of the tracked config
- `git/.gitconfig.local.example`: document SSH signing block (1Password program, `allowedSignersFile`, `gpgsign`) and switch `signingkey` to a `~`-relative path
- `.editorconfig`: remove `[*.md]` block (no markdown file followed it; aspirational rule that would conflict with formatter behavior)
- `README.md`: document per-repo bootstrap (`corepack enable`, `pnpm install`, `git config blame.ignoreRevsFile`)

### Added

- `claude/rules/dependency-management.md`: rule requiring up-to-date docs (Context7) and official codemods/migration guides before bumping or migrating dependencies
- `claude/settings.json`: enable `vizz-core@vizzuality` plugin and register the `vizzuality` marketplace (`Vizzuality/claude-code-standards`)
- `claude/settings.json`: enable `vercel@claude-plugins-official` plugin
- `claude/settings.json`: allow `Read(.env.test)` and `Read(.env.test.containers)` permissions for test environments
- `claude/settings.json`: set `theme` to `dark-ansi`
- `claude/skills/github-pull-request`: skill for clean PR workflow — branch hygiene, selective staging, rebasing, conventional commits, and `gh` CLI
- `claude/skills/grill-me`: skill to stress-test plans and designs through relentless interviewing
- `zsh/.zshrc`: add pnpm to `PATH` via `PNPM_HOME`
- `zsh/aliases.zsh`: add `..`, `...`, `....` directory navigation aliases
- `pnpm-workspace.yaml`, `package.json`, `.node-version`: pnpm 11 (Corepack) + Node 24 LTS pinned for repo-local tooling; `savePrefix: ""` for exact pinning
- `.pre-commit-config.yaml`: prek-managed hooks — oxfmt (`v0.48.0`), oxlint (`v1.63.0`), pre-commit-hooks (`v6.0.0`: `trailing-whitespace --markdown-linebreak-ext=md`, `end-of-file-fixer`, `check-merge-conflict`); excludes `claude/skills/devstack-sync/` and `pnpm-lock.yaml`
- `oxfmt.json`, `.oxlintrc.json`: oxfmt config (`proseWrap: preserve`, `printWidth: 80`); oxlint defaults
- `@j178/prek` as the only npm dev dependency; `prepare: prek install` script auto-wires the git hook on `pnpm install`
- `.git-blame-ignore-revs`: tracks the bulk-format commit so `git blame` skips it (requires `git config blame.ignoreRevsFile` per clone)

### Removed

- `claude/settings.json`: disable `figma@claude-plugins-official` plugin
- `claude/settings.json`: remove `sandbox` configuration block

## [2.2.0] - 2026-04-20

### Added

- `.gitignore`: exclude `claude/skills/devstack-sync/` (managed by DevStack, not version-controlled)
- `claude/settings.json`: deny rules for `.env*` files (Read, Edit, Write) to prevent accidental secret exposure
- `claude/settings.json`: `$schema` property pointing to the official JSON Schema for editor validation and autocompletion
- `git/.gitconfig.local.example` template copied to `~/.gitconfig.local` by `install.sh` on first run
- `.editorconfig` documented in `docs/structure.md` (single-file root config convention)

### Changed

- `claude/settings.json`: set default `model` to `claude-opus-4-6` and raised `effortLevel` from `medium` to `high`
- `install.sh` creates `~/.gitconfig.local` from the template instead of echoing commands
- `install.sh` installs Claude Code via the native installer (`curl … | bash`) instead of `npm install -g @anthropic-ai/claude-code`, avoiding Node.js/npm-related install issues
- `zsh/.zshrc` puts `~/.local/bin` on `PATH` via an explicit `export` instead of sourcing the `~/.local/bin/env` shim left behind by `uv` (no longer used)

### Removed

- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` env flag from `claude/settings.json` so the native installer's auto-updates are not blocked

### Fixed

- Starship `git_status.stashed` parse warning (escaped `$` as `\$` in a TOML literal string)

## [2.1.0] - 2026-04-19

### Added

- `atuin/config.toml` with compact style, host filter, directory-scoped up-arrow, workspace support, daemon, and stats
- `atuin`, `jq`, `yq` formulas in Brewfile
- Claude Code npm install to `install.sh` (auto-updates, replaces Homebrew cask)
- Git config: `push.default = current`, `fetch.pruneTags`, `diff.colorMoved`, `delta.dark`, `column.ui`, `help.autoCorrect = prompt`
- Git aliases: `aliases` (list all), `undo` (soft reset HEAD~1), `oops` (amend without editing)
- `eval "$(atuin init zsh)"` in `.zshrc`
- `FZF_DEFAULT_OPTS`, `FZF_DEFAULT_COMMAND`, `FZF_CTRL_T_COMMAND` for consistent fzf UX and `fd` as default source
- `font-monaspice-nerd-font` cask in Brewfile (Monaspace patched with Nerd Font glyphs)
- `ll`, `lt`, `lta` eza aliases for long-listing (with git status and group column) and tree views

### Changed

- Split git log aliases: `lg` (current branch) and `lga` (all branches). Added `gl` and `gla` shell aliases.
- Deferred OMZ git plugin loading via `zinit wait lucid` for faster shell startup
- `cat` alias now uses `bat --paging=never` to match `cat`'s non-paging behavior
- Ghostty `font-family` from `Monaspace Neon` to `MonaspiceNe Nerd Font` for icon support
- `ls` alias to `eza --icons --group-directories-first`
- Rewrote `starship.toml`: explicit two-line prompt format with only the modules used (directory, git, nodejs, docker, duration, jobs, character)
- Guarded tool init lines in `.zshrc` (`fnm`, `fzf`, `zoxide`, `atuin`, `starship`) with `command -v` checks so missing binaries don't error on shell startup
- Reordered `yq` in Brewfile to keep tools alphabetic
- Rewrote `README.md` with current stack, install steps, and git identity setup

### Removed

- Brewfile cask `claude-code` (replaced by npm install for auto-updates)
- Bun configuration from `.zshrc` and `starship.toml` (unused)
- `git log` shell wrapper in `.zshrc` (was silently rewriting flags; use `gl`/`gla` instead)
- Ineffective `log` alias from `.gitconfig` (git refuses aliases that shadow built-ins)

## [2.0.0] - 2026-04-18

### Added

- `.zshenv` setting `ZDOTDIR` to `~/.config/zsh`
- `.zprofile` for Homebrew shell environment setup
- `aliases.zsh` with personal aliases, zoxide shortcuts, and modern CLI replacements
- `git/.gitconfig` with GPG signing, delta pager, custom aliases, rebase workflow, rerere, histogram diffs
- `git/.gitconfig.local` include pattern for personal identity (not tracked)
- `git/.gitignore_global` for system-wide git ignores
- `ghostty/config` with Catppuccin theme, Monaspace font, window padding, and clipboard settings
- `starship/starship.toml` prompt configuration (bracket preset)
- `install.sh` bootstrap script with symlink management and backup
- `.gitignore` for the repo itself
- Brewfile formulas: `bat`, `eza`, `fd`, `fzf`, `git-delta`, `ripgrep`, `starship`, `zoxide`
- Brewfile casks: `brave-browser`, `claude`, `dbeaver-community`, `ghostty`, `signal`
- Brewfile fonts: `font-intel-one-mono`, `font-monaspace`
- `CLAUDE.md` with project structure conventions and changelog instructions
- `claude/` directory with Claude Code configuration merged from `agnlez/claude-setup`
- `claude/CLAUDE.md` global Claude instructions (symlinked to `~/.claude/CLAUDE.md`)
- `claude/rules/` with `context7.md`, `documentation-driven-development.md`, `esm-exports.md`
- `claude/skills/fix-vulnerabilities/` vulnerability audit and fix skill
- `claude/hooks/optimize-images/` pre-commit image optimization hook
- `claude/settings.json` with sandbox, plugins, hooks, and `acceptEdits` default mode
- `gpg.ssh.program` pointing to 1Password's `op-ssh-sign` for commit signing inside sandbox
- 1Password SSH agent socket to sandbox `allowUnixSockets` for git SSH access inside sandbox
- Auto-allow permissions for safe tools: `Read`, `Edit`, `Write`, `Glob`, `Grep`, `WebFetch`, `WebSearch`
- Auto-allow permissions for git operations: `add`, `commit`, `fetch`, `pull`, `push`, `branch`, `branch -d`, `checkout`, `merge`, `stash`, `tag`, `config`, `log`, `diff`, `show`, `rebase`, `cherry-pick`, `revert`
- Auto-allow permissions for CLI tools: `pnpm`, `npm`, `npx`, `node`, `curl`, `gh`, `jq`, `bat`, `lsof`
- Auto-allow permissions for MCP servers: Context7, Figma, Playwright, Next.js devtools, Atlassian
- Ask-before-run rules for destructive git operations: `push --force`, `push --delete`, `reset --hard`, `clean -f`, `branch -D`, `checkout --`
- Ask-before-run rules for destructive GitHub CLI operations: `pr close`, `pr merge`, `issue close`, `issue delete`, `repo delete`
- Ask-before-run rules for Atlassian write operations: create/edit/transition issues, worklogs, comments, Confluence pages

### Changed

- Renamed `oh-my-zsh/` folder to `zsh/`
- Replaced old oh-my-zsh `.zshrc` with current zinit-based configuration
- Replaced `warp` cask with `ghostty`
- Renamed `docker` cask to `docker-desktop`
- Rewrote `README.md` with install instructions and project overview

### Removed

- Legacy oh-my-zsh configuration (NVM, steeef theme)
- Brewfile casks: `1password-cli`, `notion-calendar`, `postman`, `proton-mail-bridge`, `protonvpn`, `warp`, `zoom`
- Legacy scripts: `power-management.sh`, `update.sh`
- Stale git branches: `develop`, `delete-me`
- Deprecated Homebrew taps: `homebrew/bundle`, `homebrew/services`
- Redundant `context7-mcp` skill (covered by `context7.md` rule)
- Duplicate "Docs Fetching" section from global `claude/CLAUDE.md`
- Duplicate optimize-images hook entry from settings
- `effortLevel` and `skipDangerousModePermissionPrompt` from settings (unnecessary defaults)
- `autoAllowBashIfSandboxed` from sandbox config (replaced by explicit per-command permissions)
- Vizzhub MCP from permissions (unused)

## [1.0.0] - 2019-02-01

### Added

- Changelog file 🎉
- More logs during the process informing the user what is going on 💬

### Removed

- `brew prune` command. Deprecated in [Homebrew 1.9](https://brew.sh/2019/01/09/homebrew-1.9.0/). Now it is included in `brew cleanup`
  [(https://github.com/Homebrew/brew/pull/5467)](https://github.com/Homebrew/brew/pull/5467).
