# Templates

Reusable artifact templates copied or referenced when scaffolding work in any project. Symlinked to `~/.claude/templates/` at install time so they're available cross-project.

## Templates

| Template             | Purpose                                                                                                                                                                           | Referenced by                                                                                  |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| [`adr.md`](adr.md)   | Architectural Decision Record — Status/Date frontmatter, Context, Decision, Alternatives Considered, Consequences                                                                 | [`../rules/documentation-driven-development.md`](../rules/documentation-driven-development.md) |
| [`rule.md`](rule.md) | Scaffold for new entries in `claude/rules/` — optional `paths:` frontmatter, bold imperative lead, body sections, ✅/❌ examples, explicit skip clause, optional cross-references | [`../rules/README.md`](../rules/README.md) maintenance section                                 |

## Maintenance

- Keep templates short — one screen is the goal. If a template grows past that, the artifact it produces is probably too large.
- Update this README when adding or removing a template.

## Related directories

- [`../rules/`](../rules/) — auto-loaded session instructions; `rule.md` scaffolds new entries here.
- [`../skills/`](../skills/) — invokable workflows triggered on demand.
- [`../CLAUDE.md`](../CLAUDE.md) — global instructions, lists the dotfiles symlink map.
