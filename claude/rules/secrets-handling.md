# Secrets handling

Tool-level deny rules in `settings.json` block `.env*` reads, edits, and writes — but they don't cover secrets that live elsewhere (hardcoded keys in `config.json`, tokens in source, fixtures with credentials) or guide what to do when secrets are _conceptually_ in scope (debugging an integration, discussing an env var). This rule fills that reasoning-level gap.

## Hard rule

Treat anything that looks like a secret as a secret, regardless of file location. Never ask for, echo, or redisplay secret values. Reason about them by name and purpose only.

## Discussing secrets without exposing values

When the work involves an env var, API token, password, or credential:

- **Reason about the variable freely** — its name, purpose, where it's used, what its expected shape is (e.g. _"a 32-character hex string"_), what error to expect when it's missing or wrong.
- **Don't ask the user to paste the value.** If verification is needed, suggest non-exposing commands:
  - `printenv API_KEY | head -c 4` — show only the first few characters to confirm presence and shape.
  - `printenv API_KEY | wc -c` — confirm length without revealing content.
  - `env | grep -i token` — list which secret-named vars are set, without their values.
- **Don't echo values back.** If a user pastes a config block, acknowledge what's there but don't repeat the secret. Recommend rotation if the value clearly leaked into chat.
- **Treat tool output containing secrets as sensitive.** Don't summarize by reproducing the value. Don't save to memory.

## Secrets outside `.env`

Recognize secret-shaped strings wherever they appear, not just in `.env*`:

- High-entropy tokens (long random strings, often base64 or hex)
- API key prefixes — `sk-`, `pk_live_`, `xox[bp]-`, `AKIA`, `ghp_`, `ghs_`, `gho_`, `github_pat_`
- JWT tokens — `eyJ...` three-segment strings
- Private key headers — `BEGIN PRIVATE KEY`, `BEGIN RSA PRIVATE KEY`, `BEGIN OPENSSH PRIVATE KEY`
- Connection strings with embedded credentials — `postgres://user:pass@host`, `mongodb+srv://user:pass@`
- Base64-encoded blobs in fixture or test files that look like credentials

When you find one in a file the user is editing or asking about:

1. Flag it as a security issue, not a configuration choice.
2. Recommend extraction to an env var or the project's secrets manager if one is in use (1Password CLI, Doppler, Vault, AWS Secrets Manager, etc.).
3. If the secret has been committed to git, recommend **rotation** in addition to extraction — once a secret is in history, removing it from `HEAD` doesn't fix the leak.

## When this rule does not apply

- The user is intentionally working with **example, fake, or test-fixture values** clearly marked as such (`API_KEY=test-fake-key`, `password=hunter2-example`). Literal placeholder strings are not sensitive.
- The user is **explicitly debugging a malformed value** and shows it themselves to ask _"why doesn't this parse?"_ — discuss the format, but still don't redisplay or save the value.
- **Public credentials** are not secrets — anything labeled `PUBLIC KEY`, OAuth client IDs, Stripe publishable keys (`pk_live_...` is publishable; `sk_live_...` is secret), GitHub App public IDs. The rule covers their private counterparts.

## Related

- `settings.json` — `Read(.env*)`/`Edit(.env*)` deny rules block direct file access at the tool level (`Edit` rules cover all file-editing tools, including `Write`).
- `github-pull-request` skill — staging discipline excludes `.env*`, credentials, secrets from commits.
- `superpowers:verification-before-completion` — the moment to confirm no secrets crept into staged changes before claiming work done.
