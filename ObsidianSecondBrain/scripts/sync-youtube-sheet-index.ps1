param(
  [string]$SpreadsheetId = "1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8",
  [string]$Range = "A1:K200",
  [string]$OutputDir = "raw/webclip-index",
  [string]$DriveFolderId = "1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Get-AccessToken {
  if ($env:GOOGLE_ACCESS_TOKEN) {
    return $env:GOOGLE_ACCESS_TOKEN
  }

  if ($env:GOOGLE_CLIENT_ID -and $env:GOOGLE_CLIENT_SECRET -and $env:GOOGLE_REFRESH_TOKEN) {
    $body = @{
      client_id     = $env:GOOGLE_CLIENT_ID
      client_secret = $env:GOOGLE_CLIENT_SECRET
      refresh_token = $env:GOOGLE_REFRESH_TOKEN
      grant_type    = "refresh_token"
    }

    $response = Invoke-RestMethod `
      -Method Post `
      -Uri "https://oauth2.googleapis.com/token" `
      -Body $body

    return $response.access_token
  }

  throw "Set GOOGLE_ACCESS_TOKEN, or set GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, and GOOGLE_REFRESH_TOKEN."
}

function ConvertTo-Slug {
  param([string]$Text)

  $normalized = if ([string]::IsNullOrWhiteSpace($Text)) { "youtube-source" } else { $Text.Trim().ToLowerInvariant() }
  $slug = $normalized -replace "[^\p{L}\p{Nd}]+", "-"
  $slug = $slug.Trim("-")

  if ([string]::IsNullOrWhiteSpace($slug)) {
    return "youtube-source"
  }

  if ($slug.Length -gt 80) {
    return $slug.Substring(0, 80).Trim("-")
  }

  return $slug
}

function Escape-FrontMatterValue {
  param([string]$Value)

  if ($null -eq $Value) {
    return ""
  }

  return ($Value -replace '"', '\"')
}

function Get-CellValue {
  param(
    [object[]]$Row,
    [hashtable]$HeaderMap,
    [string[]]$Names
  )

  foreach ($name in $Names) {
    if ($HeaderMap.ContainsKey($name)) {
      $index = $HeaderMap[$name]
      if ($index -lt $Row.Count) {
        return [string]$Row[$index]
      }
    }
  }

  return ""
}

function Normalize-Header {
  param([string]$Header)

  return $Header.Trim().ToLowerInvariant() -replace "\s+", "_"
}

function Get-DriveFileByName {
  param(
    [string]$AccessToken,
    [string]$FolderId,
    [string]$Name
  )

  if ([string]::IsNullOrWhiteSpace($Name)) {
    return $null
  }

  $safeName = $Name -replace "'", "\'"
  $query = "'$FolderId' in parents and name = '$safeName' and trashed = false"
  $uri = "https://www.googleapis.com/drive/v3/files?q=$([uri]::EscapeDataString($query))&fields=files(id,name,webViewLink,mimeType,modifiedTime)&pageSize=1"
  $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri

  if ($response.files.Count -gt 0) {
    return $response.files[0]
  }

  return $null
}

$root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$resolvedOutputDir = Join-Path $root $OutputDir

if (-not (Test-Path -LiteralPath $resolvedOutputDir)) {
  if ($DryRun) {
    Write-Host "Would create directory: $resolvedOutputDir"
  } else {
    New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null
  }
}

$accessToken = Get-AccessToken
$encodedRange = [uri]::EscapeDataString($Range)
$sheetsUri = "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId/values/$encodedRange"
$sheet = Invoke-RestMethod -Headers @{ Authorization = "Bearer $accessToken" } -Uri $sheetsUri

if (-not $sheet.values -or $sheet.values.Count -lt 2) {
  Write-Host "No data rows found in range $Range."
  exit 0
}

$headers = @($sheet.values[0])
$headerMap = @{}
for ($i = 0; $i -lt $headers.Count; $i++) {
  $normalizedHeader = Normalize-Header ([string]$headers[$i])
  if ($normalizedHeader -and -not $headerMap.ContainsKey($normalizedHeader)) {
    $headerMap[$normalizedHeader] = $i
  }
}

$today = (Get-Date).ToString("yyyy-MM-dd")
$created = 0
$skipped = 0

for ($rowIndex = 1; $rowIndex -lt $sheet.values.Count; $rowIndex++) {
  $row = @($sheet.values[$rowIndex])
  $title = Get-CellValue $row $headerMap @("title", "タイトル", "動画タイトル", "動画名")
  $url = Get-CellValue $row $headerMap @("url", "ｕｒｌ", "youtube_url", "youtube", "リンク")

  if ([string]::IsNullOrWhiteSpace($url)) {
    $skipped++
    continue
  }

  if ([string]::IsNullOrWhiteSpace($title)) {
    $title = "YouTube source row $($rowIndex + 1)"
  }

  $channel = Get-CellValue $row $headerMap @("channel", "チャンネル", "チャンネル名")
  $theme = Get-CellValue $row $headerMap @("theme", "テーマ", "主題")
  $priority = Get-CellValue $row $headerMap @("priority", "優先度")
  $status = Get-CellValue $row $headerMap @("status", "状態", "視聴状況")
  $keyPoints = Get-CellValue $row $headerMap @("key_points", "keypoints", "要点")
  $action = Get-CellValue $row $headerMap @("action", "反映", "自分のプロジェクトに反映すること")
  $driveUrl = Get-CellValue $row $headerMap @("drive_url", "drive", "google_drive")
  $driveName = Get-CellValue $row $headerMap @("drive_name", "drive_file", "保存ファイル名")
  $wikiLink = Get-CellValue $row $headerMap @("wiki_link", "wiki", "整理後ノート")

  if ([string]::IsNullOrWhiteSpace($driveUrl) -and -not [string]::IsNullOrWhiteSpace($driveName)) {
    $driveFile = Get-DriveFileByName $accessToken $DriveFolderId $driveName
    if ($driveFile) {
      $driveUrl = $driveFile.webViewLink
    }
  }

  $slug = ConvertTo-Slug $title
  $path = Join-Path $resolvedOutputDir "$today-youtube-$slug.md"

  if (Test-Path -LiteralPath $path) {
    $skipped++
    continue
  }

  $frontTitle = Escape-FrontMatterValue $title
  $frontUrl = Escape-FrontMatterValue $url
  $frontDriveUrl = Escape-FrontMatterValue $driveUrl

  $content = @"
---
type: source
status: 未整理
date: $today
source_type: youtube
title: "$frontTitle"
url: "$frontUrl"
drive_url: "$frontDriveUrl"
tags: [raw, youtube, ai-agent]
---

# $title

## 元動画

- URL: $url
- チャンネル: $channel
- テーマ: $theme
- 優先度: $priority
- 状態: $status
- Drive保存先: $driveUrl

## 要点メモ

$keyPoints

## 自分のプロジェクトに反映すること

$action

## 次に整理するなら

- $wikiLink
"@

  if ($DryRun) {
    Write-Host "Would create: $path"
  } else {
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
    Write-Host "Created: $path"
  }

  $created++
}

Write-Host "Done. Created: $created, skipped: $skipped."
