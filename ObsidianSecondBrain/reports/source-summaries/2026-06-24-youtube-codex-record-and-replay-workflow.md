---
type: source_summary
status: 要約済み
date: 2026-06-24
source_type: youtube
source: [[raw/webclip-index/2026-06-24-youtube-codex-record-and-replay-workflow]]
tags: [youtube, codex, record-and-replay, workflow-automation]
---

# Record & Replayの実用ワークフロー例

## 要約

- CodexのRecord & Replayで、画面録画から作業スキルを作る流れを紹介している。
- 単純例として、デスクトップに連番フォルダを作り、右上に整理する作業を録画し、指定数だけ再現するスキルにしている。
- 実用例として、Webサイトの全体スクリーンショット取得、XアナリティクスのCSVとスクリーンショット収集、Substack記事の別サービス移行、Notta動画アーカイブから文字起こし・目次・共有リンクを集める作業が挙げられている。
- うまくスキル化するには、録画だけでなく、目的、抽象化したい変数、保存先、必ず使う機能をテキストで補足する必要がある。
- ログイン済みブラウザやデスクトップ操作が絡む作業ではComputer Useが有効。

## 自分の運用への反映

- Google Drive素材確認、スプレッドシート入力補助、GitHub公開リポジトリ調査などは、Record & Replay化の候補。
- ただし、Git操作、外部送信、共有リンク発行、削除などは自動実行せず、人間確認を残す。
- 再現性がある作業は、まず小さく録画し、実行ログから失敗パターンを `rules/mistakes.md` に残す。

## 注意点

- 外部サイトの操作はUI変更やログイン状態に依存する。
- 画面録画に個人情報やAPIキーが映り込む可能性があるため、録画対象は事前に整理する。
