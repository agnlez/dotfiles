# Dependency management

When changing dependencies (adding, bumping, migrating), follow these defaults beyond the general verification expected by `knowledge-freshness.md`.

## Migrations

Prefer official codemods over manually rewriting code.

1. Search for an official migration guide and codemod (e.g. `@next/codemod`, `react-codemod`, `@biomejs/biome migrate`)
2. Run the codemod when one exists
3. Only write custom migration steps for gaps the codemod doesn't cover

## Peer dependency compatibility

Before bumping a major or minor version, verify peer dep requirements are satisfied by the rest of the tree. Use `pnpm info <pkg> peerDependencies` or `pnpm why <pkg>` rather than guessing from changelog summaries.
