#Requires -Version 7.0

param(
  [string]$SpreadsheetId = "1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8",
  [string]$DriveFolderId = "1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz",
  [string]$TokenPath = "..\secrets\google-oauth-token.json",
  [int]$HttpTimeoutSec = 30
)

$ErrorActionPreference = "Stop"

function Get-AccessTokenFromSavedToken {
  param([string]$TokenPath)

  $resolvedTokenPath = Resolve-Path -LiteralPath $TokenPath -ErrorAction SilentlyContinue
  if (-not $resolvedTokenPath) {
    throw "OAuth token not found: $TokenPath"
  }

  $token = Get-Content -LiteralPath $resolvedTokenPath.Path -Raw | ConvertFrom-Json
  Write-Host "Token file: $($resolvedTokenPath.Path)"
  Write-Host "Token created_at: $($token.created_at)"
  Write-Host "Token scope: $($token.scope)"

  $body = @{
    client_id     = $token.client_id
    client_secret = $token.client_secret
    refresh_token = $token.refresh_token
    grant_type    = "refresh_token"
  }

  $response = Invoke-RestMethod `
    -Method Post `
    -Uri "https://oauth2.googleapis.com/token" `
    -Body $body `
    -TimeoutSec $HttpTimeoutSec

  return $response.access_token
}

function Test-GoogleGet {
  param(
    [string]$Label,
    [string]$Uri,
    [string]$AccessToken
  )

  Write-Host ""
  Write-Host "== $Label =="
  try {
    $response = Invoke-RestMethod -Headers @{ Authorization = "Bearer $AccessToken" } -Uri $Uri -TimeoutSec $HttpTimeoutSec
    $response | ConvertTo-Json -Depth 8
  }
  catch {
    Write-Host "FAILED: $($_.Exception.Message)"
    if ($_.ErrorDetails.Message) {
      Write-Host $_.ErrorDetails.Message
    }
  }
}

$accessToken = Get-AccessTokenFromSavedToken -TokenPath $TokenPath

Test-GoogleGet `
  -Label "Drive user" `
  -AccessToken $accessToken `
  -Uri "https://www.googleapis.com/drive/v3/about?fields=user"

Test-GoogleGet `
  -Label "Drive folder by ID" `
  -AccessToken $accessToken `
  -Uri "https://www.googleapis.com/drive/v3/files/${DriveFolderId}?fields=id,name,mimeType,webViewLink"

$query = "'$DriveFolderId' in parents and mimeType = 'application/vnd.google-apps.spreadsheet' and trashed = false"
Test-GoogleGet `
  -Label "Spreadsheets in folder" `
  -AccessToken $accessToken `
  -Uri "https://www.googleapis.com/drive/v3/files?q=$([uri]::EscapeDataString($query))&fields=$([uri]::EscapeDataString('files(id,name,webViewLink)'))&pageSize=100"

Test-GoogleGet `
  -Label "Spreadsheet metadata by ID" `
  -AccessToken $accessToken `
  -Uri "https://sheets.googleapis.com/v4/spreadsheets/${SpreadsheetId}?fields=spreadsheetId,properties(title),sheets(properties(title,index))"
