# 01. Claude Code の拡張 — プラグイン / スキル / サブエージェント / フック / MCP

> Claude Code は「**スキル・コマンド・サブエージェント・フック・MCP/LSP サーバー**」の5部品で拡張でき、それらを束ねて配布するのが「**プラグイン（＋マーケットプレイス）**」です。本章は2026-06時点の公式ドキュメント（code.claude.com）に基づきます。

確度マーク：✅ 公式確認 ／ 🔶 流動的 ／ ⚠️ 未確認

---

## 1. スキル（Agent Skills）✅

`SKILL.md`（YAML frontmatter ＋ Markdown 本文）でできた手順書。Claude が必要時に自動ロードするか、`/skill-name` で手動起動します。

### 置き場所と優先順位

| 種類 | パス | 範囲 |
|---|---|---|
| 個人 | `~/.claude/skills/<名>/SKILL.md` | 全プロジェクト |
| プロジェクト | `.claude/skills/<名>/SKILL.md` | そのプロジェクト |
| プラグイン同梱 | `<plugin>/skills/<名>/SKILL.md` | 有効時 |
| 組織（managed） | 管理設定 | 組織全体 |

同名衝突は 組織 > 個人 > プロジェクト の順に優先。スキルとコマンドが同名ならスキル優先。✅

### frontmatter の主なフィールド（すべて任意・`description` 推奨）

- `name`（表示名・既定はディレクトリ名）
- `description`（**いつ使うか**を書く。自動デリゲートの判断材料）
- `when_to_use` / `argument-hint` / `arguments`（名前付き位置引数）
- `disable-model-invocation: true`（自動起動を止め手動のみに。削除など副作用系向け）
- `user-invocable: false`（メニュー非表示の背景知識化）
- `allowed-tools` / `disallowed-tools` / `model` / `effort`
- `context: fork`（サブエージェントに隔離実行）/ `agent` / `hooks` / `paths`（globで発火条件限定）

> ⭐ **progressive disclosure**：起動時はスキルの `name` と `description`（メタデータ）だけがコンテキストに載り、本文は呼ばれた時だけ読み込まれます。だから多数入れてもコンテキストをほぼ食いません。重い資料は `reference.md` 等に分け、`SKILL.md` から参照させて必要時のみ読ませるのがコツです。本文は **500行未満**が推奨。✅

雛形は [skills/_template/SKILL.md](../skills/_template/SKILL.md) にあります。

## 2. スラッシュコマンド ✅

`.claude/commands/<名>.md`（フラットな Markdown）でファイル名が `/名` になります。frontmatter はスキルと共通。

- **新規はスキル（`.claude/skills/`）が推奨**。補助ファイル・呼び出し制御・自動ロードが使えるため。コマンドは「シンプルな1ファイルの定型処理」向けに残っています。
- 文字列置換：`$ARGUMENTS` / `$ARGUMENTS[N]` / `$N` / `$name` / `${CLAUDE_SESSION_ID}` / `${CLAUDE_SKILL_DIR}` など。✅

## 3. サブエージェント ✅

`.claude/agents/<名>.md`（Markdown + YAML frontmatter、本文がシステムプロンプト）。独立コンテキスト・独自ツール制限で動き、結果だけ親に返します。組込みは **Explore**（読取専用）・**Plan**（読取専用）・**general-purpose**（全ツール）。

frontmatter の主なもの：`name`（必須）/ `description`（必須・いつ委譲するか）/ `tools` / `disallowedTools` / `model`（`sonnet`/`opus`/`haiku`/`inherit`、既定 `inherit`）/ `permissionMode` / `maxTurns` / `skills`（起動時に全文プリロード）/ `mcpServers` / `memory`（`user`/`project`/`local`）/ `isolation: worktree` など。✅

> 安全上、**プラグイン同梱のサブエージェントは `hooks` / `mcpServers` / `permissionMode` を持てません**。✅

管理は `/agents`、明示呼び出しは自然言語 / `@agent-<名>` / `claude --agent <名>`。

## 4. フック（Hooks）✅

`settings.json` の `hooks` キー、またはプラグインの `hooks/hooks.json` に定義。「特定のタイミングで自動でコマンドを走らせる」仕組みです。

### 主なイベント

- ツール系：`PreToolUse`（実行前・ブロック可）/ `PostToolUse` / `PermissionRequest` / `PermissionDenied`
- ターン系：`UserPromptSubmit` / `Stop`
- セッション系：`SessionStart`（matcher: `startup`/`resume`/`clear`/`compact`）/ `SessionEnd`
- サブエージェント系：`SubagentStart` / `SubagentStop`
- 圧縮系：`PreCompact` / `PostCompact` ほか

hook の `type` は `command` / `http` / `mcp_tool` / `prompt` / `agent` の5種。matcher はツール名の完全一致または `|` 区切り（`mcp__memory__.*` のような正規表現も可）。終了コード `0`=成功、`2`=ブロック（stderr を Claude に提示）。✅

最小例（編集後に lint を走らせる）：

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Edit|Write",
        "hooks": [ { "type": "command", "command": "/path/lint.sh", "timeout": 30 } ] }
    ]
  }
}
```

## 5. MCP サーバー ✅

外部サービス連携の本体。詳細とおすすめ一覧は [docs/03-mcp-servers.md](03-mcp-servers.md)。Claude Code での追加方法だけ要約します。

```bash
# リモートHTTP（推奨）
claude mcp add --transport http notion https://mcp.notion.com/mcp
# Bearerトークン付き（キーは環境変数・直書きしない）
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer ${GITHUB_PAT}"
# ローカルstdio（-- の後がサーバー起動コマンド）
claude mcp add --env AIRTABLE_API_KEY=${AIRTABLE_API_KEY} --transport stdio airtable \
  -- npx -y airtable-mcp-server
```

スコープは `--scope local|project|user`。チーム共有はプロジェクト直下の `.mcp.json`（VCSに乗る）。サンプルは [mcp/claude-code.mcp.json](../mcp/claude-code.mcp.json)。✅

## 6. プラグイン ✅

スキル・サブエージェント・フック・MCP/LSP サーバー・出力スタイルなどを**まとめた自己完結ディレクトリ**。チーム配布・バージョン管理・複数プロジェクト再利用が目的です。

### 構造（plugin root 直下に置く。`.claude-plugin/` には `plugin.json` だけ）

| ディレクトリ/ファイル | 内容 |
|---|---|
| `.claude-plugin/plugin.json` | マニフェスト（`name` のみ必須。省略時はディレクトリ名から自動推定） |
| `skills/<名>/SKILL.md` | スキル |
| `commands/*.md` | コマンド |
| `agents/*.md` | サブエージェント |
| `hooks/hooks.json` | フック |
| `.mcp.json` | MCP サーバー設定 |
| `.lsp.json` | LSP サーバー設定（コード補完・定義ジャンプ） |
| `bin/` | 有効時に PATH へ追加される実行ファイル |

`plugin.json` の主フィールド：`name`（必須・kebab-case）/ `displayName` / `version`（semver。省略時は git commit SHA を版に）/ `description` / `author` / `homepage` / `repository` / `license` / `keywords` / `dependencies`。✅

自作の最小手順は [knowledge/plugin自作ガイド.md](../knowledge/plugin自作ガイド.md)。

## 7. マーケットプレイス（プラグインのカタログ）✅

「カタログを追加（add）→ 個別にインストール」の2段階です。

| マーケットプレイス | 性質 | 使い方 |
|---|---|---|
| `claude-plugins-official` | Anthropic 管理の厳選カタログ。起動時に利用可・自動更新が既定 | `/plugin install <名>@claude-plugins-official` |
| `claude-community`（repo: `anthropics/claude-plugins-community`）🔶 | 審査済みの第三者プラグイン。各々 commit にピン | `/plugin marketplace add anthropics/claude-plugins-community` → `/plugin install <名>@claude-community` |

カタログの追加ソース形式：GitHub `owner/repo` ／ Git URL（`#ref` でブランチ/タグ指定）／ローカルパス ／ リモート `marketplace.json` URL。操作は `/plugin`（Discover/Installed/Marketplaces/Errors の4タブ）、`/plugin marketplace list|update|remove`、`/plugin disable|enable|uninstall <名>@<market>`。✅

### 公式マーケットプレイス収録の代表例 ✅

- **外部連携 MCP**：`github` / `gitlab` / `atlassian` / `asana` / `linear` / `notion` / `figma` / `vercel` / `firebase` / `supabase` / `slack` / `sentry`
- **コードインテリジェンス（LSP）**：`typescript-lsp` / `pyright-lsp` / `rust-analyzer-lsp` / `gopls-lsp` / `clangd-lsp` ほか（言語サーバーのバイナリが必要）
- **開発ワークフロー**：`commit-commands` / `pr-review-toolkit` / `agent-sdk-dev` / `plugin-dev`
- **セキュリティ**：`security-guidance`
- **出力スタイル**：`explanatory-output-style` / `learning-output-style`

### コミュニティ集約（⚠️ 未確認・導入前に各repoを精査）

- `claudemarketplaces.com`（skills/plugins/MCP のコミュニティ集約サイト）⚠️
- `anthropics/claude-plugins-community`（公式コミュニティカタログ）🔶
- その他の大型コミュニティ集（自称の収録数・スター数は自己申告で**未確認**）⚠️

## 8. settings.json の主要オプション ✅

位置：`~/.claude/settings.json`（個人）/ `.claude/settings.json`（プロジェクト・共有）/ `.claude/settings.local.json`（gitignore推奨）/ managed（組織）。優先順位は 組織 > CLI > local > project > 個人（権限ルールはマージ）。

主なキー：

- `permissions`：`allow` / `ask` / `deny`（例 `"Bash(npm run lint)"`, `"Read(./.env*)"`）
- `env`：全セッション共通の環境変数
- `model` / `availableModels`
- `hooks` / `disableAllHooks`
- `enabledPlugins` / `extraKnownMarketplaces`
- MCP：`enableAllProjectMcpServers` / `enabledMcpjsonServers` / `disabledMcpjsonServers`
- その他：`cleanupPeriodDays`（既定30）/ `outputStyle` / `effortLevel` / `autoMemoryEnabled`

全体サンプルは [config/claude-settings.json](../config/claude-settings.json)。✅

---

## 出典

- プラグイン: https://code.claude.com/docs/en/plugins ✅
- プラグイン リファレンス: https://code.claude.com/docs/en/plugins-reference ✅
- プラグイン発見: https://code.claude.com/docs/en/discover-plugins ✅
- マーケットプレイス: https://code.claude.com/docs/en/plugin-marketplaces ✅
- スキル: https://code.claude.com/docs/en/skills ✅
- サブエージェント: https://code.claude.com/docs/en/sub-agents ✅
- フック: https://code.claude.com/docs/en/hooks ✅
- 設定: https://code.claude.com/docs/en/settings ✅
- MCP: https://code.claude.com/docs/en/mcp ✅

## 未確認・注意事項

- ⚠️ コミュニティのプラグイン/スキル集の「収録数・スター数・月間訪問者数」は各サイトの自己申告で、一次裏取りしていません。導入前に各リポジトリの中身を確認してください。
- 🔶 `displayName`・`defaultEnabled`・`--plugin-dir .zip` などのバージョン注記（v2.1.x+）は閲覧時点の docs 準拠で、以降に変わる可能性があります。
- 🔶 `claude-community` マーケットプレイスの追加コマンド・正式名称は表記揺れがあり得ます。公開時に最新を再確認してください。
