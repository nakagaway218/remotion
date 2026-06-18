param(
  [string]$SpreadsheetId = "1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8",
  [string]$Range = "A1:Z1000",
  [string]$OutputDir = "raw/webclip-index",
  [string]$DriveFolderId = "1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz",
  [switch]$DisableSpreadsheetDiscovery,
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

function ConvertTo-IndexDate {
  param(
    [string]$Value,
    [string]$Fallback
  )

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $Fallback
  }

  $trimmed = $Value.Trim()
  $match = [regex]::Match($trimmed, "^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$")
  if ($match.Success) {
    return "{0}-{1:D2}-{2:D2}" -f [int]$match.Groups[1].Value, [int]$match.Groups[2].Value, [int]$match.Groups[3].Value
  }

  $parsed = [datetime]::MinValue
  if ([datetime]::TryParse($trimmed, [ref]$parsed)) {
    return $parsed.ToString("yyyy-MM-dd")
  }

  return $Fallback
}

function Get-SourceType {
  param([string]$SpreadsheetTitle)

  if ($SpreadsheetTitle -match "記事") {
    return "article"
  }

  if ($SpreadsheetTitle -match "YouTube|youtube|動画") {
    return "youtube"
  }

  return "source"
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

function Get-DriveFilesInFolder {
  param(
    [string]$AccessToken,
    [string]$FolderId
  )

  $query = "'$FolderId' in parents and trashed = false"
  $fields = "nextPageToken,files(id,name,webViewLink,mimeType,modifiedTime)"
  $pageToken = $null
  $files = @()

  do {
    $uri = "https://www.googleapis.com/drive/v3/files?q=$([uri]::EscapeDataString($query))&fields=$([uri]::EscapeDataString($fields))&pageSize=100"
    if ($pageToken) {
      $uri += "&pageToken=$([uri]::EscapeDataString($pageToken))"
    }

    $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri
    if ($response.files) {
      $files += @($response.files)
    }
    $pageToken = $response.nextPageToken
  } while ($pageToken)

  return $files
}

function Get-SpreadsheetsInDriveFolder {
  param(
    [object[]]$Files
  )

  return @($Files | Where-Object { $_.mimeType -eq "application/vnd.google-apps.spreadsheet" })
}

function Get-SourceTypeFromMimeType {
  param(
    [string]$MimeType,
    [string]$Name
  )

  if ($MimeType -eq "application/vnd.google-apps.document") {
    return "document"
  }

  if ($MimeType -eq "application/pdf") {
    return "pdf"
  }

  if ($MimeType -like "image/*") {
    return "image"
  }

  if ($MimeType -like "video/*") {
    return "video"
  }

  if ($MimeType -like "audio/*") {
    return "audio"
  }

  if ($MimeType -eq "application/vnd.google-apps.folder") {
    return "folder"
  }

  return "drive-file"
}

function Test-ExistingSourceUrl {
  param(
    [string]$OutputDirectory,
    [string]$Url
  )

  if ([string]::IsNullOrWhiteSpace($Url) -or -not (Test-Path -LiteralPath $OutputDirectory)) {
    return $false
  }

  $needle = $Url.Trim()
  $matches = Get-ChildItem -LiteralPath $OutputDirectory -Filter "*.md" -File |
    Select-String -Pattern $needle -SimpleMatch -List

  return [bool]$matches
}

function Test-ExistingDriveFileId {
  param(
    [string]$OutputDirectory,
    [string]$FileId
  )

  if ([string]::IsNullOrWhiteSpace($FileId) -or -not (Test-Path -LiteralPath $OutputDirectory)) {
    return $false
  }

  $matches = Get-ChildItem -LiteralPath $OutputDirectory -Filter "*.md" -File |
    Select-String -Pattern $FileId.Trim() -SimpleMatch -List

  return [bool]$matches
}

function Test-HeaderExists {
  param(
    [hashtable]$HeaderMap,
    [string[]]$Names
  )

  foreach ($name in $Names) {
    if ($HeaderMap.ContainsKey($name)) {
      return $true
    }
  }

  return $false
}

function Sync-SpreadsheetRows {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId,
    [string]$SpreadsheetTitle,
    [string]$Range,
    [string]$DriveFolderId,
    [string]$OutputDirectory,
    [string]$Today,
    [switch]$DryRun
  )

  $encodedRange = [uri]::EscapeDataString($Range)
  $sheetsUri = "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId/values/$encodedRange"
  $sheet = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $sheetsUri

  if (-not $sheet.values -or $sheet.values.Count -lt 2) {
    Write-Host "No data rows found in '$SpreadsheetTitle' range $Range."
    return @{ Created = 0; Skipped = 0 }
  }

  $headers = @($sheet.values[0])
  $headerMap = @{}
  for ($i = 0; $i -lt $headers.Count; $i++) {
    $normalizedHeader = Normalize-Header ([string]$headers[$i])
    if ($normalizedHeader -and -not $headerMap.ContainsKey($normalizedHeader)) {
      $headerMap[$normalizedHeader] = $i
    }
  }

  $dataRowCount = [Math]::Max(0, $sheet.values.Count - 1)
  Write-Host "Loaded spreadsheet: '$SpreadsheetTitle' headers=$($headers.Count), data_rows=$dataRowCount, range=$Range."

  $rangeLimit = [regex]::Match($Range, "(\d+)$")
  if ($rangeLimit.Success -and $sheet.values.Count -ge [int]$rangeLimit.Groups[1].Value) {
    Write-Warning "Range limit reached in '$SpreadsheetTitle' ($Range). Rows below the configured range may be missed."
  }

  $urlHeaderNames = @("url", "ｕｒｌ", "url_or_link", "ｕｒｌ_or_link", "youtube_url", "youtube", "link", "リンク", "記事url", "記事リンク")
  if (-not (Test-HeaderExists $headerMap $urlHeaderNames)) {
    Write-Warning "No URL column detected in '$SpreadsheetTitle'. Headers: $($headers -join ', ')"
    return @{ Created = 0; Skipped = $dataRowCount }
  }

  $created = 0
  $skipped = 0

  for ($rowIndex = 1; $rowIndex -lt $sheet.values.Count; $rowIndex++) {
    $row = @($sheet.values[$rowIndex])
    $sourceType = Get-SourceType $SpreadsheetTitle
    $sourceDate = Get-CellValue $row $headerMap @("date", "追加日", "日付", "登録日", "作成日")
    $indexDate = ConvertTo-IndexDate $sourceDate $Today
    $title = Get-CellValue $row $headerMap @("title", "タイトル", "動画タイトル", "動画名", "記事タイトル", "記事名", "name", "名称")
    $url = Get-CellValue $row $headerMap $urlHeaderNames

    if ([string]::IsNullOrWhiteSpace($url)) {
      $skipped++
      continue
    }

    if ([string]::IsNullOrWhiteSpace($title)) {
      $title = "$sourceType source row $($rowIndex + 1)"
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
      $driveFile = Get-DriveFileByName $AccessToken $DriveFolderId $driveName
      if ($driveFile) {
        $driveUrl = $driveFile.webViewLink
      }
    }

    $slug = ConvertTo-Slug $title
    $path = Join-Path $OutputDirectory "$indexDate-$sourceType-$slug.md"

    if ((Test-Path -LiteralPath $path) -or (Test-ExistingSourceUrl $OutputDirectory $url)) {
      $skipped++
      continue
    }

    $frontTitle = Escape-FrontMatterValue $title
    $frontUrl = Escape-FrontMatterValue $url
    $frontDriveUrl = Escape-FrontMatterValue $driveUrl
    $frontSpreadsheetTitle = Escape-FrontMatterValue $SpreadsheetTitle
    $sourceLabel = if ($sourceType -eq "article") { "元記事" } elseif ($sourceType -eq "youtube") { "元動画" } else { "元素材" }
    $tag = if ($sourceType -eq "article") { "article" } elseif ($sourceType -eq "youtube") { "youtube, ai-agent" } else { "source" }
    $sourceDetails = if ($sourceType -eq "youtube") {
      @"
- URL: $url
- チャンネル: $channel
- テーマ: $theme
- 優先度: $priority
- 状態: $status
- Drive保存先: $driveUrl
- 管理表: $SpreadsheetTitle
"@
    } else {
      @"
- URL: $url
- テーマ: $theme
- 優先度: $priority
- 状態: $status
- Drive保存先: $driveUrl
- 管理表: $SpreadsheetTitle
"@
    }

    $content = @"
---
type: source
status: 未整理
date: $indexDate
synced_at: $Today
source_type: $sourceType
title: "$frontTitle"
url: "$frontUrl"
drive_url: "$frontDriveUrl"
spreadsheet_title: "$frontSpreadsheetTitle"
spreadsheet_id: "$SpreadsheetId"
tags: [raw, $tag]
---

# $title

## $sourceLabel

$sourceDetails

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

  return @{ Created = $created; Skipped = $skipped }
}

function Sync-DriveFiles {
  param(
    [object[]]$Files,
    [string]$OutputDirectory,
    [string]$Today,
    [switch]$DryRun
  )

  $created = 0
  $skipped = 0
  $candidates = @($Files | Where-Object {
    $_.mimeType -ne "application/vnd.google-apps.spreadsheet" -and
    $_.mimeType -ne "application/vnd.google-apps.folder"
  })
  $folders = @($Files | Where-Object { $_.mimeType -eq "application/vnd.google-apps.folder" })

  if ($folders.Count -gt 0) {
    Write-Host "Detected folders in Drive source folder: $($folders.Count). Folder entries are not indexed."
  }

  if ($candidates.Count -eq 0) {
    Write-Host "No non-spreadsheet Drive files to index."
    return @{ Created = 0; Skipped = 0 }
  }

  Write-Host "Checking non-spreadsheet Drive files: $($candidates.Count)."

  foreach ($file in $candidates) {
    $sourceType = Get-SourceTypeFromMimeType $file.mimeType $file.name
    $slug = ConvertTo-Slug $file.name
    $path = Join-Path $OutputDirectory "$Today-$sourceType-$slug.md"

    if ((Test-Path -LiteralPath $path) -or (Test-ExistingDriveFileId $OutputDirectory $file.id) -or (Test-ExistingSourceUrl $OutputDirectory $file.webViewLink)) {
      $skipped++
      continue
    }

    $frontTitle = Escape-FrontMatterValue $file.name
    $frontUrl = Escape-FrontMatterValue $file.webViewLink
    $frontMimeType = Escape-FrontMatterValue $file.mimeType
    $frontModifiedTime = Escape-FrontMatterValue $file.modifiedTime

    $content = @"
---
type: source
status: 未整理
date: $Today
source_type: $sourceType
title: "$frontTitle"
url: "$frontUrl"
drive_url: "$frontUrl"
drive_file_id: "$($file.id)"
mime_type: "$frontMimeType"
modified_time: "$frontModifiedTime"
tags: [raw, drive, $sourceType]
---

# $($file.name)

## Driveファイル

- URL: $($file.webViewLink)
- File ID: $($file.id)
- MIME type: $($file.mimeType)
- 更新日時: $($file.modifiedTime)

## 要点メモ



## 自分のプロジェクトに反映すること



## 次に整理するなら

-
"@

    if ($DryRun) {
      Write-Host "Would create Drive file index: $path"
    } else {
      Set-Content -LiteralPath $path -Value $content -Encoding UTF8
      Write-Host "Created Drive file index: $path"
    }

    $created++
  }

  return @{ Created = $created; Skipped = $skipped }
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
$today = (Get-Date).ToString("yyyy-MM-dd")
$driveFiles = @()
$spreadsheets = @()

if (-not $DisableSpreadsheetDiscovery) {
  $driveFiles = @(Get-DriveFilesInFolder $accessToken $DriveFolderId)
  Write-Host "Discovered Drive files: total=$($driveFiles.Count)."
  $spreadsheets = @(Get-SpreadsheetsInDriveFolder $driveFiles | ForEach-Object {
    [PSCustomObject]@{
      Id = $_.id
      Title = $_.name
      Url = $_.webViewLink
      MimeType = $_.mimeType
      ModifiedTime = $_.modifiedTime
    }
  })
  Write-Host "Discovered spreadsheets: $($spreadsheets.Count)."
}

if ($spreadsheets.Count -eq 0) {
  $spreadsheets = @([PSCustomObject]@{
    Id = $SpreadsheetId
    Title = "Configured spreadsheet"
    Url = $null
  })
}

$totalCreated = 0
$totalSkipped = 0

foreach ($spreadsheet in $spreadsheets) {
  Write-Host "Reading spreadsheet: $($spreadsheet.Title) ($($spreadsheet.Id))"
  $result = Sync-SpreadsheetRows `
    -AccessToken $accessToken `
    -SpreadsheetId $spreadsheet.Id `
    -SpreadsheetTitle $spreadsheet.Title `
    -Range $Range `
    -DriveFolderId $DriveFolderId `
    -OutputDirectory $resolvedOutputDir `
    -Today $today `
    -DryRun:$DryRun

  $totalCreated += $result.Created
  $totalSkipped += $result.Skipped
}

if (-not $DisableSpreadsheetDiscovery) {
  $driveResult = Sync-DriveFiles `
    -Files $driveFiles `
    -OutputDirectory $resolvedOutputDir `
    -Today $today `
    -DryRun:$DryRun

  $totalCreated += $driveResult.Created
  $totalSkipped += $driveResult.Skipped
}

Write-Host "Done. Spreadsheets: $($spreadsheets.Count), drive_files: $($driveFiles.Count), created: $totalCreated, skipped: $totalSkipped."
