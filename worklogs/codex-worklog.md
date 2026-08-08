# Codex Work Log

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


## 2026-08-08 20:35

**依頼内容**
Outlook反映画面の「赤い行を入力」という不要になった案内を見直す。

**実施内容**
- 通常は手入力不要であることを案内に明記。
- 読み取り不完全な赤い行は安全表示として残し、手入力ではなく反映中止と再確認を案内。
- 水口校の必須項目チェックは誤登録防止のため維持。
- PowerShellスクリプトの構文と文字コードを確認。

**変更ファイル**
- Schedule/Local-Schedule-To-Outlook.ps1
- worklogs/codex-worklog.md

**未解決事項**
- なし。

## 2026-08-08 22:24

**依頼内容**
PDF読取に必要なツールを削除した可能性があるため、残存状況と復旧可否を調査する。

**実施内容**
- 予定表の起動ファイルと読取処理が参照する各ツールを確認。
- Ollama、Tesseract、PDF画像変換ツール、日本語OCRデータが残っていることを確認。
- Ollamaの登録モデル、モデル保存場所、ダウンロードフォルダー、予定表フォルダー、ごみ箱を確認。
- PDF画像読取モデル `qwen2.5vl:7b` だけが削除され、端末内に残っていないことを特定。

**変更ファイル**
- worklogs/codex-worklog.md

**未解決事項**
- `qwen2.5vl:7b` の再ダウンロードが必要。容量が大きいため、利用者の了承後に実施する。

## 2026-08-08 22:41

**依頼内容**
削除されていたPDF画像読取モデルを再ダウンロードし、予定表ツールを復旧する。

**実施内容**
- Ollamaへ `qwen2.5vl:7b`（約6GB）を再ダウンロード。
- 予定表ツールに設定されたモデル名と登録モデルが一致することを確認。
- ローカルで応答テストを行い、モデルが正常に起動・応答することを確認。
- Outlook予定表への書き込みは行っていない。

**変更ファイル**
- worklogs/codex-worklog.md

**未解決事項**
- なし。

## 2026-08-08 22:52

**依頼内容**
- 追加スケジュール読取時に表示された確認画面の理由を調査する。

**実施内容**
- 確認画面の表示条件とGit履歴を確認した。
- 確認一覧はローカル専用ツール導入時から存在し、未来の予定を読み取れた場合にOutlook反映前に表示される安全確認だと確認した。
- 今回は「赤い行を入力」という旧案内を通常の確認案内へ変更したため、画面が新しく見えた可能性が高いと整理した。
- PDF読取モデルの再ダウンロード自体が確認画面を追加したものではないことを確認した。
- ツール本体は変更していない。

**変更ファイル**
- `worklogs/codex-worklog.md`

**未解決事項**
- なし。

## 2026-08-08 23:10

**依頼内容**
- 読取不完全な行を赤表示して利用者に処理させず、ツール側で再確認した完成結果だけを確認画面に表示する。
- 公開差分に個人情報がないことを確認後、Gitへ反映する。

**実施内容**
- 水口校の必須項目が3段階の再読取後も確定できない場合、確認画面を開く前に停止するよう変更。
- 読取不完全な行の赤表示と手入力誘導を削除。
- Outlookへの書き込み前にも必須項目を再検査する防御処理を維持。
- ローカル処理と公開差分を確認し、予定PDF・PST・CSV・氏名・メールアドレス・認証情報を対象外とした。

**変更ファイル**
- `Schedule/Local-Schedule-To-Outlook.ps1`
- `worklogs/codex-worklog.md`

**未解決事項**
- 実際のPDFとOutlookを使う反映試験は、予定表を書き換えるため今回は実行していない。

## 2026-08-08
- 依頼内容: AI調査表記の統一。Webarticle / Scenariowriting の画面と説明文に残る Codex 表記を、将来の名称変更でも迷いにくい表記へ統一。
- 実施内容: 表示上の「Codex調査」を「AI調査」に変更し、プロンプトの宛先は「ChatGPT / Codex」として明示。内部キーや保存ファイル名は互換性維持のため変更なし。
- 変更ファイル: Webarticle/public/index.html, Webarticle/server.mjs, Webarticle/README.md, Webarticle/ANTIGRAVITY.md, Webarticle/WORKFLOWS.md, Webarticle/SKILL.md, Webarticle/AI_CONTEXT.md, Webarticle/AI_WORKFORCE.md, Scenariowriting/public/index.html, Scenariowriting/server.mjs, Scenariowriting/WORKFLOWS.md, Scenariowriting/SKILL.md, Scenariowriting/AI_CONTEXT.md, Scenariowriting/AI_WORKFORCE.md, Scenariowriting/WORKFORCE_SPEC.md
- 未解決事項: 起動ファイル名や内部の codex-research.md などは既存データとの互換性のため維持。

## 2026-08-08 23:31 - AI名称統一の追加調整
- 依頼内容: Webarticle / Scenariowriting の起動項目や手順に残る Codex 前提の名称を、将来の名称変更に強い表記へ統一する。
- 実施内容: 画面・プロンプト・手順書の表示名を「AI調査」中心に整理し、新規保存される調査メモ名を ai-research.md に変更。
- 変更ファイル: Webarticle と Scenariowriting の README / WORKFLOWS / SKILL / AI_CONTEXT / AI_WORKFORCE / RECOVERY_NOTE / public/index.html / server.mjs。
- 未解決事項: 内部変数名 codexResearch は既存データ互換のため残す。利用者画面には出さない。

## 2026-08-08 23:33:26 +09:00

- 依頼内容: Webarticle/Scenariowriting 内のAI名称統一の残確認と追加修正。
- 実施内容: Scenariowriting の手順説明に残っていた旧名称併記を、汎用的なAIツール表記へ統一。
- 変更ファイル: Scenariowriting/SKILL.md、worklogs/codex-worklog.md
- 未解決事項: なし。

## 2026-08-09 Codex / Claude Code 共有用の最小整備

- `docs/PROJECT_CONTEXT.md`、`docs/WORKFLOW.md`、`docs/DECISIONS.md` を追加し、AI 間で共有する概要・手順・判断の置き場を作成。
- `tasks/active/`、`tasks/paused/`、`tasks/done/` と各 README を追加し、タスクの現在地を Markdown で引き継げるように整理。
- `CLAUDE.md` を、詳細ルールを二重管理しない薄い参照入口として更新。
- 既存の Antigravity / RECOVERY 系メモを確認したが、確定できる途中放置タスクは見つからなかったため、推測で個別タスクは作成していない。

## 2026-08-09 会話圧縮前の情報整理

- 自動圧縮で細かな判断が落ちる可能性があるため、`docs/WORKFLOW.md` に圧縮前の Markdown 記録方針を追記。
- `docs/DECISIONS.md` に「チャット圧縮前に重要情報を Markdown に残す」判断を追記。
- `tasks/done/2026-08-09-ai-agent-shared-memory-setup.md` を追加し、今回の整備内容・判断・未着手事項・次の行動をタスク完了メモとして固定。
