[CmdletBinding()]
param(
    [string]$DownloadsPath = (Join-Path $env:USERPROFILE 'Downloads'),
    [datetime]$Today = (Get-Date).Date,
    [switch]$InitializeExisting,
    [switch]$ConfirmPending,
    [switch]$AutomationCheck
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$statePath = Join-Path $scriptRoot '.schedule-pdf-state.json'
$notificationStatePath = Join-Path $scriptRoot '.schedule-pdf-notification-state.json'
$pendingPath = Join-Path $scriptRoot 'pending-schedule-pdfs.json'
$reportPath = Join-Path $scriptRoot 'Pending-Schedule-PDFs.txt'

function Get-ScheduleRange {
    param(
        [string]$FileName,
        [datetime]$ReferenceDate
    )

    $rangePattern = '[\[［](?<sm>\d{1,2})[./月](?<sd>\d{1,2})(?:日)?\s*[～~\-－ー]\s*(?:(?<em>\d{1,2})[./月])?(?<ed>\d{1,2})(?:日)?(?:分)?[\]］]'
    $weekPattern = '[\(（](?<sm>\d{1,2})[./月](?<sd>\d{1,2})(?:日)?週[\)）]'

    $rangeMatch = [regex]::Match($FileName, $rangePattern)
    if ($rangeMatch.Success) {
        $startMonth = [int]$rangeMatch.Groups['sm'].Value
        $startDay = [int]$rangeMatch.Groups['sd'].Value
        $endMonth = if ($rangeMatch.Groups['em'].Success) {
            [int]$rangeMatch.Groups['em'].Value
        } else {
            $startMonth
        }
        $endDay = [int]$rangeMatch.Groups['ed'].Value
    } else {
        $weekMatch = [regex]::Match($FileName, $weekPattern)
        if (-not $weekMatch.Success) {
            return $null
        }

        $startMonth = [int]$weekMatch.Groups['sm'].Value
        $startDay = [int]$weekMatch.Groups['sd'].Value
        $endMonth = $startMonth
        $endDay = $startDay
    }

    $startYear = $ReferenceDate.Year
    $startDate = Get-Date -Year $startYear -Month $startMonth -Day $startDay
    if ($startDate -lt $ReferenceDate.AddMonths(-6)) {
        $startYear++
        $startDate = Get-Date -Year $startYear -Month $startMonth -Day $startDay
    }

    if ($rangeMatch.Success) {
        $endYear = if ($endMonth -lt $startMonth) { $startYear + 1 } else { $startYear }
        $endDate = Get-Date -Year $endYear -Month $endMonth -Day $endDay
    } else {
        # Weekly shift files cover Monday through Saturday.
        $endDate = $startDate.AddDays(5)
    }

    [pscustomobject]@{
        Start = $startDate.Date
        End = $endDate.Date
    }
}

function Read-State {
    if (-not (Test-Path -LiteralPath $statePath)) {
        return [pscustomobject]@{
            version = 1
            confirmed = @()
        }
    }

    $raw = Get-Content -Raw -LiteralPath $statePath
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw "State file is empty: $statePath"
    }

    $state = $raw | ConvertFrom-Json
    if ($null -eq $state.confirmed) {
        $state | Add-Member -NotePropertyName confirmed -NotePropertyValue @()
    }
    return $state
}

function Save-State {
    param([object]$State)

    $normalized = [ordered]@{
        version = 1
        confirmed = @($State.confirmed)
    }
    $normalized | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statePath -Encoding UTF8
}

function Save-Pending {
    param([object[]]$Items)

    $payload = [ordered]@{
        generatedAt = (Get-Date).ToString('o')
        today = $Today.ToString('yyyy-MM-dd')
        downloadsPath = $DownloadsPath
        items = @($Items)
    }
    $payload | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $pendingPath -Encoding UTF8
}

function Write-Report {
    param(
        [object[]]$Items,
        [string[]]$UnparsedFiles = @(),
        [string]$Message = ''
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('未確認の未来スケジュールPDF')
    $lines.Add(('確認日: {0}' -f $Today.ToString('yyyy-MM-dd')))
    $lines.Add(('確認場所: {0}' -f $DownloadsPath))
    $lines.Add('')

    if ($Message) {
        $lines.Add($Message)
        $lines.Add('')
    }

    if (@($Items).Count -eq 0) {
        $lines.Add('現在、未確認の未来PDFはありません。')
    } else {
        $lines.Add(('未確認PDF: {0}件' -f @($Items).Count))
        $lines.Add('')
        $index = 1
        foreach ($item in $Items) {
            $lines.Add(('{0}. {1}' -f $index, $item.fileName))
            $lines.Add(('   期間: {0} ～ {1}' -f $item.rangeStart, $item.rangeEnd))
            $lines.Add(('   更新日時: {0}' -f $item.lastWriteTime))
            $lines.Add(('   保存場所: {0}' -f $item.fullPath))
            $lines.Add('')
            $index++
        }
        $lines.Add('Codexへの依頼文:')
        $lines.Add('「Pending-Schedule-PDFs.txt の未確認PDFを、現在時刻より未来の予定だけデスクトップ版Outlookの使用中PSTに反映してください。Outlook Web版と過去の予定は変更・削除しないでください」')
        $lines.Add('')
        $lines.Add('デスクトップ版Outlookの使用中PSTへの反映が完了するまでは、Mark-Pending-As-Confirmed.batを実行しないでください。')
    }

    if (@($UnparsedFiles).Count -gt 0) {
        $lines.Add('')
        $lines.Add('日付をファイル名から判定できなかったPDF:')
        foreach ($name in $UnparsedFiles) {
            $lines.Add(('  - {0}' -f $name))
        }
    }

    $lines | Set-Content -LiteralPath $reportPath -Encoding UTF8
}

if (-not (Test-Path -LiteralPath $DownloadsPath -PathType Container)) {
    throw "Downloads folder was not found: $DownloadsPath"
}

$state = Read-State

if ($ConfirmPending) {
    if (-not (Test-Path -LiteralPath $pendingPath)) {
        Write-Report -Items @() -Message '確認済みにする未確認一覧がありません。'
        exit 0
    }

    $pending = Get-Content -Raw -LiteralPath $pendingPath | ConvertFrom-Json
    $pendingItems = @($pending.items)
    $knownHashes = @{}
    foreach ($entry in @($state.confirmed)) {
        $knownHashes[[string]$entry.sha256] = $true
    }

    foreach ($item in $pendingItems) {
        if (-not $knownHashes.ContainsKey([string]$item.sha256)) {
            $state.confirmed += [pscustomobject]@{
                sha256 = [string]$item.sha256
                fileName = [string]$item.fileName
                rangeStart = [string]$item.rangeStart
                rangeEnd = [string]$item.rangeEnd
                confirmedAt = (Get-Date).ToString('o')
                reason = 'DesktopOutlookUpdated'
            }
            $knownHashes[[string]$item.sha256] = $true
        }
    }

    Save-State -State $state
    Save-Pending -Items @()
    Write-Report -Items @() -Message ('{0}件を確認済みとして記録しました。' -f $pendingItems.Count)
    exit 0
}

$confirmedHashes = @{}
foreach ($entry in @($state.confirmed)) {
    $confirmedHashes[[string]$entry.sha256] = $true
}

$futureFiles = [System.Collections.Generic.List[object]]::new()
$unparsedFiles = [System.Collections.Generic.List[string]]::new()

$scheduleFilePattern = '^(守山北校)?(?:改訂)?シフト(?:表)?(?:改訂)?[\[［(（]'
$pdfFiles = Get-ChildItem -LiteralPath $DownloadsPath -File -Filter '*.pdf' |
    Where-Object { $_.BaseName -match $scheduleFilePattern }

foreach ($file in $pdfFiles) {
    $range = Get-ScheduleRange -FileName $file.Name -ReferenceDate $Today
    if ($null -eq $range) {
        $unparsedFiles.Add($file.Name)
        continue
    }
    if ($range.End -lt $Today.Date) {
        continue
    }

    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    $futureFiles.Add([pscustomobject]@{
        fileName = $file.Name
        fullPath = $file.FullName
        rangeStart = $range.Start.ToString('yyyy-MM-dd')
        rangeEnd = $range.End.ToString('yyyy-MM-dd')
        lastWriteTime = $file.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
        size = $file.Length
        sha256 = $hash
    })
}

if ($InitializeExisting) {
    foreach ($item in $futureFiles) {
        if (-not $confirmedHashes.ContainsKey([string]$item.sha256)) {
            $state.confirmed += [pscustomobject]@{
                sha256 = [string]$item.sha256
                fileName = [string]$item.fileName
                rangeStart = [string]$item.rangeStart
                rangeEnd = [string]$item.rangeEnd
                confirmedAt = (Get-Date).ToString('o')
                reason = 'InitialBaseline'
            }
            $confirmedHashes[[string]$item.sha256] = $true
        }
    }
    Save-State -State $state
}

$pendingItems = @(
    $futureFiles |
        Where-Object { -not $confirmedHashes.ContainsKey([string]$_.sha256) } |
        Sort-Object rangeStart, lastWriteTime, fileName
)

Save-Pending -Items $pendingItems
$message = if ($InitializeExisting) {
    '現在保存されている未来PDFを、初期の確認済みデータとして登録しました。'
} else {
    ''
}
Write-Report -Items $pendingItems -UnparsedFiles @($unparsedFiles) -Message $message

if ($AutomationCheck) {
    $signature = (@($pendingItems.sha256) | Sort-Object) -join '|'
    $lastNotification = $null
    if (Test-Path -LiteralPath $notificationStatePath) {
        $notificationRaw = Get-Content -Raw -LiteralPath $notificationStatePath
        if (-not [string]::IsNullOrWhiteSpace($notificationRaw)) {
            $lastNotification = $notificationRaw | ConvertFrom-Json
        }
    }

    $shouldNotify = $false
    if ($pendingItems.Count -eq 0) {
        if (Test-Path -LiteralPath $notificationStatePath) {
            Remove-Item -LiteralPath $notificationStatePath -Force
        }
    } else {
        $lastDate = if ($lastNotification -and $lastNotification.notifiedAt) {
            ([datetime]$lastNotification.notifiedAt).Date
        } else {
            $null
        }
        if (
            $null -eq $lastNotification -or
            [string]$lastNotification.signature -ne $signature -or
            $lastDate -lt $Today.Date
        ) {
            $shouldNotify = $true
            [ordered]@{
                signature = $signature
                notifiedAt = (Get-Date).ToString('o')
            } | ConvertTo-Json | Set-Content -LiteralPath $notificationStatePath -Encoding UTF8
        }
    }

    [ordered]@{
        shouldNotify = $shouldNotify
        pendingCount = $pendingItems.Count
        files = @($pendingItems | ForEach-Object { $_.fileName })
        reportPath = $reportPath
    } | ConvertTo-Json -Depth 4 -Compress
    exit 0
}

Write-Host ('未確認の未来PDF: {0}件' -f $pendingItems.Count)
Write-Host ('一覧: {0}' -f $reportPath)
