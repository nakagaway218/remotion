---
type: external_storage
status: active
date: 2026-06-15
storage: google_drive
folder_name: ObsidianSecondBrain
folder_id: 1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz
folder_url: https://drive.google.com/drive/folders/1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz
tags: [raw, google-drive, external-storage]
---

# Google Drive raw保存先

このノートは、重い素材をGit管理フォルダに直接入れないための外部保存先メモです。

## 役割

- Google Drive側: Web Clipper本文、PDF、画像、添付ファイルなどの重い素材を置く。
- このVault側: `raw/webclip-index/` にURL、タイトル、保存理由、Drive上の場所だけを残す。
- 整理済み知識: 自分の言葉で整理して `wiki/` に昇格する。
- 調査や判断: AIの回答や調査結果として `reports/` に残す。

## 保存先

- Driveフォルダ: [ObsidianSecondBrain](https://drive.google.com/drive/folders/1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz)
- Folder ID: `1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz`

## 連携している管理表

- [[raw/youtube-reference-spreadsheet|AIエージェント参考YouTubeリスト]]
- Spreadsheet ID: `1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8`
- 用途: AIエージェント関連の参考YouTubeを一覧管理し、API経由で `raw/webclip-index/` に軽い索引Markdownを作る。

## 退避済みコンテキスト

- [[reports/2026-06-16-source-index-sync-context/README|Source Index Sync Context]]
- Drive退避先: [2026-06-16 Source Index Sync Context Archive](https://docs.google.com/document/d/1NruOO5I7zxpRMQLkMP7vTE9K5E6YWR38OyEv_oOCM9Y)
- 用途: 長くなった作業文脈をGit側に抱え込みすぎず、Drive側に全文退避し、Vault側には入口だけ残す。

## 運用ルール

- `raw/webclip-index/` には軽い索引Markdownだけを置く。
- 記事本文の丸ごと保存、PDF、画像、動画、音声などはGoogle Drive側に置く。
- 有料記事、限定公開URL、個人情報、学校名、顧客名、生徒情報を含む素材は、GitHubに上げない前提で慎重に扱う。
- 必要になった素材だけ、要点を自分の言葉で `wiki/` に整理する。
