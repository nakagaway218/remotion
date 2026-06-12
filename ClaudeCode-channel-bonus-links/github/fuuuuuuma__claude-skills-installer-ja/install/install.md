# 環境別インストールガイド

skill は「`SKILL.md` が入ったフォルダ」を、エージェントが読む場所へ置けば有効になります。
置き場所は環境ごとに違うので、まず[手順1の環境判定](../AGENTS.md#手順1-環境判定どこに置くか決める)を済ませてから本ガイドへ。

---

## Claude Code

### 置き場所
- **ユーザー全体**（全プロジェクトで有効）: `~/.claude/skills/<id>/SKILL.md`
- **プロジェクト限定**（このリポジトリだけ）: `<project>/.claude/skills/<id>/SKILL.md`

「毎回どこでも使いたい」→ ユーザー全体。「このプロジェクト専用」→ プロジェクト限定。

### 方法A: 同梱skill（bundled）をコピー
```bash
# 例: 企画壁打ちパックをユーザー全体に入れる
mkdir -p ~/.claude/skills/planning-sprint
cp <このrepo>/skills/planning-sprint/SKILL.md ~/.claude/skills/planning-sprint/SKILL.md
```

### 方法B: npx ハンドラ（対応している場合）
```bash
npx skills@latest add <owner>/<repo>/<path>
# 実行前に catalog/skills.json の known_renames を当て、source で実フォルダ名を確認すること
```

### 方法C: 外部skillを手動配置
```bash
mkdir -p ~/.claude/skills/<id>
# source の SKILL.md（と同梱ファイル）を取得して ~/.claude/skills/<id>/ に保存
```

### 確認
- 新しいセッションを開き、`/` で skill 一覧に出るかを確認する。
- `~/.claude/skills/<id>/SKILL.md` 先頭の `---` frontmatter（`name` / `description`）が壊れていないこと。

---

## Codex (OpenAI)

- Codex は `AGENTS.md` 階層と `.codex/` 配下の設定でエージェントの振る舞いを定義します。
- skill 相当の手順書は、プロジェクト直下または該当ディレクトリの `AGENTS.md` に**節として取り込む**か、
  `.codex/` 配下にファイルとして置いて参照させる運用が基本です。
- このリポジトリの各 `SKILL.md` の本文（frontmatter 以下の手順）を、対象の `AGENTS.md` に移植してください。
- ⚠️ Codex の最新の配置規約はバージョンで変わり得ます。**未確認の点は実環境のドキュメントを確認**してから配置すること。

---

## Cursor / その他のエージェント

- Cursor は `.cursor/rules/`（rules ファイル）でコンテキストを与えます。
- 各 `SKILL.md` の手順本文を rules ファイルに移植するか、リポジトリ内に置いて参照させてください。
- その他のエージェントも「手順書ファイルを読ませる場所」に置く、という考え方は共通です。

---

## 配置後にやること（育てる）

- `SKILL.md` は自由に編集してよい。自分の業務に合わせてルール・テンプレ・具体例を足す。
- まず1個入れて1週間使い、効果を確かめてから次を足す。「全部入れ」はしない。
