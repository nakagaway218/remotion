#Requires -Version 7.0

param(
  [string]$DriveFolderId = "1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz",
  [string]$ToolSpreadsheetName = "ツール参考リスト",
  [string]$Range = "A1:Z1000",
  [string]$OutputDir = "reports/zip-inspections",
  [string]$TempRoot = "",
  [int]$HttpTimeoutSec = 60,
  [int]$MaxZipBytes = 104857600,
  [int]$MaxEntries = 1000,
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
      -Body $body `
      -TimeoutSec $HttpTimeoutSec

    return $response.access_token
  }

  throw "Set GOOGLE_ACCESS_TOKEN, or set GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, and GOOGLE_REFRESH_TOKEN."
}

function ConvertTo-Slug {
  param([string]$Text)

  $normalized = if ([string]::IsNullOrWhiteSpace($Text)) { "zip-source" } else { $Text.Trim().ToLowerInvariant() }
  $slug = $normalized -replace "[^\p{L}\p{Nd}]+", "-"
  $slug = $slug.Trim("-")

  if ([string]::IsNullOrWhiteSpace($slug)) {
    return "zip-source"
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

function Normalize-Header {
  param([string]$Header)

  return $Header.Trim().ToLowerInvariant() -replace "\s+", "_"
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

function Get-DriveFileIdFromUrl {
  param([string]$Url)

  if ([string]::IsNullOrWhiteSpace($Url)) {
    return ""
  }

  $patterns = @(
    "/file/d/([^/]+)",
    "/document/d/([^/]+)",
    "/spreadsheets/d/([^/]+)",
    "/presentation/d/([^/]+)",
    "[?&]id=([^&#]+)"
  )

  foreach ($pattern in $patterns) {
    $match = [regex]::Match($Url, $pattern)
    if ($match.Success) {
      return [System.Uri]::UnescapeDataString($match.Groups[1].Value)
    }
  }

  return ""
}

function Get-DriveFilesInFolder {
  param(
    [string]$AccessToken,
    [string]$FolderId
  )

  $query = "'$FolderId' in parents and trashed = false"
  $fields = "nextPageToken,files(id,name,webViewLink,mimeType,modifiedTime,size)"
  $pageToken = $null
  $files = @()

  do {
    $uri = "https://www.googleapis.com/drive/v3/files?q=$([uri]::EscapeDataString($query))&fields=$([uri]::EscapeDataString($fields))&pageSize=100"
    if ($pageToken) {
      $uri += "&pageToken=$([uri]::EscapeDataString($pageToken))"
    }

    $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
    if ($response.files) {
      $files += @($response.files)
    }
    $pageToken = $response.nextPageToken
  } while ($pageToken)

  return $files
}

function Get-DriveFileMetadata {
  param(
    [string]$AccessToken,
    [string]$FileId
  )

  $fields = "id,name,webViewLink,mimeType,modifiedTime,size"
  $uri = "https://www.googleapis.com/drive/v3/files/$FileId?fields=$([uri]::EscapeDataString($fields))"
  return Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
}

function Get-SheetValues {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId,
    [string]$SheetRange
  )

  $uri = "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId/values/$([uri]::EscapeDataString($SheetRange))"
  $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
  return @($response.values)
}

function Find-SpreadsheetByName {
  param(
    [object[]]$Files,
    [string]$Name
  )

  $matches = @($Files | Where-Object {
    $_.mimeType -eq "application/vnd.google-apps.spreadsheet" -and $_.name.Trim() -eq $Name
  })

  if ($matches.Count -eq 0) {
    return $null
  }

  return $matches[0]
}

function Test-ZipFile {
  param([object]$File)

  if ($File.mimeType -in @("application/zip", "application/x-zip-compressed", "application/x-zip")) {
    return $true
  }

  return ($File.name -match "\.zip$")
}

function Add-ZipCandidate {
  param(
    [hashtable]$CandidatesById,
    [object]$File,
    [string]$FoundFrom,
    [string]$RowTitle = "",
    [string]$RowUrl = ""
  )

  if (-not $File -or [string]::IsNullOrWhiteSpace($File.id)) {
    return
  }

  if (-not (Test-ZipFile $File)) {
    return
  }

  if (-not $CandidatesById.ContainsKey($File.id)) {
    $CandidatesById[$File.id] = [PSCustomObject]@{
      Id           = $File.id
      Name         = $File.name
      WebViewLink  = $File.webViewLink
      MimeType     = $File.mimeType
      ModifiedTime = $File.modifiedTime
      Size         = $File.size
      FoundFrom    = @()
      RowTitles    = @()
      RowUrls      = @()
    }
  }

  $candidate = $CandidatesById[$File.id]
  if ($candidate.FoundFrom -notcontains $FoundFrom) {
    $candidate.FoundFrom += $FoundFrom
  }
  if (-not [string]::IsNullOrWhiteSpace($RowTitle) -and $candidate.RowTitles -notcontains $RowTitle) {
    $candidate.RowTitles += $RowTitle
  }
  if (-not [string]::IsNullOrWhiteSpace($RowUrl) -and $candidate.RowUrls -notcontains $RowUrl) {
    $candidate.RowUrls += $RowUrl
  }
}

function Get-ZipEntryKind {
  param([string]$Name)

  $extension = [System.IO.Path]::GetExtension($Name).ToLowerInvariant()
  if ($extension -eq ".zip") {
    return "zip_candidate"
  }
  if ($extension -in @(".md", ".txt", ".csv", ".json", ".yaml", ".yml", ".html", ".htm")) {
    return "text_candidate"
  }
  if ($extension -in @(".pdf", ".docx", ".xlsx", ".pptx")) {
    return "document_candidate"
  }
  if ($extension -in @(".exe", ".dll", ".bat", ".cmd", ".ps1", ".sh", ".msi", ".jar")) {
    return "executable_or_script"
  }
  if ([string]::IsNullOrWhiteSpace($extension)) {
    return "unknown"
  }
  return "other"
}

function Write-ZipInspectionReport {
  param(
    [object]$Candidate,
    [object[]]$Entries,
    [string]$ReportPath,
    [string]$DownloadedTo
  )

  $frontTitle = Escape-FrontMatterValue $Candidate.Name
  $frontUrl = Escape-FrontMatterValue $Candidate.WebViewLink
  $frontMime = Escape-FrontMatterValue $Candidate.MimeType
  $foundFrom = ($Candidate.FoundFrom -join ", ")
  $rowTitles = if ($Candidate.RowTitles.Count -gt 0) { $Candidate.RowTitles -join "; " } else { "" }
  $rowUrls = if ($Candidate.RowUrls.Count -gt 0) { $Candidate.RowUrls -join "; " } else { "" }
  $totalBytes = ($Entries | Measure-Object -Property Length -Sum).Sum
  $textCount = @($Entries | Where-Object { $_.Kind -eq "text_candidate" }).Count
  $documentCount = @($Entries | Where-Object { $_.Kind -eq "document_candidate" }).Count
  $riskCount = @($Entries | Where-Object { $_.Kind -eq "executable_or_script" -or $_.HasTraversalRisk }).Count

  $lines = @()
  $lines += "---"
  $lines += "type: zip_inspection"
  $lines += "status: inspected"
  $lines += "date: $((Get-Date).ToString("yyyy-MM-dd"))"
  $lines += "title: `"$frontTitle`""
  $lines += "drive_file_id: `"$($Candidate.Id)`""
  $lines += "drive_url: `"$frontUrl`""
  $lines += "mime_type: `"$frontMime`""
  $lines += "modified_time: `"$($Candidate.ModifiedTime)`""
  $lines += "tags: [report, zip, drive]"
  $lines += "---"
  $lines += ""
  $lines += "# Zip inspection: $($Candidate.Name)"
  $lines += ""
  $lines += "## 元ファイル"
  $lines += ""
  $lines += "- Drive: $($Candidate.WebViewLink)"
  $lines += "- File ID: $($Candidate.Id)"
  $lines += "- MIME type: $($Candidate.MimeType)"
  $lines += "- 更新日時: $($Candidate.ModifiedTime)"
  $lines += "- Drive上のサイズ: $($Candidate.Size)"
  $lines += "- 検出元: $foundFrom"
  if ($rowTitles) {
    $lines += "- ツール参考リスト上のタイトル: $rowTitles"
  }
  if ($rowUrls) {
    $lines += "- ツール参考リスト上のURL: $rowUrls"
  }
  $lines += ""
  $lines += "## 検査方針"
  $lines += ""
  $lines += "- Zip本体と展開物はGitに保存しない。"
  $lines += "- このレポートにはファイル一覧、サイズ、読み取り候補、注意点だけを残す。"
  $lines += "- Zip内の実行ファイルやスクリプトは実行しない。"
  $lines += "- 一時ダウンロード先: $DownloadedTo"
  $lines += ""
  $lines += "## 概要"
  $lines += ""
  $lines += "- エントリ数: $($Entries.Count)"
  $lines += "- Zip内合計サイズ: $totalBytes bytes"
  $lines += "- テキスト候補: $textCount"
  $lines += "- 文書候補: $documentCount"
  $lines += "- 注意が必要な候補: $riskCount"
  $lines += ""
  $lines += "## 次に読む候補"
  $lines += ""

  $readCandidates = @($Entries | Where-Object { $_.Kind -in @("text_candidate", "document_candidate", "zip_candidate") } | Select-Object -First 30)
  if ($readCandidates.Count -eq 0) {
    $lines += "- すぐ読めそうなテキスト・文書候補は見つからなかった。"
  } else {
    foreach ($entry in $readCandidates) {
      $lines += "- ``$($entry.FullName)`` ($($entry.Kind), $($entry.Length) bytes)"
    }
  }

  $lines += ""
  $lines += "## 注意が必要なもの"
  $lines += ""
  $riskEntries = @($Entries | Where-Object { $_.Kind -eq "executable_or_script" -or $_.HasTraversalRisk } | Select-Object -First 30)
  if ($riskEntries.Count -eq 0) {
    $lines += "- 実行ファイル・スクリプト・パストラバーサル疑いは一覧上は見つからなかった。"
  } else {
    foreach ($entry in $riskEntries) {
      $reasons = @()
      if ($entry.Kind -eq "executable_or_script") { $reasons += "script_or_executable" }
      if ($entry.HasTraversalRisk) { $reasons += "path_traversal_risk" }
      $lines += "- ``$($entry.FullName)`` ($($reasons -join ", "), $($entry.Length) bytes)"
    }
  }

  $lines += ""
  $lines += "## 全ファイル一覧"
  $lines += ""
  $lines += "| 種別 | サイズ | パス |"
  $lines += "|---|---:|---|"
  foreach ($entry in $Entries) {
    $safeName = $entry.FullName -replace "\|", "\|"
    $lines += "| $($entry.Kind) | $($entry.Length) | ``$safeName`` |"
  }

  $parent = Split-Path -Parent $ReportPath
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  if ($DryRun) {
    Write-Host "[DryRun] Would write: $ReportPath"
    return
  }

  Set-Content -LiteralPath $ReportPath -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
}

function Inspect-ZipCandidate {
  param(
    [string]$AccessToken,
    [object]$Candidate,
    [string]$OutputDirectory,
    [string]$WorkingDirectory
  )

  $sizeValue = 0L
  if ([long]::TryParse([string]$Candidate.Size, [ref]$sizeValue) -and $sizeValue -gt $MaxZipBytes) {
    Write-Warning "Skipping large zip: $($Candidate.Name) ($sizeValue bytes)"
    return $null
  }

  $slug = ConvertTo-Slug $Candidate.Name
  $reportPath = Join-Path $OutputDirectory "$((Get-Date).ToString("yyyy-MM-dd"))-zip-$slug.md"
  $zipPath = Join-Path $WorkingDirectory "$($Candidate.Id).zip"

  if (-not $DryRun) {
    $downloadUri = "https://www.googleapis.com/drive/v3/files/$($Candidate.Id)?alt=media"
    Invoke-WebRequest -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $downloadUri -OutFile $zipPath -TimeoutSec $HttpTimeoutSec | Out-Null
  }

  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem

  $archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
  try {
    if ($archive.Entries.Count -gt $MaxEntries) {
      Write-Warning "Zip has too many entries. Reporting first $MaxEntries entries: $($Candidate.Name)"
    }

    $entries = @()
    foreach ($entry in ($archive.Entries | Select-Object -First $MaxEntries)) {
      $name = $entry.FullName
      $hasTraversalRisk = $name -match "(^|/|\\)\.\.($|/|\\)" -or [System.IO.Path]::IsPathRooted($name)
      $entries += [PSCustomObject]@{
        FullName         = $name
        Length           = $entry.Length
        CompressedLength = $entry.CompressedLength
        Kind             = Get-ZipEntryKind $name
        HasTraversalRisk = $hasTraversalRisk
      }
    }
  } finally {
    $archive.Dispose()
  }

  Write-ZipInspectionReport `
    -Candidate $Candidate `
    -Entries $entries `
    -ReportPath $reportPath `
    -DownloadedTo $zipPath

  return $reportPath
}

$accessToken = Get-AccessToken
$today = (Get-Date).ToString("yyyy-MM-dd")

if ([string]::IsNullOrWhiteSpace($TempRoot)) {
  $TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "obsidian-secondbrain-zip-inspections"
}

$workingDirectory = Join-Path $TempRoot $today
if (-not (Test-Path -LiteralPath $workingDirectory)) {
  New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null
}

$driveFiles = @(Get-DriveFilesInFolder $accessToken $DriveFolderId)
Write-Host "Discovered Drive files: total=$($driveFiles.Count)."

$candidatesById = @{}

foreach ($file in $driveFiles) {
  Add-ZipCandidate -CandidatesById $candidatesById -File $file -FoundFrom "drive-folder"
}

$toolSpreadsheet = Find-SpreadsheetByName -Files $driveFiles -Name $ToolSpreadsheetName
if ($toolSpreadsheet) {
  $rows = @(Get-SheetValues -AccessToken $accessToken -SpreadsheetId $toolSpreadsheet.id -SheetRange $Range)
  if ($rows.Count -gt 1) {
    $headers = @($rows[0])
    $headerMap = @{}
    for ($i = 0; $i -lt $headers.Count; $i++) {
      $normalized = Normalize-Header ([string]$headers[$i])
      if (-not [string]::IsNullOrWhiteSpace($normalized) -and -not $headerMap.ContainsKey($normalized)) {
        $headerMap[$normalized] = $i
      }
    }

    for ($rowNumber = 2; $rowNumber -le $rows.Count; $rowNumber++) {
      $row = @($rows[$rowNumber - 1])
      $title = Get-CellValue $row $headerMap @("title", "タイトル", "名前", "name", "動画名", "資料名")
      $urlValues = @(
        (Get-CellValue $row $headerMap @("url", "ｕｒｌ", "リンク", "link")),
        (Get-CellValue $row $headerMap @("drive_url", "drive", "google_drive")),
        (Get-CellValue $row $headerMap @("summary_url", "summary_link", "要約リンク", "文字起こし", "文字起こしurl"))
      ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

      foreach ($url in $urlValues) {
        $fileId = Get-DriveFileIdFromUrl $url
        if ([string]::IsNullOrWhiteSpace($fileId)) {
          continue
        }

        try {
          $metadata = Get-DriveFileMetadata -AccessToken $accessToken -FileId $fileId
          Add-ZipCandidate -CandidatesById $candidatesById -File $metadata -FoundFrom "tool-spreadsheet-row-$rowNumber" -RowTitle $title -RowUrl $url
        } catch {
          Write-Warning "Could not read Drive metadata for row $rowNumber URL '$url': $($_.Exception.Message)"
        }
      }
    }
  }
} else {
  Write-Warning "Tool spreadsheet '$ToolSpreadsheetName' was not found in Drive folder."
}

$candidates = @($candidatesById.Values)
if ($candidates.Count -eq 0) {
  Write-Host "No zip files found from Drive folder or '$ToolSpreadsheetName'."
  exit 0
}

Write-Host "Zip candidates: $($candidates.Count)."

$createdReports = @()
foreach ($candidate in $candidates) {
  $report = Inspect-ZipCandidate `
    -AccessToken $accessToken `
    -Candidate $candidate `
    -OutputDirectory $OutputDir `
    -WorkingDirectory $workingDirectory
  if ($report) {
    $createdReports += $report
    Write-Host "Wrote report: $report"
  }
}

Write-Host "Done. zip_reports=$($createdReports.Count)."
