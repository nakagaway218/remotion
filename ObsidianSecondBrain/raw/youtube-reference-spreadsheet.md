---
type: external_index
status: active
date: 2026-06-15
storage: google_sheets
title: AIエージェント参考YouTubeリスト
spreadsheet_id: 1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8
spreadsheet_url: https://docs.google.com/spreadsheets/d/1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8/edit?usp=sharing
tags: [raw, youtube, google-sheets, ai-agent]
---

# AIエージェント参考YouTubeリスト

このノートは、AIエージェント関連の参考YouTubeを管理するGoogle Sheetsの登録メモです。

## 役割

- Google Sheets側: YouTube動画の一覧、URL、視聴状況、要点、優先度を管理する。
- Google Drive側: 必要に応じて動画から作ったメモ、文字起こし、関連PDFなどの重い素材を保存する。
- このVault側: 重要な動画だけ `raw/webclip-index/` に軽い索引を作り、整理済み知識は `wiki/` に昇格する。

## スプレッドシート

- タイトル: AIエージェント参考YouTubeリスト
- URL: [AIエージェント参考YouTubeリスト](https://docs.google.com/spreadsheets/d/1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8/edit?usp=sharing)
- Spreadsheet ID: `1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8`

## おすすめ列

まだ列が固まっていない場合は、次の列を基本にする。

| 列名 | 用途 |
| --- | --- |
| title | 動画タイトル |
| url | YouTube URL |
| channel | チャンネル名 |
| theme | 主題 |
| priority | 優先度 |
| status | 未視聴 / 視聴中 / 整理済み |
| key_points | 要点 |
| action | 自分のプロジェクトに反映すること |
| drive_url | 関連メモや文字起こしのDrive保存先 |
| wiki_link | 整理後のVault内ノート |

## 運用ルール

- まず1本から登録してよい。
- スプレッドシートは一覧管理、Vaultは知識化・判断保存に使う。
- 動画の文字起こし全文や長い引用はVaultに直接入れず、必要ならGoogle Drive側に置く。
- 重要な動画だけ `raw/webclip-index/` に個別索引を作る。

