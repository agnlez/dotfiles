# ESM Exports
When writing or reviewing ESM modules, evaluate export style based on context:

Use named exports (export { myComponent }) for anything that may be partially consumed — shared utilities, component libraries, or modules with multiple exports. This enables tree shaking and keeps cache invalidation scoped to smaller chunks.
Use default exports (export default myComponent) when the module is always consumed whole — a page component, a config object, or a single-responsibility module where partial consumption doesn't apply.
Avoid mixing both styles in the same file without a clear reason, as it can confuse bundler analysis and consumers.

When in doubt, explain the trade-off and let the context of the project decide.