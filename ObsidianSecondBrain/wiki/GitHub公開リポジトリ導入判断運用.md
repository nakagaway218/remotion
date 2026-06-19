---
type: concept
status: active
date: 2026-06-19
topic: GitHub公開リポジトリ導入判断運用
tags: [github, automation, source-index, tool-review]
---

# GitHub公開リポジトリ導入判断運用

公開GitHubリポジトリは、リンクを保存するだけでなく、導入してよいかを確認してから扱う。

## 基本方針

`ツール参考リスト` などに公開GitHub URLを貼った場合、Codexは次の順番で進める。

1. `raw/webclip-index/` に索引を作る。
2. `scripts/review-github-repo-source.ps1` で公開repoを確認する。
3. `reports/github-repo-reviews/` に導入判断レポートを作る。
4. 必要なら追加で主要ファイルを読む。
5. 導入するか、保留するか、既存運用に移植するかを判断する。

## 何を見るか

- README
- AGENTS.md
- package.json
- ルートファイル一覧
- GitHubの説明、更新日、ライセンス、stars、issues
- 導入コマンド
- `curl | sh`、`Invoke-Expression`、`rm -rf`、`git reset --hard` などの注意サイン

## やらないこと

リンクを見つけただけで、次のことはしない。

- 外部コードを実行する
- パッケージをインストールする
- pluginやskillを入れる
- secretsやtokenを渡す
- 既存ファイルを上書きする

## private repoとの違い

公開repoは、URLだけでREADMEや主要ファイルを読める。

private repoは、URLを知っていても権限がないと中身を読めない。ブラウザのシークレットウィンドウで開いて中身が見えなければ、private repo、削除済み、またはURL間違いの可能性がある。

## このVaultでの置き場所

- 素材索引: [[raw/webclip-index/README]]
- 導入判断レポート: [[reports/github-repo-reviews/README]]
- 改善の引き継ぎ: [[reports/2026-06-19-github-source-review-automation-handoff]]

## 判断の原則

- 便利そうでも、すぐ導入しない。
- 既存のCodexスキル、Google Drive連携、ローカルスクリプトで足りるなら導入しない。
- Claude Code向けのskillは、Codexにそのまま入れるのではなく、必要な考え方だけを `AGENTS.md`、`.codex/`、`wiki/`、`reports/` に移す。
- 自動判断は一次判断。最終判断は用途・安全性・重複の確認後に行う。
