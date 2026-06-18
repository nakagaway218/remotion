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

同期スクリプトは、このDriveフォルダ内のGoogle Sheetsを自動検出する。

| 管理表 | Spreadsheet ID | 用途 |
| --- | --- | --- |
| [[raw/youtube-reference-spreadsheet|AIエージェント参考YouTubeリスト]] | `1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8` | AIエージェント関連の参考YouTube |
| 記事参考リスト | `16Qhjwrp5Bli9XjsxIq5-CL3uZ8qOsRRrB-HekWxWrXg` | 記事・Google Docs系の参考素材 |
| 教材参考リスト | `1xT6af9MIfwJ8eH7y_b1TaZjvKrMv6MfiFDVOk8FSyE4` | 教材作成用の参考素材 |
| ツール参考リスト | `137WKPSoGzom4IXhhgvhsuwh3o3vh9JwmYkAEMKRlsOI` | ツール調査・制作の参考素材 |

## 見落とし防止

- 既定の読み取り範囲は `A1:Z1000`。
- 各Spreadsheetについて、ヘッダー数・データ行数・読み取り範囲を実行ログに出す。
- URL列が見つからない場合は警告を出す。
- 読み取り範囲の最終行までデータがある場合は、範囲外に行がある可能性として警告を出す。
- Google Sheets以外のDriveファイルも検出し、Google Docs、PDF、画像、動画、音声などは軽いDriveファイル索引の対象にする。
- Driveフォルダ自体は素材ではないため索引化しない。

## 退避済みコンテキスト

- [[reports/2026-06-16-source-index-sync-context/README|Source Index Sync Context]]
- Drive退避先: [2026-06-16 Source Index Sync Context Archive](https://docs.google.com/document/d/1NruOO5I7zxpRMQLkMP7vTE9K5E6YWR38OyEv_oOCM9Y)
- 用途: 長くなった作業文脈をGit側に抱え込みすぎず、Drive側に全文退避し、Vault側には入口だけ残す。

## 運用ルール

- `raw/webclip-index/` には軽い索引Markdownだけを置く。
- 記事本文の丸ごと保存、PDF、画像、動画、音声などはGoogle Drive側に置く。
- 有料記事、限定公開URL、個人情報、学校名、顧客名、生徒情報を含む素材は、GitHubに上げない前提で慎重に扱う。
- 必要になった素材だけ、要点を自分の言葉で `wiki/` に整理する。
