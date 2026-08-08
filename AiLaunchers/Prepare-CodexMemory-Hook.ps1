$ErrorActionPreference = "Stop"

$ProjectDir = "C:\Users\nakag\Desktop\GitHub\Myownproject"
$MemoryDir = Join-Path $ProjectDir "CodexMemory"
$ReadmeFile = Join-Path $MemoryDir "README.md"
$HandoffFile = Join-Path $MemoryDir "Codex-Handoff.md"
$Utf8Bom = [System.Text.UTF8Encoding]::new($true)

function Write-Utf8FileIfMissing {
    param(
        [string]$Path,
        [string[]]$Lines
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        [System.IO.File]::WriteAllText($Path, ($Lines -join [Environment]::NewLine), $Utf8Bom)
    }
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
    "ローカル側のCodexは、Codexアプリ内の過去タスクを自動では読めません。そのため、重要な方針・決定・未完了タスクを `Codex-Handoff.md` に残しておき、ローカルCodex起動後にそれを読ませます。",
    "",
    "## 使い方",
    "",
    "1. ChatGPT / Codexアプリ側で、必要な内容をこのフォルダに追記します。",
    "2. `Start-Codex-GPT-OSS-20B.cmd` または作業場所判定ランチャーの『Codexを開く』を起動します。",
    "3. ローカルCodexが開いたら、次のように依頼します。",
    "",
    "```text",
    "CodexMemory\Codex-Handoff.md を読んで、前回の続きとして作業してください。",
    "```"
)

Write-Utf8FileIfMissing -Path $HandoffFile -Lines @(
    "# Codex Handoff",
    "",
    "## 目的",
    "",
    "このファイルは、ChatGPT / Codexアプリ側で相談した内容を、LM Studioローカル側のCodexへ引き継ぐためのメモです。",
    "",
    "## ローカルCodexに最初に伝える文",
    "",
    "```text",
    "CodexMemory\Codex-Handoff.md を読んで、前回の続きとして作業してください。",
    "```",
    "",
    "## 現在の運用方針",
    "",
    "- OpenAI側のChatGPT / Codexアプリ: 過去タスクの確認、方針相談、整理、判断に向いています。",
    "- LM Studioローカル側のCodex: OpenAIクレジットを使わずに、ローカルモデル `openai/gpt-oss-20b` で作業する入口です。",
    "- ローカルCodex側は、Codexアプリの過去タスクを自動では読めません。",
    "- そのため、重要な引き継ぎ内容はこのファイルに追記します。",
    "",
    "## 引き継ぎメモ",
    "",
    "- ここに、次回ローカルCodexへ渡したい内容を追記してください。"
)

Write-Host "CodexMemory hook is ready."
Write-Host "Handoff file:"
Write-Host $HandoffFile
Write-Host ""
Write-Host "First message to local Codex:"
Write-Host "CodexMemory\Codex-Handoff.md を読んで、前回の続きとして作業してください。"