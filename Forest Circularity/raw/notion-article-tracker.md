---
type: external_index
status: active
date: 2026-07-20
storage: notion
title: 記事案件・進捗
database_url: https://app.notion.com/p/5ce31ece9ac74a2589e0ca27c90266b4
database_id: 5ce31ece9ac74a2589e0ca27c90266b4
data_source_url: collection://8bcfc52f-220a-45d2-85b0-168c0f8fb097
tags: [raw, notion, article-tracker]
---

# Notion 記事案件・進捗

Codexで作成した、記事案件と進捗だけを管理するNotionデータベース。

## 管理する項目

- Name
- Status
- Progress
- Deadline
- Zotero Key
- Obsidian Path
- Source URL
- Article Type
- Article Summary

## 方針

本文、引用、研究メモはObsidianに残す。Notionには案件化したものの状態と、記事の狙いが分かる短い要約だけを送る。

## Notionに送ってよいもの

- 記事案タイトル
- 進捗
- 締切
- 起点になったObsidianノート
- Zotero key
- 記事タイプ
- Article Summary: 1〜2文の短い記事要約

## Notionに送らないもの

- 文献の詳細要約
- 引用候補
- 自分の解釈の全文
- 関連ノートの本文
- PDFや原典本文

## ローカル同期で使う値

`.env` などの未追跡ファイルに設定する。

```powershell
$env:NOTION_DATABASE_ID = "5ce31ece9ac74a2589e0ca27c90266b4"
```
