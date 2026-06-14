# Scenariowriting AI Workforce

`Scenariowriting` 用の AI 社員設計です。

共通テンプレートは `../AIWorkforceTemplate/` を参照します。このファイルでは、YouTube 台本やシナリオ制作に必要な役割だけを切り出して使います。

## 目的

- YouTube 台本制作を、企画、調査、構成、台本、対話化、レビュー、記録に分ける
- 参照動画、 transcript、商品情報、ターゲットを混ぜずに管理する
- Codex で調査・構成・チェックを行い、手動プロンプト転送を標準にする
- NotebookLM や API 自動化は任意にする

## Scenariowriting の AI 社員

| 順番 | AI 社員 | 元の汎用役割 | 担当 |
| --- | --- | --- | --- |
| 1 | 台本要件編集者 | `@requirements-architect` | 目的、尺、視聴者、成果物形式、確認点を整理 |
| 2 | 企画・市場リサーチャー | `@researcher` | 参考動画、競合、視聴者ニーズ、素材を整理 |
| 3 | 構成プロデューサー | `@planner` | 冒頭、あらすじ、章立て、CTA、流れを設計 |
| 4 | 台本ライター | `@creator` | ナレーション、会話文、シーン指示を作成 |
| 5 | 対話化・自然化担当 | `@creator` | transcript や説明文を自然な会話・台本に直す |
| 6 | 台本レビュー担当 | `@reviewer` | 目的回収、尺、矛盾、視聴維持、リスク表現を確認 |
| 7 | 納品整形・記録係 | `@formatter` / `@archivist` | Word、Excel、Markdown、引き継ぎ形式に整える |

## 標準フロー

```text
台本要件編集者
  -> 企画・市場リサーチャー
  -> 構成プロデューサー
  -> 台本ライター
  -> 対話化・自然化担当
  -> 台本レビュー担当
  -> 納品整形・記録係
```

小さい修正では、`台本ライター -> 台本レビュー担当 -> 納品整形・記録係` だけで進めます。

## 入力

- 作りたい動画テーマ
- 想定視聴者
- 尺、媒体、トーン
- 参考動画、 transcript、メモ
- 商品やサービス情報
- 手動で取得した ChatGPT / NotebookLM / 外部サービスの出力

## 出力

- 要件メモ
- 参考資料メモ
- あらすじ
- 章立て
- 台本
- 対話形式の台本
- レビュー結果
- 納品用 Word / Excel / Markdown 向け本文
- 引き継ぎメモ

## 保存方針

推奨保存先:

```text
Scenariowriting/
  script-projects/
    [project-name]/
      requirements.md
      research.md
      synopsis.md
      outline.md
      draft.md
      dialogue.md
      review.md
      final.md
      handoff.md
```

既存の保存構成がある場合は、既存構成を優先します。

## 人間に確認するポイント

- 企画の方向性
- 参考動画や情報ソースの採用範囲
- あらすじ
- 台本前の構成
- 納品形式
- 最終表現

## 禁止事項

- 参考動画の文章を丸写ししない
- 情報ソースの種類を混ぜて根拠不明にしない
- 未確認の数値や実績を断定しない
- 手動プロンプト転送で足りる作業を API 必須にしない
- 案件固有の秘密情報や個人情報を GitHub に含めない
