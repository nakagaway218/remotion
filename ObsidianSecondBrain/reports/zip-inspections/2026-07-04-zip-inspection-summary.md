---
type: zip_inspection_summary
status: reviewed
date: 2026-07-04
tags: [report, zip, drive, source-review]
---

# 2026-07-04 Zip素材確認まとめ

## 確認したZip

- [[reports/zip-inspections/2026-07-04-zip-seo-media-autopilot-skill|seo-media-autopilot.skill]]
- [[reports/zip-inspections/2026-07-04-zip-x-client-pull-post-maker-zip|x-client-pull-post-maker.zip]]
- [[reports/zip-inspections/2026-07-04-zip-ai秘書-20260704t044530z-3-001-zip|AI秘書-20260704T044530Z-3-001.zip]]
- [[reports/zip-inspections/2026-07-04-zip-ai秘書-n1-ai-employee-nested|AI秘書 / n1-ai-employee nested zip]]

## 結論

3件とも、少なくとも一覧上は実行ファイルや危険なパストラバーサル疑いは見つからなかった。

ただし、外部から来たスキル素材なので、インストールや実行はまだしない。まずは `reports/` の要約として読み、既存運用に取り込める考え方だけを採用する。

## 各素材の判断

### seo-media-autopilot.skill

- 中身: SEOオウンドメディア記事作成を、ヒアリング、キーワード、競合分析、一次情報、構成、執筆、品質確認、入稿、公開後分析へ分けるスキル。
- 読めた主なファイル: `SKILL.md`, `hearing.md`, `setup-checklist.md`, `quality-gate.md`, `agents.md`
- 使えそうな点:
  - 初心者向けに1問ずつヒアリングする設計。
  - 一次情報を捏造しない、順位保証しない、公開は人間承認を残すという安全ルール。
  - 95点以上を公開候補にする品質ゲート。
- 注意:
  - WordPress入稿や公開自動化は、権限・API・人間承認を分けて扱う必要がある。
  - このままインストールするより、`Webarticle` や既存のCodex調査ワークフローと統合するほうが安全。

### x-client-pull-post-maker.zip

- 中身: Xで案件相談につながる投稿を、実績・ノウハウ・ポートフォリオ・プロフィール・顧客の声・仕事観に分けて作るスキル。
- 読めた主なファイル: `SKILL.md`, `post-types.md`, `openai.yaml`
- 使えそうな点:
  - 7:2:1 の投稿配分。価値提供7、証拠・実績2、人柄1。
  - 煽りや強い売り込みを避け、相談につながる信頼形成を重視。
  - 実績や数字を盛らず、証拠が弱い場合はノウハウ投稿に変換するルール。
- 注意:
  - SNS運用素材としては有用だが、クライアント名・実績・数字を扱う場合は公開前確認が必要。

### AI秘書 / n1-ai-employee

- 中身: AI社員・AI秘書・週報・議事録・営業CS・人事・経理・業務棚卸し・スライド作成まで含む大きな業務運用スキル。
- 読めた主なファイル: 入れ子Zip内の `SKILL.md` とファイル一覧。
- 使えそうな点:
  - AI社員を「役割、入力、判断基準、出力、頻度、人間承認点のある反復業務システム」として扱う考え方。
  - 朝ブリーフ、夜レビュー、週報、業務棚卸しは、ユーザーのAI社員化構想と相性がよい。
  - 送信、削除、購入、予約、外部提出などは人間承認を必須にするルールが明確。
- 注意:
  - 範囲が広いので、そのまま全部導入すると運用が重くなる。
  - まずは `daily-secretary-briefing`、`weekly-report`、`process-inventory` の3領域だけを読むのがよい。

## 次の読み込み優先度

1. `n1-ai-employee/references/daily-secretary-briefing.md`
2. `n1-ai-employee/references/weekly-report.md`
3. `n1-ai-employee/references/process-inventory.md`
4. `seo-media-autopilot/references/quality-gate.md`
5. `x-client-pull-post-maker/references/post-types.md`

## 運用ルール

- Zip本体と展開物はGitに入れない。
- Gitに残すのは、Zip検査レポート、判断メモ、要約だけ。
- 外部スキルのインストールや実行は、内容確認とユーザー承認後にする。
- 実行可能ファイルやスクリプトが含まれるZipは、一覧化しても実行しない。
