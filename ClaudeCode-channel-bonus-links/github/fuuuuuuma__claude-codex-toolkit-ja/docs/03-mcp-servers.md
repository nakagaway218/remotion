# 03. おすすめ MCP サーバー網羅カタログ

> MCP サーバーは「外部サービスへのアダプタ」。**規格が共通なので、ここに挙げたものは Claude Code でも Codex でも（多くは Claude Desktop でも）同じように使えます**。本章はカテゴリ別に、canonical なパッケージ名/repo・1行用途・ローカル/リモート・公式/サードパーティを整理します。2026-06時点。

確度マーク：✅ 公式確認 ／ 🔶 一次情報あり流動的 ／ ⚠️ 未確認・二次情報

> 💡 **設定の前に**：URL・パッケージ名は変わります。導入時は各repoの README を必ず確認し、キーは環境変数で渡してください。Claude Code は `claude mcp add ...`、Codex は `config.toml` の `[mcp_servers]`（[docs/01](01-claude-code.md) / [docs/02](02-codex.md) 参照）。

---

## 0. MCP の基礎（最小限）

- **MCP**＝Model Context Protocol。Anthropic が2024年11月公開のオープン標準。✅
- **トランスポート**：`stdio`（ローカルプロセス）／`Streamable HTTP`（リモート・推奨）／`SSE`（旧式・非推奨）。✅
- **構成要素**：`Tools`（実行する関数）/ `Resources`（読めるデータ）/ `Prompts`（テンプレ）。✅
- **公式レジストリ**：`registry.modelcontextprotocol.io`（2025-09プレビュー。GA前は破壊的変更あり得る）🔶
- 最新安定仕様は `2025-11-25`。✅

---

## 1. 公式リファレンスサーバー（modelcontextprotocol/servers）✅

「まず触ってみる」基本セット。canonical な npm/PyPI パッケージ名つき。**すべてローカル（stdio）型**。

| サーバー | パッケージ名 | 用途 |
|---|---|---|
| Everything | `@modelcontextprotocol/server-everything` | 全機能入りのテスト/参照用 |
| Fetch | `@modelcontextprotocol/server-fetch`（Python: `mcp-server-fetch`） | Webページ取得・LLM向け変換 |
| Filesystem | `@modelcontextprotocol/server-filesystem` | アクセス制御つきの安全なファイル操作 |
| Git | `mcp-server-git`（**Python**・`uvx mcp-server-git`） | Gitリポジトリの読み取り・検索・操作 |
| Memory | `@modelcontextprotocol/server-memory` | ナレッジグラフ型の永続メモリ |
| Sequential Thinking | `@modelcontextprotocol/server-sequentialthinking` | 思考の段階分解で複雑な問題を整理 |
| Time | `@modelcontextprotocol/server-time` | 時刻・タイムゾーン変換 |

> 💡 **起動方法の違い**：Git だけ Python 実装で `uvx mcp-server-git` で起動します。他は npm の `@modelcontextprotocol/server-*` を `npx -y` で起動します（Fetch は Python 版 `mcp-server-fetch` も存在）。✅
>
> ⚠️ **注意**：以前リファレンスにあった GitHub / GitLab / Google Drive / PostgreSQL / Puppeteer / Slack / Brave Search / Sentry / Redis / SQLite などは **archived（非現役）** になり、現在は各ベンダーが自社運用する公式サーバー（下記）に置き換わっています。古い記事の「公式サーバー」リンクは死んでいることがあります。✅

---

## 2. 開発（コーディング・レビュー・テスト）

| サーバー | canonical | 種別 | 用途 |
|---|---|---|---|
| **GitHub** | `github/github-mcp-server`（Go製・公式）。リモート `https://api.githubcopilot.com/mcp/`（OAuth または PAT を Bearer で） | 公式・リモート/ローカル | Issue/PR/コード操作。Anthropicと協業 ✅ |
| **Context7** | `@upstash/context7-mcp`（Upstash） | 公式・ローカル/リモート | **ライブラリの最新ドキュメントを動的注入**。古いAPI知識の事故を防ぐ。エコシステム最人気級 🔶 |
| **Playwright** | `microsoft/playwright-mcp`（Microsoft公式） | 公式・ローカル | ブラウザ操作・E2Eテスト・スクショ。アクセシビリティツリーで構造把握 ✅ |
| **Sentry** | `getsentry/sentry-mcp`。リモート `https://mcp.sentry.dev/mcp`（OAuth） | 公式・リモート | エラー監視・課題の文脈取得 ✅ |
| **Figma（Dev Mode）** | Figma公式 Dev Mode MCP | 公式・ローカル/リモート | デザインのレイアウト・コンポーネント・トークンをコードへ ✅（repo名は要確認 ⚠️） |
| **GitLab** | 旧リファレンスはarchived。現行はGitLab側の公式統合 | 🔶/⚠️ | リポジトリ操作（現行公式repoは要確認） |

> このリポを使うエージェントへ：**「コードを書くとき最新ドキュメントを参照させたい」→ Context7**、**「ブラウザ自動操作」→ Playwright** が定番回答です。

---

## 3. データ / データベース

| サーバー | canonical | 種別 | 用途 |
|---|---|---|---|
| **PostgreSQL（汎用DB）** | `@bytebase/dbhub`（Postgres/MySQL/SQL Server/MariaDB/SQLite対応） | サードパーティ・ローカル | 旧公式Postgresの代替。Claude Code公式docsの例で使用 🔶 |
| **Postgres Pro** | Postgres MCP Pro | サードパーティ・ローカル | 健全性監視・インデックスチューニング ⚠️ |
| **Supabase** | `supabase-community/supabase-mcp` | 公式コミュニティ・ローカル | プロジェクト/DB/auth/storage/edge functions/SQL ✅ |
| **Pinecone** | `pinecone-io/pinecone-mcp`, `pinecone-io/assistant-mcp` | 公式・ローカル | ベクトルDB操作・ドキュメント検索 ✅ |
| **Neon** | Neon公式サーバー（リモート） | 公式・リモート | サーバーレスPostgres管理 🔶 |
| **ClickHouse** | `ClickHouse/mcp-clickhouse` | 公式・ローカル | 本番クラスタクエリ＋chDB（埋め込み版） ✅ |

---

## 4. 生産性 / ドキュメント / タスク管理

ここはリモートMCP（OAuthログインだけで使える）が主流。**コネクタとしても提供**されています（[docs/04](04-connectors.md)）。

| サーバー | エンドポイント/種別 | 用途 |
|---|---|---|
| **Notion** | リモート `https://mcp.notion.com/mcp` | ページ/DB の読み書き。企画・台本管理 🔶 |
| **Slack** | Slack公式リモート（OAuth） | メッセージ・検索。旧リファレンスはarchived 🔶 |
| **Linear** | リモート（Cloudflare上・OAuth） | 課題管理。正確なURLは要確認 ⚠️ |
| **Atlassian（Jira/Confluence）** | リモート `https://mcp.atlassian.com/v1/mcp`（Streamable HTTP・OAuth 2.1。旧 `/v1/sse` は2026-06-30で終了） | 課題・ドキュメント 🔶 |
| **Asana** | リモート `https://mcp.asana.com/v2/mcp`（Streamable HTTP・GA。旧 `/sse` は2026-05-11に終了済み） | プロジェクト/タスク管理 🔶 |
| **Google Drive** | Anthropic Directory経由のコネクタ | ファイル参照。旧リファレンスはarchived 🔶 |

> 🔶 リモートURLは変更され得ます。接続前に各公式ドキュメントで再確認してください。Linear の正確なエンドポイントは本調査で未取得（⚠️）。

---

## 5. 検索 / Web 取得

| サーバー | canonical | 用途 |
|---|---|---|
| **Firecrawl** | `firecrawl/firecrawl-mcp-server`（公式） | Webスクレイピング＋検索。整形済みmarkdownで返す ✅ |
| **Exa** | `exa-labs/exa-mcp-server`。ホスト `https://mcp.exa.ai/mcp` | Web検索・クロール（AI最適化） ✅ |
| **Tavily** | `tavily-ai/tavily-mcp`。リモート `https://mcp.tavily.com/mcp/` | リアルタイム検索・extract・map・crawl ✅ |
| **Brave Search** | 旧リファレンスはarchived。Brave側の現行提供は要確認 | Web検索 ⚠️ |

> エージェント向け：「最新情報を調べさせたい」→ Firecrawl / Exa / Tavily のいずれか。APIキーが必要なものが多いです。

---

## 6. クラウド / インフラ / デプロイ

| サーバー | canonical | 用途 |
|---|---|---|
| **Vercel** | Vercel公式リモートMCP（Streamable HTTP + OAuth 2.1） | デプロイ・プロジェクト管理 🔶 |
| **Cloudflare** | `cloudflare/mcp-server-cloudflare`（公式） | 2,500超のAPIを `search()`/`execute()` の2ツールで。製品別サーバーも ✅ |
| **AWS** | `awslabs/mcp`（公式・複数サーバーのカタログ） | AWS各種。2025-05にSSE廃止→現行トランスポート要確認 ✅/🔶 |
| **Firebase** | Firebase公式（Claude/Codex公式マーケットにも） | プロジェクト/デプロイ/セキュリティルール 🔶 |

---

## 7. 決済 / ビジネス

| サーバー | エンドポイント | 用途 |
|---|---|---|
| **Stripe** | Stripe Agent Toolkit / リモート `https://mcp.stripe.com` | 決済・顧客・請求の操作 🔶 |
| **PayPal / Square(Block) / Intercom / Webflow** | いずれもCloudflare上のリモートMCP（2025-05のMCP Demo Dayで発表） | 各サービス操作 🔶 |
| **HubSpot** | リモート `https://mcp.hubspot.com/anthropic` | CRM操作 🔶 |

> ⚠️ 決済・課金が絡むサーバーは「実行＝お金が動く」ことがあります。エージェントに任せきりにせず、実行前に必ず人間が確認してください（[docs/06](06-セキュリティ.md)）。

---

## 8. リモートMCP（OAuth対応ホスト型）の潮流 🔶

2025-05-01 の Cloudflare「MCP Demo Day」で、Anthropic と Asana / Atlassian / Block(Square) / Intercom / Linear / PayPal / Sentry / Stripe / Webflow が一斉にリモートMCPを公開しました。✅

2025〜2026のトレンドは、ベンダー運用のリモートサーバーが次の同じ形に収斂したこと：

- **Streamable HTTP** トランスポート
- **OAuth 2.1**（audience binding つき）
- **マネージドホスティング**（Cloudflare Workers 等のエッジ）
- **ワンクリック/ログインだけ**で接続

Claude Code 側は、リモートサーバーが 401/403 を返すと自動で OAuth フローを開始し、トークンはOSのキーチェーン等に安全保存されます。✅ Anthropic Directory（claude.ai/directory）のコネクタは同じMCP基盤で、`claude mcp add` でそのまま追加できます。✅

---

## 9. このリポを使うエージェント向け「用途→おすすめ」早見表

| ユーザーの用途 | 第一候補 | 種別 |
|---|---|---|
| コーディング中に最新ドキュメント参照 | Context7 | ローカル |
| ブラウザ操作・E2E | Playwright | ローカル |
| GitHubのPR/Issue操作 | GitHub MCP | リモート/ローカル |
| Webスクレイピング・調査 | Firecrawl / Exa / Tavily | ローカル/リモート |
| Notion/Slack/Driveと連携 | 各リモートMCP（コネクタ） | リモート |
| DBにクエリ | dbhub / Supabase / Pinecone | ローカル |
| デプロイ | Vercel / Cloudflare / Firebase | リモート |
| エラー監視 | Sentry | リモート |
| 自社API・社内ツール | **自作**（[knowledge/mcp自作ガイド.md](../knowledge/mcp自作ガイド.md)） | ローカル/リモート |

設定の実物は [mcp/claude-code.mcp.json](../mcp/claude-code.mcp.json)（Claude Code）と [mcp/codex-config.toml](../mcp/codex-config.toml)（Codex）にあります。

---

## 出典

- 仕様/プロトコル: https://modelcontextprotocol.io/specification/2025-11-25 ✅ ／ https://modelcontextprotocol.io/specification/2025-03-26/basic/transports ✅ ／ https://blog.modelcontextprotocol.io/posts/2025-09-08-mcp-registry-preview/ 🔶
- Claude Code の MCP: https://code.claude.com/docs/en/mcp ✅
- リファレンスサーバー: https://github.com/modelcontextprotocol/servers ✅
- 各ベンダー: https://github.com/github/github-mcp-server ✅ ／ https://github.com/microsoft/playwright-mcp ✅ ／ https://github.com/getsentry/sentry-mcp ✅ ／ https://github.com/supabase-community/supabase-mcp ✅ ／ https://github.com/pinecone-io/pinecone-mcp ✅ ／ https://github.com/ClickHouse/mcp-clickhouse ✅ ／ https://github.com/firecrawl/firecrawl-mcp-server ✅ ／ https://github.com/exa-labs/exa-mcp-server ✅ ／ https://github.com/tavily-ai/tavily-mcp ✅ ／ https://github.com/cloudflare/mcp-server-cloudflare ✅ ／ https://github.com/awslabs/mcp ✅
- リモートMCP: https://blog.cloudflare.com/mcp-demo-day/ ✅ ／ https://www.atlassian.com/blog/announcements/remote-mcp-server 🔶

## 未確認・注意事項

- ⚠️ 各サーバーのスター数・DL数（人気指標）はサードパーティ記事の数値で、本リポでは断定しません。
- ⚠️ Notion / Slack / Linear / Neon / HubSpot の**正確なリモートURL**は変わり得ます。接続前に各公式で再確認を。Linear のエンドポイントは未取得。
- ⚠️ GitLab / Brave Search / Google Drive / Figma の**現行ベンダー公式repo名**は一次確認しきれていません。個別に裏取りしてください。
- 🔶 「リモートMCPサーバー数の急増」などの集計値はサードパーティ由来で未検証です。
