# SETUP_AGENT.md — Antigravity プロジェクト初期化指示書

> **このファイルの使い方（人間向け・10秒）**
> このリポジトリを丸ごと AI エージェント（Google Antigravity の `agy` / Desktop App、または Claude Code・Cursor などの任意のコーディングエージェント）に渡し、こう頼んでください：
>
> ```
> SETUP_AGENT.md を読んで、その指示どおりに Antigravity 用のフォルダ構造をこのリポジトリに作って
> ```
>
> エージェントは以下の指示に従い、**Antigravity 専用の最小プロジェクト構造**を自動生成します。

---

## エージェントへの指示（ここから下はエージェントが実行する）

あなたはこのリポジトリを **Google Antigravity 2.0** で使えるプロジェクトに整える初期化エージェントです。
以下を **そのとおりに・過不足なく** 実行してください。Antigravity 固有の構造のみを作り、旧 Gemini 系（`GEMINI.md` / `.gemini/`）は作らないでください。

### 実行ルール

1. **冪等に動くこと** — 既に存在するファイル／ディレクトリは**上書きせず温存**し、無い物だけ新規作成する。最後に「作成した物 / 既存だった物」を一覧で報告する。
2. このリポジトリのルート（`README.md` がある階層）を基準に作成する。
3. 文字コードは UTF-8、改行は LF。
4. 生成後、`AGENTS.md` の冒頭3行をユーザーに見せ、「プロジェクト名・使用モデル・報告言語」を必要なら直すよう促す。

### 作成するフォルダ構造（これだけ）

```
.
├── AGENTS.md                          # ルートのエージェント規約（旧 GEMINI.md の後継）
└── .agents/
    └── skills/
        └── example-skill/
            └── SKILL.md               # 動作確認用のサンプル skill（最小雛形）
```

> ⚠️ ここに無いファイルは作らないこと。`.gemini/`・`GEMINI.md`・`node_modules`・各種設定ファイルは**生成対象外**。

---

### ① ルートに `AGENTS.md` を作成（無ければ）

以下を中身として作成する（プレースホルダは `<…>` のまま残してよい。ユーザーが後で埋める前提）：

```markdown
# AGENTS.md

> このプロジェクトで Antigravity のエージェントが従う規約。平易な言葉で書く。
> 旧 `GEMINI.md` の後継ファイル。

## プロジェクト概要

- 名称: <プロジェクト名をここに>
- 目的: <このリポジトリで何を作る/解説するか>

## 既定の振る舞い

- 報告・コメントは **日本語** で行う（コード内の変数・技術用語は英語）。
- 既定モデル: `gemini-3.5-flash`（速度重視）。正確性が要る作業は Claude 系に切り替えてよい。
- 取り消せない操作（削除・上書き・push・外部送信）の前は必ず確認を取る。

## スキル

- プロジェクト固有のスキルは `.agents/skills/<skill-name>/SKILL.md` に置く。
- サンプルは `.agents/skills/example-skill/SKILL.md` を参照。
```

### ② `.agents/skills/` ディレクトリを作成（無ければ）

空でよい。Antigravity はここを走査してプロジェクト固有スキルを読み込む（旧 `.gemini/skills/` の後継）。

### ③ サンプル skill `.agents/skills/example-skill/SKILL.md` を作成（無ければ）

以下を中身として作成する：

```markdown
---
name: example-skill
description: 動作確認用のサンプルスキル。Antigravity がこのプロジェクトの .agents/skills/ を正しく読み込めているか確かめるための雛形。実際のスキルを作るときはこのファイルを複製して書き換える。
---

# example-skill

これはサンプルです。エージェントがこの skill を認識できたら、Antigravity のスキル読み込みは正常です。

## 使い方

このディレクトリ（`.agents/skills/example-skill/`）を複製し、`name` / `description` と本文を
実際のスキルの内容に置き換えてください。
```

---

### 完了後の報告フォーマット

実行が終わったら、次の形式で短く報告する：

```
✅ Antigravity 構造を初期化しました
作成: AGENTS.md / .agents/skills/example-skill/SKILL.md
既存（温存）: <あれば列挙、無ければ「なし」>
次の一手: AGENTS.md の「プロジェクト名・目的」を埋めてください
```

> 📌 補足: Gemini CLI から移行中のプロジェクトでは、別途 `GEMINI.md → AGENTS.md` のリネームと
> `.gemini/skills/ → .agents/skills/` の移動が必要です（本資料 README §6-7 を参照）。
> この初期化指示書は**新規の最小構造を作る**ためのもので、移行作業は対象外です。
