---
type: context-log
status: active
date: 2026-06-16
topic: Source index sync workflow
tags: [context, source-index-sync, google-drive, google-sheets, automation, skill]
archive_url: https://docs.google.com/document/d/1NruOO5I7zxpRMQLkMP7vTE9K5E6YWR38OyEv_oOCM9Y
---

# Source Index Sync Context

Google Drive、Google Sheets、ObsidianSecondBrain、Codex automation、Codex skillを使って、重い素材を外部に置き、Git管理側には軽い索引だけを残す運用を作った記録。

詳細コンテキストはGoogle Driveへ退避済み。このVault側には、入口と再開に必要な最小情報だけを残す。

## Drive退避先

- [2026-06-16 Source Index Sync Context Archive](https://docs.google.com/document/d/1NruOO5I7zxpRMQLkMP7vTE9K5E6YWR38OyEv_oOCM9Y)

## 背景

最初の相談は、ObsidianSecondBrain内にYouTubeや記事URLを直接貼ってよいか、というものだった。

その後、Web Clipperで保存した素材は容量が大きくなりやすいため、Git管理フォルダに本文やPDFを直接入れず、Google DriveやGoogle Sheetsを外部素材管理に使う方針へ移った。

## ゴール

- 重い素材はGoogle Driveに置く。
- YouTube一覧はGoogle Sheetsで管理する。
- このVaultには軽いMarkdown索引だけを残す。
- 整理済み知識は `wiki/` に昇格する。
- AIの判断や調査結果は `reports/` に残す。
- 定期確認はオートメーション化する。
- 新情報がない場合は報告しない。
- 同じ運用を他Workspaceにも展開できるよう、Codex skill化する。

## 退避した詳細

Drive側には、次の内容を全文で保存している。

- `README.md`
- `decisions.md`
- `current-state.md`
- `automation.md`
- `skillization.md`
- `next-actions.md`

## 再開時に見る場所

- Drive詳細: [2026-06-16 Source Index Sync Context Archive](https://docs.google.com/document/d/1NruOO5I7zxpRMQLkMP7vTE9K5E6YWR38OyEv_oOCM9Y)
- 外部Drive登録: [[raw/google-drive-source]]
- YouTube管理表登録: [[raw/youtube-reference-spreadsheet]]
- 軽い索引置き場: [[raw/webclip-index/README]]
- 同期スクリプト: `scripts/sync-youtube-sheet-index.ps1`
- 再利用スキル: `C:\Users\nakag\.codex\skills\source-index-sync\SKILL.md`
