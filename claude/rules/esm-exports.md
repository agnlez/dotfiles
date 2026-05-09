---
paths:
  - "**/*.{js,jsx,ts,tsx,mjs,mts}"
---

# ESM exports

**Prefer named exports.** Use `export default` only when a framework, bundler, or tool requires it (e.g. routing conventions, config files, or library entry points whose consumers depend on default-import syntax).

## Why named

- **Refactor safety** — renaming a named export breaks consumers loudly; renaming a default export silently does nothing on the import side.
- **Consistent imports** — the import name always matches the export name, which makes grep, codemods, and IDE auto-import predictable.
- **Reliable in re-export chains** — barrel files (`export { x } from "./x"`) preserve names and shapes; default re-exports require renaming via `export { default as X }` and lose the original contract.
- **Type-only ergonomics** — named exports compose cleanly with `import type` / `export type` for per-symbol type elision (one import line for runtime + types); default exports force you to split into two parallel import statements.
- **DevTools / stack traces** — named functions and components show up with their real name without needing `displayName` workarounds.

## Examples

### ✅ Multi-export utility module

```ts
// utils/date.ts
export function formatDate(d: Date) { … }
export function parseDate(s: string) { … }
export const DATE_FORMAT = "yyyy-MM-dd";
```

### ✅ Single React component

```tsx
// components/UserCard.tsx
export function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>;
}
```

```tsx
// consumer
import { UserCard } from "@/components/UserCard";
```

### ✅ Barrel re-export

```ts
// components/index.ts
export { UserCard } from "./UserCard";
export { UserAvatar } from "./UserAvatar";
export type { UserCardProps } from "./UserCard";
```

Don't use `export { default as X } from "./X"` — it strips the original name from the source file's contract. For whether to create a barrel in the first place, see `barrel-files.md`.

### ❌ Default export of a React component (no framework requirement)

```tsx
// components/UserCard.tsx
export default function UserCard({ user }: { user: User }) { … }
```

```tsx
// consumer — name is now decoupled from the file
import UserCard from "@/components/UserCard"; // OK
import Whatever from "@/components/UserCard"; // also OK, silently
```

### ❌ Mixing default + named without a framework reason

```ts
// lib/api.ts
export default apiClient;
export function buildUrl(...) { … }
```

If consumers import `apiClient` and `buildUrl` from the same module, both should be named. Mixed shapes confuse bundler analysis and force consumers to remember which is which.

## Framework exceptions

Framework conventions override this rule. When a framework's docs require `export default` (routing files, config files, plugin entry points), follow the framework.
