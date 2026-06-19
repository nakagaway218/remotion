---
type: github_repo_review
status: auto-reviewed
date: 2026-06-19
repo: fuuuuuuma/claude-skills-installer-ja
source_url: https://github.com/fuuuuuuma/claude-skills-installer-ja
source_index: raw/webclip-index/2026-06-19-tool-claude-skills-installer-ja.md
decision: manual-review-required
tags: [report, github, tool-review]
---

# fuuuuuuma/claude-skills-installer-ja adoption review

## Decision

**Decision: manual-review-required**

Automated checks found risk signals. Review the actual files before installing or executing anything.

## Repository metadata

- GitHub: https://github.com/fuuuuuuma/claude-skills-installer-ja
- Description: AIエージェントに渡すと業務をヒアリングしながら必要なClaude Skillsを正しいファイル構造へ自動配置するカタログ＋インストーラ（72選ベース・計70件）
- Default branch: main
- License: NOASSERTION
- Stars: 3
- Forks: 2
- Open issues: 0
- Last pushed: 2026-06-03T06:43:24Z
- Source index: [2026-06-19-tool-claude-skills-installer-ja.md](raw/webclip-index/2026-06-19-tool-claude-skills-installer-ja.md)

## Install or integration signals

- AI agent, skill, plugin, or MCP reference

## Risk signals

- recursive delete command

## Root files

- .gitignore
- AGENTS.md
- catalog
- install
- LICENSE
- profiles
- README.md
- skills

## README excerpt

~~~text
# Claude Skills Installer（カタログ＋自動インストーラ）

**このリポジトリのURLをAIエージェントに渡して「業務に必要な Skills を入れて」と言うだけ。**
エージェントが業務をヒアリングし、必要な skill だけを選び、あなたの環境（Claude Code / Codex / Cursor）の
**正しいファイル構造**へ自動配置します。

> ⚠️ このリポジトリは「skill 本体の倉庫」ではなく **カタログ＋導入手順書** です。
> 72選の多くは他者の外部リポジトリにあるため、**出典へのリンク＋導入コマンド**で管理し、
> 導入時にエージェントが実在と中身を確認してから配置します。あなたが権利を持つ独自 skill 5件だけは実体を同梱しています。

---

## 使い方（30秒）

お使いのAIエージェント（Claude Code など）に、こう言ってください：

```
このリポジトリの AGENTS.md に従って、私の業務に必要な Claude Skills を入れて。
まず私の作業環境とよくやる業務を質問して、必要なものだけ正しい場所に配置してください。
（このリポジトリのURL）
```

するとエージェントが [`AGENTS.md`](AGENTS.md) の手順に沿って：

1. **環境判定** — `.claude/` などを読み、Claude Code か Codex か Cursor かを判定
2. **業務ヒアリング** — 「主な業務は？」「毎日いちばん繰り返す作業は？」「開発者？」を質問
3. **候補提示** — 業務に合う skill を3〜5個（公式/非公式の別つき）で提案
4. **セキュリティ確認** — 非公式 skill は実在と中身を確認。怪しければ入れない
5. **配置** — 選んだ skill を `~/.claude/skills/<name>/` などへ配置し、構造を見せる
6. **報告** — 入れたもの／入れなかったもの／育て方

「全部入れる」ものではありません。**各カテゴリから1つ、まず1個**から。

---

## リポジトリ構成

```
.
├── README.md                  ← いまここ（人間向け）
├── AGENTS.md                  ← インストーラの頭脳（エージェントが従う手順0〜7）
├── catalog/
│   ├── skills.json            ← 機械可読カタログ（全skillのメタデータ・出典・導入コマンド・配置先）
│   └── catalog.md             ← 人間可読カタログ（カテゴリ別の一覧表）
├── profiles/                  ← 業務別プリセット束
│   ├── planning.md            ← 企画・壁打ち
│   ├── docs-creation.md       ← 資料作成
│   ├── writing.md             ← 文書・記事
│   ├── data.md                ← データ処理
│   └── dev-baseline.md        ← コード開発の安全装置
├── skills/                    ← 独自・同梱skillの実体（このrepoが配布元）
│   ├── planning-sprint/SKILL.md
│   ├── document-processor/SKILL.md
│   ├── research-to-writing/SKILL.md
│   ├── mtg-notes/SKILL.md
│   └── read-invoices/SKILL.md
└── install/
    └── install.md             ← 環境別の配置先（Claude Code / Codex / Cursor）
```

---

## Skills とは

skill とは **`SKILL.md` ファイルが入ったフォルダ**のこと。「特定の作業をどうやるか」が手順・制約・例・テンプレートとして
書かれていて、一度入れれば毎回説明し直す必要がなくなります。Claude Code はこれを設計者・レビュアー・デバッガー・
ドキュメントライターを兼ねた「開発チーム」のように使えます。

収録は **計70件**（カテゴリ別。出典記事「Claude Skills 72選」をベースに重複を整理し、独自・同梱5件を含む）。
内訳と各 skill の詳細は [`catalog/catalog.md`](catalog/catalog.md) を参照。

---

## 収録カテゴリ

| カテゴリ | 例 |
|---|---|
| メタ（作る/探す） | Skill Creator / Write a Skill / Find Skills |
| 企画・設計 | Brainstorming / Grill Me
... (truncated)
~~~

## AGENTS.md excerpt

~~~text
# AGENTS.md — Skills オンボーディング・インストーラ（エージェント向け指示書）

> **これを読んでいるAIエージェントへ。**
> ユーザーがこのリポジトリのリンクを渡して「自分の業務に必要な Skills を入れて」と言ったら、
> **このファイルの手順0〜7をそのまま実行**してください。勝手に全部入れず、必ずヒアリングして必要なものだけを、
> ユーザーの環境に合った**正しいファイル構造**へ配置します。

---

## このリポジトリは何か

- **カタログ＋インストーラ**です。skill 本体の多くは [`catalog/skills.json`](catalog/skills.json) の `source`（外部GitHub）にあります。
- `skills/` 配下の5件だけは**実体を同梱**（このリポジトリが配布元）。
- あなたの仕事は「ユーザーに質問 → 必要 skill を選定 → 安全確認 → 正しい場所へ配置 → 報告」。

---

## 手順0. まずカタログを読む

1. [`catalog/skills.json`](catalog/skills.json) を読み込む（全 skill のメタデータ）。
2. `disclaimer` と `known_renames` を必ず確認する。
   **出典記事の skill 名と実リポジトリのフォルダ名がズレている**ものがある（例: `write-a-prd`→`to-prd`、`prd-to-issues`→`to-issues`、`triage-issue`→`triage`、`request-refactor-plan`→廃止/`diagnose`・`zoom-out`）。
3. 困ったら [`catalog/catalog.md`](catalog/catalog.md)（人間可読版）も参照。

---

## 手順1. 環境判定（どこに置くか決める）

ユーザーの作業ディレクトリを調べ、どのエージェント環境かを判定する。判定材料：

| 見つかったもの | 環境 | skill の置き場所 |
|---|---|---|
| `~/.claude/` または `<project>/.claude/` | **Claude Code** | ユーザー全体: `~/.claude/skills/<id>/`<br>プロジェクト: `<project>/.claude/skills/<id>/` |
| `AGENTS.md` 階層 / `.codex/` | **Codex (OpenAI)** | [`install/install.md`](install/install.md) 参照 |
| `.cursor/` | **Cu
... (truncated)
~~~

## package.json excerpt

~~~json
package.json was not found.
~~~

## Follow-up checks

- Before adoption, inspect the exact install commands in README or docs.
- If scripts, .github/workflows, or shell installers exist, inspect them directly.
- Do not adopt it if existing Codex skills, Google Drive integration, or local workflow files already cover the same need.
