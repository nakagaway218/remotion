#Requires -Version 7.0

param(
  [string]$VideoUrl = "",
  [int]$RowNumber = 0,
  [string]$DocTitle = "",
  [string]$ExistingDocUrl = "",
  [string]$SpreadsheetId = "1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8",
  [string]$SpreadsheetTitle = "AIエージェント参考YouTubeリスト",
  [string]$SheetName = "",
  [string]$TokenPath = "..\secrets\google-oauth-token.json",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
$repoDir = Resolve-Path -LiteralPath (Join-Path $scriptDir "..")
Set-Location -LiteralPath $repoDir.Path

if ($RowNumber -lt 1 -and [string]::IsNullOrWhiteSpace($VideoUrl)) {
  $VideoUrl = Read-Host "YouTube URLを貼り付けてください"
}

if ([string]::IsNullOrWhiteSpace($ExistingDocUrl)) {
  $clipboard = Get-Clipboard -Raw
  if ([string]::IsNullOrWhiteSpace($clipboard)) {
    throw "クリップボードが空です。先にYouTube SummaryのTranscript本文をコピーしてください。"
  }
}

$paramsForScript = @{
  SpreadsheetId = $SpreadsheetId
  SpreadsheetTitle = $SpreadsheetTitle
  TokenPath = $TokenPath
}

if ([string]::IsNullOrWhiteSpace($ExistingDocUrl)) {
  $paramsForScript.FromClipboard = $true
}
else {
  $paramsForScript.ExistingDocUrl = $ExistingDocUrl
}

if (-not [string]::IsNullOrWhiteSpace($SheetName)) {
  $paramsForScript.SheetName = $SheetName
}

if ($RowNumber -gt 0) {
  $paramsForScript.RowNumber = $RowNumber
}
elseif (-not [string]::IsNullOrWhiteSpace($VideoUrl)) {
  $paramsForScript.VideoUrl = $VideoUrl
}

if (-not [string]::IsNullOrWhiteSpace($DocTitle)) {
  $paramsForScript.DocTitle = $DocTitle
}

if ($DryRun) {
  $paramsForScript.DryRun = $true
}

& (Join-Path $scriptDir "new-youtube-transcript-doc.ps1") @paramsForScript
