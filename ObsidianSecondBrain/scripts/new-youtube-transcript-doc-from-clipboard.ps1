#Requires -Version 7.0

param(
  [string]$VideoUrl = "",
  [int]$RowNumber = 0,
  [string]$DocTitle = "",
  [string]$ExistingDocUrl = "",
  [switch]$NoFillBlankMetadata,
  [int]$MinTranscriptChars = 200,
  [switch]$AllowShortTranscript,
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

if ([string]::IsNullOrWhiteSpace($DocTitle)) {
  $DocTitle = Read-Host "動画タイトルを入力してください（推奨。空EnterならDocsタイトルと動画名は未設定）"
}

if ([string]::IsNullOrWhiteSpace($ExistingDocUrl)) {
  while ($true) {
    $clipboard = Get-Clipboard -Raw
    $clipboardText = if ($null -eq $clipboard) { "" } else { $clipboard.Trim() }

    if ([string]::IsNullOrWhiteSpace($clipboardText)) {
      Read-Host "クリップボードが空です。YouTube SummaryのTranscript本文をコピーしてからEnterを押してください"
      continue
    }

    if ($clipboardText -match '(?im)^\s*cd\s+' -or
        $clipboardText -match '(?im)^\s*powershell\s+' -or
        $clipboardText -match '(?im)^\s*pwsh\s+' -or
        $clipboardText -match '(?im)^\s*\.\s*\\scripts\\' -or
        $clipboardText -match '(?im)new-youtube-transcript-doc') {
      Read-Host "クリップボードの内容がコマンド文に見えます。Transcript本文をコピーし直してからEnterを押してください"
      continue
    }

    if (-not [string]::IsNullOrWhiteSpace($DocTitle) -and $clipboardText -eq $DocTitle.Trim()) {
      Read-Host "クリップボードの内容が動画タイトルと同じです。Transcript本文をコピーし直してからEnterを押してください"
      continue
    }

    if (-not $AllowShortTranscript -and $clipboardText.Length -lt $MinTranscriptChars) {
      $shortAnswer = Read-Host "クリップボードは$($clipboardText.Length)文字です。短いTranscriptとしてこのままDocs本文にしますか？ y/N（Nならコピーし直してEnter）"
      if ($shortAnswer -match '^(y|yes|Y|YES)$') {
        $AllowShortTranscript = $true
        break
      }

      Read-Host "YouTube SummaryのTranscript本文をコピーし直してからEnterを押してください"
      continue
    }

    break
  }
}

$paramsForScript = @{
  SpreadsheetId = $SpreadsheetId
  SpreadsheetTitle = $SpreadsheetTitle
  TokenPath = $TokenPath
  MinTranscriptChars = $MinTranscriptChars
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
  $paramsForScript.Title = $DocTitle
}

if ($DryRun) {
  $paramsForScript.DryRun = $true
}

if (-not $NoFillBlankMetadata) {
  $paramsForScript.FillBlankMetadata = $true
  $paramsForScript.FillBlankUrl = $true
}

if ($AllowShortTranscript) {
  $paramsForScript.AllowShortTranscript = $true
}

& (Join-Path $scriptDir "new-youtube-transcript-doc.ps1") @paramsForScript
