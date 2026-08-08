$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CodexLauncher = Join-Path $ScriptDir "Start-Codex-GPT-OSS-20B.cmd"
$LMStudioHelper = Join-Path $ScriptDir "Prepare-LMStudio-GPT-OSS-20B.ps1"
$ChatGPTUrl = "https://chatgpt.com/"

function Find-LMStudioApp {
    $candidatePaths = @(
        (Join-Path $env:LOCALAPPDATA "Programs\LM Studio\LM Studio.exe"),
        (Join-Path $env:LOCALAPPDATA "LM Studio\LM Studio.exe"),
        (Join-Path $env:ProgramFiles "LM Studio\LM Studio.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "LM Studio\LM Studio.exe"),
        (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\LM Studio.lnk"),
        (Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\LM Studio.lnk")
    )

    foreach ($path in $candidatePaths) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            return $path
        }
    }

    return $null
}

function Start-LMStudioApp {
    $appPath = Find-LMStudioApp

    if (-not $appPath) {
        Write-Host "LM Studio アプリ本体が見つかりませんでした。"
        Write-Host "LM Studio を手動で開いてから、もう一度 4 を選んでください。"
        return $false
    }

    Write-Host "LM Studio を開きます..."
    Write-Host $appPath
    Start-Process -FilePath $appPath
    Start-Sleep -Seconds 3
    return $true
}

function Write-Header {
    Clear-Host
    Write-Host "============================================================"
    Write-Host " 作業場所判定ランチャー"
    Write-Host " ChatGPT / Codex / LM Studio のどれで進めるかを判定します"
    Write-Host "============================================================"
    Write-Host ""
}

function Ask-YesNo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Question
    )

    while ($true) {
        $answer = Read-Host "$Question [y/n]"
        switch -Regex ($answer.Trim().ToLowerInvariant()) {
            "^(y|yes|はい|h)$" { return $true }
            "^(n|no|いいえ|i|)$" { return $false }
            default { Write-Host "y か n で答えてください。" }
        }
    }
}

function Add-Score {
    param(
        [hashtable]$Scores,
        [hashtable]$Reasons,
        [string]$Place,
        [int]$Points,
        [string]$Reason
    )

    $Scores[$Place] += $Points
    $Reasons[$Place].Add($Reason) | Out-Null
}

function Show-Recommendation {
    param(
        [string]$Winner,
        [hashtable]$Scores,
        [hashtable]$Reasons
    )

    Write-Host ""
    Write-Host "============================================================"
    Write-Host "おすすめ: $Winner"
    Write-Host "============================================================"
    Write-Host ""
    Write-Host "点数:"
    Write-Host ("  ChatGPT   : {0}" -f $Scores["ChatGPT"])
    Write-Host ("  Codex     : {0}" -f $Scores["Codex"])
    Write-Host ("  LM Studio : {0}" -f $Scores["LM Studio"])
    Write-Host ""

    if ($Reasons[$Winner].Count -gt 0) {
        Write-Host "理由:"
        foreach ($reason in $Reasons[$Winner]) {
            Write-Host "  - $reason"
        }
        Write-Host ""
    }

    Write-Host "目安:"
    Write-Host "  ChatGPT   : 相談、整理、文章化、画像、Web確認"
    Write-Host "  Codex     : ファイル編集、実装、エラー修正、テスト、Git"
    Write-Host "  LM Studio : ローカル完結、下書き、要約、モデル実験"
    Write-Host ""
}

function Start-RecommendedAction {
    param([string]$Winner)

    switch ($Winner) {
        "ChatGPT" {
            Write-Host "ChatGPT を開きます..."
            Start-Process $ChatGPTUrl
        }
        "Codex" {
            if (-not (Test-Path -LiteralPath $CodexLauncher)) {
                Write-Host "Codex 用ランチャーが見つかりません:"
                Write-Host $CodexLauncher
                return
            }

            Write-Host "Codex 用ランチャーを開きます..."
            Start-Process -FilePath $CodexLauncher -WorkingDirectory $ScriptDir
        }
        "LM Studio" {
            Start-LMStudioApp | Out-Null

            if (-not (Test-Path -LiteralPath $LMStudioHelper)) {
                Write-Host "LM Studio 用補助ファイルが見つかりません:"
                Write-Host $LMStudioHelper
                return
            }

            Write-Host "LM Studio のサーバーと openai/gpt-oss-20b を準備します..."
            & $LMStudioHelper
        }
    }
}

function Open-ActionMenu {
    param([string]$Winner)

    while ($true) {
        Write-Host "次の操作を選んでください。"
        Write-Host "  1: おすすめ先を開く / 準備する ($Winner)"
        Write-Host "  2: ChatGPT を開く (OpenAIクラウド)"
        Write-Host "  3: Codex を開く (LM Studioローカル / CodexMemory連携)"
        Write-Host "  4: LM Studio アプリだけを開く (モデル確認・管理)"
        Write-Host "  Enter: 何もせず閉じる"
        Write-Host ""

        $choice = Read-Host "番号"
        switch ($choice.Trim()) {
            "1" { Start-RecommendedAction -Winner $Winner; return }
            "2" { Start-RecommendedAction -Winner "ChatGPT"; return }
            "3" { Start-RecommendedAction -Winner "Codex"; return }
            "4" { Start-RecommendedAction -Winner "LM Studio"; return }
            "" { return }
            default {
                Write-Host ""
                Write-Host "1, 2, 3, 4, または Enter を選んでください。"
                Write-Host ""
            }
        }
    }
}

Write-Header

$scores = @{
    "ChatGPT" = 0
    "Codex" = 0
    "LM Studio" = 0
}

$reasons = @{
    "ChatGPT" = [System.Collections.Generic.List[string]]::new()
    "Codex" = [System.Collections.Generic.List[string]]::new()
    "LM Studio" = [System.Collections.Generic.List[string]]::new()
}

$needsFiles = Ask-YesNo "実ファイル、コード、Git、テスト、エラー修正を直接扱いたいですか？"
if ($needsFiles) {
    Add-Score $scores $reasons "Codex" 5 "実際のプロジェクトを操作する作業は Codex が得意です。"
}

$needsExternalInfo = Ask-YesNo "Webの最新情報、画像、メール、カレンダーなど外部情報が必要ですか？"
if ($needsExternalInfo) {
    Add-Score $scores $reasons "ChatGPT" 5 "外部情報や画像を使う相談は ChatGPT が向いています。"
}

$needsLocalOnly = Ask-YesNo "内容をできるだけローカルだけで扱いたいですか？"
if ($needsLocalOnly) {
    Add-Score $scores $reasons "LM Studio" 5 "ローカル完結を優先するなら LM Studio が向いています。"
}

$needsLongImplementation = Ask-YesNo "まとまった実装や、原因調査から修正まで任せたいですか？"
if ($needsLongImplementation) {
    Add-Score $scores $reasons "Codex" 4 "調査から修正まで続ける作業は Codex が進めやすいです。"
}

$isThinkingOrWriting = Ask-YesNo "方針相談、文章作成、整理、比較が中心ですか？"
if ($isThinkingOrWriting) {
    Add-Score $scores $reasons "ChatGPT" 3 "考えの整理や文章化は ChatGPT が扱いやすいです。"
}

$isDraftLoop = Ask-YesNo "下書き、要約、言い換え、アイデア出しを気軽に何度も回したいですか？"
if ($isDraftLoop) {
    Add-Score $scores $reasons "LM Studio" 3 "ツール不要の反復作業は LM Studio で軽く回せます。"
    Add-Score $scores $reasons "ChatGPT" 1 "文章品質を重視する場合は ChatGPT も候補です。"
}

if (($scores["ChatGPT"] + $scores["Codex"] + $scores["LM Studio"]) -eq 0) {
    Add-Score $scores $reasons "ChatGPT" 1 "まだ作業内容が曖昧なときは、まず ChatGPT で整理するのが始めやすいです。"
}

$winner = $scores.GetEnumerator() |
    Sort-Object `
        @{ Expression = "Value"; Descending = $true },
        @{ Expression = {
            switch ($_.Key) {
                "Codex" { if ($needsFiles -or $needsLongImplementation) { 0 } else { 2 } }
                "LM Studio" { if ($needsLocalOnly) { 0 } else { 2 } }
                "ChatGPT" { if ($needsExternalInfo -or $isThinkingOrWriting) { 0 } else { 1 } }
            }
        }; Ascending = $true } |
    Select-Object -First 1 -ExpandProperty Key

Show-Recommendation -Winner $winner -Scores $scores -Reasons $reasons
Open-ActionMenu -Winner $winner
