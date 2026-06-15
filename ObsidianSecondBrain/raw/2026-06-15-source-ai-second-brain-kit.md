---
type: 出典
status: 処理済み
date: 2026-06-15
topic: ai-second-brain-kit
tags: [source, obsidian, second-brain]
source_url: https://github.com/fuuuuuuma/ai-second-brain-kit
---

# fuuuuuuma/ai-second-brain-kit

## 概要

AIエージェントに渡すことで、Obsidian Vault向けの第二の脳構造を作るためのMarkdownキット。

## 取り入れた要素

- `Memory.md` と `Home.md` を最初に置く。
- `CLAUDE.md` と `AGENTS.md` でAI向けルールを明示する。
- `raw/`、`wiki/`、`reports/`、`daily/`、`outputs/` を役割別に分ける。
- 修正指示、失敗防止、命名規則、週次lintを `rules/` で管理する。
- Obsidian向けにfrontmatter、wikilink、MOCを使う。

## このVaultでの扱い

元リポジトリを丸ごと複製するのではなく、ユーザーの `Myownproject` 運用に合わせた実用雛形として再構成した。

