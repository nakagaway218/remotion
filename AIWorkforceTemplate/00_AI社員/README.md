# AI社員 名簿

このフォルダは、人間が読むための役割カードです。

Claude Code が実際に読む技術定義は `.claude/agents/` にあります。

| # | 役割 | 呼び出し名 | 主な成果物 |
| --- | --- | --- | --- |
| 1 | 要件定義担当 | `@requirements-architect` | `WORKFORCE_SPEC.md`、確認事項 |
| 2 | 調査担当 | `@researcher` | 調査メモ、材料リスト、出典メモ |
| 3 | 構成担当 | `@planner` | アウトライン、工程表、作業分解 |
| 4 | 作成担当 | `@creator` | 本文、台本、問題、README、手順書 |
| 5 | レビュー担当 | `@reviewer` | 指摘リスト、修正提案、品質判定 |
| 6 | 整形担当 | `@formatter` | 納品形式、表、Markdown整形、ファイル整理 |
| 7 | 記録担当 | `@archivist` | 引き継ぎ、未解決事項、履歴 |

## 使い分け

- 何を作るか曖昧なら `@requirements-architect`
- 材料集めが必要なら `@researcher`
- いきなり書くと崩れそうなら `@planner`
- 作るものが明確なら `@creator`
- 失敗や抜けを減らしたいなら `@reviewer`
- 納品形式を整えたいなら `@formatter`
- 後で再開したいなら `@archivist`
