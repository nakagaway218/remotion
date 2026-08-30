---
type: external_storage
status: active
date: 2026-07-21
storage: local_research_library
folder_name: Research Library
folder_path: C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero
tags: [raw, zotero, external-storage]
---

# Research Library Zotero連携

## 役割

- `Research Library`: Zoteroから自動エクスポートされた共通文献データを置く。
- `Forest Circularity`: 共通文献データを読み、媒体用のObsidianノートとNotion記事案件に整理する。

## 読み込み元

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-export.json
```

## LaTeX用BibTeX

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-library.bib
```

## 運用メモ

ZoteroのBetter BibTeXでは、Better CSL JSONの自動エクスポート先を上記の`zotero-export.json`にする。
Forest Circularity側の同期スクリプトは、このJSONを読んで新規文献だけMarkdownノート化する。
