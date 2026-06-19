---
type: source_summary
status: 要約済み
date: 2026-06-19
summarized_at: 2026-06-19
source_type: tool
source_title: claude-skills-installer-ja
source_url: https://github.com/fuuuuuuma/claude-skills-installer-ja
source_index: raw/webclip-index/2026-06-19-tool-claude-skills-installer-ja.md
tags: [report, source-summary, tool, github, skills]
---

# claude-skills-installer-ja 要約

## 概要

AIエージェントに渡すことで、業務内容をヒアリングしながら必要なClaude Skillsを選び、Claude Code / Codex / Cursor などの正しいファイル構造に配置するためのカタログ兼インストーラ。skill本体を大量に同梱するリポジトリではなく、外部skillの出典、導入コマンド、配置先を管理し、導入時にエージェントが実在性と中身を確認する設計になっている。

## 主要ポイント

- 利用者はリポジトリURLをAIエージェントに渡し、業務に必要なSkillsの導入を依頼する。
- エージェントは作業環境と業務内容をヒアリングし、候補skillを3〜5個程度に絞って提案する。
- 非公式skillは中身を確認してから入れる手順が前提。
- `catalog/` に機械可読・人間可読のskillカタログがある。
- `profiles/` に企画、資料作成、文書、データ処理、開発などの業務別プリセットがある。
- 独自skillの実体も一部同梱されている。

## ObsidianSecondBrainへの反映候補

- `source-index-sync` や `middle-school-english-workbook` のような既存スキルを増やす前に、業務別に必要なskillを絞る参考にできる。
- 「全部入れる」のではなく、現在のワークフローに効くものを1つずつ試す方針が妥当。
- 非公式skillを入れる場合は、必ず `SKILL.md` の中身とファイル構造を確認してから使う。

## 注意点

- 外部skillは移動・改名・廃止される可能性があるため、導入時点で実体確認が必要。
- セキュリティ上、見知らぬskillを無条件に入れない。
- Codex環境で使う場合は、Claude Code向けの配置先をそのまま使えるとは限らない。

## 詳細確認

- [[reports/2026-06-19-claude-skills-installer-ja-deep-dive|claude-skills-installer-ja 詳細確認]]
