---
type: external_workflow
status: draft
date: 2026-07-20
source: zotero
knowledge_center: obsidian
project_tracker: notion
tags: [raw, zotero, obsidian, notion]
---

# Zotero -> Obsidian -> Notion 自動化

## 役割分担

- Zotero: 論文、PDF、書誌情報、引用キーの管理。
- Obsidian: 研究知識の中心。文献ノート、概念ノート、問い、仮説、記事素材を育てる。
- Notion: 記事案件、進捗、締切、公開状態だけを管理する。
- Codex: Zoteroの書誌エクスポートを読み、Obsidianノートを作り、必要な進捗だけNotionへ送る。

## 推奨フロー

1. ZoteroでBetter BibTeXを有効にし、コレクションをCSL JSONまたはBetter CSL JSONとして自動エクスポートする。
2. `ZOTERO_BBT_EXPORT_PATH` にそのJSONファイルのパスを設定する。まずは `C:\Users\nakag\Documents\Obsidian Vault\zotero-export.json` を使う。
3. `OBSIDIAN_VAULT_PATH` にObsidian vaultのパスを設定する。
4. `scripts/sync-zotero-obsidian-notion.ps1` を実行して、文献ごとのMarkdownノートを作る。
5. 記事化するものだけ、Obsidianノートのfrontmatterで `article_status` や `notion_sync` を設定する。
6. Notionへ送る段階で `NOTION_TOKEN` と `NOTION_DATABASE_ID` を設定し、Notion同期を有効にする。

## 自動化

- Zotero側の再エクスポートはBetter BibTeXの自動エクスポートに任せる。
- Codex側は定期実行で同期スクリプトを走らせ、新しい文献ノートだけを追加する。
- 新規文献がない場合は報告しない。

## Obsidianに残すもの

- 文献の要点
- 引用したい箇所
- 自分の解釈
- 関連する概念ノート
- 記事化できそうな切り口

## Notionに送るもの

- タイトル
- 引用キー
- 記事ステータス
- 進捗
- 締切
- Obsidianノートへのパス

Notionには研究本文を入れない。案件と進捗だけに絞る。
