# 0001. Record architecture decisions

- **Status**: accepted
- **Date**: 2026-11-08

## Context

Some choices in this repo (layout, tooling, how configs are installed) have plausible alternatives, and the reasoning behind them isn't recoverable from the files alone.

## Decision

Record those decisions as ADRs in `docs/adr/NNNN-kebab-case-title.md`, following the template in `claude/templates/adr.md`.

## Alternatives considered

- **Commit messages and CHANGELOG only**: they say what changed, not why one option was picked over another.

## Consequences

- **Positive**: the reasoning stays next to the config it shapes.
- **Trade-offs**: one more file to write for non-obvious decisions.
- **Follow-ups**: none.
