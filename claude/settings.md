# Claude Code settings

[`settings.json`](settings.json) is the source of truth, symlinked to `~/.claude/settings.json`. JSON can't hold comments, so this file records why each part is there. Update it in the same commit as any change to `settings.json`.

Where a setting has no recorded reason, this file only says what it does. If you know the reason, add it.

## Permissions

The default mode is `auto` (`permissions.defaultMode`). Rules are checked as deny, then ask, then allow, so an ask rule takes precedence over a broader allow rule. That's how `Bash(pnpm:*)` can be allowed while `pnpm dlx` still prompts.

### Mirrored for Bash and PowerShell

Every `Bash(...)` allow and ask rule has a `PowerShell(...)` twin, except `lsof`. Bash rules don't apply to commands Claude Code runs through its PowerShell tool on Windows, so without the twins, the ask guardrails wouldn't cover Windows at all. Add or remove both together. See [`docs/structure.md`](../docs/structure.md) for why this file holds both OSes' rules side by side.

### Allow

| Group                                                                                                                                  | Why                                                                                                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Read`, `Edit`, `Write`, `Glob`, `Grep`, `WebFetch`, `WebSearch`                                                                       | Core tools, allowed so routine work doesn't prompt.                                                                                                                                  |
| `git` subcommands                                                                                                                      | Day-to-day git, from status reads to commit and push. The destructive forms are in the ask list.                                                                                     |
| `pnpm`, `npm`, `gh`                                                                                                                    | Package-manager and GitHub CLI work. The subcommands that run remote packages, publish, or write through `gh` are in the ask list.                                                   |
| `jq`, `bat`, `eza`, `rg`, `fd`, `yq`                                                                                                   | Read-only CLI tools that [`CLAUDE.md`](CLAUDE.md) tells Claude to prefer over `cat`/`ls`/`grep`/`find`.                                                                              |
| `lsof`                                                                                                                                 | Bash only, with no PowerShell twin.                                                                                                                                                  |
| `pnpx modern-web-guidance@latest`                                                                                                      | The `modern-web-guidance` skill runs its CLI through `pnpx` on every search. The rule matches only that package, so other `pnpx` commands still prompt.                              |
| `mcp__plugin_context7_context7`, `mcp__plugin_figma_figma`, `mcp__playwright`, `mcp__next-devtools`, `mcp__plugin_atlassian_atlassian` | MCP servers allowed as a whole. Atlassian's write tools are re-gated in the ask list. `mcp__playwright` is the server from [`mcp-servers.json`](mcp-servers.json), not the plugin's. |

`node`, `npx`, and `curl` are intentionally not allowed: they run arbitrary code or reach the network, so they go through the prompt.

### Ask

| Group                                                                                                                     | Why                                                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Force and delete pushes (`--force`, `-f`, `+refspec`, `--delete`), `reset --hard`, `clean -f`, `branch -D`, `checkout --` | They discard work or rewrite remote history. The patterns match flags anywhere in the command, not only right after `git push`.            |
| `gh pr close/merge`, `gh issue close/delete`, `gh repo delete/edit`, `gh gist create`, `gh secret`                        | They're outward-facing or hard to undo.                                                                                                    |
| `gh api` with `-X`, `--method`, `-f`, `-F`, `--field`, `--raw-field`, `--input`                                           | They turn a read into a write.                                                                                                             |
| `pnpm dlx/create/publish`, `npm exec/x/init/create/publish`                                                               | `pnpm:*` and `npm:*` would otherwise let Claude run remote packages or publish without asking.                                             |
| `bat`, `jq`, `yq` on anything matching `.env`                                                                             | The `.env*` deny only covers file commands Claude Code recognizes, so these catch shell reads it would miss.                               |
| Atlassian write tools (create/edit/transition issues, comments, Confluence content, `executeWrite`, `executeDestructive`) | They write to shared Jira and Confluence. Check the names when the plugin updates: rules naming removed tools match nothing and fail open. |

### Deny

`Read(.env*)` and `Edit(.env*)` block secrets at the tool level. `Edit` rules cover every file-editing tool, `Write` included, so no `Write(...)` rule is needed. `.env.test` and `.env.test.containers` are readable through `!` exceptions inside the deny list, because a separate allow rule can't override a deny. [`rules/secrets-handling.md`](rules/secrets-handling.md) covers the secrets the deny can't see.

## Plugins and marketplaces

| Plugin                                                               | State    | Why                                                                                                                                                  |
| -------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `superpowers`, `context7`, `security-guidance`, `figma`, `atlassian` | Enabled  | From the official marketplace. `context7` backs [`rules/knowledge-freshness.md`](rules/knowledge-freshness.md).                                      |
| `vizz-core`, `vizz-maps`                                             | Enabled  | Vizzuality's shared standards and react-map-gl patterns, from the `vizzuality` marketplace (`autoUpdate: true`, so they stay current without pulls). |
| `playwright`                                                         | Disabled | Its `npx` command can't take `--prefix`, so it fails in projects that pin pnpm through `devEngines`. The server in `mcp-servers.json` replaces it.   |

## Hooks

- **`SessionStart` → `rex __internal session-start`**: written by `rex skill setup`, it tells a session running inside Rex its session and pane IDs. It exits quietly outside Rex or when `rex` isn't installed.

## Session and UI

| Setting                                | Value                     | Why                                                                                                                                        |
| -------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `attribution.commit`, `attribution.pr` | `""`                      | Keeps commits and PRs free of Claude attribution. It replaces the old `includeCoAuthoredBy`.                                               |
| `effortLevel`                          | `high`                    | Default effort for every model.                                                                                                            |
| `modelSettings`                        | Opus 5.5 → `high`         | Sets effort per model rather than pinning a `model`, so the default model can change without editing this file.                            |
| `skillListingBudgetFraction`           | `0.03`                    | Fits every plugin skill's description in the session listing, which the default 1% budget truncated. Costs roughly 15k tokens per session. |
| `statusLine`                           | `~/.claude/statusline.sh` | The tracked [`statusline.sh`](statusline.sh).                                                                                              |
| `skipAutoPermissionPrompt`             | `true`                    | Hides the auto-mode permission prompt at session start.                                                                                    |
| `feedbackDrafts`                       | `off`                     |                                                                                                                                            |
| `tui`                                  | `fullscreen`              | The flicker-free alternate-screen renderer with virtualized scrollback.                                                                    |
| `theme`                                | `dark`                    |                                                                                                                                            |

Claude Code rewrites `settings.json` when you change settings from inside it (`/config`, permission approvals). Because the file is symlinked, those writes land in this repo. Review them with `git diff` before committing, and record the reason here.
