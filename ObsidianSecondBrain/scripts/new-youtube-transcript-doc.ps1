#Requires -Version 7.0

param(
  [string]$SpreadsheetId = "1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8",
  [string]$SpreadsheetTitle = "AIエージェント参考YouTubeリスト",
  [string]$SheetName = "",
  [string]$Range = "A1:Z1000",
  [string]$DriveFolderId = "1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz",
  [string]$TranscriptTextPath = "",
  [switch]$FromClipboard,
  [string]$ExistingDocUrl = "",
  [string]$VideoUrl = "",
  [string]$Title = "",
  [string]$DocTitle = "",
  [switch]$FillBlankMetadata,
  [switch]$FillBlankUrl,
  [int]$MinTranscriptChars = 200,
  [switch]$AllowShortTranscript,
  [int]$RowNumber = 0,
  [string]$LinkHeader = "要約リンク",
  [string]$TokenPath = "..\secrets\google-oauth-token.json",
  [switch]$CreateMissingLinkColumn,
  [switch]$NoSheetUpdate,
  [int]$HttpTimeoutSec = 30,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Initialize-GoogleOAuthEnvironment {
  if ($env:GOOGLE_ACCESS_TOKEN) {
    return
  }

  if ($env:GOOGLE_CLIENT_ID -and $env:GOOGLE_CLIENT_SECRET -and $env:GOOGLE_REFRESH_TOKEN) {
    return
  }

  if ([string]::IsNullOrWhiteSpace($TokenPath)) {
    return
  }

  $resolvedTokenPath = Resolve-Path -LiteralPath $TokenPath -ErrorAction SilentlyContinue
  if (-not $resolvedTokenPath) {
    return
  }

  $token = Get-Content -LiteralPath $resolvedTokenPath.Path -Raw | ConvertFrom-Json
  $scope = [string]$token.scope
  $requiredScopes = @(
    "https://www.googleapis.com/auth/drive.readonly",
    "https://www.googleapis.com/auth/drive.file",
    "https://www.googleapis.com/auth/spreadsheets"
  )

  $missingScopes = @($requiredScopes | Where-Object { $scope -notmatch [regex]::Escape($_) })
  if ($missingScopes.Count -gt 0) {
    throw "OAuth token scope is old or insufficient. Run scripts/get-google-refresh-token.ps1 again. Missing scopes: $($missingScopes -join ', ')"
  }

  $env:GOOGLE_CLIENT_ID = $token.client_id
  $env:GOOGLE_CLIENT_SECRET = $token.client_secret
  $env:GOOGLE_REFRESH_TOKEN = $token.refresh_token
}

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

function Get-ComparableUrl {
  param([string]$Value)

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return ""
  }

  $trimmed = $Value.Trim()
  $videoIdMatch = [regex]::Match($trimmed, "(?:youtube\.com/(?:watch\?.*?v=|shorts/)|youtu\.be/)([A-Za-z0-9_-]{11})")
  if ($videoIdMatch.Success) {
    return "youtube:$($videoIdMatch.Groups[1].Value)"
  }

  $withoutFragment = ($trimmed -split "#", 2)[0]
  return $withoutFragment.TrimEnd("/")
}

function Get-YouTubeOEmbedTitle {
  param([string]$Url)

  if ([string]::IsNullOrWhiteSpace($Url)) {
    return ""
  }

  if ((Get-ComparableUrl $Url) -notmatch '^youtube:') {
    return ""
  }

  $oEmbedUrl = "https://www.youtube.com/oembed?url=$([uri]::EscapeDataString($Url.Trim()))&format=json"
  try {
    $response = Invoke-RestMethod -Uri $oEmbedUrl -TimeoutSec $HttpTimeoutSec
    return [string]$response.title
  }
  catch {
    Write-Warning "Could not fetch YouTube title automatically: $($_.Exception.Message)"
    return ""
  }
}

function ConvertTo-ColumnName {
  param([int]$Index)

  if ($Index -lt 1) {
    throw "Column index must be 1 or greater."
  }

  $name = ""
  $value = $Index
  while ($value -gt 0) {
    $value--
    $name = [char](65 + ($value % 26)) + $name
    $value = [math]::Floor($value / 26)
  }

  return $name
}

function Normalize-Header {
  param([string]$Header)

  if ($null -eq $Header) {
    return ""
  }

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

function Get-SafeDocName {
  param(
    [string]$Value,
    [string]$Fallback = "YouTube transcript"
  )

  $name = if ([string]::IsNullOrWhiteSpace($Value)) { $Fallback } else { $Value.Trim() }
  $name = $name -replace '[\\/:*?"<>|]', ' '
  $name = $name -replace "\s+", " "
  $name = $name.Trim()

  if ($name.Length -gt 120) {
    return $name.Substring(0, 120).Trim()
  }

  return $name
}

function Escape-SheetName {
  param([string]$Value)

  return "'" + ($Value -replace "'", "''") + "'"
}

function Get-GoogleDriveFileIdFromUrl {
  param([string]$Url)

  if ([string]::IsNullOrWhiteSpace($Url)) {
    return ""
  }

  $patterns = @(
    '/d/([^/?#]+)',
    '[?&]id=([^&#]+)'
  )

  foreach ($pattern in $patterns) {
    $match = [regex]::Match($Url, $pattern)
    if ($match.Success) {
      return [uri]::UnescapeDataString($match.Groups[1].Value)
    }
  }

  return ""
}

function Rename-GoogleDriveFile {
  param(
    [string]$AccessToken,
    [string]$FileUrl,
    [string]$Name
  )

  if ([string]::IsNullOrWhiteSpace($FileUrl) -or [string]::IsNullOrWhiteSpace($Name)) {
    return
  }

  $fileId = Get-GoogleDriveFileIdFromUrl -Url $FileUrl
  if ([string]::IsNullOrWhiteSpace($fileId)) {
    Write-Warning "Could not parse Google Drive file ID from ExistingDocUrl; skipped renaming."
    return
  }

  $uri = "https://www.googleapis.com/drive/v3/files/$fileId?fields=id,name"
  $body = @{ name = $Name } | ConvertTo-Json -Depth 3

  try {
    Invoke-RestMethod `
      -Method Patch `
      -Headers @{ Authorization = "Bearer $AccessToken"; "Content-Type" = "application/json" } `
      -Uri $uri `
      -Body $body `
      -TimeoutSec $HttpTimeoutSec | Out-Null
    Write-Host "Renamed existing Google Doc to: $Name"
  }
  catch {
    Write-Warning "Could not rename existing Google Doc: $($_.Exception.Message)"
  }
}

function Get-TranscriptText {
  if ($FromClipboard) {
    $text = Get-Clipboard -Raw
    if ([string]::IsNullOrWhiteSpace($text)) {
      throw "Clipboard is empty. Copy the transcript text first."
    }
    Assert-TranscriptTextLooksSafe -Text $text -Source "clipboard" -MinChars $MinTranscriptChars -AllowShortTranscript:$AllowShortTranscript
    return $text
  }

  if (-not [string]::IsNullOrWhiteSpace($TranscriptTextPath)) {
    if (-not (Test-Path -LiteralPath $TranscriptTextPath)) {
      throw "TranscriptTextPath not found: $TranscriptTextPath"
    }
    $text = Get-Content -LiteralPath $TranscriptTextPath -Raw
    if ([string]::IsNullOrWhiteSpace($text)) {
      throw "Transcript text file is empty: $TranscriptTextPath"
    }
    Assert-TranscriptTextLooksSafe -Text $text -Source $TranscriptTextPath -MinChars $MinTranscriptChars -AllowShortTranscript:$AllowShortTranscript
    return $text
  }

  throw "Use -FromClipboard or set -TranscriptTextPath."
}

function Assert-TranscriptTextLooksSafe {
  param(
    [string]$Text,
    [string]$Source,
    [int]$MinChars = 200,
    [switch]$AllowShortTranscript
  )

  $trimmed = $Text.Trim()
  $commandPatterns = @(
    '(?im)^\s*cd\s+',
    '(?im)^\s*powershell\s+',
    '(?im)^\s*pwsh\s+',
    '(?im)^\s*\.\s*\\scripts\\',
    '(?im)new-youtube-transcript-doc',
    '(?im)get-google-refresh-token',
    '(?im)diagnose-google-source-access'
  )

  foreach ($pattern in $commandPatterns) {
    if ($trimmed -match $pattern) {
      throw "The $Source content looks like a command, not a YouTube Transcript. Copy the Transcript text again, then rerun this script."
    }
  }

  if (-not $AllowShortTranscript -and $trimmed.Length -lt $MinChars) {
    throw "The $Source content is too short ($($trimmed.Length) chars) to be treated as a YouTube Transcript. Copy the full Transcript text, then rerun this script."
  }
}

function Get-FirstSheetName {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId
  )

  $metadata = Get-SpreadsheetMetadata -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId
  $first = @($metadata.sheets | Sort-Object { $_.properties.index } | Select-Object -First 1)

  if (-not $first) {
    throw "No sheets found in spreadsheet: $SpreadsheetId"
  }

  return [string]$first.properties.title
}

function Get-SpreadsheetMetadata {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId
  )

  $uri = "https://sheets.googleapis.com/v4/spreadsheets/${SpreadsheetId}?fields=sheets(properties(title,index))"

  try {
    return Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
  }
  catch {
    throw "Failed to open spreadsheet metadata: spreadsheet=$SpreadsheetId. If this is a 404, the token cannot access that spreadsheet or the ID is different. Original error: $($_.Exception.Message)"
  }
}

function Find-SpreadsheetIdInDriveFolder {
  param(
    [string]$AccessToken,
    [string]$FolderId,
    [string]$Title
  )

  if ([string]::IsNullOrWhiteSpace($FolderId) -or [string]::IsNullOrWhiteSpace($Title)) {
    return ""
  }

  $query = "'$FolderId' in parents and mimeType = 'application/vnd.google-apps.spreadsheet' and trashed = false"
  $fields = "files(id,name,webViewLink)"
  $uri = "https://www.googleapis.com/drive/v3/files?q=$([uri]::EscapeDataString($query))&fields=$([uri]::EscapeDataString($fields))&pageSize=100"
  $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
  $match = @($response.files | Where-Object { $_.name -eq $Title } | Select-Object -First 1)

  if ($match) {
    return [string]$match[0].id
  }

  return ""
}

function Resolve-SpreadsheetId {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId,
    [string]$SpreadsheetTitle,
    [string]$DriveFolderId
  )

  try {
    Get-SpreadsheetMetadata -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId | Out-Null
    return $SpreadsheetId
  }
  catch {
    Write-Warning $_.Exception.Message
  }

  $discoveredId = Find-SpreadsheetIdInDriveFolder -AccessToken $AccessToken -FolderId $DriveFolderId -Title $SpreadsheetTitle
  if (-not [string]::IsNullOrWhiteSpace($discoveredId)) {
    Write-Host "Using discovered spreadsheet '$SpreadsheetTitle': $discoveredId"
    return $discoveredId
  }

  throw "Could not access spreadsheet '$SpreadsheetId' and could not find '$SpreadsheetTitle' in Drive folder '$DriveFolderId'. Re-authenticate, confirm the Google account, or pass -SpreadsheetId explicitly."
}

function Get-SheetValues {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId,
    [string]$SheetName,
    [string]$Range
  )

  $a1 = "$(Escape-SheetName $SheetName)!$Range"
  $uri = "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId/values:batchGet?ranges=$([uri]::EscapeDataString($a1))"

  try {
    $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
  }
  catch {
    throw "Failed to read sheet values: spreadsheet=$SpreadsheetId, sheet='$SheetName', range=$Range. Original error: $($_.Exception.Message)"
  }

  if ($response.valueRanges -and $response.valueRanges.Count -gt 0) {
    return @($response.valueRanges[0].values)
  }

  return @()
}

function Find-TargetRow {
  param(
    [object[]]$Rows,
    [hashtable]$HeaderMap,
    [string]$VideoUrl,
    [string]$Title,
    [int]$RowNumber
  )

  if ($RowNumber -gt 1) {
    return $RowNumber
  }

  $targetComparableUrl = Get-ComparableUrl $VideoUrl
  $seenUrls = @()

  for ($i = 1; $i -lt $Rows.Count; $i++) {
    $row = @($Rows[$i])
    $rowUrl = Get-CellValue $row $HeaderMap @("url", "ｕｒｌ", "URL", "ＵＲＬ", "youtube_url", "YouTube URL", "YouTube", "link", "リンク", "url_or_link")
    $rowTitle = Get-CellValue $row $HeaderMap @("title", "タイトル", "動画タイトル", "動画名", "name", "名称")

    if (-not [string]::IsNullOrWhiteSpace($rowUrl)) {
      $seenUrls += "row $($i + 1): $rowUrl"
    }

    if (-not [string]::IsNullOrWhiteSpace($VideoUrl) -and (Get-ComparableUrl $rowUrl) -eq $targetComparableUrl) {
      return ($i + 1)
    }

    if (-not [string]::IsNullOrWhiteSpace($Title) -and $rowTitle.Trim() -eq $Title.Trim()) {
      return ($i + 1)
    }
  }

  $sampleUrls = if ($seenUrls.Count -gt 0) { ($seenUrls | Select-Object -First 10) -join "; " } else { "(no URL-like values found in recognized URL columns)" }
  $knownHeaders = if ($HeaderMap.Keys.Count -gt 0) { ($HeaderMap.Keys | Sort-Object) -join ", " } else { "(no headers detected)" }

  throw "Target row not found for VideoUrl='$VideoUrl' normalized='$targetComparableUrl'. Headers=$knownHeaders. Candidate URLs=$sampleUrls. Add the YouTube URL to the sheet first, or rerun with -RowNumber for the target row."
}

function Invoke-SheetsValueUpdate {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId,
    [string]$SheetName,
    [string]$A1Cell,
    [string]$Value
  )

  $rangeName = "$(Escape-SheetName $SheetName)!$A1Cell"
  $uri = "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId/values/$([uri]::EscapeDataString($rangeName))?valueInputOption=USER_ENTERED"
  $body = @{ values = @(, @($Value)) } | ConvertTo-Json -Depth 4

  Invoke-RestMethod `
    -Method Put `
    -Headers @{ Authorization = "Bearer $AccessToken"; "Content-Type" = "application/json" } `
    -Uri $uri `
    -Body $body `
    -TimeoutSec $HttpTimeoutSec | Out-Null
}

function Get-FirstHeaderIndex {
  param(
    [hashtable]$HeaderMap,
    [string[]]$Names
  )

  foreach ($name in $Names) {
    $normalized = Normalize-Header $name
    if ($HeaderMap.ContainsKey($normalized)) {
      return [int]$HeaderMap[$normalized]
    }

    if ($HeaderMap.ContainsKey($name)) {
      return [int]$HeaderMap[$name]
    }
  }

  return -1
}

function Test-RowCellBlank {
  param(
    [object[]]$Row,
    [int]$Index
  )

  if ($Index -lt 0) {
    return $false
  }

  if ($Index -ge $Row.Count) {
    return $true
  }

  return [string]::IsNullOrWhiteSpace([string]$Row[$Index])
}

function New-GoogleDocFromPlainText {
  param(
    [string]$AccessToken,
    [string]$DriveFolderId,
    [string]$Name,
    [string]$Text
  )

  $metadata = @{
    name     = $Name
    mimeType = "application/vnd.google-apps.document"
    parents  = @($DriveFolderId)
  } | ConvertTo-Json -Compress

  $boundary = "codex-boundary-" + [guid]::NewGuid().ToString("N")
  $lf = "`r`n"
  $bodyText =
    "--$boundary$lf" +
    "Content-Type: application/json; charset=UTF-8$lf$lf" +
    $metadata + $lf +
    "--$boundary$lf" +
    "Content-Type: text/plain; charset=UTF-8$lf$lf" +
    $Text + $lf +
    "--$boundary--$lf"

  $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyText)
  $uri = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id,name,webViewLink"

  return Invoke-RestMethod `
    -Method Post `
    -Headers @{
      Authorization  = "Bearer $AccessToken"
      "Content-Type" = "multipart/related; boundary=$boundary"
    } `
    -Uri $uri `
    -Body $bodyBytes `
    -TimeoutSec $HttpTimeoutSec
}

Initialize-GoogleOAuthEnvironment
$accessToken = Get-AccessToken
if ([string]::IsNullOrWhiteSpace($ExistingDocUrl)) {
  $text = Get-TranscriptText
}
else {
  $text = ""
}
$SpreadsheetId = Resolve-SpreadsheetId -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SpreadsheetTitle $SpreadsheetTitle -DriveFolderId $DriveFolderId

if ([string]::IsNullOrWhiteSpace($SheetName)) {
  $SheetName = Get-FirstSheetName -AccessToken $accessToken -SpreadsheetId $SpreadsheetId
}

$rows = Get-SheetValues -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -Range $Range
if ($rows.Count -lt 1) {
  throw "No rows found in spreadsheet range: $SheetName!$Range"
}

$headers = @($rows[0])
$headerMap = @{}
for ($i = 0; $i -lt $headers.Count; $i++) {
  $normalized = Normalize-Header ([string]$headers[$i])
  if (-not [string]::IsNullOrWhiteSpace($normalized) -and -not $headerMap.ContainsKey($normalized)) {
    $headerMap[$normalized] = $i
  }
}

$rowNumberToUpdate = Find-TargetRow -Rows $rows -HeaderMap $headerMap -VideoUrl $VideoUrl -Title $Title -RowNumber $RowNumber
$targetRow = @($rows[$rowNumberToUpdate - 1])
$rowTitle = Get-CellValue $targetRow $headerMap @("title", "タイトル", "動画タイトル", "動画名", "name", "名称")
$rowUrl = Get-CellValue $targetRow $headerMap @("url", "ｕｒｌ", "URL", "ＵＲＬ", "youtube_url", "YouTube URL", "YouTube", "link", "リンク", "url_or_link")

if ([string]::IsNullOrWhiteSpace($Title)) {
  $Title = $rowTitle
}

if ([string]::IsNullOrWhiteSpace($VideoUrl)) {
  $VideoUrl = $rowUrl
}

if ([string]::IsNullOrWhiteSpace($Title) -and [string]::IsNullOrWhiteSpace($DocTitle)) {
  $autoTitle = Get-YouTubeOEmbedTitle -Url $VideoUrl
  if (-not [string]::IsNullOrWhiteSpace($autoTitle)) {
    $Title = $autoTitle
    $DocTitle = $autoTitle
    Write-Host "Fetched YouTube title: $autoTitle"
  }
}

$baseDocTitle = if (-not [string]::IsNullOrWhiteSpace($DocTitle)) { $DocTitle } else { $Title }
if ([string]::IsNullOrWhiteSpace($baseDocTitle)) {
  $baseDocTitle = "YouTube transcript"
}

if ([string]::IsNullOrWhiteSpace($Title) -and -not [string]::IsNullOrWhiteSpace($DocTitle)) {
  $Title = $DocTitle
}

$docName = "$(Get-SafeDocName $baseDocTitle) 文字起こし"

$linkHeaderKeys = @(
  Normalize-Header $LinkHeader
  "transcript_url"
  "transcript"
  "文字起こしurl"
  "文字起こし"
  "要約リンク"
  "summary_url"
  "summary_link"
)

$linkColumnIndex = -1
foreach ($key in $linkHeaderKeys) {
  if ($headerMap.ContainsKey($key)) {
    $linkColumnIndex = [int]$headerMap[$key]
    break
  }
}

if ($linkColumnIndex -lt 0 -and -not $NoSheetUpdate) {
  if (-not $CreateMissingLinkColumn) {
    throw "Link column not found. Add '$LinkHeader' header or rerun with -CreateMissingLinkColumn."
  }

  $linkColumnIndex = $headers.Count
}

if ($DryRun) {
  Write-Host "DryRun: would create Google Doc in folder $DriveFolderId"
  Write-Host "DryRun: doc name: $docName"
  if ([string]::IsNullOrWhiteSpace($ExistingDocUrl)) {
    Write-Host "DryRun: transcript chars: $($text.Length)"
  }
  else {
    Write-Host "DryRun: would reuse existing Google Doc: $ExistingDocUrl"
  }
  if (-not $NoSheetUpdate) {
    Write-Host "DryRun: would update row $rowNumberToUpdate, column $(ConvertTo-ColumnName ($linkColumnIndex + 1)) in sheet '$SheetName'"
  }
  exit 0
}

if ([string]::IsNullOrWhiteSpace($ExistingDocUrl)) {
  $doc = New-GoogleDocFromPlainText -AccessToken $accessToken -DriveFolderId $DriveFolderId -Name $docName -Text $text
  $docUrl = [string]$doc.webViewLink
}
else {
  $docUrl = $ExistingDocUrl
  Rename-GoogleDriveFile -AccessToken $accessToken -FileUrl $ExistingDocUrl -Name $docName
}

if (-not $NoSheetUpdate) {
  $columnName = ConvertTo-ColumnName ($linkColumnIndex + 1)

  if ($linkColumnIndex -ge $headers.Count) {
    Invoke-SheetsValueUpdate -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -A1Cell "${columnName}1" -Value $LinkHeader
  }

  Invoke-SheetsValueUpdate -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -A1Cell "${columnName}${rowNumberToUpdate}" -Value $docUrl

  if ($FillBlankMetadata) {
    $dateColumnIndex = Get-FirstHeaderIndex $headerMap @("date", "追加日", "日付", "登録日", "作成日")
    if (Test-RowCellBlank -Row $targetRow -Index $dateColumnIndex) {
      $dateColumnName = ConvertTo-ColumnName ($dateColumnIndex + 1)
      Invoke-SheetsValueUpdate -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -A1Cell "${dateColumnName}${rowNumberToUpdate}" -Value (Get-Date -Format "yyyy-MM-dd")
      Write-Host "Filled date column '$dateColumnName' on row $rowNumberToUpdate."
    }

    $titleColumnIndex = Get-FirstHeaderIndex $headerMap @("title", "タイトル", "動画タイトル", "動画名", "name", "名称")
    if ((Test-RowCellBlank -Row $targetRow -Index $titleColumnIndex) -and -not [string]::IsNullOrWhiteSpace($Title)) {
      $titleColumnName = ConvertTo-ColumnName ($titleColumnIndex + 1)
      Invoke-SheetsValueUpdate -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -A1Cell "${titleColumnName}${rowNumberToUpdate}" -Value $Title
      Write-Host "Filled title column '$titleColumnName' on row $rowNumberToUpdate."
    }

    if ($FillBlankUrl) {
      $urlColumnIndex = Get-FirstHeaderIndex $headerMap @("url", "ｕｒｌ", "URL", "ＵＲＬ", "youtube_url", "YouTube URL", "YouTube", "link", "リンク", "url_or_link")
      if ((Test-RowCellBlank -Row $targetRow -Index $urlColumnIndex) -and -not [string]::IsNullOrWhiteSpace($VideoUrl)) {
        $urlColumnName = ConvertTo-ColumnName ($urlColumnIndex + 1)
        Invoke-SheetsValueUpdate -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -A1Cell "${urlColumnName}${rowNumberToUpdate}" -Value $VideoUrl
        Write-Host "Filled URL column '$urlColumnName' on row $rowNumberToUpdate."
      }
    }
  }
}

if ([string]::IsNullOrWhiteSpace($ExistingDocUrl)) {
  Write-Host "Created Google Doc: $docUrl"
}
else {
  Write-Host "Reused Google Doc: $docUrl"
}
if (-not [string]::IsNullOrWhiteSpace($rowUrl)) {
  Write-Host "Matched source URL: $rowUrl"
}
if (-not $NoSheetUpdate) {
  Write-Host "Updated sheet '$SheetName' row $rowNumberToUpdate with transcript Doc link."
}
