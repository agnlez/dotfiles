# PowerShell 7 profile, the Windows counterpart of zsh/.zshrc. install.ps1
# links it to $PROFILE.CurrentUserAllHosts (so Windows Terminal and IDE
# terminals all load it) and aliases.ps1 next to it.
#
# PATH and other persistent variables (~/.local/bin, PNPM_HOME) aren't set
# here: on Windows they're per-user environment variables, which install.ps1
# sets once.

# Stop here in non-interactive sessions: scripts, `pwsh -Command`/`-File`, and
# tools that run `pwsh -NonInteractive` (e.g. Claude Code). The aliases shadow
# built-ins such as `ls` and `cat` that scripts rely on, and the prompt and
# history hooks only slow those sessions down.
$cliArgs = [Environment]::GetCommandLineArgs() | Select-Object -Skip 1
$runsCommand = $cliArgs -match '^(-{1,2}|/)(noni|c$|command$|f$|file$|e$|ec$|encodedcommand$)'
$keepsOpen = $cliArgs -match '^(-{1,2}|/)noe'
Remove-Variable cliArgs
if ($runsCommand -and -not $keepsOpen) {
  Remove-Variable runsCommand, keepsOpen
  return
}
Remove-Variable runsCommand, keepsOpen

# Native tools (starship, eza, fzf) print UTF-8; read it as such, or icons and
# box-drawing characters come out garbled.
[Console]::InputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

# --- PSReadLine (line editing) ---
# Inline history suggestions, accepted with the right arrow, like
# zsh-autosuggestions (PSReadLine refuses them when output is redirected).
# Tab cycles through a completion menu, like zsh.
if (-not [Console]::IsOutputRedirected) {
  Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# --- fzf ---
# Same defaults as zsh/.zshrc: UI, preview bindings, and fd as the walker.
$env:FZF_DEFAULT_OPTS = "--height 50% --layout=reverse --border " +
  "--bind 'ctrl-/:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,shift-up:preview-up,shift-down:preview-down'"
$env:FZF_DEFAULT_COMMAND = 'fd --hidden --follow --exclude .git'
$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'

# File picker on Alt+T and directory jump on Alt+C, as in zsh. Ctrl+R is left
# to atuin. PSFzf comes from the PowerShell Gallery (install.ps1 installs it).
if ((Get-Command fzf -ErrorAction Ignore) -and (Get-Module -ListAvailable PSFzf)) {
  Import-Module PSFzf
  Set-PsFzfOption -PSReadlineChordProvider 'Alt+t' -PSReadlineChordSetLocation 'Alt+c'
}

# --- Tools ---
# fnm: switch Node on cd per .node-version
if (Get-Command fnm -ErrorAction Ignore) {
  fnm env --use-on-cd --version-file-strategy=recursive --shell powershell | Out-String | Invoke-Expression
}

if (Get-Command zoxide -ErrorAction Ignore) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# atuin (shell history): binds Ctrl+R and the up arrow
if (Get-Command atuin -ErrorAction Ignore) {
  atuin init powershell | Out-String | Invoke-Expression
}

if (Get-Command starship -ErrorAction Ignore) {
  Invoke-Expression (&starship init powershell)
}

# Personal aliases
. (Join-Path $PSScriptRoot 'aliases.ps1')
