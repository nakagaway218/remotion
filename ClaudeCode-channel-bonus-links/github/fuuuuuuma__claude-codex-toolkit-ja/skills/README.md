# skills/ — 独自スキル置き場

このフォルダは、あなた（または受け取った人）が**自分の手順をスキルとして足していく**場所です。スキルとは「エージェントへの手順書」（[docs/00-はじめに.md](../docs/00-はじめに.md)）。

## 追加のしかた（3ステップ）

1. `_template/` をコピーして `skills/<好きな名前>/` を作る。
2. 中の `SKILL.md` を編集する（特に frontmatter の `name` と `description`）。
3. 必要なら参照資料を同じフォルダに `reference.md` 等で足す。

```bash
cp -r skills/_template skills/note-format   # 例: note記事整形スキル
$EDITOR skills/note-format/SKILL.md
```

## 置き場所（実際に使うとき）

このリポ内の `skills/` は**保管庫**です。実際にエージェントから使うには、各ツールの所定の場所に置く（コピー or シンボリックリンク）必要があります。

| ツール | 個人用 | プロジェクト用 |
|---|---|---|
| Claude Code | `~/.claude/skills/<名>/` | `.claude/skills/<名>/` |
| Codex | `~/.agents/skills/<名>/` | `.agents/skills/<名>/` |

例（このリポの note-format スキルを Claude Code 個人用に入れる）：

```bash
ln -s "$(pwd)/skills/note-format" ~/.claude/skills/note-format
```

## 書き方のコツ

- `description` は「**いつ使うか**」を厚く。トリガーになる言葉を入れると自動起動の精度が上がる。
- 本文は短く（500行未満目安）。長い資料は別ファイルに分けて「必要なら読む」と誘導。
- 詳しくは [_template/SKILL.md](_template/SKILL.md) のコメントと [docs/01-claude-code.md](../docs/01-claude-code.md) / [docs/02-codex.md](../docs/02-codex.md)。

## ここに置く独自スキルの例（アイデア）

- 自分のブログ/note の文体に整える整形スキル
- 決まった手順のリリース作業スキル
- 特定フォーマットのレポート生成スキル
- よく使う調査の定型手順スキル

> スキルを足すたびに、ルートの [README.md](../README.md) の目次に1行加えると、次に読むエージェントが見つけやすくなります。
