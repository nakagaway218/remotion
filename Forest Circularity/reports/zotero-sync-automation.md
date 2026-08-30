# Zotero 同期自動化メモ

作成日: 2026-07-20

## 自動化する範囲

Zoteroに文献を追加した後の流れを、以下のように自動化する。

1. Zotero側: Better BibTeXの自動エクスポートで `zotero-export.json` を更新する。
2. Codex側: 定期実行で `scripts/run-zotero-obsidian-sync.ps1` を走らせる。
3. 既存のMarkdown文献ノートは上書きしない。
4. 新しい文献だけ `outputs/obsidian-zotero-notes/` にMarkdown化する。
5. 新しい文献がなければ報告しない。
6. 記事化候補が見つかった場合だけ、短く報告する。

## Zotero側の設定

ZoteroにBetter BibTeXを入れ、対象ライブラリまたはコレクションを自動エクスポートする。

保存先:

```text
C:\Users\nakag\Documents\Obsidian Vault\zotero-export.json
```

形式:

```text
Better CSL JSON
```

## Codex側の実行コマンド

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\nakag\Desktop\GitHub\Myownproject\Forest Circularity\scripts\run-zotero-obsidian-sync.ps1"
```

## Codex定期実行

- automation id: `zotero-obsidian`
- 実行頻度: 毎日朝
- 通知: 失敗時のみ
- 新規文献がない場合は報告しない。

## Notionへ送る条件

Notionへ自動で全文は送らない。

送ってよいもの:

- 記事案タイトル
- 進捗
- 締切
- 起点になったObsidianノート
- Zotero key
- Article Summary

記事化候補の判断が必要な場合は、Codexが候補を報告し、ユーザー確認後にNotionへ送る。
