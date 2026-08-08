$ErrorActionPreference = "Stop"

$ModelId = "openai/gpt-oss-20b"
$ContextLength = 32768
$ServerPort = 1234
$ServerUrl = "http://127.0.0.1:$ServerPort"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host $Message
}

function Find-Lms {
    $command = Get-Command "lms.exe" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $fallback = Join-Path $env:USERPROFILE ".lmstudio\bin\lms.exe"
    if (Test-Path -LiteralPath $fallback) {
        return $fallback
    }

    throw "lms.exe was not found. Open LM Studio once and make sure its CLI is installed."
}

function Invoke-Lms {
    param([string[]]$Arguments)

    $result = Invoke-LmsRaw $Arguments
    if ($result.ExitCode -ne 0) {
        $text = ($result.Output | Out-String).Trim()
        throw "lms $($Arguments -join ' ') failed with exit code $($result.ExitCode).`n$text"
    }
    return @($result.Output)
}

function Invoke-LmsRaw {
    param([string[]]$Arguments)

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $script:LmsPath
    $startInfo.Arguments = ($Arguments | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_ -replace '"', '\"') + '"'
        }
        else {
            $_
        }
    }) -join " "
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    $exitCode = -1

    try {
        [void]$process.Start()
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        $exitCode = $process.ExitCode
    }
    finally {
        if ($process) {
            $process.Dispose()
        }
    }

    $output = @()
    if (-not [string]::IsNullOrWhiteSpace($stdout)) {
        $output += $stdout -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }
    if (-not [string]::IsNullOrWhiteSpace($stderr)) {
        $output += $stderr -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = $output
    }
}

function Wait-LMStudioServer {
    $deadline = (Get-Date).AddSeconds(45)
    while ((Get-Date) -lt $deadline) {
        try {
            $null = Invoke-RestMethod -Uri "$ServerUrl/v1/models" -Method Get -TimeoutSec 3
            return
        }
        catch {
            Start-Sleep -Seconds 2
        }
    }

    throw "LM Studio server did not respond at $ServerUrl within 45 seconds."
}

function Get-LoadedModels {
    $lines = Invoke-Lms @("ps")
    $models = @()

    foreach ($line in $lines) {
        $trimmed = "$line".Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
        if ($trimmed -like "IDENTIFIER*") { continue }

        $columns = $trimmed -split "\s{2,}"
        if ($columns.Count -lt 5) { continue }

        $contextValue = 0
        [void][int]::TryParse($columns[4], [ref]$contextValue)

        $models += [pscustomobject]@{
            Identifier = $columns[0]
            Model = $columns[1]
            Context = $contextValue
            Raw = $trimmed
        }
    }

    return $models
}

$script:LmsPath = Find-Lms
Write-Step "[1/4] Using LM Studio CLI:"
Write-Host $script:LmsPath

Write-Step "[2/4] Checking LM Studio local server..."
$serverStatus = Invoke-LmsRaw @("server", "status")
$statusText = ($serverStatus.Output | Out-String).Trim()
Write-Host $statusText

$isServerRunning = ($statusText -match "(?i)\brunning\b") -and
    ($statusText -notmatch "(?i)not running")

if (-not $isServerRunning) {
    Write-Host "Starting LM Studio server on port $ServerPort..."
    Invoke-Lms @("server", "start", "--port", "$ServerPort") | ForEach-Object { Write-Host $_ }
}

Wait-LMStudioServer
Write-Host "LM Studio server is ready at $ServerUrl."

Write-Step "[3/4] Checking loaded model and context length..."
$loadedModels = @(Get-LoadedModels)
$targetRows = @($loadedModels | Where-Object { $_.Identifier -eq $ModelId -or $_.Model -eq $ModelId })
$readyTarget = $targetRows | Where-Object { $_.Context -eq $ContextLength } | Select-Object -First 1

if ($readyTarget) {
    Write-Host "$ModelId is already loaded with context $ContextLength."
}
else {
    if ($loadedModels.Count -gt 0) {
        Write-Host "Loaded model state is not the requested one. Unloading current in-memory model(s)..."
        foreach ($model in $loadedModels) {
            Write-Host " - $($model.Raw)"
        }
        Invoke-Lms @("unload", "--all") | ForEach-Object { Write-Host $_ }
    }

    Write-Host "Loading $ModelId with context $ContextLength..."
    Invoke-Lms @(
        "load",
        $ModelId,
        "--context-length",
        "$ContextLength",
        "--identifier",
        $ModelId,
        "--yes"
    ) | ForEach-Object { Write-Host $_ }

    $loadedModels = @(Get-LoadedModels)
    $readyTarget = $loadedModels |
        Where-Object { ($_.Identifier -eq $ModelId -or $_.Model -eq $ModelId) -and $_.Context -eq $ContextLength } |
        Select-Object -First 1

    if (-not $readyTarget) {
        $current = ($loadedModels | ForEach-Object { $_.Raw }) -join "`n"
        throw "The model did not appear as $ModelId with context $ContextLength after loading.`n$current"
    }
}

Write-Step "[4/4] Ready."
Write-Host "$ModelId is loaded with context $ContextLength."
