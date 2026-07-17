---
type: source_summary
status: 整理済み
date: 2026-07-17
source_date: 2026-07-16
source_type: tool
topic: Claude Code Webサイト制作ループ
tags: [summary, tool, github, claude-code, website, workflow]
---

# Claude Code Website Builder JA 導入判断メモ

## 参照元

- YouTube索引: [[raw/webclip-index/2026-07-16-youtube-保存版-外注なら30万のwebサイト-claudecodeで誰でも簡単に作る方法を徹底解説します-fable5|【保存版】外注なら30万のWebサイト、ClaudeCodeで誰でも簡単に作る方法を徹底解説します【Fable5】]]
- ツール索引: [[raw/webclip-index/2026-07-16-tool-claude-code-website-builder-ja|claude-code-website-builder-ja]]
- GitHubレビュー: [[reports/github-repo-reviews/2026-07-17-github-fuuuuuuma-claude-code-website-builder-ja|fuuuuuuma/claude-code-website-builder-ja 導入判断]]
- GitHub: https://github.com/fuuuuuuma/claude-code-website-builder-ja

## 導入判断

現時点では「参考として採用」。外部コードの導入や実行はしない。

理由は次の通り。

- GitHubレビュー上、強い危険信号は出ていない。
- `package.json` と `AGENTS.md` は見つからず、導入コマンドや依存関係の前提は追加確認が必要。
- READMEはWebサイト制作のループ運用に関する実務ノウハウが中心で、既存のCodex運用にも考え方として取り込める。
- ただし、リポジトリ内の `kit` やHTMLファイルの具体的な中身、ライセンス、利用条件はまだ精査しきっていない。

## 要点

- Webサイト制作は一発生成ではなく、作成、評価、修正のループで品質を上げる。
- 成功条件を曖昧な「良い感じ」にしない。点数、チェックリスト、必須機能、参考サイトとの差分など、評価基準を具体化する。
- 見た目だけでなく、ボタン、リンク、フォーム、遷移先、問い合わせ先など、実際に動く部分を確認する。
- Claude CodeやCodexに任せる場合も、途中で人間がレビューする。特に公開、問い合わせフォーム、課金、外部連携、顧客情報に触れる部分は自動実行しない。
- サイトは詰め込みすぎない。1ページ1目的から始める方が品質管理しやすい。

## このプロジェクトへの反映

- Webサイト制作依頼では、最初に「目的」「読者」「必須セクション」「参考サイト」「禁止事項」「公開してよい範囲」を確認する。
- 生成後は、見た目のスクリーンショット確認だけでなく、操作できる要素の動作確認まで行う。
- GitHubやZipで配布されるWeb制作キットは、まず `reports/github-repo-reviews/` または `reports/zip-inspections/` に安全確認と導入判断を残す。
- 既存の `sites` やローカルHTML/CSS運用で足りる場合は、外部キットを導入しない。

## 既存メモとの重複判断

- [[reports/source-summaries/2026-07-12-youtube-codex-websites-work-batch|2026-07-12 YouTube追加分 / Codex・ChatGPT Work・Web制作 横断要約]] とテーマが重なる。
- 既存メモはWeb制作全般とChatGPT Workの横断整理。
- 今回は公開GitHubリポジトリ `claude-code-website-builder-ja` の導入判断と、ループ型Web制作の確認観点に焦点を絞るため、別メモとして残す。

## 次に深掘りするなら

- GitHubリポジトリ内の `kit` とHTMLファイルの中身を、外部コードを実行せずに読む。
- ライセンスが明示されているか確認する。
- 既存のCodex/Sites運用に追加すべきチェックリストだけを `wiki/` に抽出する。
