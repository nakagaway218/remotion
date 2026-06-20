#Requires -Version 7.0

param(
  [string]$IndexDir = "raw/webclip-index",
  [string]$OutputDir = "reports/github-repo-reviews",
  [int]$HttpTimeoutSec = 30,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function ConvertTo-Slug {
  param([string]$Text)

  $normalized = if ([string]::IsNullOrWhiteSpace($Text)) { "github-repo" } else { $Text.Trim().ToLowerInvariant() }
  $slug = $normalized -replace "[^\p{L}\p{Nd}]+", "-"
  $slug = $slug.Trim("-")

  if ([string]::IsNullOrWhiteSpace($slug)) {
    return "github-repo"
  }

  if ($slug.Length -gt 90) {
    return $slug.Substring(0, 90).Trim("-")
  }

  return $slug
}

function Get-FrontMatterValue {
  param(
    [string]$Content,
    [string]$Name
  )

  $pattern = "(?m)^$([regex]::Escape($Name)):\s*`"?([^`"`r`n]*)`"?\s*$"
  $match = [regex]::Match($Content, $pattern)
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }

  return ""
}

function Get-GitHubRepoFromUrl {
  param([string]$Url)

  if ([string]::IsNullOrWhiteSpace($Url)) {
    return $null
  }

  $match = [regex]::Match($Url.Trim(), "^https://github\.com/([^/\s?#]+)/([^/\s?#]+)")
  if (-not $match.Success) {
    return $null
  }

  $owner = $match.Groups[1].Value
  $repo = $match.Groups[2].Value -replace "\.git$", ""

  if ($repo -in @("pull", "issues", "compare", "releases", "topics", "marketplace")) {
    return $null
  }

  return [PSCustomObject]@{
    Owner = $owner
    Repo = $repo
    FullName = "$owner/$repo"
  }
}

function Invoke-GitHubJson {
  param([string]$Uri)

  $headers = @{
    "User-Agent" = "ObsidianSecondBrain-source-review"
    "Accept" = "application/vnd.github+json"
  }

  if ($env:GITHUB_TOKEN) {
    $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
  }

  return Invoke-RestMethod -Headers $headers -Uri $Uri -TimeoutSec $HttpTimeoutSec
}

function Invoke-GitHubText {
  param([string]$Uri)

  $headers = @{
    "User-Agent" = "ObsidianSecondBrain-source-review"
    "Accept" = "application/vnd.github.raw"
  }

  if ($env:GITHUB_TOKEN) {
    $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
  }

  return Invoke-RestMethod -Headers $headers -Uri $Uri -TimeoutSec $HttpTimeoutSec
}

function Get-RepoFileText {
  param(
    [string]$Owner,
    [string]$Repo,
    [string]$Path
  )

  try {
    return [string](Invoke-GitHubText "https://api.github.com/repos/$Owner/$Repo/contents/$([uri]::EscapeDataString($Path))")
  } catch {
    return ""
  }
}

function Limit-Text {
  param(
    [string]$Text,
    [int]$MaxChars = 2500
  )

  if ([string]::IsNullOrWhiteSpace($Text)) {
    return ""
  }

  $trimmed = $Text.Trim()
  if ($trimmed.Length -le $MaxChars) {
    return $trimmed
  }

  return $trimmed.Substring(0, $MaxChars).Trim() + "`n... (truncated)"
}

function Get-RiskSignals {
  param([string]$Text)

  $signals = @()
  $checks = @(
    @{ Pattern = "curl\s+.*\|\s*(sh|bash|powershell|pwsh)"; Label = "downloads piped directly to a shell" },
    @{ Pattern = "irm\s+.*\|\s*iex"; Label = "PowerShell Invoke-Expression pipeline" },
    @{ Pattern = "Invoke-Expression|iex\b"; Label = "Invoke-Expression usage" },
    @{ Pattern = "rm\s+-rf|Remove-Item\s+.*-Recurse"; Label = "recursive delete command" },
    @{ Pattern = "git\s+reset\s+--hard|git\s+clean\s+-fd"; Label = "destructive git operation" },
    @{ Pattern = "chmod\s+\+x|sudo\s+"; Label = "permission change or sudo usage" },
    @{ Pattern = "token|secret|credential|api[_-]?key"; Label = "credential-related wording" }
  )

  foreach ($check in $checks) {
    if ($Text -match $check.Pattern) {
      $signals += $check.Label
    }
  }

  return @($signals | Select-Object -Unique)
}

function Get-InstallSignals {
  param([string]$Text)

  $signals = @()
  $checks = @(
    @{ Pattern = "npm\s+install|npm\s+i\b|pnpm\s+add|yarn\s+add"; Label = "Node package install" },
    @{ Pattern = "pip\s+install|uv\s+add|poetry\s+add"; Label = "Python package install" },
    @{ Pattern = "cargo\s+install|go\s+install|brew\s+install"; Label = "language or system tool install" },
    @{ Pattern = "docker\s+run|docker\s+compose"; Label = "Docker execution" },
    @{ Pattern = "claude|codex|skill|plugin|mcp"; Label = "AI agent, skill, plugin, or MCP reference" }
  )

  foreach ($check in $checks) {
    if ($Text -match $check.Pattern) {
      $signals += $check.Label
    }
  }

  return @($signals | Select-Object -Unique)
}

function New-ReviewMarkdown {
  param(
    [object]$RepoInfo,
    [object]$RepoMeta,
    [object[]]$RootFiles,
    [string]$ReadmeText,
    [string]$AgentsText,
    [string]$PackageText,
    [string]$SourceIndexPath,
    [string]$Today
  )

  $combinedText = @($ReadmeText, $AgentsText, $PackageText) -join "`n"
  $riskSignals = @(Get-RiskSignals $combinedText)
  $installSignals = @(Get-InstallSignals $combinedText)
  $rootFileNames = @()
  foreach ($rootFile in $RootFiles) {
    $items = if ($rootFile -is [array]) { $rootFile } else { @($rootFile) }
    foreach ($item in $items) {
      if ($null -ne $item.name) {
        $rootFileNames += [string]$item.name
      }
    }
  }

  $license = if ($RepoMeta.license -and $RepoMeta.license.spdx_id) { $RepoMeta.license.spdx_id } else { "not detected" }
  $defaultBranch = if ($RepoMeta.default_branch) { $RepoMeta.default_branch } else { "not detected" }
  $decision = if ($riskSignals.Count -gt 0) { "manual-review-required" } elseif ($installSignals.Count -gt 0) { "candidate-with-conditions" } else { "hold-as-reference" }
  $decisionReason = if ($riskSignals.Count -gt 0) {
    "Automated checks found risk signals. Review the actual files before installing or executing anything."
  } elseif ($installSignals.Count -gt 0) {
    "The repository appears relevant to installation or integration, and no strong risk signal was found in the checked files. Confirm fit before trial use."
  } else {
    "The checked files do not provide enough evidence for adoption. Keep it as reference for now."
  }

  $riskLines = if ($riskSignals.Count -gt 0) { ($riskSignals | ForEach-Object { "- $_" }) -join "`n" } else { "- No strong risk signal detected by this script." }
  $installLines = if ($installSignals.Count -gt 0) { ($installSignals | ForEach-Object { "- $_" }) -join "`n" } else { "- No install or integration signal detected by this script." }
  $fileLines = if ($rootFileNames.Count -gt 0) { ($rootFileNames | Sort-Object | ForEach-Object { "- $($_)" }) -join "`n" } else { "- not fetched" }
  $readmeExcerpt = Limit-Text $ReadmeText 2200
  $agentsExcerpt = Limit-Text $AgentsText 1200
  $packageExcerpt = Limit-Text $PackageText 1200

  if ([string]::IsNullOrWhiteSpace($readmeExcerpt)) {
    $readmeExcerpt = "README was not fetched."
  }
  if ([string]::IsNullOrWhiteSpace($agentsExcerpt)) {
    $agentsExcerpt = "AGENTS.md was not found."
  }
  if ([string]::IsNullOrWhiteSpace($packageExcerpt)) {
    $packageExcerpt = "package.json was not found."
  }

  return @"
---
type: github_repo_review
status: auto-reviewed
date: $Today
repo: $($RepoInfo.FullName)
source_url: https://github.com/$($RepoInfo.FullName)
source_index: $SourceIndexPath
decision: $decision
tags: [report, github, tool-review]
---

# $($RepoInfo.FullName) adoption review

## Decision

**Decision: $decision**

$decisionReason

## Repository metadata

- GitHub: https://github.com/$($RepoInfo.FullName)
- Description: $($RepoMeta.description)
- Default branch: $defaultBranch
- License: $license
- Stars: $($RepoMeta.stargazers_count)
- Forks: $($RepoMeta.forks_count)
- Open issues: $($RepoMeta.open_issues_count)
- Last pushed: $($RepoMeta.pushed_at)
- Source index: [$(Split-Path -Leaf $SourceIndexPath)]($SourceIndexPath)

## Install or integration signals

$installLines

## Risk signals

$riskLines

## Root files

$fileLines

## README excerpt

~~~text
$readmeExcerpt
~~~

## AGENTS.md excerpt

~~~text
$agentsExcerpt
~~~

## package.json excerpt

~~~json
$packageExcerpt
~~~

## Follow-up checks

- Before adoption, inspect the exact install commands in README or docs.
- If scripts, .github/workflows, or shell installers exist, inspect them directly.
- Do not adopt it if existing Codex skills, Google Drive integration, or local workflow files already cover the same need.
"@
}

$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$resolvedIndexDir = Join-Path $root $IndexDir
$resolvedOutputDir = Join-Path $root $OutputDir

if (-not (Test-Path -LiteralPath $resolvedIndexDir)) {
  throw "Index directory not found: $resolvedIndexDir"
}

if (-not (Test-Path -LiteralPath $resolvedOutputDir)) {
  if ($DryRun) {
    Write-Host "Would create directory: $resolvedOutputDir"
  } else {
    New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null
  }
}

$today = (Get-Date).ToString("yyyy-MM-dd")
$created = 0
$skipped = 0
$failed = 0
$seen = @{}

$indexFiles = @(Get-ChildItem -LiteralPath $resolvedIndexDir -Filter "*.md" -File)

foreach ($indexFile in $indexFiles) {
  $content = Get-Content -LiteralPath $indexFile.FullName -Raw
  if ($content -notmatch "github\.com/") {
    continue
  }

  $url = Get-FrontMatterValue $content "url"
  if ([string]::IsNullOrWhiteSpace($url)) {
    $match = [regex]::Match($content, "https://github\.com/[^\s\)]+")
    if ($match.Success) {
      $url = $match.Value
    }
  }

  $repoInfo = Get-GitHubRepoFromUrl $url
  if (-not $repoInfo) {
    continue
  }

  if ($seen.ContainsKey($repoInfo.FullName)) {
    continue
  }
  $seen[$repoInfo.FullName] = $true

  $slug = ConvertTo-Slug $repoInfo.FullName
  $outputPath = Join-Path $resolvedOutputDir "$today-github-$slug.md"

  $existing = @(Get-ChildItem -LiteralPath $resolvedOutputDir -Filter "*.md" -File -ErrorAction SilentlyContinue |
    Select-String -Pattern "repo: $($repoInfo.FullName)" -SimpleMatch -List)

  if ((Test-Path -LiteralPath $outputPath) -or $existing.Count -gt 0) {
    $skipped++
    continue
  }

  try {
    Write-Host "Reviewing GitHub repo: $($repoInfo.FullName)"
    $repoMeta = Invoke-GitHubJson "https://api.github.com/repos/$($repoInfo.Owner)/$($repoInfo.Repo)"
    $rootFiles = @(Invoke-GitHubJson "https://api.github.com/repos/$($repoInfo.Owner)/$($repoInfo.Repo)/contents")
    $readmeText = Get-RepoFileText $repoInfo.Owner $repoInfo.Repo "README.md"
    if ([string]::IsNullOrWhiteSpace($readmeText)) {
      $readmeText = Get-RepoFileText $repoInfo.Owner $repoInfo.Repo "readme.md"
    }
    $agentsText = Get-RepoFileText $repoInfo.Owner $repoInfo.Repo "AGENTS.md"
    $packageText = Get-RepoFileText $repoInfo.Owner $repoInfo.Repo "package.json"
    $relativeIndexPath = $indexFile.FullName.Substring($root.Path.Length + 1) -replace "\\", "/"

    $review = New-ReviewMarkdown `
      -RepoInfo $repoInfo `
      -RepoMeta $repoMeta `
      -RootFiles $rootFiles `
      -ReadmeText $readmeText `
      -AgentsText $agentsText `
      -PackageText $packageText `
      -SourceIndexPath $relativeIndexPath `
      -Today $today

    if ($DryRun) {
      Write-Host "Would create GitHub repo review: $outputPath"
    } else {
      Set-Content -LiteralPath $outputPath -Value $review -Encoding UTF8
      Write-Host "Created GitHub repo review: $outputPath"
    }

    $created++
  } catch {
    $failed++
    Write-Warning "Failed to review $($repoInfo.FullName): $($_.Exception.Message)"
  }
}

Write-Host "Done. github_repos=$($seen.Count), created=$created, skipped=$skipped, failed=$failed."
