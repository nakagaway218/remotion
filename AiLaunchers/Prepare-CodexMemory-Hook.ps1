$ErrorActionPreference = "Stop"

$ProjectDir = "C:\Users\nakag\Desktop\GitHub\Myownproject"
$MemoryDir = Join-Path $ProjectDir "CodexMemory"
$ReadmeFile = Join-Path $MemoryDir "README.md"
$HandoffFile = Join-Path $MemoryDir "Codex-Handoff.md"
$ReferencePackFile = Join-Path $MemoryDir "Codex-Reference-Pack.md"
$Utf8Bom = [System.Text.UTF8Encoding]::new($true)
$MaxCharsPerFile = 90000
$MaxTotalChars = 260000

function Write-Utf8FileIfMissing {
    param(
        [string]$Path,
        [string[]]$Lines
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        [System.IO.File]::WriteAllText($Path, ($Lines -join [Environment]::NewLine), $Utf8Bom)
    }
}

function Get-ProjectRelativePath {
    param([string]$Path)

    $root = [System.IO.Path]::GetFullPath($ProjectDir)
    if (-not $root.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $root = $root + [System.IO.Path]::DirectorySeparatorChar
    }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if ($fullPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($root.Length)
    }

    return $fullPath
}

function Add-ReferenceFile {
    param(
        [System.Collections.Generic.List[string]]$Files,
        [string]$RelativePath
    )

    $path = Join-Path $ProjectDir $RelativePath
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        $Files.Add($path)
    }
}

function Add-MarkdownFilesFromFolder {
    param(
        [System.Collections.Generic.List[string]]$Files,
        [string]$RelativeFolder,
        [int]$Limit = 0
    )

    $folder = Join-Path $ProjectDir $RelativeFolder
    if (-not (Test-Path -LiteralPath $folder -PathType Container)) {
        return
    }

    $items = Get-ChildItem -LiteralPath $folder -File -Filter "*.md" |
        Sort-Object -Property Name

    if ($Limit -gt 0) {
        $items = $items | Select-Object -First $Limit
    }

    foreach ($item in $items) {
        $Files.Add($item.FullName)
    }
}

function New-CodexReferencePack {
    $files = [System.Collections.Generic.List[string]]::new()

    @(
        "AGENTS.md",
        "CLAUDE.md",
        "AI_CONTEXT.md",
        "docs\PROJECT_CONTEXT.md",
        "docs\WORKFLOW.md",
        "docs\DECISIONS.md",
        "tasks\README.md",
        "CodexMemory\README.md",
        "CodexMemory\Codex-Handoff.md"
    ) | ForEach-Object {
        Add-ReferenceFile -Files $files -RelativePath $_
    }

    Add-MarkdownFilesFromFolder -Files $files -RelativeFolder "tasks\active"
    Add-MarkdownFilesFromFolder -Files $files -RelativeFolder "tasks\paused"

    $doneFolder = Join-Path $ProjectDir "tasks\done"
    if (Test-Path -LiteralPath $doneFolder -PathType Container) {
        Get-ChildItem -LiteralPath $doneFolder -File -Filter "*.md" |
            Sort-Object -Property LastWriteTime -Descending |
            Select-Object -First 5 |
            Sort-Object -Property Name |
            ForEach-Object { $files.Add($_.FullName) }
    }

    $uniqueFiles = $files |
        Sort-Object -Unique |
        Where-Object { $_ -ne $ReferencePackFile }

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Codex Reference Pack")
    $lines.Add("")
    $lines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')")
    $lines.Add("Project: $ProjectDir")
    $lines.Add("")
    $lines.Add("このファイルは、ローカルCodexが共通資料を確認しやすいよう、起動時に自動生成される参照パックです。")
    $lines.Add("利用者は準備文を貼り付ける必要はありません。CodexはAGENTS.mdの指示に従い、作業依頼に必要な範囲だけ参照してください。")
    $lines.Add("元ファイルを変更する場合は、このパックではなく各元ファイルを直接編集してください。")
    $lines.Add("")
    $lines.Add("## Included Files")

    foreach ($file in $uniqueFiles) {
        $lines.Add("- $(Get-ProjectRelativePath -Path $file)")
    }

    $lines.Add("")

    $totalChars = 0
    foreach ($file in $uniqueFiles) {
        $relativePath = Get-ProjectRelativePath -Path $file
        $lines.Add("## $relativePath")
        $lines.Add("")

        try {
            $text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
        }
        catch {
            $lines.Add("_読み込みに失敗しました: $($_.Exception.Message)_")
            $lines.Add("")
            continue
        }

        if ($text.Length -gt $MaxCharsPerFile) {
            $text = $text.Substring(0, $MaxCharsPerFile) + [Environment]::NewLine + [Environment]::NewLine + "... (truncated by Prepare-CodexMemory-Hook.ps1)"
        }

        if (($totalChars + $text.Length) -gt $MaxTotalChars) {
            $lines.Add("_全体サイズ上限のため、このファイル本文は省略しました。必要なら元ファイルを直接読んでください。_")
            $lines.Add("")
            continue
        }

        $totalChars += $text.Length
        $lines.Add("````markdown")
        $lines.Add($text.TrimEnd())
        $lines.Add("````")
        $lines.Add("")
    }

    [System.IO.File]::WriteAllText($ReferencePackFile, ($lines -join [Environment]::NewLine), $Utf8Bom)

}

if (-not (Test-Path -LiteralPath $ProjectDir -PathType Container)) {
    throw "Project folder was not found: $ProjectDir"
}

if (-not (Test-Path -LiteralPath $MemoryDir -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $MemoryDir | Out-Null
}

Write-Utf8FileIfMissing -Path $ReadmeFile -Lines @(
    "# CodexMemory",
    "",
    "このフォルダは、ChatGPT / Codexアプリ側と、LM Studioローカル側のCodexをつなぐための『引き継ぎメモ』置き場です。",
    "",
    "ローカル側のCodexは、Codexアプリ内の過去タスクを自動では読めません。そのため、重要な方針・決定・未完了タスクを `Codex-Handoff.md` や `tasks/` に残します。起動時に参照パックが自動生成され、Codexは `AGENTS.md` の指示に従って必要な範囲を確認します。",
    "",
    "## 使い方",
    "",
    "1. ChatGPT / Codexアプリ側で、必要な内容をこのフォルダに追記します。",
    "2. `Start-Codex-GPT-OSS-20B.cmd` または作業場所判定ランチャーの『Codexを開く』を起動します。",
    "3. 起動時に参照パックが自動生成されます。クリップボードの内容は変更されません。",
    "4. 参考資料がない場合は、ローカルCodexの入力欄へそのまま実際の作業内容を入力します。",
    "5. 参考資料がある場合は、文章を貼り付けるか、作業依頼にファイルの場所を含めます。",
    "",
    "例: `docs/資料.md を読んで、内容を整理してください。`"
)

Write-Utf8FileIfMissing -Path $HandoffFile -Lines @(
    "# Codex Handoff",
    "",
    "## 目的",
    "",
    "このファイルは、ChatGPT / Codexアプリ側で相談した内容を、LM Studioローカル側のCodexへ引き継ぐためのメモです。",
    "",
    "## 起動後の使い方",
    "",
    "参考資料がない場合は、ローカルCodexの入力欄へそのまま実際の作業内容を入力します。",
    "共通資料は `AGENTS.md` の指示に従い、依頼に必要な範囲だけCodexが確認します。",
    "参考資料がある場合、文章ならその文章を入力欄へ貼り付け、ファイルならファイル自体ではなくフルパスを依頼文に書きます。",
    "",
    "例: `まず C:\Users\nakag\Desktop\GitHub\Myownproject\AiLaunchers\参考資料.pdf を読み、その内容を前提に作業してください。依頼: 内容を要約してください。`",
    "",
    "## 現在の運用方針",
    "",
    "- OpenAI側のChatGPT / Codexアプリ: 過去タスクの確認、方針相談、整理、判断に向いています。",
    "- LM Studioローカル側のCodex: OpenAIクレジットを使わずに、ローカルモデル `openai/gpt-oss-20b` で作業する入口です。",
    "- ローカルCodex側は、Codexアプリの過去タスクを自動では読めません。",
    "- そのため、重要な引き継ぎ内容はこのファイルに追記します。",
    "- 起動時には `Codex-Reference-Pack.md` が自動生成され、共通ドキュメントや進行中タスクをまとめて読ませられます。",
    "",
    "## 引き継ぎメモ",
    "",
    "- ここに、次回ローカルCodexへ渡したい内容を追記してください。"
)

New-CodexReferencePack

Clear-Host
Write-Host "============================================================"
Write-Host "参考資料が無い場合、そのまま始めてください。"
Write-Host "参考資料が文章の場合、Ctrl+Vで貼り付け、その下に依頼を書いてください。"
Write-Host "参考資料がPDFなどのファイルの場合、ファイルのフルパスと依頼を書いてください。"
Write-Host ""
Write-Host "入力例:"
Write-Host "まず次の参考資料を読み、その内容を前提に作業してください。"
Write-Host "C:\Users\nakag\Desktop\GitHub\Myownproject\AiLaunchers\参考資料.pdf"
Write-Host "依頼: この資料の内容を要約してください。"
Write-Host "※「参考資料.pdf」は、実際に読み取らせたいファイル名へ置き換えてください。"
Write-Host ""
Write-Host "資料だけ先に読ませる場合は、最後に"
Write-Host "「まだ作業は開始せず、次の指示を待ってください」と書きます。"
Write-Host "============================================================"
