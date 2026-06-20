#Requires -Version 7.0

param(
  [string]$DocumentId,
  [string]$DocumentUrl,
  [int]$MaxChars = 0,
  [int]$HttpTimeoutSec = 30
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

function Get-DocumentIdFromUrl {
  param([string]$Url)

  if ([string]::IsNullOrWhiteSpace($Url)) {
    return ""
  }

  $match = [regex]::Match($Url, "/document/d/([^/]+)")
  if ($match.Success) {
    return $match.Groups[1].Value
  }

  return ""
}

if ([string]::IsNullOrWhiteSpace($DocumentId)) {
  $DocumentId = Get-DocumentIdFromUrl $DocumentUrl
}

if ([string]::IsNullOrWhiteSpace($DocumentId)) {
  throw "Set -DocumentId or pass a Google Docs URL with -DocumentUrl."
}

$accessToken = Get-AccessToken
$uri = "https://www.googleapis.com/drive/v3/files/$DocumentId/export?mimeType=text/plain"
$text = Invoke-RestMethod -Headers @{ Authorization = "Bearer $accessToken" } -Uri $uri -TimeoutSec $HttpTimeoutSec

if ($MaxChars -gt 0 -and $text.Length -gt $MaxChars) {
  $text = $text.Substring(0, $MaxChars)
}

Write-Output $text
