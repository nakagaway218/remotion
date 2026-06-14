# GPTs Conversation Log: AI Career Guidance

日付: 2026-06-14

元のやり取り: 「あなたのAIキャリアを導く君」というGPTsでの相談内容。

## 主な結論

- 最初からChatGPT、Claude、Geminiすべてに課金する必要はない。
- 最初の1から2か月は ChatGPT Plus だけで十分。
- 案件化の目処が立ってから Claude Pro を追加するのが現実的。
- Gemini Advanced は Google Workspace 連携が必要になった段階で検討する。
- NotebookLM は教育業界特化の知識ベースとして有望。
- 重要なのはツール契約数ではなく、教育現場でAIを使ってどんな成果が出たかという事例。

## ツール導入の段階

### レベル1

- ChatGPT Plus
- 月20ドル前後
- 教材作成、指導案作成、プロンプト開発、AI活用研究に使う

### レベル2

- ChatGPT Plus
- Claude Pro
- 月40ドル前後
- 長文資料の読解、教材改善、論理構造整理、文章の自然さ改善に使う

### レベル3

- ChatGPT Plus
- Claude Pro
- Gemini Advanced
- 月60ドル前後
- 教育AIコンサルとして本格運用する段階

## NotebookLM の位置づけ

教育業界特化なら、NotebookLM は重要な武器になる。

読み込ませる候補:

- 学習指導要領
- 入試問題
- 自作教材
- 論文
- 参考書

用途:

- 専属アシスタント化
- 教材研究
- 資料要約
- 知識ベース化

## 成果事例として蓄積すべきもの

- 教材作成時間が3時間から30分になった
- 小論文添削時間が半減した
- 学習計画作成が効率化した
- 生徒ごとの弱点診断が速くなった
- 教材の改善サイクルが短くなった

## Codex での保存方針

GPTsから提案された保存方法:

1. Markdownファイルとして保存する
2. プロジェクト専用の `CONTEXT.md` を作る
3. 会話ログをそのまま保存する

今回の反映では、次の二段構成にした。

- `CareerAIProject/CONTEXT.md`: 要約された固定コンテキスト
- `CareerAIProject/chat_logs/2026-06-14_ai-career-gpts.md`: 会話ログの要点

## CONTEXT.md に入れる固定情報

- INTP-T
- 博士号
- 学振経験
- 教材開発
- 教育支援
- AI業務改善コンサル志向
- 教育AIストラテジストという軸

## 今後の派生ファイル候補

- `BUSINESS_PLAN.md`
- `SERVICE_MENU.md`
- `TARGET_CUSTOMERS.md`
- `ROADMAP_2026.md`
- `PROMPTS.md`

## Codex に渡すプロンプト例

```text
まず CareerAIProject/CONTEXT.md を読んでください。
その前提で、教育AIストラテジストとしての次の行動計画を整理してください。
```
