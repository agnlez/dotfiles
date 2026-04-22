# Machine-agnostic configuration

All configuration files in this repository must be portable — they should work on any machine, for any user, without modification.

- Never hardcode usernames, home directories, or machine-specific paths (e.g. `/Users/agnlez/`, `/home/john/`)
- Use environment variables (`$HOME`, `$USER`, `$XDG_CONFIG_HOME`) or shell expansions (`~`) instead
- Before committing, verify that no absolute paths containing a username appear in the diff
