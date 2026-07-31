## User profile

Senior frontend engineer, 12 years of experience. Primary stack: React + Next.js (App Router + RSC by default — server components first, client only when needed) + TypeScript, with Tailwind and shadcn for UI.

Domain: dashboards and data-viz, sometimes maps/GIS.

**Library defaults (use unless project says otherwise):**

- Charts: Recharts, or Visx/D3 when more control is needed.
- Maps: Mapbox GL or MapLibre.
- Map data layers: deck.gl.

## Claude Code configuration

All Claude Code global configuration is managed through `~/Developer/dotfiles` and symlinked to `~/.claude/`. When creating or modifying rules, skills, hooks, or settings, edit the source files in the dotfiles repo so changes are tracked in git:

- `~/Developer/dotfiles/claude/settings.json` → `~/.claude/settings.json`
- `~/Developer/dotfiles/claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `~/Developer/dotfiles/claude/rules/` → `~/.claude/rules/`
- `~/Developer/dotfiles/claude/skills/` → `~/.claude/skills/`
- `~/Developer/dotfiles/claude/hooks/` → `~/.claude/hooks/`
- `~/Developer/dotfiles/claude/templates/` → `~/.claude/templates/`

## Code Graph (codebase-memory-mcp)

A pre-indexed code graph is available for structural queries. Use it via CLI
(`codebase-memory-mcp cli <tool>`), not as a resident MCP server.

### When to use it (instead of grep)

- **Transitive questions**: "who consumes this hook/component, directly or
  indirectly?" → `trace_path`. One query replaces chained greps.
- **Impact analysis**: "what is affected if I change X?" → `detect_changes`
  against the current git diff.
- **Orientation in unfamiliar areas**: `get_architecture` for the module map,
  routes, and hotspots before diving in.
- **NOT for point lookups**: "where is X defined?" is one ripgrep call.
  Do not use the graph for questions grep answers in a single search.

### Trust rules — the graph guides, the code decides

- **An empty result means "unknown", never "none".** `callees: []` or
  `in_degree: 0` is NOT evidence of dead code or missing dependencies —
  resolution failures are silent. Before acting on any absence, confirm
  with ripgrep against the source.
- **Dynamic imports are invisible to the graph.** `next/dynamic`,
  `React.lazy`, and `import()` create no edges. Any impact analysis or
  dead-code claim MUST be complemented with
  `rg "dynamic\(|lazy\(|import\(" ` across the affected paths.
- **Python edges are unreliable** (cross-file calls often missing, plus
  false-positive CALLS from suffix matching). Use the graph for the
  TypeScript side only; for Python, use ripgrep.
- Never conclude, refactor, or delete based on graph output alone.
  Positive results (an edge exists) are trustworthy; negative results
  (no edge) require source verification.

### Token hygiene

- Prefer `trace_path` / `query_graph` (compact) over `search_graph`
  (~1KB of internal metadata per result). Pipe through
  `jq '{name, file_path, qualified_name}'` when listing more than a few nodes.
- Re-index after large refactors or branch switches
  (`cli index_repository --repo-path .`); it is incremental and takes <5s.

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
