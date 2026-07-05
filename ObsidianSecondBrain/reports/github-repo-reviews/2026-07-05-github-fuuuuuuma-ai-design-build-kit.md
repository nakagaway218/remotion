---
type: github_repo_review
status: auto-reviewed
date: 2026-07-05
repo: fuuuuuuma/ai-design-build-kit
source_url: https://github.com/fuuuuuuma/ai-design-build-kit
source_index: raw/webclip-index/2026-07-04-tool-ai-design-build-kit.md
decision: manual-review-required
tags: [report, github, tool-review]
---

# fuuuuuuma/ai-design-build-kit adoption review

## Decision

**Decision: manual-review-required**

Automated checks found risk signals. Review the actual files before installing or executing anything.

## Repository metadata

- GitHub: https://github.com/fuuuuuuma/ai-design-build-kit
- Description: AIでWeb/アプリ/LPを作り込む設計キット — ファイル構造・design.md・デザインプロンプト100選・OpenAI Codex最新解説（非公式まとめ）
- Default branch: main
- License: not detected
- Stars: 2
- Forks: 0
- Open issues: 0
- Last pushed: 06/03/2026 02:09:40
- Source index: [2026-07-04-tool-ai-design-build-kit.md](raw/webclip-index/2026-07-04-tool-ai-design-build-kit.md)

## Install or integration signals

- AI agent, skill, plugin, or MCP reference

## Risk signals

- credential-related wording

## Root files

- .gitignore
- prompts.json
- README.md

## README excerpt

~~~text
# AIでWebサイト・アプリ・LPを作り込むための設計キット

**— ファイル構造 / `design.md` / おすすめプラグイン・スキル / デザイン系プロンプト100選 / OpenAI Codex 最新アップデート解説**

> AIコーディングエージェント（Claude Code・Codex など）に「Webサイト・アプリ・LP・ヘルプページ・スライド」を高い完成度で作らせるための"土台"を1か所にまとめたキットです。
> 「毎回ゼロから指示して、毎回バラバラの見た目になる」を卒業し、**ファイル構造とデザインのルールを先に置いてから作る**やり方に切り替えます。
> 対象は初心者〜中級者。コードが書けなくても「どう頼めば崩れないか」が分かるように書いています。プロンプト100選（[`prompts.json`](./prompts.json)）も同梱。

---

## ⚠️ この資料の読み方（確度について）

- **作成日**: 2026-06-03 時点の情報です。AIツールの仕様は週単位で変わります。最終確認は必ず公式で。
- **確度マーク**: ✅ 公式・複数ソースで確認済み ／ 🔶 一次情報はあるが流動的 ／ ⚠️ 未確認・推測
- 本資料は非公式まとめです。OpenAI / Anthropic / Google / Vercel 各社とは無関係です。
- ファイル構造・design.md・プロンプトは「型のたたき台」です。プロジェクトに合わせて必ず手を入れてください。コピペして終わり、にはしないこと。

## TL;DR（3行）

- **作る前に"置く"**: `CLAUDE.md`／`AGENTS.md`（働き方）・`DESIGN.md`（見た目の正典）・`SKILL.md`（再利用する手順）の3〜4ファイルを最初に用意するだけで、AIの出力がブレなくなる。✅
- **`design.md` は2026年の実在フォーマット**: 色・タイポ・余白などの"デザイントークン"をYAML＋Markdownで書き、リポジトリのルートに置くと、エージェントが毎回それを読んでUIを揃えてくれる（[Google Labs公式仕様](https://github.com/google-labs-code/design.md)あり）。✅
- **最新トピック**: 2026/6/2、OpenAIが Codex に「**Sites**（アイデアをURL共有できるWeb/アプリに変換）」と「**6つのロール特化プラグイン**（product design・creative production など）」を追加。"非エンジニアがCodexでモノを作る"方向に大きく舵を切った。✅

## 目次

1. [このキットの全体像 — 「3層モデル」で考える](#1-このキットの全体像--3層モデルで考える)
2. [【2026年6月最新】OpenAI Codex 大型アップデート解説（添付5ポスト）](#2-2026年6月最新openai-codex-大型アップデート解説添付5ポスト)
3. [なぜ「ファイル構造」から始めるのか](#3-なぜファイル構造から始めるのか)
4. [完璧に近づけるファイル構造テンプレート（Webサイト / アプリ / LP）](#4-完璧に近づけるファイル構造テンプレートwebサイト--アプリ--lp)
5. [`design.md` ベストプラクティス（このキットの中核）](#5-designmd-ベストプラクティスこのキットの中核)
6. [デザイン品質の原則 — "AIっぽさ"を消す](#6-デザイン品質の原則--aiっぽさを消す)
7. [おすすめプラグイン / MCP](#7-おすすめプラグイン--mcp)
8. [おすすめスキル](#8-おすすめスキル)
9. [デザイン系プロンプト100選](#9-デザイン系プロンプト100選)
10. [使い方（初心者基準）— 悩み → こう頼むだけ](#10-使い方初心者基準-悩み--こう頼むだけ)
11. [もう一歩進んだ使い方](#11-もう一歩進んだ使い方)
12. [出典](#12-出典)
13. [未確認・注意事項](#13-未確認注意事項)

---

## 1. このキットの全体像 — 「3層モデル」で考える

AIに何かを作らせるとき、指示を毎回プロンプトに全部書くと「先週と今週で見た目が違う」「3ページ目から急にデザインが崩れる」ということが起きます。原因はシンプルで、**AIは前回の文脈を覚えていない**からです。

そこで2026年に定着してきたのが、指示を「3つの層」に分けてファイルとして置いておく考え方です。料理に例えると、**毎回シェフに口頭で全部伝える**のではなく、**お店のルールブックを厨房に貼っておく**イメージです。

| 層 | ファイル | 役割（料理の例え） | いつ読まれる |
|---|---|---|---|
| ① 働き方 | `CLAUDE.md` / `AGENTS.md` | 「うちの厨房のルール」。言語・コミット規約・禁止事項・使うコマンド | セッション開始時に毎回 |
... (truncated)
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
