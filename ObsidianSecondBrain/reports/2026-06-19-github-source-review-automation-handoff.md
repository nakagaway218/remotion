---
type: handoff
status: active
date: 2026-06-19
topic: 公開GitHubリポジトリ導入判断の自動化
tags: [github, source-index, automation, tool-review, handoff]
---

# 公開GitHubリポジトリ導入判断の自動化 引き継ぎ

今回の改善は、Google SheetsやGoogle Driveから取り込んだ公開GitHubリポジトリURLについて、索引作成だけで止めず、導入判断レポートまで進めるためのもの。

## 目的

`ツール参考リスト` などに `https://github.com/owner/repo` 形式の公開GitHub URLを貼ったとき、次回以降の自動確認で次の処理まで進める。

1. `raw/webclip-index/` に軽い索引を作る。
2. 公開GitHubリポジトリの中身を確認する。
3. README、AGENTS.md、package.json、ルートファイル、GitHubメタ情報を確認する。
4. 危険な導入コマンドや破壊的操作のサインを検出する。
5. `reports/github-repo-reviews/` に導入判断レポートを作る。
6. 必要ならCodexが追加で主要ファイルを読み、既存機能で代替できるかを判断する。

## 追加・更新したファイル

- [[scripts/review-github-repo-source.ps1]]
  - `raw/webclip-index/` 内のGitHub URLを検出し、導入判断レポートを作る。
- [[scripts/README]]
  - 公開GitHubリポジトリ導入判断スクリプトの使い方を追記。
- [[raw/webclip-index/README]]
  - GitHub URLの扱いを追記。
- [[raw/google-drive-source]]
  - Drive/Sheets同期後にGitHub導入判断へ進める方針を追記。
- [[reports/github-repo-reviews/README]]
  - GitHub導入判断レポート置き場の入口。
- [[wiki/GitHub公開リポジトリ導入判断運用]]
  - 今後の運用ルール。

## スクリプト

実行:

```powershell
pwsh -File .\scripts\review-github-repo-source.ps1
```

確認だけ:

```powershell
pwsh -File .\scripts\review-github-repo-source.ps1 -DryRun
```

GitHub APIの未認証アクセスは回数制限がある。必要な場合だけ、読み取り用の `GITHUB_TOKEN` を環境変数に入れる。

```powershell
$env:GITHUB_TOKEN = "GitHubの読み取り用トークン"
```

## 自動確認への反映

Codex automation `youtube` は、名称を `素材リスト同期確認` に変更し、プロンプトに公開GitHubリポジトリ確認を追加した。

今後の自動確認では、公開GitHubリポジトリURLを含む索引が新規作成された場合、`scripts/review-github-repo-source.ps1` を実行し、`reports/github-repo-reviews/` に導入判断Markdownを作る。

## 対象

対象:

- `https://github.com/owner/repo` 形式の公開リポジトリ
- READMEが公開されているリポジトリ
- AGENTS.md、package.jsonなどが公開されている場合はそれも確認対象

対象外:

- private repo
- ログインしないと見られないリポジトリ
- GitHub以外の配布ページ
- `issues`、`pull`、`releases` など個別ページだけのURL

## 導入判断の安全方針

自動で行うのは、調査と判断レポート作成まで。

次は自動では行わない。

- 外部コードの実行
- `npm install`、`pip install` などのパッケージ導入
- pluginやskillのインストール
- `curl | sh` や `Invoke-Expression` の実行
- 破壊的なgit操作

導入が必要な場合は、レポートを見てから明示的に判断する。

## 既存例

`fuuuuuuma/claude-skills-installer-ja` について、次のレポートを作成済み。

- [[reports/github-repo-reviews/2026-06-19-github-fuuuuuuma-claude-skills-installer-ja]]
- [[reports/2026-06-19-claude-skills-installer-ja-deep-dive]]
- [[reports/source-summaries/2026-06-19-tool-claude-skills-installer-ja]]

## 判断結果の読み方

`decision` は一次判断。

| decision | 意味 |
| --- | --- |
| `manual-review-required` | 注意サインあり。導入前に追加確認が必要。 |
| `candidate-with-conditions` | 候補にはなるが、用途一致と重複確認が必要。 |
| `hold-as-reference` | 参考情報として保留。すぐ導入しない。 |

## 今後の作業者への注意

- レポートに危険サインが出ても、それだけで悪いリポジトリとは限らない。インストール手順やサンプルに削除コマンドがあるだけの場合もある。
- 逆に危険サインが出なくても安全確定ではない。自動検査は一次確認にすぎない。
- Codexで使う場合は、Claude Code向けのskillやpluginをそのまま入れるのではなく、既存のCodexスキル、`AGENTS.md`、`.codex/`、`wiki/` へ必要部分だけ移植する判断を優先する。
- private repoや認証必須のrepoは、この運用だけでは読めない。
- API連携スクリプトはPowerShell 7（`pwsh`）で実行し、Windows PowerShell 5の `powershell.exe` を経由させない。
