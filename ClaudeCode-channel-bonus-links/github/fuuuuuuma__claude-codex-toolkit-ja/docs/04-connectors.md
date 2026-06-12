# 04. コネクタ（Connectors）— Claude アプリで外部サービスにつなぐ

> 「コネクタ」は、Claude（claude.ai / Claude Desktop / Cowork / モバイル）を外部アプリに接続し、データ取得とアクション実行を可能にする仕組みです。**中身はMCPサーバー**で、それをログインだけで使える形にしたもの。MCP の技術用語を知らなくても使えるのがコネクタの役割です。2026-06時点、docs.claude.com / support.claude.com / anthropic.com に基づきます。

確度マーク：✅ 公式確認 ／ 🔶 流動的 ／ ⚠️ 未確認・二次情報

---

## 1. コネクタ・MCP・プラグインの関係（混同注意）

公式の説明をかみ砕くと、層はこうなります。✅

```
コネクタ（Connector）        ← claude.ai / Desktop の「ログインして繋ぐ」体験・実装層
   ├─ Web/リモート: Anthropicのクラウド → リモートMCPサーバー（OAuth, HTTPS）
   └─ Desktop Extension(.mcpb): ローカルMCPサーバーをワンクリック導入
MCP（Model Context Protocol）  ← Anthropic制定のオープン標準（土台）
MCPサーバー                    ← ツール/リソースを公開する実体（remote / local）
```

- **コネクタはユーザー体験の層**、**MCPサーバーは実体**。コネクタの中身はMCPサーバーです。✅
- リモートコネクタでは、Claude は **Anthropic のクラウドから**リモートMCPサーバーに接続します（あなたのPCからではない）。だからサーバーは公開到達可能である必要があります。✅
- ⚠️ Claude.ai のコネクタ体系に「プラグイン」という層は公式には登場しません。Claude Code の「プラグイン」とは別概念です。

利用範囲（プラン）🔶：
- ディレクトリのWebコネクタ … 全ユーザー
- カスタム/リモートMCP … Free（1個まで）/ Pro / Max / Team / Enterprise

---

## 2. 第一者コネクタ（Anthropic 提供・ログインだけ）✅

公式 overview が明示する第一者（first-party）コネクタは次の6つ：

| コネクタ | 用途 |
|---|---|
| **Google Drive** | ファイル参照・検索 |
| **Gmail** | メール参照 |
| **Google Calendar** | 予定参照 |
| **GitHub** | リポジトリ・Issue・PR |
| **Slack** | メッセージ・検索 |
| **Microsoft 365** | Office系ドキュメント |

> 🔶 Google Workspace 系は read+create 中心で、移動・リネーム・削除など一部の書き込み操作に制限があるとの報告（GitHub issue ベース・継続変動）。最新の可否は公式で確認を。

---

## 3. コネクタ・ディレクトリ（サードパーティ・検証済み）✅

`claude.com/connectors`（旧称 Connectors Directory）は、**サードパーティ開発者が作り維持し、Anthropic が検証（vetted）した MCP サーバーのカタログ**です。公式は「Each connector provider has their own terms and privacy policy」と明記。各社の規約・プライバシーが適用される点に注意。✅

ディレクトリで確認できた具体名（一部）🔶：

- タスク/PM：**Asana / Atlassian Rovo（Jira/Confluence系）/ Linear**
- ドキュメント/デザイン：**Notion / Canva / Figma**
- データ/分析：**Airtable / Amplitude / Ahrefs**
- 営業/CRM：**Apollo.io / Attio / ActiveCampaign / HubSpot**
- 決済/金融：**Stripe / PayPal / Square / Plaid**（掲載・公式/三者別は要確認 ⚠️）
- 監視/インフラ：**Sentry / Cloudflare**

> ⚠️ ディレクトリの**正確な掲載総数**は時期で大きく変わります（二次情報では数十〜400件超と幅がある）。本文に数値を固定せず、**`claude.com/connectors` の実ページを都度参照**するのが安全です。

---

## 4. Desktop Extension（.mcpb）— ワンクリックでローカルMCP導入 ✅

Claude Desktop に**ローカルMCPサーバーをワンクリックで入れる**パッケージ形式です。MCPサーバーを依存関係ごと単一ファイルにまとめます。

- 発表：2025-06-26。✅
- ファイル形式：当初 `.dxt` → **現 `.mcpb`（MCP Bundle）**。2025年後半に改名（既存 `.dxt` も動くが新規は `.mcpb` 推奨）。🔶
- インストール：`.mcpb` をダウンロード → ダブルクリック → Install。「ターミナル不要・設定ファイル不要・依存衝突なし」。✅
- 作る側：`npm install -g @anthropic-ai/mcpb` → `mcpb init`（マニフェスト生成）→ `mcpb pack`（バンドル化）。仕様はOSS化されている（リポジトリ名は `anthropics/dxt` から移行中のため要確認）。🔶
- 特徴：パッケージするのは**ローカルMCPサーバー**で、データを端末に保持。リモートコネクタとは対照的。✅

> 「リモートコネクタ」と「Desktop Extension(.mcpb)」の違い＝**前者はクラウドのサーバーにOAuthで繋ぐ／後者は自分のPCでサーバーを動かす**。プライバシー重視ならローカル、手軽さ重視ならリモート、と覚えると整理できます。

---

## 5. カスタムコネクタ / リモートMCP を自分で追加する ✅

### 個人（Pro / Max）

1. Customize > Connectors
2. 「+」→「Add custom connector」
3. リモートMCPサーバーの **URL** を入力
4. （任意）Advanced settings で OAuth Client ID / Secret
5. 「Add」

### Team / Enterprise（Owner のみ）

1. Organization settings > Connectors
2. 「Add」→「Custom」→「Web」
3. URL入力、（任意）OAuth資格情報 → 「Add」
4. メンバーは Customize > Connectors から「Connect」して各自認証

> ⚠️ 公式の警告：「カスタムコネクタは Anthropic が検証していない任意のサービスに Claude を繋げる」。**信頼できるサーバーのみ**接続し、要求される権限を確認してください（[docs/06](06-セキュリティ.md)）。✅

---

## 6. エンタープライズ / 管理者管理 ✅

組織オーナーは次を制御できます：

- コネクタを組織全体で有効化
- アクション制限（read-only か書き込み可か）
- プライベートプロジェクト内に利用を限定
- 「同期コンテンツを含むチャットは共有不可（Chats with synced content can't be shared）」

組織で有効化しても、各メンバーは個別にOAuth認証が必要です。✅

---

## 7. コンテンツ制作者（YouTube/SNS運用）に効くコネクタ

公式ディレクトリ掲載で制作運用に直結するもの 🔶：

- **Canva** … サムネ・グラフィック制作
- **Figma** … デザイン
- **Notion** … 企画・台本・カレンダー
- **Google Drive / Gmail / Google Calendar**（第一者）… 素材・連絡・スケジュール
- **Slack**（第一者）… チーム連絡
- **Asana / Linear / Atlassian Rovo** … 制作タスク管理
- **Ahrefs** … SEO・キーワード調査

> ⚠️ **YouTube / TikTok / Instagram の「公式コネクタ」が Anthropic ディレクトリに存在するかは未確認**です。SNS媒体への直結は、サードパーティMCPやカスタムコネクタ（自分でURL登録）での対応が前提になる可能性が高いです（推測・要検証）。これらは [docs/03-mcp-servers.md](03-mcp-servers.md) の自作や専用MCPで補う形になります。

---

## 出典

- コネクタ概要: https://claude.com/docs/connectors/overview ✅
- コネクタを使う（support）: https://support.claude.com/en/articles/11176164-use-connectors-to-extend-claude-s-capabilities ✅
- カスタムコネクタ（リモートMCP）: https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp ✅
- コネクタ・ディレクトリ: https://claude.com/connectors ✅ ／ ブログ https://claude.com/blog/connectors-directory 🔶
- Desktop Extensions: https://www.anthropic.com/engineering/desktop-extensions ✅ ／ OSS（`.mcpb` 仕様。リポジトリ名は要確認）🔶
- ローカルMCP（Desktop）: https://support.claude.com/en/articles/10949351-getting-started-with-local-mcp-servers-on-claude-desktop ✅

## 未確認・注意事項

- ⚠️ ディレクトリの掲載総数・「Aマークで第一者を区別」説・公開開始日（2025-07-14）は二次情報で、本リポでは断定しません。
- 🔶 Google Workspace コネクタの書き込み制限は GitHub issue ベース。変動が速いので最新を公式で確認。
- 🔶 金融系コネクタ（Stripe/PayPal/Square/Plaid）の掲載・公式/三者別は `claude.com/connectors` 実ページで都度確認を。
- ⚠️ YouTube/TikTok/Instagram 等 SNS媒体の公式コネクタの有無は未確認。
