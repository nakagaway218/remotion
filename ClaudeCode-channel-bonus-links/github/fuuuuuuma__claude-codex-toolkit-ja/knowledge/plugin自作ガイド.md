# プラグイン自作ガイド（Claude Code / Codex）

> スキル・コマンド・フック・MCP設定などを**まとめて1つにして配る**のがプラグインです。「自分の拡張一式を、チームや視聴者にワンコマンドで配りたい」時に作ります。Claude Code と Codex で構造が似ています。

確度マーク：✅ 一次確認 ／ 🔶 流動的 ／ ⚠️ 要確認

---

## 0. まず判断

- スキル1個で足りる → プラグインは不要。[skills/](../skills/) にスキルを置くだけでよい。
- スキル＋MCP＋フックを**一括で配りたい** → プラグインにする価値あり。

---

## 1. Claude Code プラグインの最小構成 ✅

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        ← マニフェスト（name のみ必須）
├── skills/
│   └── hello/SKILL.md     ← 同梱スキル
├── commands/              ← 任意（コマンド）
├── agents/                ← 任意（サブエージェント）
├── hooks/hooks.json       ← 任意（フック）
└── .mcp.json              ← 任意（MCP サーバー設定）
```

`.claude-plugin/plugin.json`（最小）：

```json
{
  "name": "my-plugin",
  "description": "自分の拡張一式",
  "version": "0.1.0",
  "author": { "name": "あなた" }
}
```

### ローカルで試す ✅

```bash
claude --plugin-dir ./my-plugin
```

同梱スキルは名前空間つきで `/my-plugin:hello` のように呼べます（衝突防止）。

---

## 2. マーケットプレイス（配布カタログ）にする ✅

プラグインを人に配るには、`marketplace.json` を持つ git リポジトリを「マーケットプレイス」として公開します。

```
my-marketplace/            ← GitHubリポジトリ
├── .claude-plugin/
│   └── marketplace.json
└── my-plugin/             ← プラグイン本体（上の構成）
    └── .claude-plugin/plugin.json
```

`marketplace.json`（最小）：

```json
{
  "name": "my-marketplace",
  "owner": { "name": "あなた" },
  "plugins": [
    { "name": "my-plugin", "source": "./my-plugin", "description": "自分の拡張一式" }
  ]
}
```

利用側（受け取った人）：

```bash
/plugin marketplace add あなたのID/my-marketplace   # GitHub owner/repo
/plugin install my-plugin@my-marketplace
```

`source` は `"./相対パス"` のほか `{ "source": "github", "repo": "owner/repo" }` も可。✅

---

## 3. Codex プラグインの最小構成 ✅

Codex も公式のプラグイン＋マーケットプレイス機構を持ちます（2026年の追加機能）。

- マニフェスト：`.codex-plugin/plugin.json`
- 作成補助：組み込みスキル `@plugin-creator` が雛形を生成。✅
- マーケットプレイス追加：

```bash
codex plugin marketplace add owner/repo     # GitHub ショートハンド（@ref 可）
# 管理は /plugins（一覧・インストール・有効切替）
```

> ⚠️ `codex plugin` 系コマンドの完全な引数は公式 plugins ページの一部のみ確認。細部は公式 plugins/build で再確認してください。

---

## 4. 配布のコツ

- **README を必ず付ける**：何が入っているか、どう入れるか、必要な環境変数は何か。
- **キーを同梱しない**：MCP設定は `${ENV}` で。実キーは配布物に入れない。
- **バージョンを切る**：`version` を更新して配ると、利用側に更新が届く（Claude Code は省略時 git commit SHA を版に扱う）。✅
- **このリポを土台に**：本リポの `skills/` `mcp/` をそのままプラグイン化すれば、配布物の出来上がりが速い。

---

## 出典

- Claude Code プラグイン: https://code.claude.com/docs/en/plugins ✅
- プラグイン リファレンス: https://code.claude.com/docs/en/plugins-reference ✅
- マーケットプレイス: https://code.claude.com/docs/en/plugin-marketplaces ✅
- Codex プラグイン: https://developers.openai.com/codex/plugins ✅

## 未確認・注意事項

- 🔶 マニフェストのフィールド（`displayName` 等）やCLIフラグはバージョンで増減します。
- ⚠️ Codex の `codex plugin` 完全仕様は未確認部分あり。公式で再確認を。
