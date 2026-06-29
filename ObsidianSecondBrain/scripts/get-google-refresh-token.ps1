param(
  [string]$ClientSecretPath,
  [string]$TokenOutputPath,
  [int]$Port = 53682
)

$ErrorActionPreference = "Stop"

function Resolve-DefaultClientSecretPath {
  $root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")
  $secretsDir = Join-Path $root "secrets"
  $files = Get-ChildItem -LiteralPath $secretsDir -Filter "client_secret_*.json" -File | Sort-Object LastWriteTime -Descending

  if ($files.Count -eq 0) {
    throw "No client_secret_*.json file found in $secretsDir."
  }

  return $files[0].FullName
}

function Get-OAuthClient {
  param([string]$Path)

  $json = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json

  if ($json.installed) {
    return $json.installed
  }

  if ($json.web) {
    return $json.web
  }

  throw "Unsupported OAuth client JSON. Expected 'installed' or 'web' client."
}

if ([string]::IsNullOrWhiteSpace($ClientSecretPath)) {
  $ClientSecretPath = Resolve-DefaultClientSecretPath
}

if ([string]::IsNullOrWhiteSpace($TokenOutputPath)) {
  $root = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")
  $TokenOutputPath = Join-Path $root "secrets\google-oauth-token.json"
}

$client = Get-OAuthClient -Path $ClientSecretPath
$redirectUri = "http://127.0.0.1:$Port/"
$scopes = @(
  "https://www.googleapis.com/auth/drive.readonly",
  "https://www.googleapis.com/auth/drive.file",
  "https://www.googleapis.com/auth/spreadsheets"
) -join " "

$authParams = @{
  client_id     = $client.client_id
  redirect_uri  = $redirectUri
  response_type = "code"
  scope         = $scopes
  access_type   = "offline"
  prompt        = "consent"
}

$authQuery = ($authParams.GetEnumerator() | ForEach-Object {
  "$([uri]::EscapeDataString($_.Key))=$([uri]::EscapeDataString([string]$_.Value))"
}) -join "&"
$authUrl = "https://accounts.google.com/o/oauth2/v2/auth?$authQuery"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse("127.0.0.1"), $Port)

try {
  $listener.Start()

  Write-Host "Opening browser for Google OAuth consent..."
  Write-Host "If the browser does not open, paste this URL manually:"
  Write-Host $authUrl

  Start-Process $authUrl

  $clientConnection = $listener.AcceptTcpClient()
  $stream = $clientConnection.GetStream()
  $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8)
  $requestLine = $reader.ReadLine()

  while ($reader.ReadLine()) {
    # Drain request headers.
  }

  if ([string]::IsNullOrWhiteSpace($requestLine)) {
    throw "OAuth redirect request was empty."
  }

  $pathAndQuery = ($requestLine -split " ")[1]
  $query = ([uri]"http://127.0.0.1$pathAndQuery").Query.TrimStart("?")
  $queryValues = [System.Web.HttpUtility]::ParseQueryString($query)

  $code = $queryValues["code"]
  $errorMessage = $queryValues["error"]

  $html = "<html><body><h1>Google OAuth finished</h1><p>You can close this tab and return to Codex.</p></body></html>"
  $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
  $header = "HTTP/1.1 200 OK`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($buffer.Length)`r`nConnection: close`r`n`r`n"
  $headerBuffer = [System.Text.Encoding]::ASCII.GetBytes($header)
  $stream.Write($headerBuffer, 0, $headerBuffer.Length)
  $stream.Write($buffer, 0, $buffer.Length)
  $stream.Close()
  $clientConnection.Close()

  if ($errorMessage) {
    throw "OAuth failed: $errorMessage"
  }

  if ([string]::IsNullOrWhiteSpace($code)) {
    throw "OAuth authorization code was not returned."
  }

  $tokenBody = @{
    client_id     = $client.client_id
    client_secret = $client.client_secret
    code          = $code
    redirect_uri  = $redirectUri
    grant_type    = "authorization_code"
  }

  $token = Invoke-RestMethod `
    -Method Post `
    -Uri "https://oauth2.googleapis.com/token" `
    -Body $tokenBody

  $output = [ordered]@{
    client_id     = $client.client_id
    client_secret = $client.client_secret
    refresh_token = $token.refresh_token
    scope         = $token.scope
    token_type    = $token.token_type
    created_at    = (Get-Date).ToString("o")
  }

  $outputDir = Split-Path -Parent $TokenOutputPath
  if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
  }

  $output | ConvertTo-Json | Set-Content -LiteralPath $TokenOutputPath -Encoding UTF8

  Write-Host "Saved OAuth token file to: $TokenOutputPath"
  Write-Host "Do not commit this file."
} finally {
  $listener.Stop()
}
