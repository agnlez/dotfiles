---
paths:
  - "**/*.{js,jsx,ts,tsx,mjs,mts}"
---

# Barrel files

**Prefer direct imports over barrel files** (`index.ts` re-exports). Reach for a barrel only when it defines a curated public surface that consumers depend on — not as a dumping ground for "everything in this directory."

## Why direct imports

- **Dev-server and build cost** — bundlers (Vite, Turbopack, webpack) must resolve the barrel and crawl every sibling it re-exports, even when the consumer uses one. Importing `from "@/components"` to grab a single `Button` can pull 30+ modules through the resolver.
- **Test isolation** — Vitest, Jest, and similar runners follow the same import graph. A test that imports one component through a barrel ends up loading every sibling, slowing the suite and creating spurious failures when unrelated siblings have missing mocks or side effects.
- **Tree-shaking reliability** — even with `"sideEffects": false`, a side effect in any barrel sibling can keep the whole chain alive. Direct imports sidestep the analysis entirely.
- **Refactor friction** — moving or renaming a file means updating the barrel plus every consumer; direct imports update consumers only.

## When a barrel is appropriate

A barrel is the right shape when it **is the public API**, not when it's masking a directory layout:

- **Library entry points** — `packages/foo/src/index.ts` is the contract for npm consumers. What's exported here is what the package publishes.
- **Deliberately curated facades** — a small, stable surface that consumers should treat as a single unit (a design-system component family always shipped together, a feature module's external interface).

The signal is intent: every line in the barrel is a deliberate API decision. If the barrel grows automatically as files appear in the directory, that's accumulation, not curation, and it should become direct imports instead.

## Examples

### ❌ Auto-aggregating barrel for app code

```ts
// src/components/index.ts
export { Button } from "./Button";
export { Card } from "./Card";
export { Modal } from "./Modal";
// …30 more
```

```tsx
// consumer — resolves all 33 modules to use 1
import { Button } from "@/components";
```

### ✅ Direct import in app code

```tsx
import { Button } from "@/components/Button";
```

### ✅ Library entry as a deliberate public surface

```ts
// packages/ui/src/index.ts — the published API
export { Button } from "./components/Button";
export { Card } from "./components/Card";
export type { ButtonProps } from "./components/Button";
```

The barrel here _is_ the contract — consumers can't reach internals, and every line reflects an intentional export decision.

## Related

For the shape of the exports themselves (named vs. default), see `esm-exports.md`. The `export { default as X }` anti-pattern in re-export chains is documented there.
