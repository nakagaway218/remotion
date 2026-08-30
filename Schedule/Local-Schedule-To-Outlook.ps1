[CmdletBinding()]
param(
    [string[]]$PdfPath,
    [switch]$AnalyzeOnly,
    [string[]]$TargetSlot,
    [switch]$ApplyDirectly,
    [string]$InstructorNameForTest
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$privateRoot = Join-Path $scriptRoot 'private'
$configPath = Join-Path $privateRoot 'local-schedule-config.json'
$logPath = Join-Path $privateRoot 'local-schedule-tool.log'
$pendingPath = Join-Path $scriptRoot 'pending-schedule-pdfs.json'
$scannerPath = Join-Path $scriptRoot 'Check-New-Schedule-PDFs.ps1'
$ollamaUri = 'http://127.0.0.1:11434/api/chat'
$ollamaModel = 'qwen2.5vl:7b'

New-Item -ItemType Directory -Force -Path $privateRoot | Out-Null

function Write-LocalLog {
    param([string]$Message)

    ('{0} {1}' -f (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'), $Message) |
        Add-Content -LiteralPath $logPath -Encoding UTF8
}

function Get-Sha256Hex {
    param([string]$Path)

    $stream = [IO.File]::OpenRead($Path)
    try {
        $sha256 = [Security.Cryptography.SHA256]::Create()
        try {
            ([BitConverter]::ToString($sha256.ComputeHash($stream))).Replace('-', '')
        } finally {
            $sha256.Dispose()
        }
    } finally {
        $stream.Dispose()
    }
}

function Show-Message {
    param(
        [string]$Text,
        [string]$Title = 'ローカル予定表ツール',
        [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::Information
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Text,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $Icon
    ) | Out-Null
}

function Get-Config {
    if (-not (Test-Path -LiteralPath $configPath)) {
        return [pscustomobject]@{
            instructorName = ''
            calendarEntryId = ''
            pstPath = ''
        }
    }

    $config = Get-Content -Raw -LiteralPath $configPath -Encoding UTF8 | ConvertFrom-Json
    if ($null -eq $config.PSObject.Properties['pstPath']) {
        $config | Add-Member -NotePropertyName pstPath -NotePropertyValue ''
    }
    return $config
}

function Save-Config {
    param([object]$Config)

    $Config | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $configPath -Encoding UTF8
}

function Get-InstructorName {
    param([object]$Config)

    if (-not [string]::IsNullOrWhiteSpace($InstructorNameForTest)) {
        return $InstructorNameForTest.Trim()
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$Config.instructorName)) {
        return ([string]$Config.instructorName).Trim()
    }

    Add-Type -AssemblyName Microsoft.VisualBasic
    $name = [Microsoft.VisualBasic.Interaction]::InputBox(
        "シフトPDFに記載されている担当者名を入力してください。`r`nこの名前はPC内の非公開フォルダーだけに保存されます。",
        '初回設定',
        ''
    ).Trim()

    if ([string]::IsNullOrWhiteSpace($name)) {
        throw '担当者名が入力されなかったため中止しました。'
    }

    $Config.instructorName = $name
    Save-Config -Config $Config
    return $name
}

function Find-Executable {
    param(
        [string]$Name,
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "$Name が見つかりません。"
}

function Find-OptionalExecutable {
    param(
        [string]$Name,
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }
    return $null
}

function Get-ScheduleRange {
    param(
        [string]$FileName,
        [datetime]$ReferenceDate = (Get-Date).Date
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
        $endDate = $startDate.AddDays(5)
    }

    [pscustomobject]@{
        Start = $startDate.Date
        End = $endDate.Date
    }
}

function Get-InputPdfs {
    $explicitPaths = @($PdfPath | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    if ($explicitPaths.Count -gt 0) {
        return @($explicitPaths | ForEach-Object { (Resolve-Path -LiteralPath $_).Path })
    }

    if (-not (Test-Path -LiteralPath $scannerPath)) {
        throw '新着シフトPDFの確認プログラムが見つかりません。'
    }

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scannerPath -AutomationCheck | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw '新着シフトPDFの確認に失敗しました。'
    }

    if (-not (Test-Path -LiteralPath $pendingPath)) {
        return @()
    }

    $pending = Get-Content -Raw -LiteralPath $pendingPath -Encoding UTF8 | ConvertFrom-Json
    @($pending.items | ForEach-Object { [string]$_.fullPath } | Where-Object { Test-Path -LiteralPath $_ })
}

function Select-LatestSchedulePdfs {
    param([string[]]$Paths)

    $candidates = foreach ($path in $Paths) {
        $file = Get-Item -LiteralPath $path
        $range = Get-ScheduleRange -FileName $file.Name
        if (-not $range) {
            continue
        }
        $school = if ($file.BaseName -like '守山北*') { '守山北校' } else { '水口校' }
        [pscustomobject]@{
            Path = $file.FullName
            Key = '{0}|{1}|{2}' -f $school, $range.Start.ToString('yyyy-MM-dd'), $range.End.ToString('yyyy-MM-dd')
            Modified = $file.LastWriteTime
        }
    }

    @($candidates |
        Group-Object Key |
        ForEach-Object { $_.Group | Sort-Object Modified -Descending | Select-Object -First 1 } |
        ForEach-Object { $_.Path })
}

function Invoke-LocalModel {
    param(
        [string]$ImagePath,
        [string]$Prompt,
        [string]$ResultPath
    )

    $image = [Convert]::ToBase64String([IO.File]::ReadAllBytes($ImagePath))
    $payload = @{
        model = $ollamaModel
        stream = $false
        format = 'json'
        messages = @(
            @{
                role = 'user'
                content = $Prompt
                images = @($image)
            }
        )
        options = @{
            temperature = 0
            num_ctx = 16384
        }
    }

    $json = $payload | ConvertTo-Json -Depth 8 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $response = Invoke-RestMethod -Method Post -Uri $ollamaUri -ContentType 'application/json; charset=utf-8' -Body $bytes -TimeoutSec 600
    $response.message.content | Set-Content -LiteralPath $ResultPath -Encoding UTF8
    $response.message.content | ConvertFrom-Json
}

function Ensure-LocalModel {
    $tagsUri = 'http://127.0.0.1:11434/api/tags'
    $tags = $null
    try {
        $tags = Invoke-RestMethod -Method Get -Uri $tagsUri -TimeoutSec 3
    } catch {
        $ollama = Find-Executable -Name 'ollama.exe' -Candidates @(
            (Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama.exe')
        )
        Start-Process -FilePath $ollama -ArgumentList 'serve' -WindowStyle Hidden
        for ($i = 0; $i -lt 20; $i++) {
            Start-Sleep -Seconds 1
            try {
                $tags = Invoke-RestMethod -Method Get -Uri $tagsUri -TimeoutSec 3
                break
            } catch {
                # Wait for the local-only service to finish starting.
            }
        }
    }
    if (-not $tags) {
        throw '端末内AIを起動できませんでした。Ollamaを起動して、もう一度お試しください。'
    }
    if (-not @($tags.models | Where-Object { $_.name -eq $ollamaModel })) {
        throw "端末内AIモデル $ollamaModel が見つかりません。"
    }
}

function Get-LocalOcrData {
    param(
        [string]$ImagePath,
        [string]$Tesseract,
        [string]$TessdataPath,
        [string]$OutputBase,
        [string]$InstructorName
    )

    $texts = @()
    $points = @()
    $tokens = @()
    foreach ($psm in @(4, 11, 12)) {
        $base = "$OutputBase-psm$psm"
        $previousErrorPreference = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        & $Tesseract $ImagePath $base --tessdata-dir $TessdataPath -l 'jpn' --psm $psm 2>$null
        $tesseractExitCode = $LASTEXITCODE
        $ErrorActionPreference = $previousErrorPreference
        if ($tesseractExitCode -ne 0) {
            throw "日本語OCRに失敗しました (PSM $psm)。"
        }
        $textPath = "$base.txt"
        if (Test-Path -LiteralPath $textPath) {
            $texts += [IO.File]::ReadAllText($textPath, [Text.Encoding]::UTF8)
        }

        $tsvBase = "$OutputBase-psm$psm-coordinates"
        $previousErrorPreference = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        & $Tesseract $ImagePath $tsvBase --tessdata-dir $TessdataPath -l 'jpn' --psm $psm -c tessedit_create_tsv=1 2>$null
        $tesseractExitCode = $LASTEXITCODE
        $ErrorActionPreference = $previousErrorPreference
        if ($tesseractExitCode -ne 0) {
            throw "日本語OCRの座標取得に失敗しました (PSM $psm)。"
        }

        $tsvPath = "$tsvBase.tsv"
        if (Test-Path -LiteralPath $tsvPath) {
            foreach ($row in (Import-Csv -LiteralPath $tsvPath -Delimiter "`t")) {
                if ($row.level -ne '5' -or [string]::IsNullOrWhiteSpace([string]$row.text)) {
                    continue
                }
                $normalized = [regex]::Replace([string]$row.text, '\s', '')
                $tokens += [pscustomobject]@{
                    Text = $normalized
                    X = [int]$row.left
                    Y = [int]$row.top
                }
                if ($normalized.Contains($InstructorName)) {
                    $points += [pscustomobject]@{
                        X = [int]$row.left
                        Y = [int]$row.top
                        Width = [int]$row.width
                        Height = [int]$row.height
                    }
                }
            }
        }
    }

    $uniquePoints = @()
    foreach ($point in ($points | Sort-Object X, Y)) {
        $nearby = $uniquePoints | Where-Object {
            [Math]::Abs($_.X - $point.X) -lt 25 -and [Math]::Abs($_.Y - $point.Y) -lt 25
        }
        if (-not $nearby) {
            $uniquePoints += $point
        }
    }

    [pscustomobject]@{
        Text = ($texts -join "`r`n---`r`n")
        Coordinates = @($uniquePoints)
        Tokens = @($tokens)
    }
}

function Get-PageLayout {
    param(
        [string]$ImagePath,
        [object[]]$Tokens,
        [object[]]$Points,
        [object]$Range
    )

    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Bitmap]::new($ImagePath)
    try {
        $imageHeight = $image.Height
    } finally {
        $image.Dispose()
    }

    $dateColumns = @()
    for ($date = $Range.Start.Date; $date -le $Range.End.Date; $date = $date.AddDays(1)) {
        $month = [string]$date.Month
        $day = [string]$date.Day
        $pairs = foreach ($monthToken in @($Tokens | Where-Object { $_.Text -eq $month })) {
            foreach ($dayToken in @($Tokens | Where-Object { $_.Text -eq $day })) {
                $distance = [int]$dayToken.X - [int]$monthToken.X
                if ($distance -ge 15 -and $distance -le 120 -and [Math]::Abs([int]$dayToken.Y - [int]$monthToken.Y) -le 25) {
                    [pscustomobject]@{
                        X = ([int]$monthToken.X + [int]$dayToken.X) / 2.0
                        Y = ([int]$monthToken.Y + [int]$dayToken.Y) / 2.0
                        Distance = $distance
                    }
                }
            }
        }
        $pair = $pairs | Sort-Object { [Math]::Abs($_.Distance - 38) }, Y | Select-Object -First 1
        if ($pair) {
            $dateColumns += [pscustomobject]@{
                Date = $date.Date
                X = $pair.X
                Y = $pair.Y
            }
        }
    }
    if ($dateColumns.Count -eq 0) {
        throw 'PDF上部の日付を読み取れませんでした。'
    }

    $headerY = [double](($dateColumns | Measure-Object Y -Average).Average)
    $approximatePeriodHeight = ($imageHeight - ($headerY + 40) - 60) / 4.0
    $heightCandidates = @()
    foreach ($group in ($Points | Group-Object X)) {
        $ys = @($group.Group.Y | Sort-Object -Unique)
        for ($i = 1; $i -lt $ys.Count; $i++) {
            $difference = [double]$ys[$i] - [double]$ys[$i - 1]
            if ($difference -lt 100) {
                continue
            }
            $heightCandidates += 1..4 |
                ForEach-Object { $difference / $_ } |
                Sort-Object { [Math]::Abs($_ - $approximatePeriodHeight) } |
                Select-Object -First 1
        }
    }
    $periodHeight = if ($heightCandidates.Count -gt 0) {
        [double](($heightCandidates | Measure-Object -Average).Average)
    } else {
        $approximatePeriodHeight
    }

    [pscustomobject]@{
        DateColumns = @($dateColumns)
        PeriodTop = $headerY + 40
        PeriodHeight = $periodHeight
    }
}

function New-DayColumnCrop {
    param(
        [string]$ImagePath,
        [object[]]$Points,
        [string]$OutputPath
    )

    Add-Type -AssemblyName System.Drawing
    $source = [System.Drawing.Bitmap]::new($ImagePath)
    try {
        $approximateWidth = $source.Width / 6.0
        $left = [Math]::Max(0, [int]([double]$Points[0].X - ($approximateWidth * 0.09)))
        $width = [Math]::Min($source.Width - $left, [int]($approximateWidth * 1.08))
        $crop = [System.Drawing.Bitmap]::new($width, $source.Height)
        $graphics = [System.Drawing.Graphics]::FromImage($crop)
        try {
            $graphics.DrawImage(
                $source,
                [System.Drawing.Rectangle]::new(0, 0, $width, $source.Height),
                [System.Drawing.Rectangle]::new($left, 0, $width, $source.Height),
                [System.Drawing.GraphicsUnit]::Pixel
            )
            $crop.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $graphics.Dispose()
            $crop.Dispose()
        }
    } finally {
        $source.Dispose()
    }

    [pscustomobject]@{
        Left = $left
        Width = $width
    }
}

function Get-EnhancedInstructorPoints {
    param(
        [string]$ImagePath,
        [object[]]$Points,
        [object[]]$DateColumns,
        [double]$PeriodTop,
        [double]$PeriodHeight,
        [string]$InstructorName,
        [string]$Tesseract,
        [string]$TessdataPath,
        [string]$WorkPath
    )

    if ($DateColumns.Count -lt 2) {
        return @($Points)
    }
    $dateXs = @($DateColumns.X | Sort-Object)
    $columnWidths = for ($i = 1; $i -lt $dateXs.Count; $i++) {
        [double]$dateXs[$i] - [double]$dateXs[$i - 1]
    }
    $columnWidth = [double](($columnWidths | Measure-Object -Average).Average)
    Add-Type -AssemblyName System.Drawing
    $source = [System.Drawing.Bitmap]::new($ImagePath)
    $enhanced = @($Points)
    try {
        $groupNumber = 0
        foreach ($group in ($Points | Group-Object X | Sort-Object { [int]$_.Name })) {
            $groupNumber++
            $instructorX = [double]$group.Group[0].X
            $left = [Math]::Max(0, [int]($instructorX - ($columnWidth * 0.09)))
            $width = [Math]::Min($source.Width - $left, [int]($columnWidth * 0.30))
            $scale = 4
            for ($period = 0; $period -lt 4; $period++) {
                $periodY = [Math]::Max(0, [int]($PeriodTop + ($PeriodHeight * $period) - 15))
                $periodCropHeight = [Math]::Min($source.Height - $periodY, [int]($PeriodHeight + 30))
                $stripPath = Join-Path $WorkPath ("instructor-$groupNumber-period-$period.png")
                $strip = [System.Drawing.Bitmap]::new($width * $scale, $periodCropHeight * $scale)
                $graphics = [System.Drawing.Graphics]::FromImage($strip)
                try {
                    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                    $graphics.DrawImage(
                        $source,
                        [System.Drawing.Rectangle]::new(0, 0, $strip.Width, $strip.Height),
                        [System.Drawing.Rectangle]::new($left, $periodY, $width, $periodCropHeight),
                        [System.Drawing.GraphicsUnit]::Pixel
                    )
                    $strip.Save($stripPath, [System.Drawing.Imaging.ImageFormat]::Png)
                } finally {
                    $graphics.Dispose()
                    $strip.Dispose()
                }

                foreach ($psm in @(6, 11, 12)) {
                $base = Join-Path $WorkPath ("instructor-$groupNumber-period-$period-psm$psm")
                $previousErrorPreference = $ErrorActionPreference
                $ErrorActionPreference = 'SilentlyContinue'
                & $Tesseract $stripPath $base --tessdata-dir $TessdataPath -l 'jpn' --psm $psm -c tessedit_create_tsv=1 2>$null
                $tesseractExitCode = $LASTEXITCODE
                $ErrorActionPreference = $previousErrorPreference
                if ($tesseractExitCode -ne 0 -or -not (Test-Path -LiteralPath "$base.tsv")) {
                    continue
                }
                foreach ($row in (Import-Csv -LiteralPath "$base.tsv" -Delimiter "`t")) {
                    $text = [regex]::Replace([string]$row.text, '[\s・]', '')
                    if ($row.level -ne '5' -or -not $text.Contains($InstructorName)) {
                        continue
                    }
                    $enhanced += [pscustomobject]@{
                        X = [int]$instructorX
                        Y = $periodY + [int]([double]$row.top / $scale)
                        Width = [int]([double]$row.width / $scale)
                        Height = [int]([double]$row.height / $scale)
                    }
                }
            }
            }
        }
    } finally {
        $source.Dispose()
    }

    $unique = @()
    foreach ($point in ($enhanced | Sort-Object X, Y)) {
        if (-not ($unique | Where-Object {
            [Math]::Abs($_.X - $point.X) -lt 25 -and [Math]::Abs($_.Y - $point.Y) -lt 25
        })) {
            $unique += $point
        }
    }
    @($unique)
}

function New-EventRowCrop {
    param(
        [string]$DayImagePath,
        [object]$Point,
        [string]$OutputPath,
        [string]$RawOutputPath
    )

    Add-Type -AssemblyName System.Drawing
    $source = [System.Drawing.Bitmap]::new($DayImagePath)
    try {
        $top = [Math]::Max(0, [int]$Point.Y - 24)
        $height = [Math]::Min($source.Height - $top, [Math]::Max(80, [int]$Point.Height + 48))
        $crop = [System.Drawing.Bitmap]::new($source.Width, $height)
        $graphics = [System.Drawing.Graphics]::FromImage($crop)
        try {
            $graphics.DrawImage(
                $source,
                [System.Drawing.Rectangle]::new(0, 0, $source.Width, $height),
                [System.Drawing.Rectangle]::new(0, $top, $source.Width, $height),
                [System.Drawing.GraphicsUnit]::Pixel
            )
        } finally {
            $graphics.Dispose()
        }

        if (-not [string]::IsNullOrWhiteSpace($RawOutputPath)) {
            $rawScaled = [System.Drawing.Bitmap]::new($crop.Width * 3, $crop.Height * 3)
            $rawGraphics = [System.Drawing.Graphics]::FromImage($rawScaled)
            try {
                $rawGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $rawGraphics.DrawImage($crop, 0, 0, $rawScaled.Width, $rawScaled.Height)
                $rawScaled.Save($RawOutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
            } finally {
                $rawGraphics.Dispose()
                $rawScaled.Dispose()
            }
        }

        $clean = [System.Drawing.Bitmap]::new($crop.Width, $crop.Height)
        $assignmentColorPixels = 0
        try {
            for ($y = 0; $y -lt $crop.Height; $y++) {
                for ($x = 0; $x -lt $crop.Width; $x++) {
                    $color = $crop.GetPixel($x, $y)
                    if (
                        $x -ge ($crop.Width * 0.22) -and
                        $x -le ($crop.Width * 0.82) -and
                        $y -ge 20 -and
                        $y -le (32 + [int]$Point.Height) -and
                        $color.G -gt ($color.R + 20) -and
                        $color.G -gt ($color.B + 20) -and
                        $color.G -gt 110
                    ) {
                        $assignmentColorPixels++
                    }
                    $brightness = (0.299 * $color.R) + (0.587 * $color.G) + (0.114 * $color.B)
                    $value = if ($brightness -lt 150) { 0 } else { 255 }
                    $clean.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($value, $value, $value))
                }
            }
            $scaled = [System.Drawing.Bitmap]::new($clean.Width * 2, $clean.Height * 2)
            $scaledGraphics = [System.Drawing.Graphics]::FromImage($scaled)
            try {
                $scaledGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $scaledGraphics.DrawImage($clean, 0, 0, $scaled.Width, $scaled.Height)
                $scaled.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
            } finally {
                $scaledGraphics.Dispose()
                $scaled.Dispose()
            }
        } finally {
            $clean.Dispose()
            $crop.Dispose()
        }
    } finally {
        $source.Dispose()
    }

    [pscustomobject]@{
        HasAssignmentColor = ($assignmentColorPixels -ge 20)
    }
}

function Convert-PdfToEvents {
    param(
        [string]$Path,
        [string]$InstructorName,
        [string]$Python,
        [string]$PdfToPpm,
        [string]$Tesseract,
        [string]$TessdataPath
    )

    $file = Get-Item -LiteralPath $Path
    $range = Get-ScheduleRange -FileName $file.Name
    if (-not $range) {
        throw "日付範囲を読み取れません: $($file.Name)"
    }

    $school = if ($file.BaseName -like '守山北*') { '守山北校' } else { '水口校' }
    $hash = (Get-Sha256Hex -Path $file.FullName).ToLowerInvariant()
    $work = Join-Path $privateRoot ("analysis-" + $hash.Substring(0, 12))
    New-Item -ItemType Directory -Force -Path $work | Out-Null

    if ($Python) {
        $tableExtractor = Join-Path $scriptRoot 'Extract-Schedule-Table.py'
        $tableResultPath = Join-Path $work 'embedded-table-events.json'
        if (Test-Path -LiteralPath $tableExtractor) {
            $previousErrorPreference = $ErrorActionPreference
            $ErrorActionPreference = 'SilentlyContinue'
            & $Python $tableExtractor `
                --pdf $file.FullName `
                --config $configPath `
                --start-date $range.Start.ToString('yyyy-MM-dd') `
                --output $tableResultPath 2>$null
            $pythonExitCode = $LASTEXITCODE
            $ErrorActionPreference = $previousErrorPreference
            if ($pythonExitCode -eq 0 -and (Test-Path -LiteralPath $tableResultPath)) {
                $tableResult = Get-Content -Raw -LiteralPath $tableResultPath -Encoding UTF8 | ConvertFrom-Json
                if ([bool]$tableResult.supported -and @($tableResult.events).Count -gt 0) {
                    Write-LocalLog -Message ('埋め込み表を使用 {0}件' -f @($tableResult.events).Count)
                    return @($tableResult.events | ForEach-Object {
                        [pscustomobject]@{
                            Include = $false
                            Date = [string]$_.date
                            Start = [string]$_.start
                            End = [string]$_.end
                            School = $school
                            Student = ([string]$_.student).Trim()
                            Subject = ([string]$_.subject).Trim()
                            Number = ([string]$_.number).Trim()
                            Confidence = [string]$_.confidence
                            SourcePath = $file.FullName
                            SourceHash = $hash
                        }
                    } | Where-Object {
                        $eventDate = [datetime]::ParseExact($_.Date, 'yyyy-MM-dd', $null)
                        $eventDate.Add([timespan]::Parse($_.Start)) -gt (Get-Date)
                    } | Sort-Object Date, Start -Unique)
                }
            }
        }
    }

    $prefix = Join-Path $work 'page'

    & $PdfToPpm -png -r 220 $file.FullName $prefix
    if ($LASTEXITCODE -ne 0) {
        throw "PDF画像化に失敗しました: $($file.Name)"
    }

    $allEvents = @()
    $pageNumber = 0
    foreach ($image in (Get-ChildItem -LiteralPath $work -Filter 'page-*.png' | Sort-Object Name)) {
        $pageNumber++
        $ocrData = Get-LocalOcrData `
            -ImagePath $image.FullName `
            -Tesseract $Tesseract `
            -TessdataPath $TessdataPath `
            -OutputBase (Join-Path $work ("ocr-$pageNumber")) `
            -InstructorName $InstructorName
        if (@($ocrData.Coordinates).Count -eq 0) {
            continue
        }
        $layout = Get-PageLayout `
            -ImagePath $image.FullName `
            -Tokens @($ocrData.Tokens) `
            -Points @($ocrData.Coordinates) `
            -Range $range
        $ocrData.Coordinates = @(Get-EnhancedInstructorPoints `
            -ImagePath $image.FullName `
            -Points @($ocrData.Coordinates) `
            -DateColumns @($layout.DateColumns) `
            -PeriodTop $layout.PeriodTop `
            -PeriodHeight $layout.PeriodHeight `
            -InstructorName $InstructorName `
            -Tesseract $Tesseract `
            -TessdataPath $TessdataPath `
            -WorkPath $work)
        $layout = Get-PageLayout `
            -ImagePath $image.FullName `
            -Tokens @($ocrData.Tokens) `
            -Points @($ocrData.Coordinates) `
            -Range $range
        $studentRule = if ($school -eq '水口校') {
            '生徒名、教科名、教科名の後に付く番号を読み取る。生徒名と教科名は必須。'
        } else {
            '守山北校には生徒名がないためstudentは空文字にする。担当する指導時間だけを読み取る。'
        }

        $xGroups = @($ocrData.Coordinates | Group-Object X | Sort-Object { [int]$_.Name })
        $dayNumber = 0
        foreach ($xGroup in $xGroups) {
            $dayNumber++
            $points = @($xGroup.Group | Sort-Object Y)
            $dayImage = Join-Path $work ("day-$pageNumber-$dayNumber.png")
            $cropInfo = New-DayColumnCrop -ImagePath $image.FullName -Points $points -OutputPath $dayImage
            $dateColumn = $layout.DateColumns |
                Sort-Object { [Math]::Abs([double]$_.X - [double]$points[0].X) } |
                Select-Object -First 1
            if (-not $dateColumn) {
                continue
            }
            foreach ($target in $points) {
                $rowImage = Join-Path $work ("row-$pageNumber-$dayNumber-$($target.Y).png")
                $rawRowImage = Join-Path $work ("row-raw-$pageNumber-$dayNumber-$($target.Y).png")
                $rowInfo = New-EventRowCrop -DayImagePath $dayImage -Point $target -OutputPath $rowImage -RawOutputPath $rawRowImage
                if ($school -eq '水口校' -and -not $rowInfo.HasAssignmentColor) {
                    continue
                }
                $prompt = @"
この画像は日本の学習塾「$school」のシフト表から、担当者名「$InstructorName」がある1行だけを切り出したものです。
$studentRule
担当者名と同じ横の行だけを読み、上下の行が少し写っていても無視してください。
画像中央の表は、左から「担当者欄」「生徒欄」「教科欄」の順です。担当者名のすぐ右にある中央セルが生徒欄、そのさらに右のセルが教科欄です。
studentには中央の生徒欄を必ず転記し、担当者名や左右端に少し写った別曜日の文字は入れないでください。
生徒欄や教科欄に2行ある場合は両方を読み、同じ順番で「 / 」区切りにしてください。
生徒欄または教科欄が空白なら推測せず空文字にしてください。
次のJSONだけを返してください。
{"student":"","subject":"","number":"","confidence":0.0}
"@
                $resultPath = Join-Path $work ("result-row-$pageNumber-$dayNumber-$($target.Y).json")
                $event = Invoke-LocalModel -ImagePath $rowImage -Prompt $prompt -ResultPath $resultPath
                if (
                    $school -eq '水口校' -and (
                        [string]::IsNullOrWhiteSpace([string]$event.student) -or
                        [string]::IsNullOrWhiteSpace([string]$event.subject)
                    )
                ) {
                    $fallbackPrompt = @"
この画像は日本の学習塾「$school」の1日分の列です。
担当者名「$InstructorName」がある y=$($target.Y) 付近の横1行だけを確認してください。
中央の表は左から担当者欄、生徒欄、教科欄です。対象行以外の文字は無視してください。
生徒や教科が2行なら、同じ順番で両方を「 / 」区切りにしてください。空欄は推測しません。
次のJSONだけを返してください。
{"student":"","subject":"","number":"","confidence":0.0}
"@
                    $fallbackPath = Join-Path $work ("result-fallback-$pageNumber-$dayNumber-$($target.Y).json")
                    $fallback = Invoke-LocalModel -ImagePath $dayImage -Prompt $fallbackPrompt -ResultPath $fallbackPath
                    if (
                        -not [string]::IsNullOrWhiteSpace([string]$fallback.student) -and
                        -not [string]::IsNullOrWhiteSpace([string]$fallback.subject)
                    ) {
                        $event = $fallback
                    }
                }
                if (
                    $school -eq '水口校' -and (
                        [string]::IsNullOrWhiteSpace([string]$event.student) -or
                        [string]::IsNullOrWhiteSpace([string]$event.subject)
                    )
                ) {
                    $rawPrompt = @"
この画像は水口校のシフト表から、担当者名「$InstructorName」がある横1行を加工せず拡大したものです。
担当者欄の右隣にある生徒欄と、その右隣にある教科欄だけを読み取ってください。
氏名は姓と名を省略せず転記してください。2人分が上下2行にある場合は、studentとsubjectを同じ順番で「 / 」区切りにしてください。
教科の後の丸数字などの番号はnumberへ入れてください。推測はせず、画像にある文字だけを使ってください。
次のJSONだけを返してください。
{"student":"","subject":"","number":"","confidence":0.0}
"@
                    $rawResultPath = Join-Path $work ("result-raw-$pageNumber-$dayNumber-$($target.Y).json")
                    $rawResult = Invoke-LocalModel -ImagePath $rawRowImage -Prompt $rawPrompt -ResultPath $rawResultPath
                    if (
                        -not [string]::IsNullOrWhiteSpace([string]$rawResult.student) -and
                        -not [string]::IsNullOrWhiteSpace([string]$rawResult.subject)
                    ) {
                        $event = $rawResult
                    }
                }

                $periodIndex = [int][Math]::Floor(([double]$target.Y - $layout.PeriodTop) / $layout.PeriodHeight)
                if ($periodIndex -lt 0 -or $periodIndex -gt 3) {
                    continue
                }
                $times = @(
                    @('15:10', '16:40'),
                    @('16:50', '18:20'),
                    @('18:30', '20:00'),
                    @('20:10', '21:40')
                )
                $eventDate = [datetime]$dateColumn.Date
                $start = $eventDate.Add([timespan]::Parse($times[$periodIndex][0]))
                $end = $eventDate.Add([timespan]::Parse($times[$periodIndex][1]))
            if ($end -le $start) {
                continue
            }
            if ($start -le (Get-Date)) {
                continue
            }

            $student = ([string]$event.student).Trim()
            $subject = ([string]$event.subject).Trim()
            $number = ([string]$event.number).Trim()
            $allEvents += [pscustomobject]@{
                Include = $false
                Date = $eventDate.ToString('yyyy-MM-dd')
                Start = $start.ToString('HH:mm')
                End = $end.ToString('HH:mm')
                School = $school
                Student = $student
                Subject = $subject
                Number = $number
                Confidence = [string]$event.confidence
                SourcePath = $file.FullName
                SourceHash = $hash
            }
            }
        }
    }

    @($allEvents | Sort-Object Date, Start, School, Student, Subject -Unique)
}

function Get-TargetStoreAndCalendars {
    param([object]$Config)

    $outlook = New-Object -ComObject Outlook.Application
    $namespace = $outlook.GetNamespace('MAPI')
    $pstStores = @()
    foreach ($candidate in $namespace.Stores) {
        $path = [string]$candidate.FilePath
        if (-not [string]::IsNullOrWhiteSpace($path) -and [IO.Path]::GetExtension($path) -ieq '.pst') {
            $pstStores += $candidate
        }
    }
    if ($pstStores.Count -eq 0) {
        throw 'デスクトップ版Outlookで使用中のローカルPSTが見つかりません。'
    }

    $stores = @($pstStores | Where-Object {
        [string]::IsNullOrWhiteSpace([string]$Config.pstPath) -or
        [string]$_.FilePath -eq [string]$Config.pstPath
    })
    if ($stores.Count -eq 0) {
        $stores = $pstStores
    }

    $calendars = New-Object System.Collections.ArrayList
    function Add-CalendarFolder {
        param(
            [object]$Folder,
            [object]$Store
        )
        try {
            if ($Folder.DefaultItemType -eq 1) {
                [void]$calendars.Add([pscustomobject]@{
                    Folder = $Folder
                    DisplayName = ('{0} > {1}' -f $Store.DisplayName, $Folder.Name)
                    PstPath = [string]$Store.FilePath
                })
            }
            foreach ($child in $Folder.Folders) {
                Add-CalendarFolder -Folder $child -Store $Store
            }
        } catch {
            # Outlook can expose virtual folders that are not readable.
        }
    }
    foreach ($store in $stores) {
        Add-CalendarFolder -Folder $store.GetRootFolder() -Store $store
    }

    [pscustomobject]@{
        Outlook = $outlook
        Namespace = $namespace
        Calendars = @($calendars)
    }
}

function Get-IncompleteMizuguchiEvents {
    param([object[]]$Events)

    @($Events | Where-Object {
        $_.School -eq '水口校' -and (
            [string]::IsNullOrWhiteSpace([string]$_.Student) -or
            [string]::IsNullOrWhiteSpace([string]$_.Subject)
        )
    })
}

function Show-ReviewForm {
    param(
        [object[]]$Events,
        [object[]]$Calendars,
        [object]$Config
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'ローカル予定表確認'
    $form.StartPosition = 'CenterScreen'
    $form.Size = New-Object System.Drawing.Size(1120, 650)
    $form.MinimumSize = New-Object System.Drawing.Size(900, 520)

    $top = New-Object System.Windows.Forms.Panel
    $top.Dock = 'Top'
    $top.Height = 52
    $form.Controls.Add($top)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = '反映先の予定表:'
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(12, 17)
    $top.Controls.Add($label)

    $calendarBox = New-Object System.Windows.Forms.ComboBox
    $calendarBox.DropDownStyle = 'DropDownList'
    $calendarBox.Location = New-Object System.Drawing.Point(125, 12)
    $calendarBox.Width = 520
    $top.Controls.Add($calendarBox)

    $openPdf = New-Object System.Windows.Forms.Button
    $openPdf.Text = 'PDFを開く'
    $openPdf.Location = New-Object System.Drawing.Point(660, 11)
    $openPdf.Size = New-Object System.Drawing.Size(100, 30)
    $top.Controls.Add($openPdf)

    $selectAll = New-Object System.Windows.Forms.Button
    $selectAll.Text = 'すべて選択'
    $selectAll.Location = New-Object System.Drawing.Point(770, 11)
    $selectAll.Size = New-Object System.Drawing.Size(100, 30)
    $top.Controls.Add($selectAll)

    $clearAll = New-Object System.Windows.Forms.Button
    $clearAll.Text = 'すべて解除'
    $clearAll.Location = New-Object System.Drawing.Point(880, 11)
    $clearAll.Size = New-Object System.Drawing.Size(100, 30)
    $top.Controls.Add($clearAll)

    $selectedIndex = -1
    for ($i = 0; $i -lt $Calendars.Count; $i++) {
        $calendarInfo = $Calendars[$i]
        $folder = $calendarInfo.Folder
        [void]$calendarBox.Items.Add(("{0} ({1}件)" -f $calendarInfo.DisplayName, $folder.Items.Count))
        if ([string]$folder.EntryID -eq [string]$Config.calendarEntryId) {
            $selectedIndex = $i
        }
    }
    if ($selectedIndex -lt 0 -and $Calendars.Count -gt 0) {
        $largest = 0
        for ($i = 1; $i -lt $Calendars.Count; $i++) {
            if ($Calendars[$i].Folder.Items.Count -gt $Calendars[$largest].Folder.Items.Count) {
                $largest = $i
            }
        }
        $selectedIndex = $largest
    }
    $calendarBox.SelectedIndex = $selectedIndex

    $grid = New-Object System.Windows.Forms.DataGridView
    $grid.Dock = 'Fill'
    $grid.AllowUserToAddRows = $false
    $grid.AllowUserToDeleteRows = $false
    $grid.AutoSizeColumnsMode = 'Fill'
    $grid.SelectionMode = 'CellSelect'
    $form.Controls.Add($grid)
    $grid.BringToFront()

    $includeColumn = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
    $includeColumn.Name = 'Include'
    $includeColumn.HeaderText = '反映'
    $includeColumn.FillWeight = 45
    [void]$grid.Columns.Add($includeColumn)

    foreach ($definition in @(
        @('Date', '日付', 90),
        @('Start', '開始', 65),
        @('End', '終了', 65),
        @('School', '校舎', 80),
        @('Student', '生徒名', 105),
        @('Subject', '教科名', 90),
        @('Number', '番号', 55),
        @('Confidence', '確信度', 55)
    )) {
        $column = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
        $column.Name = $definition[0]
        $column.HeaderText = $definition[1]
        $column.FillWeight = $definition[2]
        [void]$grid.Columns.Add($column)
    }

    $sourceColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $sourceColumn.Name = 'SourcePath'
    $sourceColumn.Visible = $false
    [void]$grid.Columns.Add($sourceColumn)

    foreach ($event in $Events) {
        [void]$grid.Rows.Add(
            $true,
            $event.Date,
            $event.Start,
            $event.End,
            $event.School,
            $event.Student,
            $event.Subject,
            $event.Number,
            $event.Confidence,
            $event.SourcePath
        )
    }

    $selectAll.Add_Click({
        foreach ($row in $grid.Rows) {
            $row.Cells['Include'].Value = $true
        }
    })

    $clearAll.Add_Click({
        foreach ($row in $grid.Rows) {
            $row.Cells['Include'].Value = $false
        }
    })

    $openPdf.Add_Click({
        $paths = @($grid.Rows | ForEach-Object { [string]$_.Cells['SourcePath'].Value } | Where-Object { $_ } | Sort-Object -Unique)
        foreach ($path in $paths) {
            if (Test-Path -LiteralPath $path) {
                Start-Process -FilePath $path
            }
        }
    })

    $bottom = New-Object System.Windows.Forms.Panel
    $bottom.Dock = 'Bottom'
    $bottom.Height = 62
    $form.Controls.Add($bottom)
    $bottom.BringToFront()

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = 'キャンセル'
    $cancel.Size = New-Object System.Drawing.Size(110, 34)
    $cancel.Location = New-Object System.Drawing.Point(850, 14)
    $cancel.Anchor = 'Top,Right'
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $bottom.Controls.Add($cancel)

    $apply = New-Object System.Windows.Forms.Button
    $apply.Text = 'Outlookへ反映'
    $apply.Size = New-Object System.Drawing.Size(130, 34)
    $apply.Location = New-Object System.Drawing.Point(970, 14)
    $apply.Anchor = 'Top,Right'
    $apply.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $apply.Add_Click({
        $grid.CommitEdit([System.Windows.Forms.DataGridViewDataErrorContexts]::Commit)
        $grid.EndEdit()
    })
    $bottom.Controls.Add($apply)

    $form.AcceptButton = $apply
    $form.CancelButton = $cancel
    $result = $form.ShowDialog()

    $selectedEvents = @()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        foreach ($row in $grid.Rows) {
            if ([bool]$row.Cells['Include'].Value) {
                $selectedEvents += [pscustomobject]@{
                    Date = [string]$row.Cells['Date'].Value
                    Start = [string]$row.Cells['Start'].Value
                    End = [string]$row.Cells['End'].Value
                    School = [string]$row.Cells['School'].Value
                    Student = [string]$row.Cells['Student'].Value
                    Subject = [string]$row.Cells['Subject'].Value
                    Number = [string]$row.Cells['Number'].Value
                }
            }
        }
    }

    [pscustomobject]@{
        DialogResult = $result
        CalendarIndex = $calendarBox.SelectedIndex
        Events = $selectedEvents
    }
}

function Ensure-YellowCategory {
    param([object]$Namespace)

    $category = $null
    for ($i = 1; $i -le $Namespace.Categories.Count; $i++) {
        $candidate = $Namespace.Categories.Item($i)
        if ([string]$candidate.Name -eq '黄色') {
            $category = $candidate
            break
        }
    }
    if (-not $category) {
        $category = $Namespace.Categories.Add('黄色', 4)
    }
    if ($category.Color -ne 4) {
        $category.Color = 4
    }
}

function Split-ScheduleValue {
    param(
        [string]$Value,
        [switch]$PreserveEmpty
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return @()
    }
    $parts = @([regex]::Split($Value.Trim(), '\s*/\s*'))
    if ($PreserveEmpty) {
        return $parts
    }
    @($parts | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Convert-ToCircledNumber {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ''
    }
    $normalized = $Value.Trim()
    $fullWidthDigits = '０１２３４５６７８９'
    for ($i = 0; $i -lt 10; $i++) {
        $normalized = $normalized.Replace([string]$fullWidthDigits[$i], [string]$i)
    }
    $circledNumbers = @('', '①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩', '⑪', '⑫', '⑬', '⑭', '⑮', '⑯', '⑰', '⑱', '⑲', '⑳')
    $number = 0
    if ([int]::TryParse($normalized, [ref]$number) -and $number -ge 1 -and $number -le 20) {
        return $circledNumbers[$number]
    }
    $normalized
}

function Format-ScheduleEventBody {
    param([object]$Event)

    $students = @(Split-ScheduleValue -Value ([string]$Event.Student))
    $subjects = @(Split-ScheduleValue -Value ([string]$Event.Subject) -PreserveEmpty)
    $numbers = @(Split-ScheduleValue -Value ([string]$Event.Number) -PreserveEmpty)
    $lineCount = [Math]::Max($students.Count, [Math]::Max($subjects.Count, $numbers.Count))
    $seenStudents = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $lines = for ($i = 0; $i -lt $lineCount; $i++) {
        $student = if ($i -lt $students.Count) { $students[$i] } elseif ($students.Count -eq 1) { $students[0] } else { '' }
        $subject = if ($i -lt $subjects.Count) { $subjects[$i] } elseif ($subjects.Count -eq 1) { $subjects[0] } else { '' }
        $number = if ($i -lt $numbers.Count) { Convert-ToCircledNumber -Value $numbers[$i] } elseif ($numbers.Count -eq 1) { Convert-ToCircledNumber -Value $numbers[0] } else { '' }
        if (-not [string]::IsNullOrWhiteSpace($number) -and $subject -notlike "*$number*") {
            $subject = (($subject, $number | Where-Object { $_ }) -join ' ')
        }
        $line = (($student, $subject | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ' ').Trim()
        $studentKey = if ([string]::IsNullOrWhiteSpace($student)) { $line } else { $student.Trim() }
        if (-not [string]::IsNullOrWhiteSpace($line) -and $seenStudents.Add($studentKey)) {
            $line
        }
    }
    @($lines) -join "`r`n"
}

function Get-ScheduleEventKey {
    param(
        [datetime]$Start,
        [string]$School
    )
    '{0}|{1}' -f $Start.Ticks, $School.Trim()
}

function Test-TargetSlot {
    param(
        [object]$Event,
        [string]$Selector
    )
    $parts = @([regex]::Split($Selector, '\|'))
    if ($parts.Count -ne 3) {
        throw "TargetSlot は YYYY-MM-DD|HH:mm|校舎 の形式で指定してください: $Selector"
    }
    ([string]$Event.Date -like $parts[0]) -and
        ([string]$Event.Start -like $parts[1]) -and
        ([string]$Event.School -like $parts[2])
}

function Apply-Events {
    param(
        [object[]]$Events,
        [object]$Calendar,
        [object]$Namespace
    )

    Ensure-YellowCategory -Namespace $Namespace
    $created = 0
    $updated = 0
    $removedDuplicates = 0
    $now = Get-Date
    $preparedEvents = @()
    $desiredKeys = @{}

    foreach ($event in $Events) {
        $date = [datetime]::ParseExact($event.Date, 'yyyy-MM-dd', $null)
        $start = $date.Add([timespan]::Parse($event.Start))
        $end = $date.Add([timespan]::Parse($event.End))
        if ($start -le $now) {
            continue
        }

        $key = Get-ScheduleEventKey -Start $start -School $event.School
        $preparedEvents += [pscustomobject]@{
            Event = $event
            Start = $start
            End = $end
            Key = $key
        }
        $desiredKeys[$key] = $true
    }

    $eventGroups = @($preparedEvents | Group-Object Key)
    $appointmentsByKey = @{}
    $calendarItems = $Calendar.Items
    $calendarItemCount = $calendarItems.Count
    for ($i = 1; $i -le $calendarItemCount; $i++) {
        try {
            $candidate = $calendarItems.Item($i)
            if ($candidate.Class -ne 26 -or [string]$candidate.Subject -notlike '*IE*個別*') {
                continue
            }
            $key = Get-ScheduleEventKey -Start ([datetime]$candidate.Start) -School ([string]$candidate.Location)
            if ($desiredKeys.ContainsKey($key)) {
                if (-not $appointmentsByKey.ContainsKey($key)) {
                    $appointmentsByKey[$key] = New-Object System.Collections.ArrayList
                }
                [void]$appointmentsByKey[$key].Add($candidate)
            }
        } catch {
            # Skip unreadable items.
        }
    }

    foreach ($eventGroup in $eventGroups) {
        $prepared = $eventGroup.Group[0]
        $event = $prepared.Event
        $start = $prepared.Start
        $end = ($eventGroup.Group | Sort-Object End -Descending | Select-Object -First 1).End
        $key = $eventGroup.Name
        $appointments = if ($appointmentsByKey.ContainsKey($key)) { @($appointmentsByKey[$key]) } else { @() }
        $appointment = if ($appointments.Count -gt 0) { $appointments[0] } else { $null }

        if (-not $appointment) {
            $appointment = $Calendar.Items.Add(1)
            $created++
        } else {
            $updated++
            for ($duplicateIndex = 1; $duplicateIndex -lt $appointments.Count; $duplicateIndex++) {
                $appointments[$duplicateIndex].Delete()
                $removedDuplicates++
            }
        }

        $mergedEvent = [pscustomobject]@{
            Student = (@($eventGroup.Group | ForEach-Object { $_.Event.Student }) -join ' / ')
            Subject = (@($eventGroup.Group | ForEach-Object { $_.Event.Subject }) -join ' / ')
            Number = (@($eventGroup.Group | ForEach-Object { $_.Event.Number }) -join ' / ')
        }
        $formattedBody = Format-ScheduleEventBody -Event $mergedEvent
        $bodyLines = if ([string]::IsNullOrWhiteSpace($formattedBody)) { @() } else { @($formattedBody -split "`r?`n") }

        $appointment.Subject = 'IE 個別指導'
        $appointment.Start = $start
        $appointment.End = $end
        $appointment.Location = $event.School
        $appointment.Categories = '黄色'
        $appointment.ReminderSet = $false
        if ($event.School -eq '水口校') {
            $appointment.Body = $bodyLines -join "`r`n"
        }
        else {
            # 守山北校は日時だけを登録し、個人情報を本文へ入れない。
            $appointment.Body = ''
        }

        $managed = $appointment.UserProperties.Find('LocalScheduleManaged')
        if (-not $managed) {
            $managed = $appointment.UserProperties.Add('LocalScheduleManaged', 1)
        }
        $managed.Value = 'true'
        $appointment.Save()
    }

    [pscustomobject]@{
        Created = $created
        Updated = $updated
        RemovedDuplicates = $removedDuplicates
    }
}

try {
    Add-Type -AssemblyName System.Windows.Forms
    $effectiveTargetSlots = @(
        @($TargetSlot) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }
    )

    if ($ApplyDirectly -and $effectiveTargetSlots.Count -eq 0) {
        throw '-ApplyDirectly には -TargetSlot の指定が必要です。'
    }
    Write-LocalLog -Message ('開始 AnalyzeOnly={0} ApplyDirectly={1}' -f [bool]$AnalyzeOnly, [bool]$ApplyDirectly)
    if (-not $AnalyzeOnly -and -not $ApplyDirectly) {
        Show-Message -Text "処理を開始しました。`r`nPDFの読み取りに2～4分ほどかかる場合があります。`r`n確認画面が出るまでお待ちください。"
    }

    $config = Get-Config
    $instructorName = Get-InstructorName -Config $config
    $pdfs = @(Select-LatestSchedulePdfs -Paths @(Get-InputPdfs))
    Write-LocalLog -Message ('対象PDF {0}件' -f $pdfs.Count)
    if ($pdfs.Count -eq 0) {
        if ($ApplyDirectly) {
            throw '未確認の対象シフトPDFはありません。'
        }
        if ($AnalyzeOnly) {
            [pscustomobject]@{ eventCount = 0; dates = @() } | ConvertTo-Json -Compress
        } else {
            Show-Message -Text '未確認の対象シフトPDFはありません。'
        }
        exit 0
    }

    $pdfToPpm = Find-Executable -Name 'pdftoppm.exe' -Candidates @(
        'C:\texlive\2024\bin\windows\pdftoppm.exe',
        (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\native\poppler\Library\bin\pdftoppm.exe'),
        (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\native\poppler\bin\pdftoppm.cmd')
    )
    $python = Find-OptionalExecutable -Name 'python.exe' -Candidates @(
        (Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe')
    )
    $tesseract = Find-Executable -Name 'tesseract.exe' -Candidates @(
        'C:\Program Files\Tesseract-OCR\tesseract.exe'
    )
    $tessdataPath = Join-Path $privateRoot 'tessdata'
    if (-not (Test-Path -LiteralPath (Join-Path $tessdataPath 'jpn.traineddata'))) {
        throw '日本語OCRデータが見つかりません。'
    }
    Ensure-LocalModel

    $events = @()
    foreach ($pdf in $pdfs) {
        $events += @(Convert-PdfToEvents `
            -Path $pdf `
            -InstructorName $instructorName `
            -Python $python `
            -PdfToPpm $pdfToPpm `
            -Tesseract $tesseract `
            -TessdataPath $tessdataPath)
    }
    $events = @($events | Sort-Object Date, Start, School, Student, Subject -Unique)
    Write-LocalLog -Message ('抽出予定 {0}件' -f $events.Count)

    if ($effectiveTargetSlots.Count -gt 0) {
        $filteredEvents = @()
        foreach ($candidateEvent in $events) {
            foreach ($selector in $effectiveTargetSlots) {
                if (Test-TargetSlot -Event $candidateEvent -Selector $selector) {
                    $filteredEvents += $candidateEvent
                    break
                }
            }
        }
        $events = @($filteredEvents)
        Write-LocalLog -Message ('対象枠抽出 {0}件 Selector={1}' -f $events.Count, ($effectiveTargetSlots -join ','))
    }

    if ($AnalyzeOnly) {
        $incompleteCount = @(Get-IncompleteMizuguchiEvents -Events $events).Count
        [pscustomobject]@{
            eventCount = $events.Count
            dates = @($events | ForEach-Object { $_.Date } | Sort-Object -Unique)
            slots = @($events | ForEach-Object {
                [pscustomobject]@{
                    date = $_.Date
                    start = $_.Start
                    end = $_.End
                    school = $_.School
                    hasStudent = -not [string]::IsNullOrWhiteSpace([string]$_.Student)
                    hasSubject = -not [string]::IsNullOrWhiteSpace([string]$_.Subject)
                    studentCount = @(Split-ScheduleValue -Value ([string]$_.Student)).Count
                    subjectCount = @(Split-ScheduleValue -Value ([string]$_.Subject)).Count
                }
            })
            allWaterEventsHaveDetails = ($incompleteCount -eq 0)
        } | ConvertTo-Json -Compress
        exit 0
    }

    if ($events.Count -eq 0) {
        if ($ApplyDirectly) {
            throw '指定した対象枠に一致する予定を読み取れませんでした。'
        }
        Show-Message -Text '担当者名に一致する未来の予定を読み取れませんでした。PDF上の担当者名を確認してください。' -Icon Warning
        exit 1
    }

    # Incomplete rows never reach the review form or Outlook.
    $incomplete = @(Get-IncompleteMizuguchiEvents -Events $events)
    if ($incomplete.Count -gt 0) {
        Write-LocalLog -Message ('読み取り未完了 {0}件。確認画面とOutlook反映を中止' -f $incomplete.Count)
        if ($ApplyDirectly) {
            throw "水口校の生徒名または教科名を確定できない予定が $($incomplete.Count) 件あります。Outlookは変更していません。"
        }
        Show-Message -Text "PDFを行・日付欄・元画像の3通りで再確認しましたが、水口校の生徒名または教科名を確定できない予定が $($incomplete.Count) 件ありました。`r`n確認画面は開かず、Outlookも変更していません。PDFの画質や最新版かどうかを確認して、もう一度実行してください。" -Icon Warning
        exit 1
    }

    if ($ApplyDirectly) {
        $outlookData = Get-TargetStoreAndCalendars -Config $config
        $calendarInfo = @($outlookData.Calendars | Where-Object {
            ([string]$_.Folder.EntryID -eq [string]$config.calendarEntryId) -and
            ([string]$_.PstPath -eq [string]$config.pstPath)
        } | Select-Object -First 1)
        if ($calendarInfo.Count -eq 0) {
            throw '保存済みの対象PST予定表が見つかりません。設定画面から対象を選び直してください。'
        }
        $calendarInfo = $calendarInfo[0]
        $applied = Apply-Events -Events $events -Calendar $calendarInfo.Folder -Namespace $outlookData.Namespace
        Write-LocalLog -Message ('直接反映完了 New={0} Updated={1} RemovedDuplicates={2}' -f $applied.Created, $applied.Updated, $applied.RemovedDuplicates)
        $slotCount = @($events | ForEach-Object {
            $eventDate = [datetime]::ParseExact($_.Date, 'yyyy-MM-dd', $null)
            Get-ScheduleEventKey -Start $eventDate.Add([timespan]::Parse($_.Start)) -School $_.School
        } | Sort-Object -Unique).Count
        [pscustomobject]@{
            eventCount = $events.Count
            slotCount = $slotCount
            created = $applied.Created
            updated = $applied.Updated
            removedDuplicates = $applied.RemovedDuplicates
            dates = @($events | ForEach-Object { $_.Date } | Sort-Object -Unique)
        } | ConvertTo-Json -Compress
        exit 0
    }

    Show-Message -Text "PDFを3通りの方法で確認し、必要項目をすべて読み取れました。`r`n内容を最終確認してください。通常は入力不要で、全件が選択済みです。" -Icon Information

    $outlookData = Get-TargetStoreAndCalendars -Config $config
    Write-LocalLog -Message ('対象予定表候補 {0}件' -f $outlookData.Calendars.Count)
    if ($outlookData.Calendars.Count -eq 0) {
        throw '対象PST内に予定表が見つかりません。'
    }

    $review = Show-ReviewForm -Events $events -Calendars $outlookData.Calendars -Config $config
    Write-LocalLog -Message ('確認画面終了 Result={0} Selected={1}' -f $review.DialogResult, @($review.Events).Count)
    if ($review.DialogResult -ne [System.Windows.Forms.DialogResult]::OK) {
        exit 0
    }
    if ($review.CalendarIndex -lt 0 -or @($review.Events).Count -eq 0) {
        Show-Message -Text '反映する予定または予定表が選択されていません。' -Icon Warning
        exit 1
    }
    $incomplete = @(Get-IncompleteMizuguchiEvents -Events $review.Events)
    if ($incomplete.Count -gt 0) {
        Show-Message -Text '確認画面で水口校の生徒名または教科名が未入力になった予定があります。Outlookは変更していません。PDFからもう一度実行してください。' -Icon Warning
        exit 1
    }

    $calendarInfo = $outlookData.Calendars[$review.CalendarIndex]
    $calendar = $calendarInfo.Folder
    $config.calendarEntryId = [string]$calendar.EntryID
    $config.pstPath = [string]$calendarInfo.PstPath
    Save-Config -Config $config
    $applied = Apply-Events -Events @($review.Events) -Calendar $calendar -Namespace $outlookData.Namespace
    Write-LocalLog -Message ('反映完了 New={0} Updated={1} RemovedDuplicates={2}' -f $applied.Created, $applied.Updated, $applied.RemovedDuplicates)

    $allEventsApplied = @($review.Events).Count -eq $events.Count
    if ($allEventsApplied) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scannerPath -ConfirmPending | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw 'Outlookへの反映後、PDFを確認済みにする処理に失敗しました。'
        }
    }
    $pendingMessage = if ($allEventsApplied) { '' } else { "`r`n未選択の予定があるため、PDFは未確認のまま残しました。" }
    Show-Message -Text (("完了しました。`r`n新規: {0}件`r`n更新: {1}件`r`n重複削除: {2}件" -f $applied.Created, $applied.Updated, $applied.RemovedDuplicates) + $pendingMessage)
} catch {
    Write-LocalLog -Message ('エラー: {0}' -f $_.Exception.Message)
    if ($AnalyzeOnly -or $ApplyDirectly) {
        throw
    }
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Show-Message -Text $_.Exception.Message -Icon Error
    } catch {
        Write-Error $_
    }
    exit 1
}
