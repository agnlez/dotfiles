# Machine-agnostic configuration

All configuration files in this repository must be portable — they should work on any machine, for any user, without modification. That covers both supported OSes: macOS and Windows.

- Never hardcode usernames, home directories, or machine-specific paths (e.g. `/Users/<name>/`, `/home/<name>/`, `C:\Users\<name>\`, `C:/Users/<name>/`)
- Use environment variables (`$HOME`, `$USER`, `$XDG_CONFIG_HOME`; in PowerShell `$HOME`, `$env:USERPROFILE`, `$env:LOCALAPPDATA`) or shell expansions (`~`) instead. Git expands `~` in path settings on Windows too
- Prefer calling a binary by name when it's on `PATH` over an absolute install path (e.g. `op-ssh-sign.exe`, which 1Password puts on `PATH` through an app execution alias)
- Keep OS-specific values out of shared files: put them in that OS's file (see `docs/structure.md`) so the other OS never loads them
- Before committing, verify that no absolute paths containing a username appear in the diff
