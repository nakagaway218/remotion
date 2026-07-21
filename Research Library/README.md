# Research Library

このフォルダは、複数の媒体で共通して使うZotero文献データの置き場所です。

## 役割

- Zotero: 文献そのものの管理場所
- Research Library: Zoteroから自動エクスポートされた共通データの保存場所
- Forest Circularity: 記事化・Obsidianメモ・Notion進捗管理の作業場所

## Zoteroから保存するファイル

Better BibTeXの自動エクスポートは、次の場所に保存します。

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-export.json
```

このZoteroエクスポート本体はローカル運用データとして扱い、Gitには入れません。

LaTeX用のBibTeXファイルを使う場合は、同じフォルダに保存します。

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-library.bib
```

BibTeXファイルも同様にローカル運用データとして扱います。

## 媒体ごとの使い方

Forest Circularityなど媒体ごとのフォルダは、この共通Zoteroデータを読み、必要な文献だけをObsidianノートやNotion案件にします。

## CodexからObsidianノートを作る

Codexでは次を実行します。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\run-zotero-obsidian-sync.ps1"
```

既定では次の場所にObsidian向けノートを作ります。

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\outputs\obsidian-zotero-notes\00_sources\zotero
```

このフォルダは、Obsidianで新しいvaultとして開くか、必要なノートだけ既存vaultへ移します。
