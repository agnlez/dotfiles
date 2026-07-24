# Test restraint

**Don't write tests by default — assess whether each test earns its place,
and propose non-obvious additions to the user before implementing them.**
AI-generated changes tend to arrive wrapped in test suites regardless of
scope, overloading the codebase and the PR review with tests that assert
nothing at risk. A test is code to maintain; it must pay for itself.

## When a test is warranted

- **A bug fix** — one regression test reproducing the bug is the default,
  no discussion needed.
- **New behavior with meaningful logic** — branching, edge cases,
  calculations, parsing. Test the contract, not the internals.
- **A public API or shared utility contract** other code depends on.
- **An edge case with real failure risk** identified during the work
  (boundary values, empty states, error paths that matter).

## When a test is not warranted

- **Trivial or mechanical changes** — renames, prop pass-through, config
  tweaks, styling, copy changes.
- **Restating the implementation** — a test that mirrors the code line by
  line breaks on every refactor and catches nothing.
- **Testing the framework or a library** — React rendering props, a
  well-tested dependency doing its documented job.
- **Duplicating existing coverage** — check first (`rg <identifier>` in
  test files) whether the path is already exercised.
- **Padding a minimal diff** — a two-line change does not need a new test
  file to look thorough.

## Before writing tests

1. Check existing coverage for the changed identifiers — extend an
   existing test before creating a new file.
2. If the change is a bug fix, write the single regression test and move
   on.
3. Otherwise, **propose the tests before writing them**: list each test
   name and what it asserts, in one or two lines, and let the user confirm
   or trim. Don't present a fait accompli of 400 test lines in the diff.

## When this rule does not apply

- The user **explicitly asks for tests** or for a coverage target — write
  what they asked for.
- A **TDD workflow is in effect** (user request or an active skill like
  `superpowers:test-driven-development`) — the test comes first by design;
  restraint then applies to scope (test the behavior, not every internal).
- The project has a **documented or enforced convention** (coverage
  thresholds in CI, a CONTRIBUTING rule) — follow the project.

## Related

- [`code-comments.md`](code-comments.md) — sibling restraint rule; same
  "the diff should carry only what earns its place" spirit.
- `superpowers:verification-before-completion` — restraint doesn't waive
  verification; changed behavior still gets run/checked before claiming
  done.
