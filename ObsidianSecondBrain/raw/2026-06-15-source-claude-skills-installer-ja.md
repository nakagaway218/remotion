---
type: 出典
status: 処理済み
date: 2026-06-15
topic: Skills installer
tags: [source, skills, codex, claude-code]
source_title: fuuuuuuma/claude-skills-installer-ja
source_url: https://github.com/fuuuuuuma/claude-skills-installer-ja
---

# fuuuuuuma/claude-skills-installer-ja

## 概要

Claude Skillsを業務別に選び、必要なものだけを正しい場所へ配置するためのカタログ兼インストーラ。

## 構成

- `README.md`: 人間向け説明
- `AGENTS.md`: エージェントが従う導入手順
- `catalog/skills.json`: 機械可読のskillカタログ
- `catalog/catalog.md`: 人間可読の一覧
- `profiles/`: 業務別プリセット
- `skills/`: 同梱skill 5件
- `install/install.md`: Claude Code / Codex / Cursor別の配置方針

## 取り入れる要点

- skillは全部入れず、業務ヒアリング後に3〜5個だけ候補提示する。
- まず1個入れて使い、効果を確認してから増やす。
- 非公式skillは導入前に実在、`SKILL.md`、中身、ライセンス、危険な操作を確認する。
- 出典記事時点の名称や導入コマンドは古くなるので、実リポジトリの現在のフォルダ名を確認する。
- CodexではClaude Codeの `~/.claude/skills/` にそのまま入れるのではなく、`AGENTS.md`、`SKILL.md`、またはCodex skill/pluginとして移植する。

## このVaultでの扱い

全文や全カタログは取り込まず、`reports/2026-06-15-運用メモ-Skills導入判断.md` にCodex向けの判断ルールとして要約した。

