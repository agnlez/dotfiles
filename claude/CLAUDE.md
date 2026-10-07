## User profile

Senior frontend engineer, 12 years of experience. Primary stack: React + Next.js (App Router + RSC by default — server components first, client only when needed) + TypeScript, with Tailwind and shadcn for UI.

Domain: dashboards and data-viz, sometimes maps/GIS.

**Library defaults (use unless project says otherwise):**

- Charts: Recharts, or Visx/D3 when more control is needed.
- Maps: Mapbox GL or MapLibre.
- Map data layers: deck.gl.

## Claude Code configuration

All Claude Code global configuration is managed through `~/dev/dotfiles` and symlinked to `~/.claude/`. When creating or modifying rules, skills, or settings, edit the source files in the dotfiles repo so changes are tracked in git:

- `~/dev/dotfiles/claude/settings.json` → `~/.claude/settings.json`
- `~/dev/dotfiles/claude/statusline.sh` → `~/.claude/statusline.sh`
- `~/dev/dotfiles/claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `~/dev/dotfiles/claude/rules/` → `~/.claude/rules/`
- `~/dev/dotfiles/claude/skills/` → `~/.claude/skills/`
- `~/dev/dotfiles/claude/templates/` → `~/.claude/templates/`

## Tool preferences

- Assume `rg`, `fd`, `bat`, `eza`, `jq`, and `yq` are available in the environment
- Use `rg --type` flags to scope searches by language when appropriate
- Use `fd -e` to filter by extension or `fd -t` to filter by type when appropriate
- Prefer `rg` (ripgrep) over `grep` for all file and pattern searches
- Prefer `fd` over `find` for all filesystem searches
- Prefer `bat` over `cat` for reading and displaying file contents
- Prefer `eza` over `ls` for directory listings; use `eza --tree` instead of `tree`
- Prefer `jq` for JSON querying, filtering, and transformation from the command line
- Prefer `yq` for YAML, TOML, and XML querying and in-place edits; use `yq -o json` to convert to JSON when needed
