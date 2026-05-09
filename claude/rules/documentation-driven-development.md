# Documentation-driven development

Treat documentation as part of every change, not a separate phase. Read what's already there before changing code, and reconcile it before claiming the task done.

## Before changing code

Before starting any non-trivial change, scan the project's existing documentation for context:

- `CLAUDE.md` (or equivalent project rules)
- `docs/` directory, if present
- `docs/adr/` for prior architectural decisions
- READMEs in the affected directory and its parents

Skim for current architecture, conventions, constraints, and prior decisions that would shape the change.

## Before reporting completion

This step fires at the same moment as `superpowers:verification-before-completion` — before claiming a task done, before committing, before opening a PR. Run two checks, then acknowledge explicitly.

### Check 1 — Existing docs

`rg` for the changed identifiers (function names, feature terms, configuration keys) in `docs/`, `README*`, and ADRs. For each hit:

- Update the doc if the documented behavior is now different.
- Extend the doc if the change adds capability that consumers should know about.
- Remove the doc text if the documented behavior no longer exists.

### Check 2 — Missing docs

Ask whether the change introduces something a future reader can't infer from code + tests alone:

- **New concept, term, component, or convention** → extend an existing README/doc, or create one if no fit.
- **Architectural choice with multiple plausible alternatives where the reasoning isn't obvious from the code** → create an ADR (see below).
- **Default that future contributors should follow** → record where contributors will look (CLAUDE.md, README, CONTRIBUTING).

### Acknowledge in the end-of-task summary

State explicitly one of:

- **`Docs updated: <files>`** — list every file you changed or created.
- **`No doc updates needed because <reason>`** — a specific, verifiable reason (e.g. _"change is internal; rg for `parseDate` returns no hits in `docs/`, `README*`, or ADRs; introduces no new concept; makes no architectural decision"_).

An implicit skip is not acceptable. If you can't articulate why no doc update is needed, a doc update is needed.

## Architectural Decision Records (ADRs)

An ADR captures a decision and its reasoning so future readers don't have to reverse-engineer the "why" from the diff. Create one when:

- The change makes an architectural choice with multiple plausible alternatives.
- The reasoning would not be obvious to a future reader from the code alone.
- The decision constrains or shapes future work in the area.
- The change deviates from a previous pattern intentionally.

### Where ADRs live

`docs/adr/NNNN-kebab-case-title.md` where `NNNN` is a sequential 4-digit number. Find the next number with `ls docs/adr/`. If `docs/adr/` doesn't exist, create it with `0001-record-architecture-decisions.md` declaring that the project uses ADRs — that adoption is itself the first decision.

### Template

The ADR template lives at `~/.claude/templates/adr.md` — read it before drafting. It captures Status/Date metadata, Context, Decision, Alternatives Considered, and Consequences. Keep ADRs short — one screen is the goal. If the decision doesn't fit, it's probably too large and should be split.

## When to skip the completion-time checks

Skip both checks only when **all** of the following hold:

- No public API, interface, configuration, or user-visible behavior changed.
- `rg` for the changed identifiers in `docs/`, `README*`, and ADRs returns zero hits.
- The change introduces no new concept, term, or convention.
- The change makes no architectural choice with non-obvious reasoning.
- The change is small enough that a future reader won't need an explanation (formatting, dependency bump with no API impact, comment cleanup).

If any of these is uncertain, run the checks.

## Guidelines

- Write documentation for humans — clear, concise, with examples where helpful.
- Keep documentation close to the code it describes (a README in the relevant directory beats a central doc).
- Stale docs are worse than no docs. If a change invalidates existing documentation, update or remove it.
- Don't over-document the self-evident. New docs are warranted only when the change introduces something a reader can't infer from code + tests.
