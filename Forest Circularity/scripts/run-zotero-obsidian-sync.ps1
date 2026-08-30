param(
    [string]$ZoteroExportPath = "C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-export.json",
    [string]$ObsidianVaultPath = "",
    [string]$ObsidianFolder = ".",
    [ValidateSet("off", "dry-run", "sync")]
    [string]$NotionMode = "dry-run",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$syncScript = Join-Path $PSScriptRoot "sync-zotero-obsidian-notion.ps1"

if ([string]::IsNullOrWhiteSpace($ObsidianVaultPath)) {
    $ObsidianVaultPath = Join-Path $repoRoot "outputs\obsidian-zotero-notes"
}

if (-not (Test-Path -LiteralPath $ObsidianVaultPath -PathType Container)) {
    [System.IO.Directory]::CreateDirectory($ObsidianVaultPath) | Out-Null
}

if (-not (Test-Path -LiteralPath $ObsidianVaultPath)) {
    throw "Obsidian vault was not found: $ObsidianVaultPath"
}

if (-not (Test-Path -LiteralPath $ZoteroExportPath)) {
    Write-Host "Zotero export JSON was not found yet."
    Write-Host "Please export from Zotero / Better BibTeX to:"
    Write-Host $ZoteroExportPath
    Write-Host ""
    Write-Host "After that, run this script again."
    exit 2
}

$env:ZOTERO_BBT_EXPORT_PATH = $ZoteroExportPath
$env:OBSIDIAN_VAULT_PATH = $ObsidianVaultPath

& $syncScript `
    -ZoteroExportPath $env:ZOTERO_BBT_EXPORT_PATH `
    -ObsidianVaultPath $env:OBSIDIAN_VAULT_PATH `
    -ObsidianFolder $ObsidianFolder `
    -NotionMode $NotionMode `
    -DryRun:$DryRun

Set-Location -LiteralPath $repoRoot

