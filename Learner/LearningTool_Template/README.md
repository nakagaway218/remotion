# LearningTool Template

新しい学習ツールを作るためのテンプレートです。

Learnerを第1号モデルとして、次の学習ツールを作るときに使う共通構成をまとめています。

## 想定する使い方

1. `LearningTool_Template` フォルダをコピーします。
2. コピー先のフォルダ名を新しいツール名に変えます。
3. `TOOL_BRIEF.md` に、対象者・科目・目的・入力・出力を書きます。
4. `Template_Index.html` と `Template_Mobile.html` のタイトルやStepを新ツール用に調整します。
5. `AI_CONTEXT.md`、`SKILL.md`、`WORKFLOWS.md` を新ツール用に更新します。
6. 必要に応じて配布zipを作ります。

## 基本方針

- 最初はAPIなしの手動コピー連携にする。
- ChatGPT / Claude / Gemini のどれでも使える形にする。
- PC版とスマホ版を分ける。
- 配布時に迷わないよう、入口ファイルを少なくする。
- 参考資料や外部ファイル連携は、必要性が固まるまで入れない。
- API連携は、手動版で価値が確認できてから別版として検討する。

## 同梱ファイル

- `TOOL_BRIEF.md`: 新ツールの設計メモ。
- `Template_Index.html`: PC版HTMLの雛形。
- `Template_Mobile.html`: スマホ版HTMLの雛形。
- `Template_Start.cmd`: Windows PC向け起動ファイル。
- `README_FOR_USERS.md`: PC利用者向け説明。
- `README_FOR_MOBILE_USERS.md`: スマホ利用者向け説明。
- `AI_CONTEXT.md`: サブエージェント用の状況説明。
- `SKILL.md`: 保守時の作業ルール。
- `WORKFLOWS.md`: 主要ワークフロー。
- `SUBAGENT_PROMPT.md`: Codexサブエージェントへ渡す指示文。

## サブエージェント化

新しい学習ツールごとに、`AI_CONTEXT.md`、`SKILL.md`、`WORKFLOWS.md`、`SUBAGENT_PROMPT.md` を整えることで、Codexのサブエージェントへ作業を渡しやすくします。

たとえば、次のように依頼できます。

```text
LearningTool_Template/SUBAGENT_PROMPT.md を読み、このテンプレートをもとに英単語確認ツールを作ってください。
```

