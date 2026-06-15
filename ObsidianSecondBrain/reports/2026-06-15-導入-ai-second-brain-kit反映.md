---
type: 導入メモ
status: 完了
date: 2026-06-15
topic: ai-second-brain-kit
tags: [obsidian, second-brain, codex]
source_url: https://github.com/fuuuuuuma/ai-second-brain-kit
---

# ai-second-brain-kit 反映メモ

## 反映したこと

- Obsidian Vaultとして開けるフォルダ構造を `ObsidianSecondBrain/` に作った。
- `Memory.md` と `Home.md` を必須ファイルとして置いた。
- AIが毎回読むルールを `CLAUDE.md` と `AGENTS.md` に分けた。
- 修正指示、失敗防止、命名規則、週次点検を `rules/` に置いた。
- 日次、議事録、概念、出典、MOCの雛形を `templates/` に置いた。
- 初期MOCとして `wiki/moc/AI活用と学習設計.md` を作った。

## 元URLから取り入れた設計

- AIに読ませる起点として `Memory.md` と `Home.md` を持つ。
- `raw/` に素材を入れ、`wiki/` に整理済み知識を作る。
- 重要な答えは `reports/` に残す。
- 訂正や失敗をルールとして蓄積し、次回以降に活かす。
- Obsidianの `[[wikilink]]` とfrontmatterで、AIにも人間にも探しやすくする。

## このプロジェクト向けの調整

- ドメインを、AI活用・教育AI・教材作成・ツール制作・記事/台本制作に合わせた。
- 既存方針に合わせ、Obsidianの思考メモとGitHubに置く確定文脈を分ける前提を入れた。
- GitHubに載せる前の個人情報・顧客情報チェックをルールに入れた。

## 次の一歩

1. Obsidianで `ObsidianSecondBrain/` をVaultとして開く。
2. `daily/2026-06-15.md` に今日のメモを足す。
3. Web記事や思いつきメモを `raw/` に入れる。
4. Codexに「`raw/` を読んで `wiki/` に整理して」と依頼する。

