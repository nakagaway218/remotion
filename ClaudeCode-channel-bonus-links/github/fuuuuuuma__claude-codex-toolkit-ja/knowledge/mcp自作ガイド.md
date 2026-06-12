# MCP サーバー自作ガイド（最小テンプレ）

> 既製のMCPサーバーに無い「自社API・社内ツール・自分の定型処理」を、エージェントから使えるようにする最短手順です。MCP は共通規格なので、**一度作れば Claude Code でも Codex でも Claude Desktop でも使えます**。

確度マーク：✅ 一次確認 ／ 🔶 流動的 ／ ⚠️ 要確認

> ⚠️ **重要**：MCP SDK の API は更新されます。下のコードは「形」を示す最小例です。実装前に必ず公式 SDK の README を確認してください（末尾の出典）。

---

## 0. 作る前に考えること

- **本当に自作が要るか**：[docs/03-mcp-servers.md](../docs/03-mcp-servers.md) に既製がないか先に確認。あるならそれが速い。
- **何を公開するか**：MCPサーバーが提供できるのは `Tools`（実行する関数）/ `Resources`（読めるデータ）/ `Prompts`（テンプレ）。まずは Tools 1個から。
- **ローカルかリモートか**：自分だけ/開発中なら **stdio（ローカル）** が簡単。チーム配布・常時稼働なら **Streamable HTTP（リモート）**。

---

## 1. Python で最小サーバー（FastMCP）

Python SDK の高水準API `FastMCP` を使うと数行で作れます。

```python
# server.py
# pip install mcp   ※公式 Python SDK。APIは公式READMEで要確認
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-tools")  # サーバー名

@mcp.tool()
def add(a: int, b: int) -> int:
    """2つの整数を足す。説明文(docstring)がそのままツール説明になる。"""
    return a + b

@mcp.tool()
def greet(name: str) -> str:
    """名前を受け取り挨拶を返す。"""
    return f"こんにちは、{name}さん"

if __name__ == "__main__":
    mcp.run()  # 既定で stdio
```

エージェントへの登録：

```bash
# Claude Code
claude mcp add my-tools -- python /絶対パス/server.py
# Codex（config.toml）
#   [mcp_servers.my-tools]
#   command = "python"
#   args = ["/絶対パス/server.py"]
```

---

## 2. TypeScript で最小サーバー

```ts
// server.ts
// npm i @modelcontextprotocol/sdk zod   ※公式 TS SDK。APIは公式READMEで要確認
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "my-tools", version: "0.1.0" });

server.tool(
  "add",
  { a: z.number(), b: z.number() },
  async ({ a, b }) => ({ content: [{ type: "text", text: String(a + b) }] })
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

登録は Python と同様（`command = "node"`, `args = ["server.js"]` 等）。

---

## 3. 動作確認

- **MCP Inspector**（公式のデバッグUI）でツールが見えるか確認するのが定番。🔶
- エージェント側では Claude Code は `/mcp`、Codex は `/mcp` でサーバー/ツールの一覧を確認できる。✅

---

## 4. リモート化（チームで使う）🔶

- トランスポートを **Streamable HTTP** にして公開URLでホストする（Cloudflare Workers 等のエッジが定番）。
- 認証は **OAuth 2.1** を付けるのが主流（[docs/03-mcp-servers.md](../docs/03-mcp-servers.md) の「リモートMCPの潮流」参照）。
- Claude のアプリから使わせるなら、リモートMCPを**カスタムコネクタ**として登録できる（[docs/04-connectors.md](../docs/04-connectors.md)）。

---

## 5. Claude Desktop 向けに配る（.mcpb）✅

ローカルMCPサーバーをワンクリック導入できる単一ファイルにまとめられます。

```bash
npm install -g @anthropic-ai/mcpb
mcpb init     # マニフェスト(manifest.json)を生成
mcpb pack     # .mcpb バンドルを作成
```

できた `.mcpb` を配れば、相手は**ダブルクリック → Install**で導入できます（ターミナル不要）。

---

## 6. セキュリティ（自作でも必ず）

- ツール説明（docstring）に不審な指示を書かない。**受け取る側の信頼を裏切らない**設計に。
- 破壊的な操作（削除・送信・課金）を行うツールは、引数で対象を明示し、安易に実行しない設計に。
- キーは環境変数で受け取り、コード/設定に直書きしない。
- 詳細は [docs/06-セキュリティ.md](../docs/06-セキュリティ.md)。

---

## 出典

- MCP 公式（仕様・SDK入口）: https://modelcontextprotocol.io/ ✅
- Python SDK: https://github.com/modelcontextprotocol/python-sdk 🔶（APIは要確認）
- TypeScript SDK: https://github.com/modelcontextprotocol/typescript-sdk 🔶（APIは要確認）
- MCP Inspector: https://github.com/modelcontextprotocol/inspector 🔶
- .mcpb バンドル（Desktop Extensions）: https://www.anthropic.com/engineering/desktop-extensions ✅（OSSリポジトリ名は要確認 🔶）

## 未確認・注意事項

- ⚠️ SDK のクラス名・メソッド名（`FastMCP` / `McpServer` / `server.tool` 等）はバージョンで変わり得ます。実装前に各 SDK の README を確認してください。
- 🔶 リモート化・OAuth の具体手順はホスティング環境に依存。本ガイドは方針のみ示します。
