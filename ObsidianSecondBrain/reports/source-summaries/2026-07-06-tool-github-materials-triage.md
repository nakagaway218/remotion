---
type: source_summary
status: triaged
date: 2026-07-06
source_type: tool_batch
tags: [tool, github, claude-code, workflow, duplicate-triage]
---

# 2026-07-06 ツール参考リスト追加分 / GitHub導入判断メモ

## 対象

- [[raw/webclip-index/2026-07-06-tool-claudecode-channel-20260626]]
- [[raw/webclip-index/2026-07-06-tool-claudecode-channel-20260622]]
- [[raw/webclip-index/2026-07-06-tool-claude-code-dynamic-workflows-guide-cc]]

## 読めたもの

- [[reports/github-repo-reviews/2026-07-06-github-chaaaaarin-claudecode-channel-20260626]]
  - AquaVoice向けの音声入力後処理プロンプトや、Codex long-running系の素材。
  - 判定: `candidate-with-conditions`。既存の音声入力・Transcript運用と近いが、話し言葉の熱量を残す編集方針は参考になる。
- [[reports/github-repo-reviews/2026-07-06-github-chaaaaarin-claudecode-channel-20260622]]
  - Claude Designの概要、デザイン同期、スライド/onepager系資料。
  - 判定: `candidate-with-conditions`。現時点ではCodex側のGoogle Drive/Docs/Slides運用と重なるため、読む資料として扱う。
- [[reports/github-repo-reviews/2026-07-06-github-fuuuuuuma-claude-code-dynamic-workflows-guide-cc]]
  - Claude Code Dynamic Workflowsの非公式ガイド。大量サブエージェント、ワークフロー、プロンプト/Skills集の説明。
  - 判定: `manual-review-required`。credential関連語があり、内容も公式仕様の変化を受けやすい。

## 統合方針

- Dynamic Workflows系は、すぐ導入せず、[[wiki/GitHub公開リポジトリ導入判断運用]] と既存のAI社員化判断に統合する。
- 音声入力後処理プロンプトは、YouTube Transcriptや自分の発話メモの整形ルールとして一部採用候補。ただし自動要約とは別物として扱う。
- Claude Design素材は、デザイン制作・スライド制作の参考に留める。現時点で新しいローカル導入はしない。

## 注意点

- 外部コード、HTML、スクリプト、ワークフローは実行しない。
- Claude/Opus/Dynamic Workflows/Designの仕様や名称は変化しやすい。実運用に入れる前に公式情報で確認する。
- 既存のCodexプラグイン、Google Drive連携、`ObsidianSecondBrain` 運用で代替できるものは、新規ツール導入を増やさない。
