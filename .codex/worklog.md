# Codex Work Log

## 2026-08-09: ローカルCodex起動案内の反省点を記録

- 度重なった修正の原因を、話者、資料の種類、表示タイミング、CMD/PowerShell境界、通し確認の観点で整理した。
- `tasks/done/2026-08-09-local-codex-launcher-lessons.md` に再発防止チェックリストを追加した。
- 自動生成される `CodexMemory/Codex-Reference-Pack.md` をGit管理対象から外した。

## 2026-08-09: Codex起動時の参考資料案内を簡素化

- クリップボードへ準備文をコピーする手順を廃止した。
- 「準備できました」と返答させる往復を廃止した。
- Codexの入力欄が表示されたら、最初から実際の作業依頼を入力する方式に統一した。
- 追加の参考資料は、実際の依頼文にファイルのフルパスを書く。

## 2026-08-08

**依頼内容**
CodexをLM Studio上のローカルモデルで運用し、作業記録を残す仕組みを追加する。

**実施内容**
- AGENTS.md に Work Log Policy を追加。
- Windows環境では apply_patch を使用せず、PowerShellで編集する運用を追加。
- .codex/worklog.md を作成。

**変更ファイル**
- AGENTS.md
- .codex/worklog.md

**未解決事項**
- CodexとLM Studio間のコンテキスト長設定を安定させる必要がある。

## 2026-08-08 12:32

**依頼内容**
指定時刻に新しいシフトPDFがあるか自動確認する。

**実施内容**
- `Check-New-Schedule-PDFs.ps1 -AutomationCheck` を実行。
- 未確認の新しいシフトPDFが0件であることを確認。
- Outlook予定表への書き込みは行っていない。

**変更ファイル**
- `.codex/worklog.md`（作業記録のみ）

**未解決事項**
- なし。

## 2026-08-08 AGENTS.md worklog policy cleanup

- 依頼内容: AGENTS.md の文字化け修正と作業記録先の統一。
- 実施内容: 文字化けしていたダッシュ表記を復元し、作業記録先を .codex/worklog.md に統一。
- 変更ファイル: AGENTS.md, .codex/worklog.md
- 未解決事項: なし。

## 2026-08-09 00:29 +09:00 LM Studio / Codex ローカル運用整理

**依頼内容**
LM Studioを使ってCodexの推論クレジットを節約する構成、Qwen系モデルの検証・整理、`openai/gpt-oss-20b` をダブルクリックで起動するツール作成までの流れを記録する。

**実施内容**
- 添付された過去会話を確認し、CodexからLM Studio/Ollamaのローカルモデルへ接続する試行内容を整理。
- LM Studio CLI、LM Studioサーバー、`codex.cmd` 経由の起動確認、PowerShell実行ポリシーによる `codex.ps1` ブロック回避を記録。
- Qwen2.5-Coder 14B は reasoning 設定を外すと起動できるものの、正式な `tool_calls` ではなくJSON風テキストを返すため、Codexの実作業用モデルには不向きと判断。
- Ollama側のQwen系モデル削除後、`ollama list` が空になったことを記録。LM Studio側のQwen Coder系はアプリの My Models から削除し、`openai/gpt-oss-20b` は残す方針を記録。
- 既存の `AiLaunchers/Start-Codex-GPT-OSS-20B.cmd` と準備スクリプトを確認し、`Mytools/` からダブルクリックで起動できる入口を追加。
- `Mytools/README.md` に起動ツールの説明を追加。
- PowerShell構文パーサーで `Prepare-LMStudio-GPT-OSS-20B.ps1` と `Prepare-CodexMemory-Hook.ps1` に構文エラーがないことを確認。

**変更ファイル**
- `Mytools/Codex GPT-OSS-20B 起動ツール.bat`
- `Mytools/README.md`
- `.codex/worklog.md`

**未解決事項**
- 実際のLM Studio/Codex起動テストは、ローカルモデルと対話セッションを起動する操作になるため未実行。
- LM Studio側に残っているQwen Coder系モデルの削除は、必要に応じてLM Studioアプリの My Models から実施する。

## 2026-08-09 CodexMemory 参照パック自動生成

**依頼内容**
作業場所判定ランチャーの3番などでPowerShellからローカルCodexを起動したとき、ChatGPTのように参考ファイルを添付できない問題を補う。

**実施内容**
- `Prepare-CodexMemory-Hook.ps1` に参照パック生成を追加。
- `Codex-Reference-Pack.md` に共通指示、docs、進行中/保留タスク、直近完了タスクをまとめるようにした。
- `Codex-Attachment-Prompt.txt` を生成し、起動時にクリップボードへコピーするようにした。
- `CodexMemory` の手順書と引き継ぎ文を参照パック方式へ更新。
- PowerShell構文チェックとフック実行で生成確認。

**変更ファイル**
- `AiLaunchers/Prepare-CodexMemory-Hook.ps1`
- `CodexMemory/README.md`
- `CodexMemory/Codex-Handoff.md`
- `CodexMemory/Codex-Reference-Pack.md`
- `CodexMemory/Codex-Attachment-Prompt.txt`
- `.codex/worklog.md`

**未解決事項**
- LM Studio/Codex本体の対話起動は未実行。
