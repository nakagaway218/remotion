#Requires -Version 7.0

param(
  [string]$SpreadsheetId = "1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8",
  [string]$SheetName = "",
  [string]$Range = "A1:Z1000",
  [string]$DriveFolderId = "1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz",
  [string]$TranscriptTextPath = "",
  [switch]$FromClipboard,
  [string]$VideoUrl = "",
  [string]$Title = "",
  [string]$DocTitle = "",
  [int]$RowNumber = 0,
  [string]$LinkHeader = "要約リンク",
  [switch]$CreateMissingLinkColumn,
  [switch]$NoSheetUpdate,
  [int]$HttpTimeoutSec = 30,
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

function Get-TranscriptText {
  if ($FromClipboard) {
    $text = Get-Clipboard -Raw
    if ([string]::IsNullOrWhiteSpace($text)) {
      throw "Clipboard is empty. Copy the transcript text first."
    }
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
    return $text
  }

  throw "Use -FromClipboard or set -TranscriptTextPath."
}

function Get-FirstSheetName {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId
  )

  $uri = "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId?fields=sheets(properties(title,index))"
  $metadata = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
  $first = @($metadata.sheets | Sort-Object { $_.properties.index } | Select-Object -First 1)

  if (-not $first) {
    throw "No sheets found in spreadsheet: $SpreadsheetId"
  }

  return [string]$first.properties.title
}

function Get-SheetValues {
  param(
    [string]$AccessToken,
    [string]$SpreadsheetId,
    [string]$SheetName,
    [string]$Range
  )

  $a1 = "$(Escape-SheetName $SheetName)!$Range"
  $uri = "https://sheets.googleapis.com/v4/spreadsheets/$SpreadsheetId/values/$([uri]::EscapeDataString($a1))"
  $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec
  return @($response.values)
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

  for ($i = 1; $i -lt $Rows.Count; $i++) {
    $row = @($Rows[$i])
    $rowUrl = Get-CellValue $row $HeaderMap @("url", "ｕｒｌ", "link", "リンク", "url_or_link")
    $rowTitle = Get-CellValue $row $HeaderMap @("title", "タイトル", "動画タイトル", "動画名")

    if (-not [string]::IsNullOrWhiteSpace($VideoUrl) -and $rowUrl.Trim() -eq $VideoUrl.Trim()) {
      return ($i + 1)
    }

    if (-not [string]::IsNullOrWhiteSpace($Title) -and $rowTitle.Trim() -eq $Title.Trim()) {
      return ($i + 1)
    }
  }

  throw "Target row not found. Set -VideoUrl, -Title, or explicit -RowNumber."
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
  $body = @{ values = @(@($Value)) } | ConvertTo-Json -Depth 4

  Invoke-RestMethod `
    -Method Put `
    -Headers @{ Authorization = "Bearer $AccessToken"; "Content-Type" = "application/json" } `
    -Uri $uri `
    -Body $body `
    -TimeoutSec $HttpTimeoutSec | Out-Null
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

$accessToken = Get-AccessToken
$text = Get-TranscriptText

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
$rowTitle = Get-CellValue $targetRow $headerMap @("title", "タイトル", "動画タイトル", "動画名")
$rowUrl = Get-CellValue $targetRow $headerMap @("url", "ｕｒｌ", "link", "リンク", "url_or_link")

if ([string]::IsNullOrWhiteSpace($Title)) {
  $Title = $rowTitle
}

$baseDocTitle = if (-not [string]::IsNullOrWhiteSpace($DocTitle)) { $DocTitle } else { $Title }
if ([string]::IsNullOrWhiteSpace($baseDocTitle)) {
  $baseDocTitle = "YouTube transcript"
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
  Write-Host "DryRun: transcript chars: $($text.Length)"
  if (-not $NoSheetUpdate) {
    Write-Host "DryRun: would update row $rowNumberToUpdate, column $(ConvertTo-ColumnName ($linkColumnIndex + 1)) in sheet '$SheetName'"
  }
  exit 0
}

$doc = New-GoogleDocFromPlainText -AccessToken $accessToken -DriveFolderId $DriveFolderId -Name $docName -Text $text
$docUrl = [string]$doc.webViewLink

if (-not $NoSheetUpdate) {
  $columnName = ConvertTo-ColumnName ($linkColumnIndex + 1)

  if ($linkColumnIndex -ge $headers.Count) {
    Invoke-SheetsValueUpdate -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -A1Cell "$columnName`1" -Value $LinkHeader
  }

  Invoke-SheetsValueUpdate -AccessToken $accessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName -A1Cell "$columnName$rowNumberToUpdate" -Value $docUrl
}

Write-Host "Created Google Doc: $docUrl"
if (-not [string]::IsNullOrWhiteSpace($rowUrl)) {
  Write-Host "Matched source URL: $rowUrl"
}
if (-not $NoSheetUpdate) {
  Write-Host "Updated sheet '$SheetName' row $rowNumberToUpdate with transcript Doc link."
}
