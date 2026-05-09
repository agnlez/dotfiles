---
# Optional. Add only when this rule should load conditionally for specific
# file types. Without `paths:`, the rule loads in every Claude Code session.
# paths:
#   - "**/*.{js,jsx,ts,tsx,mjs,mts}"
---

# <Rule title — sentence case, matches the filename>

**<Bold imperative lead.>** One sentence stating the rule. Follow with one
or two sentences of context: why this matters, what gap it fills, when it
fires.

<!-- Alternative lead shape: a short context paragraph that ends with the
imperative, followed by an explicit `## Hard rule` section. Use this when
the rule is a reasoning-level guardrail rather than a pattern to recognize
(see `knowledge-freshness.md`, `secrets-handling.md`). -->

## <Body section heading>

The substantive guidance. Pick the shape that fits the rule:

- **Rationale** (`## Why <X>`) — bulleted reasons the default is what it is.
- **Workflow** (`## Before X` / `## Before reporting completion`) — for
  procedural rules with discrete checkpoints.
- **Taxonomy table** — when the rule classifies things (types, severities,
  verification sources).
- **Concrete bulleted guidance** — for everything else.

Add as many H2 sections as the rule needs. Keep them focused — one concern
per section. If a section grows past ~30 lines, consider splitting.

## Examples

Use `✅` / `❌` subheadings to show good and bad cases. Keep snippets
minimal — just enough to make the contrast obvious.

### ✅ <What's right>

```ts
// minimal example
```

### ❌ <What's wrong>

```ts
// minimal counter-example
```

Brief prose under each example explaining _why_ it's right or wrong, when
the contrast isn't self-evident.

<!-- Examples are strongly preferred when the rule is enforced by
recognizing patterns. Skip when the rule is purely procedural. -->

## When this rule does not apply

Explicit skip conditions. Vague skips invite drift — be specific:

- The project has a **documented or strictly-enforced** different convention.
- The user explicitly asks for something else.
- A higher-priority instruction overrides this one — flag the substitution
  to the user.
- <Domain-specific carve-out, e.g. "test-fixture values clearly marked as
  fake">.

If there are no legitimate carve-outs, say so explicitly.

## Related

- [`<sibling-rule>.md`](<sibling-rule>.md) — what it covers and how it
  complements this one.
- `<skill-name>` skill — pointer to an invokable workflow.
- [`~/.claude/templates/<name>.md`](../templates/<name>.md) — reusable
  artifact this rule references.

<!-- Optional. Include when sibling rules, skills, or templates extend or
complement this rule. -->
