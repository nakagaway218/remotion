---
type: github_repo_review
status: auto-reviewed
date: 2026-07-17
repo: fuuuuuuma/claude-code-website-builder-ja
source_url: https://github.com/fuuuuuuma/claude-code-website-builder-ja
source_index: raw/webclip-index/2026-07-16-tool-claude-code-website-builder-ja.md
decision: candidate-with-conditions
tags: [report, github, tool-review]
---

# fuuuuuuma/claude-code-website-builder-ja adoption review

## Decision

**Decision: candidate-with-conditions**

The repository appears relevant to installation or integration, and no strong risk signal was found in the checked files. Confirm fit before trial use.

## Repository metadata

- GitHub: https://github.com/fuuuuuuma/claude-code-website-builder-ja
- Description: ループで完璧なWebサイトを1発生成【Claude Code版】— 解説（README/スライド/1枚資料）＋Claude Code配布キット（ウルトラコード対応）同梱
- Default branch: main
- License: not detected
- Stars: 0
- Forks: 0
- Open issues: 0
- Last pushed: 07/04/2026 15:27:13
- Source index: [2026-07-16-tool-claude-code-website-builder-ja.md](raw/webclip-index/2026-07-16-tool-claude-code-website-builder-ja.md)

## Install or integration signals

- AI agent, skill, plugin, or MCP reference

## Risk signals

- No strong risk signal detected by this script.

## Root files

- .gitignore
- kit
- onepager.html
- present.html
- README.md
- slides.html

## README excerpt

~~~text
# ループで「完璧なWebサイト」を1発生成する方法【Claude Code版】徹底解説

> AIに「サイト作って」と一度頼むだけでは、なぜ“それっぽいガワ”で止まってしまうのか。
> その答えが **ループ（loop）**。作る人と採点する人を分けて、合格するまで回す——さらに **Claude Code なら
> 「ウルトラコード（マルチエージェント）」で採点を一気に並列化**できます。ボタンの押した先まで動く
> 「完璧なWebサイト」を仕上げる方法を、はじめての人にも分かるようにまとめました。
> （ClaudeCodeチャンネル・解説用リサーチノート／視聴者は初心者を含む前提）

📊 [スライド資料を見る](./slides.html) ｜ 📄 [1枚まとめ資料を見る](./onepager.html) ｜ 🎁 [プレゼントを受け取る](./present.html) ｜ 📦 [キット一式](./kit/)

## TL;DR（3行）

- **1発で完璧なサイトは出ない。** AIは“動くと思う”ものを返すだけ。だから **「合格の定義」と「採点役」を用意して、達成するまで繰り返す＝ループ** で仕上げる ✅
- **Claude Code はこのループの道具が最初から揃っている。** `/goal`・サブエージェント・スキル・フック、そして **ウルトラコード（マルチエージェントのWorkflow）** で採点を並列化して徹底できる ✅
- 大事な2つの合言葉。**「側だけ作らない（ボタンの押した先まで）」** と **「Simple is the best（目的1つ・要素を盛らない）」** 🔶

## 目次

1. ループとは何か
2. なぜ Webサイト作成に「ループ」が必要なのか
3. AIでWebサイトを作るのに必要な3つ
4. 「側だけ」作ってもダメ — 押した先まで作り込む
5. Simple is the best — 盛らない勇気
6. Claude Code だからできること（ウルトラコード）
7. 使い方（初心者基準・コピペでOK）
8. もう一歩進んだ使い方
9. プレゼント（配布キットの中身）
10. 出典
11. 未確認・注意事項

---

## 1. ループとは何か

### まず一言で

**ループ**とは、AIエージェントが「**止まる条件に達するまで、作って→確かめて→直すを自分で繰り返すこと**」です ✅。
人間が毎回「これ直して」「次これやって」と舵を取るのではなく、**AIが自分で検証しながら完成へ向かいます**。

この考え方は、Anthropic（Claude Codeの開発元）の公式ブログ
**「Getting Started with Loops」**（2026年6月30日公開・Delba de Oliveira / Michael Segner）で整理されています ✅。
記事は Claude Code のループそのものを扱っているので、**Claude Code はこのループを一番きれいに回せる道具**を最初から持っています。
なお、この一連の設計は「ループエンジニアリング」とも呼ばれます。

### なぜ「ループ」なのか — 1回の会話の限界

AIに「いいねボタンを作って」と頼むと、記事の言葉を借りればこうなります ✅:

> 「AIはコードを読み、編集し、テストを走らせ、**"動くと思う"ものを返す**」

問題はこの **“思う”** の部分。合っているかを**人間が毎回チェックして、直しを指示する**必要があります。
サイト全体ともなると、この往復が積み重なって時間も気力も削られます。
**ループは、この「毎回人間が確認する」ボトルネックを、AI自身の検証に置き換えます。**

### ループの種類（公式ブログの分類）

公式ブログは、ループを**きっかけ・止まり方・使う道具**で4種類に分けています ✅:

| 種類 | きっかけ | 止まる条件 | 使う道具 | 向いている仕事 |
|---|---|---|---|---|
| **ターン型** | あなたの一言 | AIが「できた」と判断 | スキル（検証手順を教える） | 短い・単発の作業 |
| **ゴール型（`/goal`）** | あなたが手で送る | ゴール達成 or 上限ターン | 成功条件＋採点役 | **ゴールが明確な作業（サイト制作）** |
| **時間型（`/loop`・`/schedule`）** | 時間・間隔 | 完了 or 停止 | ローカル/クラウドの繰り返し | 定期・監視 |
| **プロアクティブ型** | イベント・予定 | 目標達成まで自動 | 上記の合わせ技＋ワークフロー | 定型の運用フロー |

Webサイト制作で使うのは **ゴール型（`/goal`）**。「各観点100点」という合格条件を決めて、達成するか上限まで、作って→採点して→直すを繰り返します。

### 効くループの3原則

公式ブログが挙げる、うまくいくループのコツはこの3つです ✅:

1. **自分で検証できる形にする。** 「良い感じ」ではなく**数えられ
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
