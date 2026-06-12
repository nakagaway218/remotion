# 02. OpenAI Codex の拡張 — AGENTS.md / MCP / スキル / サブエージェント / プラグイン / フック

> OpenAI Codex（ターミナルで動くエージェント型コーディングツール / Codex CLI）も、Claude Code とほぼ同じ部品で拡張できます。設定はおもに `~/.codex/config.toml`（TOML形式）に集約されるのが特徴です。本章は2026-06時点の公式（developers.openai.com / github.com/openai/codex）に基づきます。

確度マーク：✅ 公式確認 ／ 🔶 流動的 ／ ⚠️ 未確認

---

## 1. 設定ファイルの場所 ✅

- 個人設定：`~/.codex/config.toml`
- プロジェクト設定：各リポジトリの `.codex/config.toml`（「信頼済み（trusted）」プロジェクトでのみ読み込み）
- `~/.codex` の位置は環境変数 `CODEX_HOME` で変更可能

主な設定キー：

- `model` … 使うモデル名
- `model_provider` … `model_providers` テーブルのプロバイダ識別子（既定 `openai`）
- `approval_policy` … 実行承認ポリシー（`untrusted` / `on-request` / `never`、加えて粒度指定の `granular`）
- `sandbox_mode` … ファイル/ネットワークのアクセス範囲（`read-only` / `workspace-write` / `danger-full-access`）
- `[features]` … `multi_agent`, `web_search`, `hooks`, `memories` などのトグル

全体サンプルは [config/codex-config.toml](../config/codex-config.toml)。

## 2. AGENTS.md（Codex の指示ファイル）✅

Codex が作業開始前に読む**永続カスタム指示**。Claude Code の `CLAUDE.md` に相当します。

### 探索の階層

1. **グローバル**：`~/.codex/AGENTS.override.md` があればそれ、なければ `~/.codex/AGENTS.md`
2. **プロジェクト**：Git ルートからカレントディレクトリへ下りながら、各ディレクトリで `AGENTS.override.md` → `AGENTS.md` の順にチェック
3. **マージ**：ルートから下方向へ連結。カレントに近いファイルほど後ろ＝上書き優先

- 連結サイズの上限は `project_doc_max_bytes`（既定 32 KiB）。✅
- `project_doc_fallback_filenames` で代替ファイル名（例 `TEAM_GUIDE.md`）を追加できる。✅

> 🔶 **CLAUDE.md との共用**：`project_doc_fallback_filenames` に `"CLAUDE.md"` を入れれば Codex に CLAUDE.md を読ませられます（設定キー自体は公式、ただし「CLAUDE.md 互換」と公式が明言しているわけではなく運用テクは二次情報）。`ln -s AGENTS.md CLAUDE.md` のシンボリックリンク共用も同様に二次情報です。両ツールを使うなら、本リポのように **AGENTS.md と CLAUDE.md を両方置く**のが堅実です。

## 3. MCP サポート ✅

組み込み機能（ファイル/シェル/git/Web検索）の外側のツールに MCP で接続します。2系統あります。

### CLIコマンドで追加

```bash
codex mcp add context7 -- npx -y @upstash/context7-mcp
# 一覧/ヘルプ
codex mcp --help
# TUI内では /mcp でアクティブなサーバー・ツールを確認
```

### config.toml で定義

```toml
# stdio型（ローカルプロセス）
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
# env = { API_KEY = "..." }  ← キーは環境変数経由で。直書きしない

# HTTP型（リモート / Streamable HTTP）
[mcp_servers.notion]
url = "https://mcp.notion.com/mcp"
bearer_token_env_var = "NOTION_TOKEN"
```

共通オプション：`startup_timeout_sec`（既定10秒）/ `tool_timeout_sec`（既定60秒）/ `enabled` / `enabled_tools` / `disabled_tools`。✅

> Codex 自身を MCP サーバーとして公開する `codex mcp-server`（stdio）もあり、別のエージェントから Codex を呼び出せます。✅

おすすめMCPの一覧は [docs/03-mcp-servers.md](03-mcp-servers.md)（**MCPサーバーは規格が共通なので Claude Code と同じものが使えます**）。

## 4. カスタムプロンプト / コマンド（⚠️ 非推奨化）🔶

`~/.codex/prompts/` 直下の Markdown をスラッシュコマンド化できます（`/<名>` で起動）。frontmatter に `description` / `argument-hint`、本文で `$1`〜`$9` / `$ARGUMENTS` を使います。トップレベルの Markdown のみスキャン（サブディレクトリ不可）。

> 🔶 **重要**：公式はカスタムプロンプトを **deprecated（非推奨）** とし、再利用可能な指示は **Skills** を推奨しています。新規はスキルで作るのが安全です。

## 5. スキル（Agent Skills）✅

カスタムプロンプトの後継。Claude Code のスキルと同じ思想です。

- 置き場所（階層スキャン）：リポジトリ `.agents/skills`（CWD〜リポジトリルート）／ユーザー `$HOME/.agents/skills`／システム `/etc/codex/skills`。リポジトリ優先。
- 形式：各スキルはディレクトリ。`SKILL.md`（必須・frontmatter に `name` / `description`）＋任意の `scripts/` `references/` `assets/` `agents/`。
- 起動：明示（`/skills` または `$skillname`）／暗黙（タスク内容に応じ自動選択）。
- progressive disclosure（メタデータ→本文の段階ロード）も同様。✅

> ⭐ Claude Code とスキルの**ディレクトリ規約が違う**点に注意：Claude Code は `.claude/skills/`、Codex は `.agents/skills/`。同じ `SKILL.md` を両方に置けば共用できます。本リポの [skills/_template/SKILL.md](../skills/_template/SKILL.md) は両対応の雛形です。

## 6. サブエージェント / プロファイル ✅

### サブエージェント（カスタムエージェント）

- 配置：個人 `~/.codex/agents/`、プロジェクト `.codex/agents/`。1ファイル＝1エージェント（TOML）。
- スキーマ：必須 `name` / `description` / `developer_instructions`。任意 `model` / `model_reasoning_effort` / `sandbox_mode` / `mcp_servers` / `skills.config` など。
- グローバル `[agents]` テーブル：`max_threads`（同時起動上限・既定6 🔶）/ `max_depth`（ネスト深さ・既定1 🔶）/ `job_max_runtime_seconds`。
- 並列起動は明示依頼時のみ。`multi_agent` は `[features]` トグル。✅

### プロファイル

`--profile <名>` で `~/.codex/config.toml` の上に `~/.codex/<名>.config.toml` を重ねて読み込む、名前付き設定レイヤー。✅

## 7. プラグイン / マーケットプレイス ✅

Codex も**公式のプラグイン＋マーケットプレイス機構**を持ちます（メモリに無かった2026年の更新点）。

- プラグインは「skills / apps（GitHub・Slack・Google Drive 等の連携）/ MCP servers」を束ねた再利用ワークフロー。
- マニフェスト：`.codex-plugin/plugin.json`。
- 管理：CLI の `/plugins`（一覧・インストール/アンインストール・有効切替）。`codex plugin marketplace add` は GitHub ショートハンド `owner/repo`（`@ref` 可）、HTTP(S) Git URL、SSH Git URL、ローカルディレクトリを受け付ける。
- 作成：組み込みの `@plugin-creator` スキルが `.codex-plugin/plugin.json` の雛形を生成。✅

> ⚠️ `codex plugin` 系コマンドの完全な引数仕様は公式 plugins トップでは一部のみ記載。細部は公式の plugins/build ページで再確認してください。

## 8. フック（Hooks）✅

`config.toml` の `[hooks]`（または `hooks.json`）でライフサイクルイベントにフックできます。イベントは `PreToolUse` / `PermissionRequest` / `PostToolUse` / `PreCompact` / `PostCompact` / `SessionStart` / `SubagentStart` / `SubagentStop` / `UserPromptSubmit` / `Stop`。

> 🔶 現状は **command フックのみ動作**（prompt/agent ハンドラはパースされるが skip）との記載。更新が速い領域なので利用時に再確認を。管理者強制フックは `requirements.toml`。✅

---

## 出典

- 設定リファレンス: https://developers.openai.com/codex/config-reference ✅
- 設定の基本: https://developers.openai.com/codex/config-basic ✅
- 高度な設定: https://developers.openai.com/codex/config-advanced ✅
- AGENTS.md: https://developers.openai.com/codex/guides/agents-md ✅
- MCP: https://developers.openai.com/codex/mcp ✅
- カスタムプロンプト: https://developers.openai.com/codex/custom-prompts ✅
- スキル: https://developers.openai.com/codex/skills ✅
- サブエージェント: https://developers.openai.com/codex/subagents ✅
- フック: https://developers.openai.com/codex/hooks ✅
- プラグイン: https://developers.openai.com/codex/plugins ✅
- GitHub: https://github.com/openai/codex ✅

## 未確認・注意事項

- 🔶 `model` の最新既定値・選択可能なモデル名は更新が速く、本リポの作成時点と異なる可能性。利用前に公式で確認を。
- 🔶 `[agents]` の既定値（`max_threads`=6 / `max_depth`=1 等）は要約由来。一次ソースの該当行で再確認推奨。
- 🔶 カスタムプロンプトの「非推奨化」と Skills への移行スケジュールの正式時期は未確認。
- ⚠️ `project_doc_fallback_filenames` に `CLAUDE.md` を入れる運用、シンボリックリンク共用は二次情報。動作は環境で確認してください。
