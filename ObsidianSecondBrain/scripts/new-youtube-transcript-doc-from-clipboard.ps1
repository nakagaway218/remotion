#Requires -Version 7.0

param(
  [string]$VideoUrl = "",
  [int]$RowNumber = 0,
  [string]$DocTitle = "",
  [string]$SpreadsheetId = "1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8",
  [string]$TokenPath = "..\secrets\google-oauth-token.json",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
$repoDir = Resolve-Path -LiteralPath (Join-Path $scriptDir "..")
Set-Location -LiteralPath $repoDir.Path

$resolvedTokenPath = Resolve-Path -LiteralPath $TokenPath -ErrorAction SilentlyContinue
if (-not $resolvedTokenPath) {
  throw "OAuth token not found: $TokenPath. Run scripts/get-google-refresh-token.ps1 first."
}

$token = Get-Content -LiteralPath $resolvedTokenPath.Path -Raw | ConvertFrom-Json
$env:GOOGLE_CLIENT_ID = $token.client_id
$env:GOOGLE_CLIENT_SECRET = $token.client_secret
$env:GOOGLE_REFRESH_TOKEN = $token.refresh_token

if ($RowNumber -lt 1 -and [string]::IsNullOrWhiteSpace($VideoUrl)) {
  $VideoUrl = Read-Host "YouTube URLを貼り付けてください"
}

$clipboard = Get-Clipboard -Raw
if ([string]::IsNullOrWhiteSpace($clipboard)) {
  throw "クリップボードが空です。先にYouTube SummaryのTranscript本文をコピーしてください。"
}

$argsForScript = @(
  "-FromClipboard",
  "-SpreadsheetId", $SpreadsheetId
)

if ($RowNumber -gt 0) {
  $argsForScript += @("-RowNumber", $RowNumber)
}
elseif (-not [string]::IsNullOrWhiteSpace($VideoUrl)) {
  $argsForScript += @("-VideoUrl", $VideoUrl)
}

if (-not [string]::IsNullOrWhiteSpace($DocTitle)) {
  $argsForScript += @("-DocTitle", $DocTitle)
}

if ($DryRun) {
  $argsForScript += "-DryRun"
}

& (Join-Path $scriptDir "new-youtube-transcript-doc.ps1") @argsForScript
