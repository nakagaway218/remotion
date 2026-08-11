# LM Studioへの単発委譲

## 目的

Codex、Claude Code、その他のエージェントから、起動中のLM Studioへ質問・要約・レビューなどを単発で委譲するための共通手順です。

共通の呼び出し口は `AiLaunchers/Invoke-LMStudioTask.ps1` です。このスクリプトはLM StudioのOpenAI互換APIへ接続するだけで、サーバーの起動、モデルのロード、アンロードは行いません。

## ユーザーから委譲を指定された場合

1. `-ListModels` でAPIから見えるモデルを確認する。
2. 依頼内容に合うモデルを呼び出し元のエージェントが選び、`-Model` で明示する。
3. LM Studioへ必要最小限の情報だけを渡す。
4. 回答を補助意見として読み、重要な事実・コード・判断は呼び出し元が検証する。
5. 最終報告で、使用したモデルとLM Studioに担当させた範囲を伝える。

モデルを自動選択するルーターはありません。「LM Studioに任せて」という指定だけで特定モデルへ固定せず、利用可能モデルと用途を見て毎回選択します。

## 実行例

`Myownproject` のルートから実行する場合:

```powershell
& .\AiLaunchers\Invoke-LMStudioTask.ps1 -ListModels

& .\AiLaunchers\Invoke-LMStudioTask.ps1 `
  -Model "openai/gpt-oss-20b" `
  -Prompt "次の設計案の弱点を3点挙げてください: ..."
```

GitHub配下の別フォルダから実行する場合:

```powershell
$lmStudioTask = "C:\Users\nakag\Desktop\GitHub\Myownproject\AiLaunchers\Invoke-LMStudioTask.ps1"
& $lmStudioTask -ListModels
& $lmStudioTask -Model "openai/gpt-oss-20b" -Prompt "この文章を要約してください: ..."
```

標準出力は回答本文です。モデル名や使用量を含む構造化データが必要なら `-AsJson` を指定します。

## モデル選択の目安

- コード、論理的な検討、長めの分析: reasoningやcodingに向くモデルを優先する。
- 短い要約、分類、文章案: 軽量な指示追従モデルで十分な場合がある。
- 画像を含む依頼: 画像入力に対応するモデルとAPI形式を確認する。現在の共通スクリプトはテキスト入力専用。
- モデルの適性が不明: 小さな試行を行い、品質が足りなければ別モデルへ切り替える。

## `Start-Codex-GPT-OSS-20B` との違い

`Start-Codex-GPT-OSS-20B` はCodexを特定のローカルモデル構成で起動するためのランチャーです。準備処理で既存モデルをアンロードする場合があるため、別タスクがLM Studioを使用中のときに単発依頼の準備として起動してはいけません。

単発委譲では、すでに利用可能なLM Studio APIへ `Invoke-LMStudioTask.ps1` で接続します。接続できない場合や必要モデルが利用できない場合は、勝手にモデル構成を変更せず、現在の状況と必要な操作をユーザーへ伝えます。

## 制約と安全

- LM Studioが起動していても、OpenAI互換APIサーバーが利用可能とは限らない。
- LM Studio側の設定によってはAPI要求時にモデルがロードされることがある。並行作業中はメモリ使用量にも注意する。
- ローカルモデル単体には最新Web情報を取得する能力がない。最新情報の調査は、別途Web検索した資料を渡すか、呼び出し元が検証する。
- APIキー、OAuthトークン、個人情報、顧客・生徒情報などをプロンプトへ含めない。
- LM Studioの回答だけを根拠に、破壊的操作、公開、送信、commit、pushを行わない。
