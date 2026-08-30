[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Prompt,

    [string]$Model = "openai/gpt-oss-20b",

    [string]$SystemPrompt = "You are a local assistant. Answer the requested task directly and clearly.",

    [ValidateRange(1, 32768)]
    [int]$MaxTokens = 1024,

    [ValidateRange(0.0, 2.0)]
    [double]$Temperature = 0.2,

    [ValidateRange(1, 600)]
    [int]$TimeoutSec = 120,

    [string]$BaseUrl = "http://127.0.0.1:1234",

    [switch]$ListModels,

    [switch]$AsJson
)

$ErrorActionPreference = "Stop"
$apiBase = $BaseUrl.TrimEnd("/")

try {
    $modelsResponse = Invoke-RestMethod `
        -Method Get `
        -Uri "$apiBase/v1/models" `
        -TimeoutSec ([Math]::Min($TimeoutSec, 30))
} catch {
    throw "LM Studio APIに接続できません: $apiBase。LM StudioのOpenAI互換APIサーバーを確認してください。Start-Codex-GPT-OSS-20Bの起動は単発依頼の必須条件ではありません。詳細: $($_.Exception.Message)"
}

$modelIds = @($modelsResponse.data | ForEach-Object { $_.id } | Where-Object { $_ })

if ($ListModels) {
    $modelIds
    return
}

if ([string]::IsNullOrWhiteSpace($Prompt)) {
    throw "-Prompt を指定してください。利用可能モデルの確認だけを行う場合は -ListModels を使用します。"
}

if ($modelIds.Count -gt 0 -and $Model -notin $modelIds) {
    $availableModels = $modelIds -join ", "
    throw "モデル '$Model' はAPIのモデル一覧にありません。利用可能モデル: $availableModels"
}

$messages = @()
if (-not [string]::IsNullOrWhiteSpace($SystemPrompt)) {
    $messages += [ordered]@{
        role = "system"
        content = $SystemPrompt
    }
}
$messages += [ordered]@{
    role = "user"
    content = $Prompt
}

$requestBody = [ordered]@{
    model = $Model
    messages = $messages
    max_tokens = $MaxTokens
    temperature = $Temperature
    stream = $false
} | ConvertTo-Json -Depth 8

try {
    $response = Invoke-RestMethod `
        -Method Post `
        -Uri "$apiBase/v1/chat/completions" `
        -ContentType "application/json; charset=utf-8" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($requestBody)) `
        -TimeoutSec $TimeoutSec
} catch {
    throw "LM Studioへの依頼に失敗しました。モデル構成を変更せず、LM Studioの状態を確認してください。詳細: $($_.Exception.Message)"
}

$content = $response.choices[0].message.content
if ([string]::IsNullOrWhiteSpace([string]$content)) {
    throw "LM Studioから回答本文を取得できませんでした。推論モデルではMaxTokensが小さいと推論だけで上限に達するため、値を増やして再実行してください。"
}

if ($AsJson) {
    [ordered]@{
        model = $response.model
        content = $content
        usage = $response.usage
    } | ConvertTo-Json -Depth 8
} else {
    $content
}
