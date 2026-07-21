param(
    [string]$ZoteroExportPath = (Join-Path (Split-Path -Parent $PSScriptRoot) "zotero\zotero-export.json"),
    [string]$ObsidianVaultPath = "C:\Users\nakag\Documents\Obsidian Vault",
    [string]$ObsidianFolder = "00_sources\zotero",
    [ValidateSet("off", "dry-run", "sync")]
    [string]$NotionMode = "dry-run",
    [string]$NotionDatabaseId = $env:NOTION_DATABASE_ID,
    [string]$NotionToken = $env:NOTION_TOKEN,
    [switch]$DryRun,
    [switch]$UpdateExisting
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Value {
    param([string]$Value, [string]$Name)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required. Set the parameter or environment variable."
    }
}

function Get-PropertyValue {
    param(
        [object]$Item,
        [string[]]$Names
    )
    foreach ($name in $Names) {
        if ($Item.PSObject.Properties.Name -contains $name) {
            $value = $Item.$name
            if ($null -eq $value) {
                continue
            }
            if ($value -is [array]) {
                if ($value.Count -gt 0) {
                    return $value
                }
                continue
            }
            if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
                return $value
            }
        }
    }
    return $null
}

function ConvertTo-SafeFileName {
    param([string]$Text)
    $safe = $Text -replace '[\\/:*?"<>|#\[\]]', '-'
    $safe = $safe -replace '\s+', ' '
    $safe = $safe.Trim()
    if ($safe.Length -gt 90) {
        $safe = $safe.Substring(0, 90).Trim()
    }
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return "untitled"
    }
    return $safe
}

function ConvertTo-ZoteroKey {
    param([object]$Item)
    $key = Get-PropertyValue $Item @("citation-key", "citationKey", "citekey", "key")
    if ($key) {
        return [string]$key
    }

    $id = Get-PropertyValue $Item @("id")
    if ($id) {
        $idText = [string]$id
        if ($idText -match '/items/([^/?#]+)') {
            return $Matches[1]
        }
        return $idText
    }

    return $null
}

function Format-Authors {
    param([object]$Authors)
    if ($null -eq $Authors) {
        return ""
    }
    $names = @()
    foreach ($author in @($Authors)) {
        if ($author -is [string]) {
            $names += $author
            continue
        }
        $family = Get-PropertyValue $author @("family", "lastName", "last")
        $given = Get-PropertyValue $author @("given", "firstName", "first")
        $literal = Get-PropertyValue $author @("literal", "name")
        if ($literal) {
            $names += [string]$literal
        } elseif ($family -or $given) {
            $names += (@($given, $family) | Where-Object { $_ }) -join " "
        }
    }
    return ($names | Where-Object { $_ }) -join "; "
}

function ConvertTo-Year {
    param([object]$Item)
    $issued = Get-PropertyValue $Item @("issued")
    if ($issued -and $issued.PSObject.Properties.Name -contains "date-parts") {
        return [string]$issued."date-parts"[0][0]
    }
    $date = Get-PropertyValue $Item @("year", "date")
    if ($date -match '\d{4}') {
        return $Matches[0]
    }
    return [string]$date
}

function ConvertTo-MarkdownNote {
    param([object]$Item)

    $title = Get-PropertyValue $Item @("title", "Title")
    if (-not $title) { $title = "Untitled" }

    $key = ConvertTo-ZoteroKey $Item
    $year = ConvertTo-Year $Item
    $url = Get-PropertyValue $Item @("URL", "url")
    $doi = Get-PropertyValue $Item @("DOI", "doi")
    $sourceUrl = if ($url -and ([string]$url -match '^https?://')) { [string]$url } else { $null }
    $itemType = Get-PropertyValue $Item @("type", "itemType")
    $authors = Format-Authors (Get-PropertyValue $Item @("author", "creators"))
    $abstract = Get-PropertyValue $Item @("abstract", "abstractNote")

    $frontmatter = @(
        "---"
        "type: literature_note"
        "status: unread"
        "article_status: none"
        "notion_sync: false"
        "zotero_key: `"$key`""
        "year: `"$year`""
        "source_type: `"$itemType`""
        "url: `"$url`""
        "doi: `"$doi`""
        "tags: [zotero, literature]"
        "---"
    ) -join "`n"

    $body = @"
$frontmatter

# $title

## Bibliography

- Authors: $authors
- Year: $year
- Zotero key: $key
- URL: $url
- DOI: $doi

## Abstract

$abstract

## Key points

-

## Quote candidates

-

## My interpretation

-

## Article notes

- article_status: none
- progress:
- deadline:

## Related notes

-
"@
    return @{
        Title = [string]$title
        Key = [string]$key
        SourceUrl = $sourceUrl
        Markdown = $body
    }
}

function Send-NotionPage {
    param(
        [hashtable]$Note,
        [string]$ObsidianPath
    )
    if ($NotionMode -eq "off") {
        return "notion-off"
    }
    if ($NotionMode -eq "dry-run" -or $DryRun) {
        return "notion-dry-run"
    }
    Require-Value $NotionToken "NOTION_TOKEN"
    Require-Value $NotionDatabaseId "NOTION_DATABASE_ID"

    $headers = @{
        "Authorization" = "Bearer $NotionToken"
        "Notion-Version" = "2022-06-28"
        "Content-Type" = "application/json"
    }
    $payload = @{
        parent = @{ database_id = $NotionDatabaseId }
        properties = @{
            Name = @{ title = @(@{ text = @{ content = $Note.Title } }) }
            "Zotero Key" = @{ rich_text = @(@{ text = @{ content = $Note.Key } }) }
            Status = @{ status = @{ name = "Not started" } }
            Progress = @{ select = @{ name = "Not started" } }
            "Obsidian Path" = @{ rich_text = @(@{ text = @{ content = $ObsidianPath } }) }
            "Source URL" = @{ url = $Note.SourceUrl }
        }
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Method Post -Uri "https://api.notion.com/v1/pages" -Headers $headers -Body $payload | Out-Null
    return "notion-created"
}

Require-Value $ZoteroExportPath "ZoteroExportPath"
Require-Value $ObsidianVaultPath "ObsidianVaultPath"

if (Test-Path -LiteralPath $ZoteroExportPath -PathType Container) {
    throw "ZoteroExportPath points to a folder, not a JSON file: $ZoteroExportPath"
}
if (-not (Test-Path -LiteralPath $ZoteroExportPath -PathType Leaf)) {
    throw "Zotero export JSON was not found: $ZoteroExportPath"
}
if (-not (Test-Path -LiteralPath $ObsidianVaultPath -PathType Container)) {
    [System.IO.Directory]::CreateDirectory($ObsidianVaultPath) | Out-Null
}

$resolvedVaultPath = (Resolve-Path -LiteralPath $ObsidianVaultPath).Path
if ($ObsidianFolder -eq "." -or [string]::IsNullOrWhiteSpace($ObsidianFolder)) {
    $targetDir = $resolvedVaultPath
} else {
    $targetDir = Join-Path $resolvedVaultPath $ObsidianFolder
}
if (-not $DryRun -and -not (Test-Path -LiteralPath $targetDir -PathType Container)) {
    [System.IO.Directory]::CreateDirectory($targetDir) | Out-Null
}

$jsonText = [System.IO.File]::ReadAllText($ZoteroExportPath, [System.Text.Encoding]::UTF8)
try {
    $json = $jsonText | ConvertFrom-Json
} catch {
    throw "Could not parse Zotero export as CSL JSON. In Zotero / Better BibTeX, export as Better CSL JSON or CSL JSON. Path: $ZoteroExportPath"
}
$items = if ($json -is [array]) { $json } else { @($json.items) }

$created = 0
$updated = 0
$skipped = 0
$notion = 0
$existingTitles = @{}

if (Test-Path -LiteralPath $targetDir -PathType Container) {
    foreach ($existingFile in Get-ChildItem -LiteralPath $targetDir -Filter "*.md" -File) {
        $heading = Get-Content -LiteralPath $existingFile.FullName -TotalCount 20 | Where-Object { $_ -like "# *" } | Select-Object -First 1
        if ($heading) {
            $existingTitle = $heading.Substring(2).Trim()
            if (-not [string]::IsNullOrWhiteSpace($existingTitle) -and -not $existingTitles.ContainsKey($existingTitle)) {
                $existingTitles[$existingTitle] = $existingFile.FullName
            }
        }
    }
}

foreach ($item in $items) {
    if ($null -eq $item) { continue }
    $note = ConvertTo-MarkdownNote $item
    $prefix = if ($note.Key) { ConvertTo-SafeFileName $note.Key } else { ConvertTo-SafeFileName $note.Title }
    $fileName = "$prefix.md"
    $notePath = Join-Path $targetDir $fileName

    if (Test-Path -LiteralPath $notePath) {
        if ($UpdateExisting) {
            if (-not $DryRun) {
                [System.IO.File]::WriteAllText($notePath, $note.Markdown, [System.Text.UTF8Encoding]::new($true))
            }
            $updated++
        } else {
            $skipped++
        }
        continue
    }

    if ($existingTitles.ContainsKey($note.Title)) {
        $skipped++
        continue
    }

    if (-not $DryRun) {
        [System.IO.File]::WriteAllText($notePath, $note.Markdown, [System.Text.UTF8Encoding]::new($true))
    }
    $created++
    if (-not $existingTitles.ContainsKey($note.Title)) {
        $existingTitles[$note.Title] = $notePath
    }

    $notionResult = Send-NotionPage $note $notePath
    if ($notionResult -eq "notion-created") {
        $notion++
    }
}

[pscustomobject]@{
    zotero_items = @($items).Count
    created_notes = $created
    updated_notes = $updated
    skipped_existing_notes = $skipped
    notion_pages_created = $notion
    notion_mode = $NotionMode
    zotero_export = (Resolve-Path -LiteralPath $ZoteroExportPath).Path
    obsidian_folder = $targetDir
} | Format-List
