---
type: source_summary
status: 要約済み
date: 2026-07-03
source_type: youtube
source: [[raw/webclip-index/2026-07-03-youtube-20260613-claudecode勉強会]]
tags: [youtube, claude-code, proposal, workflow]
---

# ClaudeCode勉強会 2026-06-13 / 店舗改善提案書

## 要約

- 店舗の複数資料をClaude Codeに渡して、現状分析と改善提案書を作る実演。
- 入力素材は、店舗情報、メニュー、売上メモ、SNS状況、口コミ、店主の悩みなど。
- 最初に `genjou_bunseki.md` のような現状分析やSWOTを作り、そこから改善策や提案書へ展開する。
- 重要なのは、AIに断片的な依頼をするより、関連ファイルをまとめて渡し、文脈を増やすこと。
- GitHubは履歴管理、ObsidianはMarkdownの検索と整理に向いている、という運用面の話も含む。

## 自分の運用への反映

- このリポジトリの `raw/`、`reports/`、`wiki/` 分離は、店舗改善提案のような複数素材ワークフローにそのまま使える。
- 実務案件では、素材そのものをGitに入れず、索引と要約だけGitに残すほうが安全。
- 提案書作成では、最初に「素材一覧」「不足情報」「仮説」を作ってから成果物に進むとよい。

## 注意点

- 店舗や顧客の実データは機密になりやすい。
- AIのSWOTや改善案は仮説であり、現場確認や顧客ヒアリングで検証する必要がある。
