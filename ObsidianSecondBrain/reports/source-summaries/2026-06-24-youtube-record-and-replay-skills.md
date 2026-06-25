---
type: source_summary
status: 要約済み
date: 2026-06-24
source_type: youtube
source: [[raw/webclip-index/2026-06-24-youtube-record-and-replay-skills]]
tags: [youtube, codex, record-and-replay, skills]
---

# Codex Record & Replayで画面操作をスキル化する

## 要約

- CodexのRecord & Replayは、作業を一度画面録画で見せ、その流れを検査・編集可能なSkillに変換する機能として紹介されている。
- 例として、YouTube Studioへの非公開アップロード手順を録画し、後から `/skill-creator` でスキル化している。
- 一度作ったスキルはそのまま完成品と考えず、実行時に出た確認漏れ、チャンネル指定、Chrome拡張の権限などを追記して改善する。
- Computer UseやChrome操作と組み合わせることで、ブラウザ操作、ファイル選択、フォーム入力を含む反復作業を自動化できる。
- スキル化に向くのは、毎回ほぼ同じ手順で、人間が確認すべきポイントを明示できる作業。

## 自分の運用への反映

- スプレッドシート整備、Drive素材登録、GitHub公開リポジトリ確認などの定型作業は、録画ベースでスキル化候補になる。
- ただし外部送信、アップロード、公開、削除を含む操作は確認ステップを必ず残す。
- 作ったスキルの修正履歴は、このVaultでは `rules/mistakes.md` または `reports/` に残すと再利用しやすい。

## 注意点

- 動画時点ではMac優先の説明が含まれており、Windows環境では提供状況や手順が異なる可能性がある。
- 録画だけで意図が完全に伝わるわけではないため、目的、除外条件、確認条件をテキストで補足する必要がある。
