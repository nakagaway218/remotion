# Markdown文脈粒度 棚卸メモ

日付: 2026-06-15

## 相談内容

ユーザーから、これまでの `C:\Users\nakag\Desktop\GitHub` 配下のタスクで、Markdownファイルを無理に圧縮してしまったものがないか確認したい、という相談があった。

確認基準は次の2点。

- 次回のAIや人間が必要な粒度で読み分けられること
- 長い文脈は分割して連携すること

## 確認範囲

主に次の領域を確認した。

- `Myownproject/`
- `MyProject/`
- `特典_AIインスタマーケ会社テンプレート/`

`Myownproject/packages/` と `packages/docs/` 配下のRemotion公式ドキュメントは、今回の「チャット文脈の圧縮」問題とは性質が違うため、重点確認から外した。

## 確認方法

- `git status --short --branch` で作業状態を確認
- `rg --files` で対象Markdownを一覧化
- 行数、見出し数、`未解決`、`引き継ぎ`、`context`、`コンテキスト`、`要確認` などの語を含むファイルを重点確認
- 長大な単一Markdownと、AI文脈・引き継ぎ系Markdownを優先して確認

## 結論

`Myownproject` 内のAI社員化、サブエージェント化、文脈保存関連ファイルについては、現時点で「無理に1ファイルへ圧縮してしまった」と判断するものは見つからなかった。

理由:

- `AIWorkforceTemplate/` は、判断ガイド、既存タスクAI社員化、チャット文脈保存ルールに分かれている
- `CareerAIProject/` は、固定コンテキストの `CONTEXT.md` と会話ログの `chat_logs/` が分かれている
- `Webarticle/`、`Scenariowriting/`、`Mytool/`、`teaching materials/` は、`AI_WORKFORCE.md` と `WORKFORCE_SPEC.md` に分かれている
- 多くのプロジェクトで `handoff.md` を作る前提が明記されている

## 注意が必要な候補

| ファイル | 状態 | 判断 |
| --- | --- | --- |
| `MyProject/google_io_2026_complete_guide.md` | 約1774行の長大な単一ガイド | チャット文脈というより完成資料。ただし再利用するなら章別分割が望ましい |
| `Myownproject/google-antigravity-2-guide-ja/README.md` | 約356行の要約版 | 1テーマのガイドとしては許容範囲。章が増えるなら分割候補 |
| `Myownproject/CareerAIProject/CONTEXT.md` | 約287行の固定コンテキスト | 長めだが、`chat_logs/` と分離済みなので現時点では許容 |
| `Myownproject/Rikei_Kokkoritsu_Juken_Learner/RECOVERED_LEARNER_CHAT_NOTES.md` | 約101行の復元メモ | 復元要点として妥当。今後増えるなら `handoff.md` と `unresolved.md` へ分割 |

## 現時点で分割不要と判断したもの

- `AIWorkforceTemplate/04_判断ガイド/README.md`
- `AIWorkforceTemplate/05_チャット文脈保存/README.md`
- `AIWorkforceTemplate/05_チャット文脈保存/2026-06-15_ai-workforce-judgment-consultation.md`
- `ShoppingList/AI_WORKFORCE.md`
- `Webarticle/AI_WORKFORCE.md`
- `Scenariowriting/AI_WORKFORCE.md`
- `Mytool/AI_WORKFORCE.md`
- `teaching materials/AI_WORKFORCE.md`
- `CareerAIProject/chat_logs/2026-06-14_ai-career-gpts.md`

これらは、現状では1ファイル内のテーマが比較的一貫している。

## 今後の運用

長いMarkdownが出てきた場合は、次の基準で分割する。

1. 200行を超え、複数テーマを含む場合は分割候補にする
2. 相談ログ、固定コンテキスト、実作業ルール、未解決事項を同じファイルに詰め込みすぎない
3. 固定方針は `AI_CONTEXT.md`、`DESIGN.md`、`SKILL.md`、または各プロジェクトの `AI_WORKFORCE.md` に反映する
4. 日付付きの相談ログは `chat_logs/` または `05_チャット文脈保存/` に残す
5. 次回作業者が最初に読むものは `handoff.md` に分ける
6. まだ決めきれない事項は `unresolved.md` に分ける

## 次に分割するなら

優先候補は `MyProject/google_io_2026_complete_guide.md`。

ただし、このファイルは `Myownproject` の外にあるため、編集や移動を行う場合は別途ユーザー確認が必要。

分割案:

```text
MyProject/google_io_2026/
  README.md
  00_overview.md
  01_models.md
  02_agents.md
  03_antigravity.md
  04_workspace.md
  05_android_xr.md
  06_video_and_media.md
  sources.md
  unresolved.md
```

## 未解決事項

- `MyProject/google_io_2026_complete_guide.md` を実際に分割するかは未決定
- `Myownproject` 外のファイルをGit管理対象にするかどうかも未決定
- 今回は棚卸メモの作成までとし、外部フォルダの編集は行っていない
