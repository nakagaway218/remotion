---
type: index
status: active
date: 2026-06-15
topic: Web clip index
tags: [raw, webclip, index]
---

# Web Clip Index

Google Driveに保存した重い素材への軽い索引を置くフォルダです。

## 書くもの

- 元URL
- タイトル
- 保存日
- 保存理由
- Google Drive上の保存先
- 短い要点メモ
- 公開GitHubリポジトリの場合は、導入判断レポートへのリンク

## 書かないもの

- 記事本文の丸ごとコピー
- 大量の引用
- PDF、画像、動画、音声などの重いファイル
- 個人情報や公開すべきでない情報

## GitHubリポジトリURLの扱い

`https://github.com/owner/repo` 形式の公開リポジトリは、索引化後に `scripts/review-github-repo-source.ps1` で `reports/github-repo-reviews/` へ導入判断レポートを作る。

判断対象:

- README
- AGENTS.md
- package.json
- ルートファイル一覧
- GitHub上の更新状況、ライセンス、stars、issues
- 危険な導入コマンドや破壊的操作の記述

GitHubのリンクだけでも一次確認はできる。ただし、private repo、ログイン必須ページ、GitHub以外の配布ページは別途認証や手動確認が必要。

## テンプレート

```md
---
type: source
status: 未整理
date: YYYY-MM-DD
source_type: article
url:
drive_url:
tags: []
---

# タイトル

## 保存理由

-

## 要点メモ

-

## 次に整理するなら

- [[wiki/関連ノート]]
```
