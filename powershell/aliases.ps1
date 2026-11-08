# Personal aliases, the Windows counterpart of zsh/aliases.zsh. Loaded by
# profile.ps1, in interactive sessions only.
#
# PowerShell aliases can't carry arguments, so anything with flags is a
# function forwarding @args. Built-in aliases (`ls`, `cat`) win over
# functions, so they're removed before being redefined.

# --- Config editors ---
# The WebStorm installer doesn't put its launcher on PATH: fall back to the
# newest install under Program Files.
if (-not (Get-Command webstorm -ErrorAction Ignore)) {
  function webstorm {
    $exe = Get-ChildItem "$env:ProgramFiles\JetBrains\WebStorm*\bin\webstorm64.exe" -ErrorAction Ignore |
      Sort-Object LastWriteTime | Select-Object -Last 1
    if (-not $exe) { Write-Error 'WebStorm not found under Program Files\JetBrains.'; return }
    & $exe.FullName @args
  }
}
function psconfig { webstorm $PROFILE.CurrentUserAllHosts }
function sshconfig { webstorm "$HOME\.ssh\config" }
function gitconfig { webstorm "$HOME\.gitconfig" }
function gitignore { webstorm "$HOME\.gitignore" }

# --- Navigation ---
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# zoxide (`z` and `zi` come from `zoxide init`)
function zz { z - }                         # Quick back navigation
function zh { z ~ }                         # Quick home
function zl { zoxide query -l -s @args }    # List with scores

# --- Git ---
function gla { git lga @args }

# --- Modern CLI replacements ---
# Bypass with the full name when you need the original: `findstr`/`find.exe`,
# `Get-Content`, `Get-ChildItem`.
if (Get-Command rg -ErrorAction Ignore) { Set-Alias grep rg }
if (Get-Command fd -ErrorAction Ignore) { Set-Alias find fd }
if (Get-Command bat -ErrorAction Ignore) {
  Remove-Item Alias:cat -Force -ErrorAction Ignore
  function cat { bat --paging=never @args }
}
if (Get-Command eza -ErrorAction Ignore) {
  Remove-Item Alias:ls -Force -ErrorAction Ignore
  function ls { eza --icons --group-directories-first @args }
  # No --group, unlike zsh: Windows files have no Unix group to show.
  function ll { eza --icons --group-directories-first -la --git @args }
  function lt { eza --icons --tree --level=2 @args }
  function lta { eza --icons --tree --level=2 -a --ignore-glob='.git|node_modules' @args }
}
