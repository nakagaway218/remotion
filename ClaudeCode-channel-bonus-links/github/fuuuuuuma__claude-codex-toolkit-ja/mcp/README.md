# mcp/ — MCP サーバー設定サンプル

外部サービスに繋ぐ MCP サーバーの設定ひな型です。**同じサーバーを Claude Code 形式と Codex 形式の両方**で用意しています。

| ファイル | 対象 | 形式 |
|---|---|---|
| [claude-code.mcp.json](claude-code.mcp.json) | Claude Code | JSON（`.mcp.json`） |
| [codex-config.toml](codex-config.toml) | OpenAI Codex | TOML（`config.toml` の `[mcp_servers]`） |

収録サーバー（同一構成）：`context7`（最新ドキュメント注入）/ `filesystem`（安全なファイル操作）/ `playwright`（ブラウザ操作）/ `github`（リモート）/ `notion`（リモート）。

## 使い方

### Claude Code

`claude-code.mcp.json` の中身を、プロジェクト直下の `.mcp.json` にコピーします（プロジェクト共有になる）。または個別に：

```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp
claude mcp add --transport http notion https://mcp.notion.com/mcp
```

### Codex

`codex-config.toml` の `[mcp_servers.*]` を `~/.codex/config.toml` に貼り付けます。または：

```bash
codex mcp add context7 -- npx -y @upstash/context7-mcp
```

## 必ず守ること（セキュリティ）

- **実キーを書かない**。`${GITHUB_PAT}` のように環境変数で渡す。`.mcp.json` をコミットする場合は特に注意。
- サーバーは信頼できるものだけ。詳しくは [docs/06-セキュリティ.md](../docs/06-セキュリティ.md)。
- 他のサーバーを足したいときは [docs/03-mcp-servers.md](../docs/03-mcp-servers.md) のカタログから選ぶ。

> JSON 内の `"//"` キーはコメント代わりです（JSON標準にコメントが無いため）。実運用では消しても構いません。
