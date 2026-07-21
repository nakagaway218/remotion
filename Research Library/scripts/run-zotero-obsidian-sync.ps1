param(
    [switch]$DryRun,
    [switch]$UpdateExisting,
    [ValidateSet("off", "dry-run", "sync")]
    [string]$NotionMode = "dry-run",
    [string]$ObsidianVaultPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$zoteroExportPath = Join-Path $repoRoot "zotero\zotero-export.json"
$syncScript = Join-Path $PSScriptRoot "sync-zotero-obsidian-notion.ps1"

if ([string]::IsNullOrWhiteSpace($ObsidianVaultPath)) {
    $ObsidianVaultPath = Join-Path $repoRoot "outputs\obsidian-zotero-notes"
}

if (-not (Test-Path -LiteralPath $zoteroExportPath -PathType Leaf)) {
    Write-Host "Zotero export JSON was not found."
    Write-Host "In Zotero / Better BibTeX, export Better CSL JSON or CSL JSON to:"
    Write-Host $zoteroExportPath
    exit 2
}

& $syncScript `
    -ZoteroExportPath $zoteroExportPath `
    -ObsidianVaultPath $ObsidianVaultPath `
    -ObsidianFolder "00_sources\zotero" `
    -NotionMode $NotionMode `
    -DryRun:$DryRun `
    -UpdateExisting:$UpdateExisting
