# PSScriptAnalyzer settings for the repo's PowerShell (install.ps1,
# powershell/). Used by the `psscriptanalyzer` job in .github/workflows/lint.yml.
@{
  Severity     = @('Error', 'Warning')
  ExcludeRules = @(
    # These are interactive scripts: colored console output is the point.
    'PSAvoidUsingWriteHost'
    # starship, zoxide, fnm and atuin ship their shell integration as code to
    # pipe into Invoke-Expression, and so do the scoop and Claude Code installers.
    'PSAvoidUsingInvokeExpression'
    # Every script here requires PowerShell 7, which reads UTF-8 without a BOM.
    # A BOM would only matter to Windows PowerShell 5.1.
    'PSUseBOMForUnicodeEncodedFile'
  )
}
