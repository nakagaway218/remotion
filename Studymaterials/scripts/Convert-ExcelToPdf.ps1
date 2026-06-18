param(
    [string]$WorkbookPath,
    [ValidateSet("all", "bookmarks", "sheets")]
    [string]$Mode,
    [string]$OutputDirectory,
    [string]$PythonCommand = "python",
    [switch]$KeepTemporary,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Resolve-WorkbookPath {
    param([string]$PathFromUser)

    if ($PathFromUser) {
        return (Resolve-Path -LiteralPath $PathFromUser).Path
    }

    $workbooks = Get-ChildItem -LiteralPath (Get-Location) -File |
        Where-Object {
            $_.Extension -in @(".xlsx", ".xlsm", ".xls") -and -not $_.Name.StartsWith("~$")
        } |
        Sort-Object Name

    if ($workbooks.Count -eq 0) {
        throw "No Excel files were found in this folder."
    }

    Write-Host "Select an Excel file to convert to PDF."
    for ($i = 0; $i -lt $workbooks.Count; $i++) {
        Write-Host ("{0}: {1}" -f ($i + 1), $workbooks[$i].Name)
    }

    $selected = Read-Host "Number"
    $index = [int]$selected - 1
    if ($index -lt 0 -or $index -ge $workbooks.Count) {
        throw "The selected number is out of range."
    }

    return $workbooks[$index].FullName
}

function Resolve-Mode {
    param([string]$ModeFromUser)

    if ($ModeFromUser) {
        return $ModeFromUser
    }

    Write-Host ""
    Write-Host "Select a PDF output mode."
    Write-Host "1: Convert the whole workbook to one PDF"
    Write-Host "2: Convert sheets to one PDF with bookmarks"
    Write-Host "3: Convert each sheet to a separate PDF"

    $selected = Read-Host "Number"
    switch ($selected) {
        "1" { return "all" }
        "2" { return "bookmarks" }
        "3" { return "sheets" }
        default { throw "The selected number is out of range." }
    }
}

function Get-SafeFileName {
    param([string]$Name)

    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    $safe = $Name
    foreach ($char in $invalidChars) {
        $safe = $safe.Replace($char, "_")
    }
    $safe = $safe.Trim()
    if (-not $safe) {
        return "sheet"
    }
    return $safe
}

function Confirm-OverwritePaths {
    param(
        [string[]]$Paths,
        [switch]$ForceOverwrite
    )

    if ($ForceOverwrite) {
        return $true
    }

    $existingPaths = @($Paths | Where-Object { Test-Path -LiteralPath $_ })
    if ($existingPaths.Count -eq 0) {
        return $true
    }

    Write-Host ""
    Write-Host "The following output file(s) already exist:"
    foreach ($path in $existingPaths) {
        Write-Host ("  {0}" -f $path)
    }

    $answer = Read-Host "Overwrite? Type y to overwrite, or press Enter to cancel"
    if ($answer -ne "y" -and $answer -ne "Y") {
        Write-Host "Canceled."
        return $false
    }

    return $true
}

function Export-WorksheetPdf {
    param(
        [object]$Worksheet,
        [string]$PdfPath
    )

    $xlTypePDF = 0
    $xlQualityStandard = 0
    $includeDocumentProperties = $true
    $ignorePrintAreas = $false

    $Worksheet.ExportAsFixedFormat(
        $xlTypePDF,
        $PdfPath,
        $xlQualityStandard,
        $includeDocumentProperties,
        $ignorePrintAreas
    )
}

function Export-WorkbookPdf {
    param(
        [object]$Workbook,
        [string]$PdfPath
    )

    $xlTypePDF = 0
    $xlQualityStandard = 0
    $includeDocumentProperties = $true
    $ignorePrintAreas = $false

    $Workbook.ExportAsFixedFormat(
        $xlTypePDF,
        $PdfPath,
        $xlQualityStandard,
        $includeDocumentProperties,
        $ignorePrintAreas
    )
}

$resolvedWorkbookPath = Resolve-WorkbookPath -PathFromUser $WorkbookPath
$resolvedMode = Resolve-Mode -ModeFromUser $Mode
$workbookItem = Get-Item -LiteralPath $resolvedWorkbookPath

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $workbookItem.DirectoryName "output\pdf"
}
$resolvedOutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $resolvedOutputDirectory | Out-Null

$excel = $null
$workbook = $null

try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    $workbook = $excel.Workbooks.Open($resolvedWorkbookPath, 3, $true)
    $visibleSheets = @()
    foreach ($worksheet in $workbook.Worksheets) {
        if ($worksheet.Visible -eq -1) {
            $visibleSheets += $worksheet
        }
    }

    if ($visibleSheets.Count -eq 0) {
        throw "No visible worksheets were found."
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedWorkbookPath)

    switch ($resolvedMode) {
        "all" {
            $pdfPath = Join-Path $resolvedOutputDirectory ($baseName + "_all.pdf")
            if (-not (Confirm-OverwritePaths -Paths @($pdfPath) -ForceOverwrite:$Force)) {
                return
            }
            Export-WorkbookPdf -Workbook $workbook -PdfPath $pdfPath
            Write-Host ("Created: {0}" -f $pdfPath)
        }
        "sheets" {
            $sheetOutputDirectory = Join-Path $resolvedOutputDirectory ($baseName + "_sheets")
            $targetPaths = @()

            for ($i = 0; $i -lt $visibleSheets.Count; $i++) {
                $worksheet = $visibleSheets[$i]
                $safeSheetName = Get-SafeFileName -Name $worksheet.Name
                $targetPaths += Join-Path $sheetOutputDirectory ("{0:00}_{1}.pdf" -f ($i + 1), $safeSheetName)
            }

            if (-not (Confirm-OverwritePaths -Paths $targetPaths -ForceOverwrite:$Force)) {
                return
            }
            New-Item -ItemType Directory -Force -Path $sheetOutputDirectory | Out-Null

            for ($i = 0; $i -lt $visibleSheets.Count; $i++) {
                $worksheet = $visibleSheets[$i]
                $pdfPath = $targetPaths[$i]
                Export-WorksheetPdf -Worksheet $worksheet -PdfPath $pdfPath
                Write-Host ("Created: {0}" -f $pdfPath)
            }
        }
        "bookmarks" {
            $mergedPdfPath = Join-Path $resolvedOutputDirectory ($baseName + "_bookmarked.pdf")
            if (-not (Confirm-OverwritePaths -Paths @($mergedPdfPath) -ForceOverwrite:$Force)) {
                return
            }

            $temporaryDirectory = Join-Path $resolvedOutputDirectory ($baseName + "_bookmark_tmp")
            if (Test-Path -LiteralPath $temporaryDirectory) {
                Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
            }
            New-Item -ItemType Directory -Force -Path $temporaryDirectory | Out-Null

            $entries = @()
            for ($i = 0; $i -lt $visibleSheets.Count; $i++) {
                $worksheet = $visibleSheets[$i]
                $safeSheetName = Get-SafeFileName -Name $worksheet.Name
                $pdfPath = Join-Path $temporaryDirectory ("{0:00}_{1}.pdf" -f ($i + 1), $safeSheetName)
                Export-WorksheetPdf -Worksheet $worksheet -PdfPath $pdfPath
                $entries += [ordered]@{
                    title = $worksheet.Name
                    pdf = $pdfPath
                }
                Write-Host ("Created temporary PDF: {0}" -f $pdfPath)
            }

            $manifestPath = Join-Path $temporaryDirectory "manifest.json"
            [ordered]@{
                output = $mergedPdfPath
                entries = $entries
            } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

            $mergeScriptPath = Join-Path $PSScriptRoot "merge_pdfs_with_bookmarks.py"
            & $PythonCommand $mergeScriptPath $manifestPath
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to merge the bookmarked PDF."
            }

            if (-not $KeepTemporary) {
                Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
            }

            Write-Host ("Created: {0}" -f $mergedPdfPath)
        }
    }
}
finally {
    if ($workbook -ne $null) {
        $workbook.Close($false) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) | Out-Null
    }
    if ($excel -ne $null) {
        $excel.Quit() | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
