param(
    [string]$ZoteroExportPath = $env:ZOTERO_BBT_EXPORT_PATH,
    [string]$ObsidianVaultPath = $env:OBSIDIAN_VAULT_PATH,
    [string]$ObsidianFolder = "00_sources/zotero",
    [ValidateSet("off", "dry-run", "sync")]
    [string]$NotionMode = "dry-run",
    [string]$NotionDatabaseId = $env:NOTION_DATABASE_ID,
    [string]$NotionToken = $env:NOTION_TOKEN,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Value {
    param([string]$Value, [string]$Name)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required. Set the parameter or environment variable."
    }
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

function Get-PropertyValue {
    param(
        [object]$Item,
        [string[]]$Names
    )
    foreach ($name in $Names) {
        if ($Item.PSObject.Properties.Name -contains $name) {
            $value = $Item.$name
            if ($null -ne $value -and -not [string]::IsNullOrWhiteSpace([string]$value)) {
                return $value
            }
        }
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

function ConvertTo-MarkdownNote {
    param([object]$Item)

    $title = Get-PropertyValue $Item @("title", "Title")
    if (-not $title) { $title = "Untitled" }

    $key = ConvertTo-ZoteroKey $Item
    $year = Get-PropertyValue $Item @("issued", "year", "date")
    if ($year -and $year.PSObject.Properties.Name -contains "date-parts") {
        $year = $year."date-parts"[0][0]
    }

    $url = Get-PropertyValue $Item @("URL", "url", "DOI", "doi")
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
        "tags: [zotero, literature]"
        "---"
    ) -join "`n"

    $body = @"
$frontmatter

# $title

## 書誌

- Authors: $authors
- Year: $year
- Zotero key: $key
- URL/DOI: $url

## 要約

$abstract

## 重要ポイント

-

## 引用候補

-

## 自分の解釈

-

## 記事化メモ

- article_status: none
- progress:
- deadline:

## 関連ノート

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
            Status = @{ status = @{ name = "未着手" } }
            Progress = @{ select = @{ name = "未着手" } }
            "Obsidian Path" = @{ rich_text = @(@{ text = @{ content = $ObsidianPath } }) }
            "Source URL" = @{ url = $Note.SourceUrl }
        }
    } | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Method Post -Uri "https://api.notion.com/v1/pages" -Headers $headers -Body $payload | Out-Null
    return "notion-created"
}

Require-Value $ZoteroExportPath "ZOTERO_BBT_EXPORT_PATH"
Require-Value $ObsidianVaultPath "OBSIDIAN_VAULT_PATH"

if (-not (Test-Path -LiteralPath $ZoteroExportPath -PathType Leaf)) {
    throw "Zotero export was not found: $ZoteroExportPath"
}
if (-not (Test-Path -LiteralPath $ObsidianVaultPath)) {
    throw "Obsidian vault was not found: $ObsidianVaultPath"
}

$resolvedVaultPath = (Resolve-Path -LiteralPath $ObsidianVaultPath).Path
if ($ObsidianFolder -eq "." -or [string]::IsNullOrWhiteSpace($ObsidianFolder)) {
    $targetDir = $resolvedVaultPath
} else {
    $targetDir = Join-Path $resolvedVaultPath $ObsidianFolder
}
if (-not $DryRun -and -not (Test-Path -LiteralPath $targetDir -PathType Container)) {
    throw "Obsidian output folder was not found: $targetDir"
}

$jsonText = [System.IO.File]::ReadAllText($ZoteroExportPath, [System.Text.Encoding]::UTF8)
$json = $jsonText | ConvertFrom-Json
$items = if ($json -is [array]) { $json } else { @($json.items) }

$created = 0
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
        $skipped++
        continue
    }

    if ($existingTitles.ContainsKey($note.Title)) {
        $skipped++
        continue
    }

    if (-not $DryRun) {
        $parentDir = [System.IO.Path]::GetDirectoryName($notePath)
        if (-not [System.IO.Directory]::Exists($parentDir)) {
            throw "Output folder disappeared before writing: $parentDir"
        }
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
    created_notes = $created
    skipped_existing_notes = $skipped
    notion_pages_created = $notion
    notion_mode = $NotionMode
    obsidian_folder = $targetDir
} | Format-List
