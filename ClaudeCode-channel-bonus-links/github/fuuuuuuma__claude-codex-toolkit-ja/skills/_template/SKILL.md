---
name: my-skill
description: <いつ使うかを具体的に書く>。例「Xという依頼や、Yというファイルを渡された時に、Zの手順で処理する」。この一文がエージェントの自動起動の判断材料になるので、トリガー語を含める。
# 以下は任意（Claude Code / Codex で一部キーが異なる。共通は name と description）
# argument-hint: "<引数の説明>"
# allowed-tools: Read, Write, Bash       # Claude Code: 使ってよいツールを絞る
# disable-model-invocation: false        # true で自動起動を止め、手動(/my-skill)のみに
---

# My Skill（雛形）

> この `SKILL.md` を複製して自分のスキルを作ります。`skills/_template/` をコピーし、`skills/<好きな名前>/SKILL.md` にリネームしてください。
> **Claude Code と Codex の両方で使えます**（frontmatter の `name` / `description` は共通）。置き場所だけ違います（下記）。

## このスキルがすること

<1〜3行で、このスキルの目的を書く。>

## 使うタイミング（発火条件）

- <こういう依頼が来たら>
- <こういうファイル/状況なら>

## 手順

1. <ステップ1：何を確認するか>
2. <ステップ2：何を実行するか（コマンド例があれば書く）>
3. <ステップ3：どう結果を返すか>

## 注意・ルール

- <守ること。例：取り消せない操作の前は確認する／キーは環境変数で渡す>
- <出力の形式・禁止事項など>

## 例（任意）

入力例：
```
<ユーザーの依頼例>
```
期待する動き：
```
<エージェントがどう動くか>
```

---

<!--
== 置き場所（このファイルをどこに置くか）==

Claude Code:
  個人用      ~/.claude/skills/<名>/SKILL.md
  プロジェクト .claude/skills/<名>/SKILL.md
  プラグイン   <plugin>/skills/<名>/SKILL.md

OpenAI Codex:
  リポジトリ   .agents/skills/<名>/SKILL.md
  ユーザー     ~/.agents/skills/<名>/SKILL.md
  システム     /etc/codex/skills/<名>/SKILL.md

両対応にするなら、同じ <名>/ ディレクトリを両方の場所に置く（またはシンボリックリンク）。

== 書き方のコツ（progressive disclosure）==
- 本文は短く（目安 500 行未満）。起動中ずっとコンテキストに載るため。
- 長い参照資料・データは別ファイル（reference.md, data.json 等）に分け、
  本文から「必要なら reference.md を読む」と誘導する。メタデータ(name/description)だけが
  常時ロードされ、本文は呼ばれた時だけ読まれるので、補助ファイルはさらに必要時のみ。
- description は「何をするか」より「いつ使うか」を厚く。自動起動の精度が上がる。

== 補助ファイルの例（任意で同じディレクトリに置ける）==
  <名>/
  ├── SKILL.md        ← このファイル（必須）
  ├── reference.md    ← 詳細手順・仕様（必要時のみ読ませる）
  ├── scripts/        ← 実行スクリプト（Codexは scripts/ を認識）
  └── assets/         ← テンプレ・画像など
-->
