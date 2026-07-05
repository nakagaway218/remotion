---
type: github_repo_review
status: auto-reviewed
date: 2026-07-05
repo: smotoDays/AI_blog-post01
source_url: https://github.com/smotoDays/AI_blog-post01
source_index: raw/webclip-index/2026-07-04-tool-crowdworks-pipeline-スキル.md
decision: candidate-with-conditions
tags: [report, github, tool-review]
---

# smotoDays/AI_blog-post01 adoption review

## Decision

**Decision: candidate-with-conditions**

The repository appears relevant to installation or integration, and no strong risk signal was found in the checked files. Confirm fit before trial use.

## Repository metadata

- GitHub: https://github.com/smotoDays/AI_blog-post01
- Description: 
- Default branch: main
- License: not detected
- Stars: 0
- Forks: 0
- Open issues: 0
- Last pushed: 05/31/2026 06:32:03
- Source index: [2026-07-04-tool-crowdworks-pipeline-スキル.md](raw/webclip-index/2026-07-04-tool-crowdworks-pipeline-スキル.md)

## Install or integration signals

- AI agent, skill, plugin, or MCP reference

## Risk signals

- No strong risk signal detected by this script.

## Root files

- assets
- README.md
- references
- SKILL.md

## README excerpt

~~~text
# crowdworks-pipeline スキル（配布版）

クラウドワークスのライティング案件を **探す → 応募 → 執筆 → 納品** まで通しで支援する
Claude Code スキルです。AI臭を避けた人間らしい文章づくりと、安全な役割分担（ログイン・
送信は人間）を組み込んでいます。

## 中身

```
crowdworks-pipeline/
├── SKILL.md                       … スキル本体（全体フロー・起動条件・安全原則）
├── README.md                      … このファイル
├── assets/
│   └── agent-org-chart.png        … 9体エージェントの組織図
└── references/
    ├── phase1-apply.md            … 案件リサーチ→応募 の詳細手順
    ├── phase2-write.md            … 執筆→納品 の詳細手順
    ├── proposal-template.md       … 応募文テンプレート
    ├── ai-smell-guide.md          … AI臭を防ぐ言い換えガイド
    └── agents.md                  … 9体エージェント設計・組織図
```

## 導入方法（Claude Code）

1. この `crowdworks-pipeline` フォルダを、スキル置き場にコピーします
   - 自分用：`~/.claude/skills/crowdworks-pipeline/`
   - プロジェクト用：`<プロジェクト>/.claude/skills/crowdworks-pipeline/`
2. Claude Code を開き直すと、スキルが読み込まれます
3. 「クラウドワークスの案件を探して」「ライティング案件に応募したい」
   「受注した記事を書いて納品まで」などで起動します

## 使い方のイメージ

- **フェーズ単独でもOK**：応募だけ／執筆だけ でも使えます
- **安全第一**：ログイン・応募の送信・納品の最終提出は、必ず人間が確認して実行します

## 注意

- ブラウザ操作には Claude in Chrome 拡張が必要です
- 機微情報（口座・本人確認書類など）はスキル・AIが入力しません
~~~

## AGENTS.md excerpt

~~~text
AGENTS.md was not found.
~~~

## package.json excerpt

~~~json
package.json was not found.
~~~

## Follow-up checks

- Before adoption, inspect the exact install commands in README or docs.
- If scripts, .github/workflows, or shell installers exist, inspect them directly.
- Do not adopt it if existing Codex skills, Google Drive integration, or local workflow files already cover the same need.
