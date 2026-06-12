# claude-code-skills

Claude Code 用の再利用可能なスキル集です。
`.claude/skills/` に配置するだけで使えます。

## スキル一覧

| スキル | 概要 |
|--------|------|
| [youtube-html-slides](./youtube-html-slides/) | YouTube解説動画用の16:9 HTMLスライドを自動生成 |
| [write-article](./write-article/) | AIツール最新アップデート記事を超初心者向けに執筆（リサーチ→執筆→採点の全工程自動化） |

## 使い方

```bash
# リポジトリをクローン
git clone https://github.com/hyuga55n1/claude-code-skills

# スキルをプロジェクトに配置
cp -r claude-code-skills/youtube-html-slides .claude/skills/
cp -r claude-code-skills/write-article .claude/skills/
```

Claude Code でそれぞれのスキルに対応した指示をすると起動します。

## ライセンス

MIT
