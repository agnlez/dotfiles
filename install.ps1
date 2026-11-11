#Requires -Version 7.0
<#
.SYNOPSIS
  Windows installer for the dotfiles, the counterpart of install.sh.

.DESCRIPTION
  Installs packages (winget, scoop, PowerShell Gallery), Node via fnm and
  Claude Code; sets per-user environment variables; and symlinks the configs
  into place, backing up anything already there to ~/.dotfiles-backup/.

  Safe to rerun: installed packages are skipped and correct links are left
  alone. Needs Developer Mode, so symlinks can be created without admin.

.EXAMPLE
  ./install.ps1 -WhatIf
  Shows what the script would install, set and link, without changing
  anything.
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Info([string]$Message) { Write-Host "→ $Message" -ForegroundColor Blue }
function Write-Success([string]$Message) { Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Caution([string]$Message) { Write-Host "! $Message" -ForegroundColor Yellow }

if (-not $IsWindows) {
  Write-Host '✗ install.ps1 is Windows-only. On macOS, run ./install.sh.' -ForegroundColor Red
  exit 1
}

$Dotfiles = $PSScriptRoot
$BackupDir = Join-Path $HOME ".dotfiles-backup\$(Get-Date -Format yyyyMMdd_HHmmss)"

# --- Helpers ---

function Set-Link {
  [CmdletBinding(SupportsShouldProcess)]
  param([string]$Source, [string]$Destination)

  $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction Ignore

  if ($existing -and $existing.LinkType -eq 'SymbolicLink') {
    if ($existing.LinkTarget -eq $Source) { return }
    if ($PSCmdlet.ShouldProcess($Destination, "Repoint symlink to $Source")) {
      # Delete() removes the link itself, never the directory it points to.
      $existing.Delete()
      New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
      Write-Success "Updated symlink: $Destination → $Source"
    }
    return
  }

  if ($existing) {
    $backup = Join-Path $BackupDir $existing.Name
    if ($PSCmdlet.ShouldProcess($Destination, "Back up to $backup and link to $Source")) {
      New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
      Move-Item -LiteralPath $Destination -Destination $backup
      Write-Caution "Backed up $Destination → $backup"
      New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
      Write-Success "Linked: $Destination → $Source"
    }
    return
  }

  if ($PSCmdlet.ShouldProcess($Destination, "Link to $Source")) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Destination) | Out-Null
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    Write-Success "Linked: $Destination → $Source"
  }
}

# Reload PATH from the registry, so tools installed by this run resolve in it.
function Sync-SessionPath {
  $env:Path = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine'),
    [Environment]::GetEnvironmentVariable('Path', 'User')
  ) -join ';'
}

# Prepend a directory to the user PATH. Reads and writes the raw registry
# value, because [Environment]::SetEnvironmentVariable would expand and
# flatten the existing %VAR% entries.
function Add-UserPath {
  [CmdletBinding(SupportsShouldProcess)]
  param([string]$Directory)

  $key = Get-Item 'HKCU:\Environment'
  $raw = $key.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
  $entries = @($raw -split ';' | Where-Object { $_ })
  $expanded = $entries | ForEach-Object { [Environment]::ExpandEnvironmentVariables($_).TrimEnd('\') }
  if ($expanded -contains [Environment]::ExpandEnvironmentVariables($Directory).TrimEnd('\')) { return }

  if ($PSCmdlet.ShouldProcess('user PATH', "Prepend $Directory")) {
    $value = (@($Directory) + $entries) -join ';'
    Set-ItemProperty -Path 'HKCU:\Environment' -Name Path -Value $value -Type ExpandString
    $script:EnvironmentChanged = $true
    Write-Success "Added to user PATH: $Directory"
  }
}

function Set-UserVariable {
  [CmdletBinding(SupportsShouldProcess)]
  param([string]$Name, [string]$Value)

  if ([Environment]::GetEnvironmentVariable($Name, 'User') -eq $Value) { return }
  if ($PSCmdlet.ShouldProcess("user variable $Name", "Set to $Value")) {
    [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
    Set-Item -Path "Env:$Name" -Value $Value
    Write-Success "Set $Name = $Value"
  }
}

# Tell running apps (Explorer, Windows Terminal) that environment variables
# changed, so processes they start next pick up the new PATH. Registry writes
# alone don't notify anyone.
function Send-EnvironmentChange {
  $signature = @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
  $native = Add-Type -Namespace Dotfiles -Name NativeMethods -MemberDefinition $signature -PassThru
  $HWND_BROADCAST = [IntPtr]0xffff
  $WM_SETTINGCHANGE = 0x1a
  $SMTO_ABORTIFHUNG = 0x2
  $result = [UIntPtr]::Zero
  [void]$native::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, 'Environment', $SMTO_ABORTIFHUNG, 5000, [ref]$result)
}

# --- Prerequisites ---

# Developer Mode lets a non-admin create symlinks. Probe for it directly, which
# also covers an elevated shell.
$probe = Join-Path ([IO.Path]::GetTempPath()) "dotfiles-symlink-probe-$PID"
try {
  New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath -WhatIf:$false | Out-Null
  Remove-Item -LiteralPath $probe -WhatIf:$false
} catch {
  Write-Host "✗ Can't create symlinks. Turn on Developer Mode (Settings → System → For developers) and rerun." -ForegroundColor Red
  exit 1
}

if (-not (Get-Command winget -ErrorAction Ignore)) {
  Write-Host '✗ winget not found. Install App Installer from the Microsoft Store and rerun.' -ForegroundColor Red
  exit 1
}

# --- Packages ---
# A failed package shouldn't leave the machine without its shell and git
# config, so failures are reported at the end instead of stopping the run.
$packagesOk = $true
$script:EnvironmentChanged = $false

Write-Info 'Installing winget packages...'
if ($PSCmdlet.ShouldProcess('winget/packages.json', 'winget import')) {
  # --no-upgrade skips installed packages, so reruns are quick and exit 0.
  # Upgrade separately with `winget upgrade --all`.
  winget import --import-file (Join-Path $Dotfiles 'winget\packages.json') --no-upgrade `
    --accept-package-agreements --accept-source-agreements --disable-interactivity
  if ($LASTEXITCODE -ne 0) { $packagesOk = $false }
  Sync-SessionPath
}

if (-not (Get-Command scoop -ErrorAction Ignore)) {
  Write-Info 'Installing scoop...'
  if ($PSCmdlet.ShouldProcess('scoop', 'Install from get.scoop.sh')) {
    Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
    Sync-SessionPath
  }
}

Write-Info 'Installing scoop packages...'
if ($PSCmdlet.ShouldProcess('scoop/scoopfile.json', 'scoop import')) {
  if (Get-Command scoop -ErrorAction Ignore) {
    scoop import (Join-Path $Dotfiles 'scoop\scoopfile.json')
    if ($LASTEXITCODE -ne 0) { $packagesOk = $false }
  } else {
    Write-Caution 'scoop not available, skipping its packages.'
    $packagesOk = $false
  }
}

# PSFzf backs the profile's Alt+T and Alt+C fzf widgets.
if (-not (Get-Module -ListAvailable PSFzf)) {
  Write-Info 'Installing the PSFzf module...'
  if ($PSCmdlet.ShouldProcess('PSFzf', 'Install-PSResource from the PowerShell Gallery')) {
    try {
      Install-PSResource PSFzf -Scope CurrentUser -TrustRepository -Quiet
    } catch {
      Write-Caution "PSFzf install failed: $_"
      $packagesOk = $false
    }
  }
}

# --- Environment ---
# Persistent per-user variables: what zsh/.zshrc exports on macOS. Stored with
# %USERPROFILE% unexpanded, like Windows' own default PATH entries. Set before
# the tool installs below, so ~/.local/bin is on PATH when Claude Code's
# installer checks for it.
Write-Info 'Setting user environment variables...'
Add-UserPath '%USERPROFILE%\.local\bin'
Set-UserVariable PNPM_HOME (Join-Path $env:LOCALAPPDATA 'pnpm')
Add-UserPath '%USERPROFILE%\AppData\Local\pnpm\bin'
if ($script:EnvironmentChanged) { Send-EnvironmentChange }
Sync-SessionPath

# --- Node (version pinned in .node-version) ---
if (Get-Command fnm -ErrorAction Ignore) {
  Write-Info 'Installing Node via fnm...'
  if ($PSCmdlet.ShouldProcess((Get-Content (Join-Path $Dotfiles '.node-version')).Trim(), 'fnm install and make default')) {
    Push-Location $Dotfiles
    try {
      fnm install
      fnm default (Get-Content .node-version).Trim()
    } finally {
      Pop-Location
    }
  }
} else {
  Write-Caution 'fnm not installed, skipping Node.'
}

# --- Claude Code (native installer: self-contained, auto-updating) ---
if (-not (Get-Command claude -ErrorAction Ignore)) {
  Write-Info 'Installing Claude Code (native)...'
  if ($PSCmdlet.ShouldProcess('Claude Code', 'Install from claude.ai/install.ps1')) {
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
  }
}

# --- Directories ---
New-Item -ItemType Directory -Force -Path (Join-Path $HOME 'dev') | Out-Null

# --- Symlinks ---
Write-Info 'Linking config files...'

# git
Set-Link (Join-Path $Dotfiles 'git\.gitconfig') (Join-Path $HOME '.gitconfig')
Set-Link (Join-Path $Dotfiles 'git\.gitconfig.windows') (Join-Path $HOME '.gitconfig.os')
Set-Link (Join-Path $Dotfiles 'git\.gitignore_global') (Join-Path $HOME '.gitignore')
$gitLocal = Join-Path $HOME '.gitconfig.local'
if (-not (Test-Path $gitLocal)) {
  Copy-Item (Join-Path $Dotfiles 'git\.gitconfig.local.example') $gitLocal
  if (-not $WhatIfPreference) { Write-Success "Created $gitLocal from template" }
}

# starship
Set-Link (Join-Path $Dotfiles 'starship\starship.toml') (Join-Path $HOME '.config\starship.toml')

# atuin: reads ~/.config/atuin as long as ~/.atuin/config.toml doesn't exist
Set-Link (Join-Path $Dotfiles 'atuin\config.toml') (Join-Path $HOME '.config\atuin\config.toml')

# PowerShell: the all-hosts profile, so IDE terminals load it too
$profileDir = Split-Path $PROFILE.CurrentUserAllHosts
Set-Link (Join-Path $Dotfiles 'powershell\profile.ps1') $PROFILE.CurrentUserAllHosts
Set-Link (Join-Path $Dotfiles 'powershell\aliases.ps1') (Join-Path $profileDir 'aliases.ps1')

# Windows Terminal (a fragment: it rewrites settings.json itself)
Set-Link (Join-Path $Dotfiles 'windows-terminal\dotfiles.json') `
  (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\dotfiles\dotfiles.json')

# user scripts (bin/): only Windows ones; extensionless POSIX scripts are macOS-only
Get-ChildItem (Join-Path $Dotfiles 'bin') -File -ErrorAction Ignore |
  Where-Object Extension -In '.cmd', '.ps1' |
  ForEach-Object { Set-Link $_.FullName (Join-Path $HOME ".local\bin\$($_.Name)") }

# editorconfig
Set-Link (Join-Path $Dotfiles '.editorconfig') (Join-Path $HOME '.editorconfig')

# claude code
$claudeDir = Join-Path $HOME '.claude'
foreach ($item in 'CLAUDE.md', 'settings.json', 'statusline.sh', 'rules', 'skills', 'templates') {
  Set-Link (Join-Path $Dotfiles "claude\$item") (Join-Path $claudeDir $item)
}

# User-scope MCP servers live in ~/.claude.json, which is runtime state and
# can't be linked, so they're registered through the CLI instead. Arguments are
# passed one by one rather than as JSON because PowerShell before 7.3 mangles
# quotes inside native-command arguments.
$mcpOk = $true
if (Get-Command claude -ErrorAction Ignore) {
  Write-Info 'Registering Claude Code MCP servers...'
  $servers = Get-Content (Join-Path $Dotfiles 'claude\mcp-servers.json') -Raw | ConvertFrom-Json
  foreach ($server in $servers.PSObject.Properties) {
    $serverArgs = @($server.Value.args | ForEach-Object { $_.Replace('${HOME}', $HOME) })
    if ($PSCmdlet.ShouldProcess($server.Name, 'Register user-scope MCP server')) {
      claude mcp remove -s user $server.Name *> $null
      claude mcp add -s user $server.Name -- $server.Value.command @serverArgs | Out-Null
      if ($LASTEXITCODE -eq 0) {
        Write-Success "MCP server: $($server.Name)"
      } else {
        $mcpOk = $false
      }
    }
  }
} else {
  $mcpOk = $false
  Write-Caution "claude isn't on PATH yet, skipping MCP servers."
}

# The skills CLI's relative links break because ~/.claude/skills points into
# this repo. Tracked skills of the same name are left alone.
Get-ChildItem (Join-Path $HOME '.agents\skills') -Directory -ErrorAction Ignore |
  Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
  ForEach-Object {
    $dst = Join-Path $claudeDir "skills\$($_.Name)"
    $existing = Get-Item -LiteralPath $dst -Force -ErrorAction Ignore
    if ($existing -and $existing.LinkType -ne 'SymbolicLink') { return }
    Set-Link $_.FullName $dst
  }

# --- Summary ---
Write-Host ''
Write-Success 'Done! Open a new terminal to load the updated config.'
Write-Host ''
if (-not $packagesOk) { Write-Caution 'Some packages failed: fix the errors above and rerun ./install.ps1.' }
if (-not $mcpOk) { Write-Caution "Some MCP servers weren't registered: fix the errors above and rerun ./install.ps1." }
Write-Caution 'Edit ~/.gitconfig.local with your git identity and signing key.'
Write-Caution 'Commits are signed: enable the 1Password SSH agent, stop and disable the "OpenSSH Authentication Agent" service (it holds the same pipe), and create ~/.config/git/allowed_signers before committing.'

# Windows Terminal applies profiles.defaults over fragments, so a colorScheme or
# font there hides the fragment's.
$wtSettings = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json" -ErrorAction Ignore |
  Select-Object -First 1
if ($wtSettings) {
  try {
    $profiles = (Get-Content $wtSettings.FullName -Raw | ConvertFrom-Json).PSObject.Properties['profiles']
    $defaults = if ($profiles) { $profiles.Value.PSObject.Properties['defaults'] }
    $overrides = @('colorScheme', 'font') | Where-Object { $defaults -and $defaults.Value.PSObject.Properties[$_] }
    if ($overrides) {
      Write-Caution "Windows Terminal: remove $($overrides -join ' and ') from profiles.defaults in settings.json, or they override the dotfiles fragment."
    }
  } catch {
    # An unreadable settings.json only costs the hint.
    Write-Verbose "Skipped the Windows Terminal check: $_"
  }
}
