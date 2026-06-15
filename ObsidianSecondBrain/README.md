# Obsidian Second Brain

このフォルダは、Obsidianを「考えをためる場所」にしつつ、Codexにも読みやすい形で前提・判断基準・修正履歴を残すためのVault雛形です。

## 位置づけ

- 元にした考え方: [fuuuuuuma/ai-second-brain-kit](https://github.com/fuuuuuuma/ai-second-brain-kit)
- 反映日: 2026-06-15
- 用途: AI活用、教育AI、教材作成、ツール制作、記事・台本制作のための第二の脳
- 使うAI: Codexを主に想定し、Claude Codeなども読める構成

## 使い方

1. Obsidianでこの `ObsidianSecondBrain/` フォルダをVaultとして開く。
2. 最初に [[Home]] と [[Memory]] を確認する。
3. 考え中の素材やWebメモは `raw/` に入れる。
4. AIに「`raw/` を読んで `wiki/` に整理して」と頼む。
5. 重要な答えや判断は `reports/` に残す。
6. 「次からこうしてほしい」と思った指示は `rules/corrections.md` に蓄積する。

## フォルダの意味

| 場所 | 役割 |
|---|---|
| `Memory.md` | ユーザーの前提・判断基準・進行中のこと |
| `Home.md` | Vaultの玄関 |
| `raw/` | 素材置き場。AIは原則として削除・改名しない |
| `wiki/` | AIが構造化した知識 |
| `wiki/moc/` | テーマ別の地図 |
| `reports/` | 調査結果・判断・回答 |
| `daily/` | 日々のメモ |
| `outputs/` | 公開・提出する成果物 |
| `rules/` | 運用ルール、修正指示、失敗防止 |
| `templates/` | ノート雛形 |

## 運用ルール

- Obsidian側で思考を育て、Codexに読ませたい確定情報はMarkdownとして残す。
- `raw/` は入力素材なので、整理済みの知識と混ぜない。
- 細かいフォルダ分類より、frontmatter、命名、`[[wikilink]]` でつなぐ。
- 古くなった情報は消す前に、`rules/lint.md` の観点で洗い出して確認する。

