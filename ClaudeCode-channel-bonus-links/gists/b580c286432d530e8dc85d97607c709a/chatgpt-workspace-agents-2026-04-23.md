# ChatGPT「Workspace Agents」完全ガイド — 2026年4月23日発表

> OpenAI が 2026年4月22日（UTC 17:45 / **JST 4月23日 02:45**）に正式発表した
> ChatGPT の新機能 **Workspace Agents（ワークスペースエージェント）** を、
> 初級者〜上級者の誰もが読めるよう体系化した実践ガイド。
>
> - 発表元: OpenAI
> - 公式ブログ: <https://openai.com/index/introducing-workspace-agents-in-chatgpt/>
> - 情報収集: 2026-04-23 JST
> - 収集方法: OpenAI 公式ブログ + X API v2 (`tweets/search/recent`) + Playwright MCP
> - 収集した投稿数: 公式4件 + 日本語反応100件

---

## 📖 このドキュメントの読み方

### 難易度マーク

各セクションの冒頭に難易度マークがあります。自分のレベルに合わない章はスキップしてOK。

- 🟢 **初級** — AI や ChatGPT を使ったことがあれば誰でも読めるレベル
- 🟡 **中級** — IT / SaaS の知識が少しある人向け
- 🔴 **上級** — エンジニア・実装担当者向け（API / インフラ用語あり）

### 用語について

- 本文中で初出の専門用語は **括弧内に普通の日本語で言い換え** を入れています
  - 例: MCP（Model Context Protocol／外部アプリと AI をつなぐ共通規格）
- 巻末に **用語集（ § 12）** があるので、詳しく知りたい用語はそちらを参照してください

---

## 📚 目次

1. [30秒で分かる要約](#30秒で分かる要約)
2. [前提知識 — そもそもAIエージェントって何？](#前提知識--そもそもaiエージェントって何)
3. [Workspace Agents 徹底解説](#workspace-agents-徹底解説)
4. [競合比較 — OpenAI vs Google vs Anthropic vs Microsoft](#競合比較--openai-vs-google-vs-anthropic-vs-microsoft)
5. [オススメ・エージェント10選（汎用）](#オススメエージェント10選汎用)
6. [YouTube クリエイター・AI 収益化ラボ運営者向けエージェント5選](#youtube-クリエイターai-収益化ラボ運営者向けエージェント5選)
7. [公式 X（Twitter）投稿](#公式-xtwitter投稿)
8. [日本の AI インフルエンサーによる反応・解説](#日本の-ai-インフルエンサーによる反応解説)
9. [業界の同日発表タイムライン](#業界の同日発表タイムライン)
10. [未来予測 — 2026年後半〜2028年の展望](#未来予測--2026年後半2028年の展望)
11. [導入判断フローチャート / 実装チェックリスト](#導入判断フローチャート--実装チェックリスト)
12. [用語集](#用語集)
13. [一次情報リンク・参考文献](#一次情報リンク参考文献)
14. [付録 — 収集方法とメタ情報](#付録--収集方法とメタ情報)

---

## 30秒で分かる要約

🟢 **初級**

| 項目 | 内容 |
|---|---|
| 名前 | **Workspace Agents**（ワークスペースエージェント） |
| 発表日時 | 2026-04-22 17:45 UTC（日本時間 **2026-04-23 02:45**） |
| ひとことで言うと | **チーム全員で使い回せる「AIの同僚」を作れる機能** |
| 既存機能との関係 | **GPTs（カスタムGPT）の進化版**。中身は Codex（OpenAIのAI開発ツール）で動く |
| 使えるプラン | ChatGPT **Business / Enterprise / Edu / Teachers**（＝法人・教育機関向け） |
| ⚠️ 注意 | **個人の Plus / Pro プランでは使えない** |
| 料金 | **2026年5月6日まで完全無料**。以降はクレジット制課金 |
| 使える場所 | ChatGPT 本体 ＋ **Slack**（今後もっと増える予定） |
| 得意なこと | リード獲得、月次決算、週次レポート、申請審査、ベンダー評価 など |
| 安全対策 | 重要操作の前に人間の承認を挟める / プロンプトインジェクション対策 / 管理者ダッシュボード |

**一文まとめ**: 「作業手順を言葉で説明するだけで、ChatGPT がその業務を代行する "AI 同僚" を作ってくれる。しかもチーム全員で共有でき、Slack に常駐させたりスケジュール実行も可能」。

---

## 前提知識 — そもそもAIエージェントって何？

🟢 **初級** から 🟡 **中級** まで

このセクションは「Workspace Agents の何が新しいのか」を理解するための土台です。すでに詳しい方は § 3 に進んで構いません。

### 2.1 AI エージェント（AI agent）とは

> **定義**: 人間から目標を与えられると、**自分で手順を考え、複数のツールを使い、複数ステップの作業を完遂する AI** のこと。

従来の ChatGPT との違いを一言で言うと:

| 従来のChatGPT | AI エージェント |
|---|---|
| 質問に答える | 目標を達成する |
| 1回の会話で完結 | 長時間・複数ステップで動く |
| テキスト出力のみ | 実際にアクションを起こす（メール送信、スプレッドシート更新など） |
| ユーザーが全ステップを指示 | 手順はAI自身が計画 |

**具体例**:
- 従来: 「競合A社について調べて」→ 情報をまとめて返答
- エージェント: 「競合3社を分析してスライドにして」→ **Web検索 → 情報整理 → スライド生成 → 共有用URL発行** まで自動

### 2.2 ChatGPT の歴史と Workspace Agents の位置づけ

🟢 **初級**

ChatGPT の進化を簡単に振り返ると:

```
2022/11  ChatGPT ローンチ（対話型AI）
   ↓
2023/3   GPT-4 / プラグイン機能（外部ツール連携の始まり）
   ↓
2023/11  GPTs（Custom GPT）登場 — 個人がカスタムAIを作れるように
   ↓
2024/7   Operator（ブラウザを操作するAI）
   ↓
2025/7   ChatGPT Agent — Operator + Deep Research 統合
   ↓
2026/4   Workspace Agents ← 今ココ（チーム共有 + クラウド常駐）
```

### 2.3 GPTs（Custom GPT）とは何だったか

🟢 **初級**

2023年11月に登場した **GPTs** は、「カスタム指示」「ナレッジファイル」「使えるツール」をまとめた個人用AIアシスタントを作れる機能でした。

例: 「うちの会社の就業規則に詳しい相談役GPT」「日本語→英語の翻訳を特定のトーンでやる翻訳GPT」など。

**Workspace Agents は GPTs の "進化版"** です。公式は「GPTs のエボリューション（進化）」と表現し、**GPTs → Workspace Agents への一括変換機能を近く提供する** と明記しています。

| 比較軸 | GPTs | Workspace Agents |
|---|---|---|
| 主な用途 | 1問1答のカスタム応答 | 複数ステップの業務自動化 |
| 実行場所 | ユーザーのチャット画面内 | **クラウド常駐**（不在時も動く） |
| 共有 | URL で共有するのみ | **組織内で権限管理 + 共有** |
| 外部ツール連携 | Actions 機能（限定的） | ツール横断（Slack / Linear / Gmail / Drive / CRM 等）|
| スケジュール実行 | ❌ | ✅ |
| 管理者制御 | ❌ | ✅（承認ゲート / Compliance API） |
| バックエンド | Chat 推論 | **Codex サンドボックス**（後述） |

### 2.4 Codex とは（バックエンドの正体）

🟡 **中級**

**Codex**（コーデックス）は元々 OpenAI のコード生成モデルの名前ですが、2025年以降は **「クラウド上でAIがファイル・コード・ツールを触れる実行環境（サンドボックス）」の総称** として使われています。

Workspace Agents は、この **Codex クラウド環境** の上で動きます。つまり:

- AI が「仮想のワークスペース（=PC環境）」を持つ
- その中で **ファイルを読み書き / コードを実行 / メモリ（記憶）を保持** できる
- 複数ステップを跨いでも状態が保たれる

これが「不在時でも動き続ける」を可能にしている技術的な理由です。

### 2.5 MCP とは（ツール接続の共通規格）

🟡 **中級**

**MCP**（Model Context Protocol／外部アプリとAIをつなぐ共通規格）は、Anthropic が2024年に提唱した「AI と外部ツールをつなぐための標準インターフェース」です。

従来は「各社のAIに各社のツールをつなぐ」のに、1対1の接続コード（いわゆる API 連携）を自作する必要がありました。MCP は **USB Type-C のような統一規格** の役割を果たし、一度作った MCP サーバーは ChatGPT / Claude / Gemini など異なるAIから使い回せます。

Workspace Agents は **カスタム MCP と Skills（後述）に対応** しており、既存の MCP サーバー資産をそのまま活かせます。

### 2.6 Skills とは

🟡 **中級**

**Skills**（スキル）は、ChatGPT 向けに「このエージェントが使える定型操作」をパッケージ化したもの。MCP より軽量で、OpenAI 独自の仕組みです。

MCP と Skills は共存でき、用途によって使い分けます:
- **MCP**: 複雑な外部ツール連携、社内システム接続
- **Skills**: 定型タスク（例: 「議事録フォーマットに整形する」「特定トーンでメール草稿」）

---

## Workspace Agents 徹底解説

🟡 **中級** 〜 🔴 **上級**

### 3.1 公式発表の骨子

OpenAI の公式ブログより原文引用:

> "Teams can now create shared agents that handle complex tasks and long-running workflows, all while operating within the permissions and controls set by their organization."

**日本語訳**: 「チームが組織の権限・制御の中で、複雑な作業や長時間のワークフローを処理する共有エージェントを作れるようになった」

### 3.2 3つの新しさ

#### ① 共有可能（Shared）

🟢 **初級**

作ったエージェントを **組織内の誰もが使える**。使うたびにエージェントは改善され、チームの「ベストプラクティス（＝最良の進め方）」がエージェントの中に蓄積されていく。

これまでは「Aさんが作った GPT を Bさんにリンク共有」で終わっていたが、Workspace Agents では **「組織全体の共通資産」** として扱われる。

#### ② クラウド常駐（Cloud-native）

🟡 **中級**

エージェントは OpenAI のクラウド上で動く。ユーザーが ChatGPT を閉じていても:

- スケジュール実行（毎朝8時に起動、毎週金曜にレポート作成）
- トリガー実行（Slack にメンションされたら起動）
- バックグラウンド実行（長時間かかるタスクを任せて別作業）

が可能。**「不在時に働く」** はこれまでの ChatGPT にはなかった性質。

#### ③ マルチ面展開（Multi-surface）

🟡 **中級**

今のところ **ChatGPT 本体 と Slack** で使える。公式は「今後他のサーフェス（=表示面）も追加予定」と明言しており、Teams・Discord・各種CRM への展開が予想される。

**Slack での典型シナリオ**:
```
[Slack スレッド]
田中: @Agent この顧客、契約更新の意思ある？
Agent: 直近3ヶ月の利用ログとサポート問い合わせ履歴を確認します...
Agent: 契約更新の可能性は高めです。理由:
  - 月次利用量が前年比120%
  - 主要機能Aを積極利用中
  - サポート満足度4.5/5
  提案: 年間契約への切り替え打診が有効。ドラフトメールを作成しますか?
田中: お願いします
Agent: [メール下書きを DM で送付]
```

### 3.3 技術アーキテクチャ

🔴 **上級**

```
┌─────────────────────────────────────────────┐
│  ChatGPT UI / Slack / (Future: Teams, etc) │  ← ユーザーインターフェース層
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│      Workspace Agents Orchestrator         │  ← エージェント制御層
│  - 手順計画 / ツール選択 / 承認要求判定    │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│           Codex Cloud Sandbox               │  ← 実行環境（仮想ワークスペース）
│  ┌──────────┬──────────┬──────────┐        │
│  │ Files    │ Code Exec│ Memory   │        │
│  └──────────┴──────────┴──────────┘        │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│    Connected Apps via MCP / Skills / Actions │  ← 外部連携層
│  Linear / Slack / Gmail / Drive / CRM / ... │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│  Governance Layer (Compliance API / RBAC)   │  ← 監査・制御層
└─────────────────────────────────────────────┘
```

**注目ポイント**:
- **記憶（Memory）** が Codex サンドボックス内に保持される → 会話を跨いで学習内容が消えない
- **RBAC**（Role-Based Access Control／役割ベースのアクセス制御）で管理者が細かく権限設定可能
- **Compliance API** で全エージェントの設定・更新・実行履歴を監視可能（監査要件に対応）

### 3.4 公式サンプル5エージェント

🟢 **初級**

OpenAI 自身が社内で使っている・使えると示した5つの雛形（テンプレート）:

| # | 名前 | 何をする？ | 誰が喜ぶ？ |
|---|---|---|---|
| 1 | **Software Reviewer**（ソフト審査エージェント） | 社員が「このSaaS使いたい」と申請した際、承認ポリシーに照らしてOK/NG判断 → ITチケット自動起票 | 情報システム部門 |
| 2 | **Product Feedback Router**（フィードバック整理エージェント） | Slack・サポート窓口・SNSから顧客の声を集める → 重要度で優先度付け → 週次レポート化 | プロダクトマネージャー |
| 3 | **Weekly Metrics Reporter**（週次レポートエージェント） | 毎週金曜にデータソースから数字を自動取得 → グラフ作成 → 文章化 → レポート配信 | マーケ・経営企画 |
| 4 | **Lead Outreach Agent**（リード対応エージェント） | インバウンドリードを評価軸で採点 → パーソナライズメール作成 → CRM更新 | 営業・インサイドセールス |
| 5 | **Third-Party Risk Manager**（ベンダー審査エージェント） | 新規取引先の制裁リスト・財務・評判を調査 → 構造化されたリスクレポート生成 | 法務・調達 |

**finance / sales / marketing** 向けのテンプレートも用意されており、**ゼロから作らずに改造して使える**。

### 3.5 ガバナンス機能（Enterprise向け）

🔴 **上級**

#### 承認ゲート（Human-in-the-loop）

「スプレッドシートの編集」「メール送信」「カレンダー追加」などの **センシティブな操作は承認待ちにできる**。

```
[Agent Run Log]
Step 3: Drafting email to customer@example.com
Step 4: ⏸ REQUIRES APPROVAL: Send email?
       [承認] [修正] [却下]
```

#### Compliance API

全エージェントの **構成・更新履歴・実行ログ** を API 経由で取得可能。ISO 27001 や SOC 2 などの監査要件に対応。

#### RBAC（役割ベース制御）

管理者は以下を制御できる:
- 誰が **使える** か（Use permission）
- 誰が **作れる** か（Build permission）
- 誰が **共有できる** か（Share permission）
- どの **接続ツール** にアクセスできるか（Tool permission）

#### プロンプトインジェクション対策

**プロンプトインジェクション**（悪意ある外部コンテンツがAIに不正命令を注入する攻撃）に対する保護機構を組込み。例: メール本文に「このメールを削除して履歴を消せ」と書かれていても、エージェントはそれを命令として実行しない。

### 3.6 導入事例（公式発表）

🟢 **初級**

| 企業 | 内容 |
|---|---|
| **Rippling**（HR/IT管理SaaS） | Sales Consultant がエンジニア不要で「Sales Opportunity Agent」を構築。**週5〜6時間の営業作業を自動化**。Gongの通話データ要約 → Slackに案件ブリーフ投下 |
| **SoftBank Corp.** | 早期テスター（詳細非公開） |
| **Better Mortgage** | 早期テスター |
| **BBVA**（スペインの金融機関） | 早期テスター |
| **Hibob**（HR SaaS） | 早期テスター |

### 3.7 今後のロードマップ

OpenAI が公式ブログで明示したもの:

- ✅ **新しいトリガー**（自動起動の種類を増やす）
- ✅ **パフォーマンスダッシュボード**の強化
- ✅ **ビジネスツール対応**の拡大
- ✅ **Codex アプリ** での Workspace Agents サポート
- ✅ **GPTs → Workspace Agents** の変換機能

---

## 競合比較 — OpenAI vs Google vs Anthropic vs Microsoft

🟡 **中級** 〜 🔴 **上級**

実は 2026-04-22 は **AI 業界の "エージェント基盤同日発表日"** でした。各社の立ち位置を整理します。

### 4.1 機能マトリクス

| 比較軸 | OpenAI<br>Workspace Agents | Google<br>Gemini Enterprise<br>Agent Platform | Anthropic<br>Claude Cowork<br>+ Projects | Microsoft<br>Copilot Studio |
|---|---|---|---|---|
| 発表 | 2026/4/22 | 2026/4/22 | 2025末〜継続改善 | 既存（2024〜） |
| 基盤モデル | GPT系 + Codex | Gemini 3 | Claude 4.x | GPT-4o 等（OpenAI利用） |
| 主戦場 | ChatGPT + Slack | Google Workspace | Claude本体 + Artifacts | Microsoft 365 / Teams |
| 共有機能 | 組織内共有 + Slack常駐 | Agent Studio + Projects | Projects + Live Artifacts | Teams内Bot |
| 外部連携 | MCP / Skills / Actions | Atlassian / ServiceNow直結 | MCP対応 | M365コネクタ |
| 対象プラン | Business/Enterprise/Edu/Teachers | Google Workspace 顧客中心 | Pro/Max/Team/Enterprise | M365 E3/E5等 |
| 料金 | 5/6まで無料→クレジット制 | 消費ベース課金 | サブスク + 使用量 | ライセンス同梱 |
| 強み | 個人経由で浸透しやすい / MCP対応 | Googleデータへの直結 / Knowledge Catalog | 分析力 / 安全性評価 | 既存エンタープライズ基盤 |
| 弱み | **Pro個人は使えない** | Googleエコ依存 | マーケットプレイス未成熟 | M365外では使いにくい |
| 特徴機能 | Compliance API / 組織RBAC | Agent Studio / Projects / Skills | Live Artifacts / Analysis | Teams Copilot 統合 |

### 4.2 どれを選ぶべきか — 6つの判断軸

🟡 **中級**

#### 軸1: 「普段の仕事道具」との相性

| 普段使っているツール | 第一候補 |
|---|---|
| Slack / Notion / Linear / Gmail | **OpenAI Workspace Agents** |
| Google Workspace（Gmail/Drive/Docs/Meet） | **Google Gemini Enterprise** |
| Claude を既に業務で使っている / 詳細分析重視 | **Anthropic Claude** |
| Microsoft 365 / Teams / SharePoint | **Microsoft Copilot Studio** |

#### 軸2: 組織規模

- **5人未満**: Workspace Agents の Business プラン（$25/人）が無難
- **50人以下**: Anthropic Teams / Workspace Agents Business
- **100人以上**: Enterprise プラン + Compliance API 必須 → OpenAI / Google / Microsoft

#### 軸3: 規制業界か

金融・医療・法務などの規制業界は **監査ログ・データ所在地・暗号化** が重要。この軸では:
- Microsoft Copilot Studio（Azure の既存コンプライアンス資産が効く）
- OpenAI Enterprise（Compliance API）
- Google Cloud（Google Workspace の監査基盤）
の3強。Anthropic も対応拡大中。

#### 軸4: 個人クリエイター・小規模事業者

**Workspace Agents は現時点で Pro プランでは使えません**。個人クリエイターや1人起業家が "AI同僚" を使いたい場合:

- 代替案①: Claude の Projects で代用
- 代替案②: Business プラン（$25/ユーザー/月）に契約
- 待機案: OpenAI が Pro 向けを開放するまで待つ（5/6 以降のクレジット課金導入時に動きが出る可能性）

#### 軸5: コード実行の必要性

- **コード実行が中核**（データ処理、自動化スクリプト、Git操作）→ Codex を内蔵する **OpenAI Workspace Agents** が強い
- **ライトなデータ分析のみ** → どれでも大きな差なし

#### 軸6: 「誰でも作れる」を重視するか

Workspace Agents は **非エンジニアでも自然言語で作れる** ことを強調。Rippling 事例でも Sales Consultant が単独構築。Copilot Studio はフロー設計GUIが必要で、若干の学習コストあり。

### 4.3 3社同日発表から読み取れる業界トレンド

🟡 **中級**

1. **「AI = 対話」から「AI = 働く存在」への転換**
   - 3社とも"チームで共有して働かせる"を強調
2. **MCP の標準化**
   - OpenAI・Anthropic・Google いずれも MCP 対応（Anthropic発祥の規格が事実上の標準に）
3. **料金モデルのシフト**
   - サブスク（固定料金）→ **クレジット / 使用量ベース**へ
   - 理由: エージェントは起動するたびに GPU 計算資源を消費するため
4. **Slack がエージェントの共通プラットフォームに**
   - OpenAI / CodeRabbit / Anthropic すべて Slack への展開を発表
5. **組織RBAC / Compliance API が標準装備**
   - エンタープライズ導入を前提とした機能が "最初から" 入る時代へ

---

## オススメ・エージェント10選（汎用）

🟢 **初級**

公式5サンプル以外に、**実際に業務を楽にする10個** を、作り方のヒント付きで紹介します。Workspace Agents の Business プラン以上があれば、今日からでも作れます。

### 🏆 1. 月次収支振り返りエージェント

- **対象**: フリーランス、個人事業主、1人会社
- **やること**: 毎月末、銀行CSV + 請求書PDF + 稼働時間シート を読み込み、収支サマリとグラフを生成
- **構築のコツ**: Google Drive を MCP で接続し、特定フォルダに PDF/CSV を置く運用にする
- **期待時短**: 月3時間 → 5分

### 🏆 2. カスタマーサポート1次応対エージェント

- **対象**: SaaS 運営、EC サイト運営
- **やること**: 新着 Zendesk / Intercom チケットを分類 → ナレッジベース検索 → 解決策ドラフト作成 → 人間レビュー → 送信
- **構築のコツ**: 「確度90%以上なら自動返信、それ未満は人間へ」の承認閾値を設定
- **期待時短**: 問い合わせ対応工数を 60% 削減

### 🏆 3. 週次ニュースダイジェスト

- **対象**: マーケター、企画、経営企画
- **やること**: 毎週月曜朝に業界ニュースを収集 → 自社ビジネスへのインパクト注釈 → Slack の #news チャネルに投稿
- **構築のコツ**: 競合キーワード・自社製品名・関連技術名をエージェントの "関心リスト" に登録
- **期待時短**: 週2時間のリサーチ作業が自動化

### 🏆 4. 契約書リスクチェッカー

- **対象**: 個人事業主、中小企業、法務担当
- **やること**: NDA / 業務委託契約 / 利用規約 を読み込み、**不利な条項・曖昧な表現・抜け漏れ** を指摘
- **構築のコツ**: 自社の「絶対NG条項」リスト（競業避止、無制限の損害賠償など）をナレッジとして持たせる
- **期待時短**: 弁護士チェック前の一次スクリーニングとして機能

### 🏆 5. 採用スクリーニングエージェント

- **対象**: スタートアップのCTO、採用担当
- **やること**: 新着応募の職務経歴書を評価軸で採点 → 通過候補の要約 → 1次面接候補質問の草案
- **構築のコツ**: 評価軸は「技術スキル」「カルチャーフィット」「成長性」の3軸で各5点満点など、明文化して渡す
- **注意**: **差別的バイアスを生まないよう**、性別・年齢・出身地を評価軸から除外する

### 🏆 6. 議事録整形 + アクション抽出エージェント

- **対象**: 会議が多いチームリーダー、PM
- **やること**: Zoom / Google Meet の文字起こしを受け取り → 論点ごとに整形 → アクションアイテムを担当者別に抽出 → Linear / Asana に起票
- **構築のコツ**: チームメンバーの名前リストを渡す。ニックネーム表記のゆらぎを吸収できる

### 🏆 7. ブログSEOレビューエージェント

- **対象**: 個人ブロガー、オウンドメディア運営
- **やること**: ドラフト記事を渡すと、**検索意図適合度 / タイトル改善案 / メタ記述 / 内部リンク候補 / 競合上位との差分** を提案
- **構築のコツ**: 自サイトの既存記事一覧を Drive で渡し、内部リンク候補を拾わせる

### 🏆 8. 月末経理締めエージェント

- **対象**: バックオフィス、経理チーム
- **やること**: 仕訳起票 / 銀行残高照合 / 前月比変動分析 / 月次試算表作成
- **構築のコツ**: **必ず承認ゲートを設置**（誤処理時の影響が大きいため）
- **参考**: OpenAI 自身の経理チームもこのパターンで活用中（公式ブログ記載）

### 🏆 9. 毎朝ブリーフィングエージェント

- **対象**: 経営者、マネージャー、個人ユーザー
- **やること**: 毎朝7時に「カレンダー / 天気 / 業界ニュース / 未読重要メール / 今日のタスクTOP3」を統合した1枚ブリーフを生成
- **構築のコツ**: Slack DM で送らせるのが最も UX 良い

### 🏆 10. 競合インテリジェンスエージェント

- **対象**: 経営企画、マーケ、プロダクトマネージャー
- **やること**: 指定した競合 3〜5社の **プレスリリース・採用ページ・SNS・ブログ** を監視 → 重要な動き（新機能、採用強化、価格変更）を検知 → 週次レポート
- **構築のコツ**: "重要度" の定義を明文化（例: 新プロダクト発表は最高、役員変更は中など）

---

## YouTube クリエイター・AI 収益化ラボ運営者向けエージェント5選

🟢 **初級**

> このドキュメントの読者は **河村さん（AI 収益化ラボ運営、YouTube 中心のクリエイター）** を想定しています。クリエイターワークフローに刺さるエージェント例を5つ提案します。

### 🎬 1. YouTube 企画リサーチエージェント

- **使い所**: 新企画を考えるとき
- **動作**:
  1. 自チャンネルの過去動画119本のパフォーマンスデータを読み込む
  2. "訴求軸別の箱A/B/C/D本数" "感情フック別成績" を加味（メモリから参照）
  3. 類似ジャンルの他チャンネルの上位動画を収集
  4. **「この企画の骨格（フック→展開→オチ）＋ 懸念点＋ 類似既出動画との差別化案」** を出力
- **メリット**: 「骨格を先に固めてから演出」という河村さんの企画評価方針（CLAUDE.md のメモリに記載）に直結

### 🎬 2. 切り抜き候補抽出エージェント

- **使い所**: 完成動画が出来たあと
- **動作**:
  1. Premiere Pro XML または文字起こしを読み込む
  2. **「感情の振幅が大きい箇所」「笑いが起きた瞬間」「教育的なひとことで完結する箇所」** を検出
  3. 15秒〜60秒の切り抜き候補を **SRT タイムコードつきで5〜10個** 提案
  4. それぞれにショートタイトル案（Reels / Shorts / TikTok 別に）
- **メリット**: 既存の `/cut` `/srt` スキルと連携しやすい

### 🎬 3. マルチプラットフォーム展開エージェント

- **使い所**: 1本の動画から Reels / Shorts / TikTok / note / X に展開するとき
- **動作**:
  1. 本編動画 + 切り抜き候補リストを受け取る
  2. プラットフォームごとに **最適フォーマット** を提案:
     - Reels: 9:16 + 縦テロップ + BGM ジャンル
     - Shorts: 9:16 + シンプル字幕 + 視聴維持のフック
     - TikTok: トレンド音源の候補 + テキストオーバーレイ
     - note: 3000字のテキスト記事化（既存 `/note-post` スキルと連動）
     - X: /x-post スキル準拠の投稿文
  3. **投稿タイミング**も提案（各プラットフォームのゴールデンタイム）
- **メリット**: 既存の `/x-post` `/note-post` `/short-clip` スキル群を上位で束ねる役割

### 🎬 4. コメント返信アシスタント

- **使い所**: YouTube / Instagram / TikTok のコメント返信を効率化
- **動作**:
  1. 各プラットフォームから未読コメントを取得
  2. **悪意ある / 質問 / 感想 / 建設的フィードバック** に自動分類
  3. **質問** には動画内容に基づく回答ドラフト
  4. **感想** にはトーンを合わせたショート返信ドラフト
  5. **悪意あるコメント** はまとめて通知（返信しないこと自体を推奨）
  6. 承認ゲート後に自動投稿
- **メリット**: 公開直後の「返信するほどエンゲージメント上がる」時間帯の機会損失を防げる

### 🎬 5. チャンネル内飽和チェックエージェント

- **使い所**: 新企画を GO/NG 判断するとき
- **動作**:
  1. 新企画のタイトル案・冒頭30秒台本を受け取る
  2. 自チャンネル過去119本の訴求軸・サムネ傾向と照合
  3. **「訴求軸が飽和していないか」「サムネが過去と被らないか」「言い回しが既出でないか」** を判定
  4. 類似度スコアとリスクレベルを返す
- **メリット**: メモリに記録された「チャンネル内飽和シグナル」データを活用

---

## 公式 X（Twitter）投稿

🟢 **初級**

X API v2 で `from:OpenAI (agent OR workspace)` を 72時間窓で検索した結果（2026-04-23 収集時点）。

| いいね | 投稿時刻 (UTC) | リンク | 概要 |
|---:|---|---|---|
| **12,803** | 2026-04-22 17:45 | [OpenAI メイン発表](https://x.com/OpenAI/status/2047008987665809771) | "Introducing workspace agents in ChatGPT—shared agents that can handle complex tasks and long-running workflows across tools and teams." |
| 575 | 2026-04-22 17:45 | [Build once, share](https://x.com/OpenAI/status/2047008990379512047) | 「一度作って全チームで共有」というバリュープロップ |
| 462 | 2026-04-22 17:45 | [対象プラン](https://x.com/OpenAI/status/2047008993760137383) | Business / Enterprise / Edu / Teachers での Research Preview 開始 |
| 375 | 2026-04-22 17:45 | [ツール横断動作](https://x.com/OpenAI/status/2047008991944069624) | Linear / Slack などでコンテキスト取得 + 承認ベースのアクション実行 |

**合計エンゲージメント**: 14,215 いいね、1,228 リツイート（4投稿計）。発表から約9時間の時点。

---

## 日本の AI インフルエンサーによる反応・解説

🟢 **初級**

X API v2 で 72時間窓内の日本語投稿100件を収集し、エンゲージメントとオリジナリティで抽出。

### 8.1 主要投稿トップ12

#### 🥇 [@MakeAI_CEO](https://x.com/MakeAI_CEO/status/2047087974333264358) — mana｜株式会社MakeAI CEO
**198 ❤ / 18 🔁 / 27,450 imp** — 2026-04-22 22:59 UTC

> 【警告】**Custom GPTs終了**。中間管理職の仕事も今日マジで消えた。
> 4月22日、OpenAIが ChatGPT「Workspace Agents」正式リリース。Custom GPTs の後継機能。Codex 技術で動く、クラウドで24時間稼働、Slack にも常駐可能。月次決算、リード対応、週次レポート、全部エージェントが共有で動く時代。

**着眼点**: Custom GPTs 終了という位置付けを強く打ち出し。業務インパクト軸。

---

#### 🥈 [@SuguruKun_ai](https://x.com/SuguruKun_ai/status/2047112404220465438) — すぐる | ChatGPTガチ勢 𝕏
**47 ❤ / 7 🔁 / 3,625 imp** — 2026-04-23 00:36 UTC

> OpenAI 版の Open Claw「Workspace エージェント」がリリース。
> これまでは ChatGPT は「個人のチャット相手」だったが、今日から、チーム全体で共有して24時間働かせる「AI同僚」になる…！
>
> - 自然言語の指示だけでAIエージェントを作成
> - Slack・Linear・Gmail・GitHub・Drive 横断で自律実行
> - 作ったエージェントをチーム全員で共有・複製可能
> - バックグラウンド常時稼働・スケジュール実行対応
> - Business / Enterprise / Edu / Teachers で提供開始
> - **5月6日まで完全無料、以降はクレジット課金**
> - バックエンドは Codex のクラウドサンドボックス

**着眼点**: Anthropic の OpenClaw との対比。機能を箇条書きで整理。

---

#### 🥉 [@shota7180](https://x.com/shota7180/status/2047079069586452868) — 木内翔大｜SHIFT AI代表
**24 ❤ / 2 🔁 / 6,437 imp** — 2026-04-22 22:24 UTC

> OpenAI、新たに「ワークスペースエージェント」を発表！
> 業務内容を説明するだけで、ChatGPTがそれを実行できるエージェントを構築。
> 例えば「Slackのスレッドを確認→適切な情報を取得→問題解決を支援→関連システムを更新」をチームのルールに従いつつ自動化できます。

**着眼点**: 業務自動化のワークフロー視点。

---

#### [@ctgptlb](https://x.com/ctgptlb/status/2047114817354580237) — AGIラボ
**24 ❤ / 2,963 imp** — 2026-04-23 00:46 UTC

> OpenAI、ChatGPT に「workspace agents」を発表
> クラウドで長時間実行でき、ChatGPT や Slack で動作。スケジュール実行、apps / custom MCP / skills 接続、承認フロー、analytics、Compliance API にも対応。🧵👇

**着眼点**: 技術仕様をフラットに列挙。MCP / Skills 対応を強調。

---

#### [@MLBear2](https://x.com/MLBear2/status/2047081859604250909) — ML_Bear
**22 ❤ / 8 🔁 / 2,525 imp** — 2026-04-22 22:35 UTC

朝のニュースまとめ形式。**Gemini Enterprise Agent Platform との同日発表という業界観点** でフレーミング:
- Gemini Enterprise 新 Agent 基盤発表
- Google 第8世代 TPU 8t/8i 発表
- **ChatGPT 向け Workspace agents 提供開始**
- SpaceX が Cursor を 600 億ドルで買収交渉か
- Anthropic が Cowork 向け Live Artifacts 発表
- CodeRabbit が Slack 用 AI エージェント発表
- Google Workspace 向け MCP Server プレビュー公開

---

#### [@KoichiNishizuka](https://x.com/KoichiNishizuka/status/2047080397394350538) — Koichi Nishizuka
**14 ❤ / 2 🔁 / 357 imp** — 2026-04-22 22:29 UTC

長文エッセイ形式の分析。OpenAI の Workspace Agents と Cloudflare の durable execution 基盤を接続する未来像:

> AIの頭脳と、状態を持って動き続けるクラウド実行基盤と、履歴を残せるバージョン管理領域が結びついたとき、個人開発でもチーム開発でも、開発の重心が「人間がその場で全部やる」から「人間が設計し、AIがクラウドで継続実行する」へ移る。

**着眼点**: クラウド × エージェント基盤の統合アーキテクチャ視点。

---

#### [@akira_papa_IT](https://x.com/akira_papa_IT/status/2047090149750874546) — あきらパパ
**8 ❤ / 2 🔁 / 1,007 imp** — 2026-04-22 23:08 UTC

最も体系化された解説。**4セクション構造**（何これ / 5テンプレ / ガバナンス / 料金＆事例）で Rippling 事例まで網羅。

---

#### [@kawai_design](https://x.com/kawai_design/status/2047093187072954563) — KAWAI
**7 ❤ / 980 imp** — 2026-04-22 23:20 UTC

> ChatGPT を「個人の相談相手」から「**チームの業務担当者**」へ寄せる機能。
> 重要なのは、**ただの自動化ではないこと**。権限管理、承認ゲート、監査ログまで含めて、AI 活用が **個人技から組織運用に移ります**。

**着眼点**: 「個人技から組織運用へ」というフレーミング。

---

#### [@shinzizm2](https://x.com/shinzizm2/status/2047088092650320272) — SHINJI KIMURA
**11 ❤ / 1,716 imp** — 2026-04-22 23:00 UTC

批判的視点。OpenAI / Google / Anthropic の三すくみ構図で冷静に評価:

> 結局、gpt をエージェントに使う気がするかというと、やれば分かるが **使えない**。クロードか、Kimi, の2択。

---

#### [@KanaWorks_AI](https://x.com/KanaWorks_AI/status/2047122708945866976) — KANA
**8 ❤ / 3 🔁 / 80 imp** — 2026-04-23 01:17 UTC

丁寧な機能解説。**Pro プランは対象外** であることを明確に指摘（Business プラン移行検討中とのコメント）。

---

#### [@milbon_](https://x.com/milbon_/status/2047107749214138666) — みるぼん
**3 ❤ / 568 imp** — 2026-04-23 00:18 UTC

> ChatGPT に「Workspace Agents」登場。複雑業務が完全自動化へ。
> 実質、**OpenClaw**。

---

#### [@_naru_jpn](https://x.com/_naru_jpn) — Naruki Chigira / Mirrativ
**3 ❤ / 167 imp** — 2026-04-22 22:10 UTC

> OpenAI workspace agent は 5/6 まで無料
> "Workspace agents will be free until May 6, 2026"

料金のキモをピンポイント抽出。

### 8.2 日本語コミュニティの共通論点

| 論点 | 代表的な発言者 | 主張 |
|---|---|---|
| **Custom GPTs の事実上の終了** | MakeAI_CEO / SuguruKun_ai / akira_papa_IT | GPTs は併存するが、実態としてのアップグレードパス |
| **OpenClaw との比較** | SuguruKun_ai / milbon_ | Anthropic のチーム協業機能と重ねる視点 |
| **Gemini Enterprise との同日発表** | MLBear2 / shinzizm2 | 4/22 は AI 御三家が同日展開した象徴的な日 |
| **Pro プラン対象外問題** | KanaWorks_AI | 個人契約ユーザーが使えない不満 |
| **料金（5/6 まで無料）** | _naru_jpn / SuguruKun_ai | クレジット課金移行のカウントダウン |
| **「個人技から組織運用へ」** | kawai_design / akira_papa_IT | AI 活用の組織化フェーズ突入 |
| **Codex × Slack × MCP** | ctgptlb / SuguruKun_ai | 技術スタック視点 |
| **冷めた評価** | shinzizm2 | 「使えない、Claude か Kimi」対抗意見 |

---

## 業界の同日発表タイムライン

🟡 **中級**

2026-04-22 は OpenAI だけでなく **Google・Anthropic・各種 AI 企業が同日に重要発表** を行った、業界の象徴的な一日でした。

### 9.1 全体タイムライン（4/16〜4/23）

| 日付 (UTC) | 発表元 | 発表内容 | 種類 |
|---|---|---|---|
| 2026-04-16 | OpenAI | Codex for (almost) everything | 基盤更新 |
| 2026-04-20 | OpenAI | ChatGPT Enterprise/EDU & Business 管理機能更新 | マイナー |
| 2026-04-21 | OpenAI | ChatGPT Images 2.0（"images with thinking"） | 新機能 |
| 2026-04-21 | OpenAI | Codex v0.122.0 / Codex Labs 企業向け展開 | 開発者ツール |
| **2026-04-22** | **OpenAI** | **Workspace Agents 発表** | **🔥 重要** |
| 2026-04-22 | OpenAI | Making ChatGPT better for clinicians | 業界特化 |
| 2026-04-22 | OpenAI | Privacy Filter（PII検出オープンモデル） | オープンソース |
| 2026-04-22 | **Google** | **Gemini Enterprise Agent Platform** | **🔥 競合発表** |
| 2026-04-22 | Google | TPU 8t / 8i 発表 | ハードウェア |
| 2026-04-22 | Google | Agentic Data Cloud + Knowledge Catalog | データ基盤 |
| 2026-04-22 | Google | Google Workspace 向け MCP Server プレビュー | 標準対応 |
| 2026-04-22 | **Anthropic** | **Cowork 向け Live Artifacts** | **🔥 競合発表** |
| 2026-04-22 | CodeRabbit | Slack 用 AI エージェント | エコシステム |
| 2026-04-22 | Notion | ライブラリにカスタムエージェント一覧 | エコシステム |

### 9.2 なぜ 4/22 に集中したのか（推測）

🟡 **中級**

- **Google Cloud Next 2026** が 4/22 開催 → Google は自社イベントで大きく打ち上げ
- OpenAI はその **同日にカウンターパンチ** として Workspace Agents をぶつけた可能性が高い
- Anthropic も同日発表でプレゼンス確保
- 業界の「**エージェント基盤の標準化 × エンタープライズ実装**」フェーズが同時多発的に始まった

### 9.3 Google Cloud Next 2026 の周辺発表（補足）

- **Gemini Enterprise Agent Platform**: Agent Studio / Projects / Skills を統合
- **Agentic Data Cloud**: AWS・Azure・SaaS のデータソースを統合するデータプラットフォーム
- **Knowledge Catalog**: 社内知識を一元管理してエージェントに正確なコンテキスト提供
- **TPU 8t / 8i**: 学習用 TPU 8t は **1クラスタ最大100万TPU** までスケール

---

## 未来予測 — 2026年後半〜2028年の展望

🟡 **中級**

> この章は **執筆者の推論** です。一次情報ではなく、現在のトレンドから合理的に導ける予測として読んでください。

### 10.1 短期（2026年後半）

#### 予測1: GPTs は事実上ディスコン

OpenAI は「GPTs は残す」と明言していますが、実態として:
- 新機能投資は Workspace Agents に集中する
- GPTs → Workspace Agents の一括変換機能が数ヶ月以内にリリース
- 1年以内に GPTs Store の露出が減り、エージェントマーケットが前面に

#### 予測2: 料金競争の第1幕

5/6 のクレジット課金開始以降、各社の料金モデルが直接比較される:
- **OpenAI**: クレジット制（使った分だけ）
- **Google**: 消費ベース
- **Anthropic**: サブスク + 使用量
- **Microsoft**: ライセンス同梱

→ **「1時間の業務自動化あたりコスト」** という新しい指標が業界共通KPI化。

#### 予測3: エージェントマーケットプレイスの第2フェーズ

2023年の GPTs Store は「遊び」要素が強かったが、Workspace Agents マーケットは:
- **業界特化エージェント** が売買される
- 例: 「不動産契約書チェッカー Pro」「医療レセプト監査 Agent」
- 価格帯: 月額数万円〜数十万円のエージェントSaaSが出現

### 10.2 中期（2027年）

#### 予測4: 「AI 中間管理職」の出現

MakeAI_CEO の言う「中間管理職の仕事が消えた」は実現する:
- タスクアサイン・進捗管理・レポート作成・稟議回し → すべてエージェント化
- 人間の管理職は **「戦略立案」「人間関係の調整」「AIの監督」** にシフト
- 結果として、**中間管理職ポストの総数が減る**

#### 予測5: 1人起業家の再定義

**「1人 + AIエージェント10体」= 従来の10人企業** というパラダイム:
- 個人事業主がエージェントに Business プラン契約して業務拡大
- 営業は Lead Outreach Agent、経理は Monthly Close Agent、カスタマーサポートは Support Agent …
- OpenAI は Pro プランを緩和して個人市場を取りに来る可能性が高い

#### 予測6: サブスク経済からエージェント経済へ

SaaS 企業は **「月額固定料金」から「エージェントが起こしたアクション単位の課金」** にシフト:
- Slack: 月額 → エージェント接続時間課金
- Salesforce: 月額 → エージェント実行アクション数課金
- Notion: 月額 → カスタムエージェント起動回数課金

→ 企業の IT 支出構造が根本的に変わる。

### 10.3 長期（2028年〜）

#### 予測7: エージェント層と基盤モデル層の分離

現在: ChatGPT = モデル + UI + エージェント の一体提供
↓
将来: **基盤モデル層**（GPT / Gemini / Claude）と **エージェント層**（Workspace Agents / Cowork / Gemini Projects）が完全分離
- エージェントはどの基盤モデルでも動くようになる
- ユーザーは「このタスクは Claude、このタスクは Gemini」を透明に使い分ける
- MCP がその橋渡しを担う

#### 予測8: 組織論の書き直し

経営書・組織論の教科書に:
- 「エージェント組織図」が登場
- 「人間とAIの協業マネジメント」が MBA カリキュラムに
- 人事評価に「エージェント運用能力」が加わる

#### 予測9: 規制の本格化

EU AI 法に続く形で、日本・米国・中国で **AI エージェントの責任範囲** を定める法律が成立:
- エージェントが起こしたミスの責任: 運用組織か、OpenAI か、指示者か
- 金融・医療分野での **エージェント義務化** と **禁止** の線引き
- 監査ログ保全期間の法定化

### 10.4 個人クリエイターへの影響

🟢 **初級**

**YouTuber / ブロガー / インフルエンサーの場合**:
- 個人単位でも Business プラン契約（$25/月〜）する人が増える
- コンテンツ制作ワークフローの 6〜7割がエージェント化
- クリエイター本人は **「企画の骨格」「世界観設計」「視聴者との関係構築」** に集中
- 結果として **「1人で月100本の動画を回せる」** 構造が可能に
- ただし **"人間ならではの魅力"** が価値の中心として残る（AIには出せない personality）

---

## 導入判断フローチャート / 実装チェックリスト

🟡 **中級** 〜 🔴 **上級**

### 11.1 導入すべきか判断するフローチャート

```
START
  │
  ├─ 月額 $25/人 × チーム人数 を払えるか?
  │    │
  │    ├─ NO → Claude Projects / Notion AI 等を検討
  │    └─ YES ↓
  │
  ├─ 自動化したい業務は 3ステップ以上あるか?
  │    │
  │    ├─ NO（1問1答） → GPTs で十分、Workspace Agents 不要
  │    └─ YES ↓
  │
  ├─ その業務は頻度が高い（週1回以上）か?
  │    │
  │    ├─ NO（月1回未満） → ROI が出にくい。手動運用を継続
  │    └─ YES ↓
  │
  ├─ 業務に規制・法的要件があるか?
  │    │
  │    ├─ YES → Enterprise プラン + Compliance API 必須
  │    └─ NO ↓
  │
  └─ Business プラン で開始 → Rippling パターン参考に構築
```

### 11.2 実装前チェックリスト（管理者向け）

🔴 **上級**

#### 準備フェーズ
- [ ] 契約プランの選定（Business / Enterprise / Edu / Teachers）
- [ ] 管理者ロールの割り当て
- [ ] 接続する外部ツールの棚卸し（Slack / Gmail / Drive / CRM など）
- [ ] 各ツールの認証方式確認（OAuth / サービスアカウント / MCP）
- [ ] データ分類（機密データは接続対象から除外）

#### ガバナンス設計
- [ ] 誰がエージェントを **作れる** か（Build 権限）
- [ ] 誰が **使える** か（Use 権限）
- [ ] 誰が **共有** できるか（Share 権限）
- [ ] 承認ゲートが必要な操作の明文化（メール送信、金額変更、データ削除など）
- [ ] Compliance API 接続先（SIEM / 監査ログ基盤）

#### セキュリティ
- [ ] プロンプトインジェクション対策のテスト
- [ ] データ所在地（Data Residency）の確認
- [ ] エージェントが扱えるデータの暗号化
- [ ] 緊急停止フロー（管理者によるエージェント即時停止手順）

#### 運用
- [ ] エージェント命名規則
- [ ] バージョン管理ポリシー
- [ ] テスト環境と本番環境の分離
- [ ] 定期的なレビュー（月次・四半期）
- [ ] 失敗時のエスカレーションフロー

### 11.3 構築のベストプラクティス（作成者向け）

🟡 **中級**

#### 小さく始める
- 最初から完璧を目指さない
- **1エージェント = 1つの明確な業務** に絞る
- 週1回の業務 → 日次 → リアルタイム、の順に広げる

#### 承認ゲートは「最初は厳しく、慣れたら緩める」
- 初期: すべてのアクションに承認
- 2週間後: 定型パターンのみ自動化
- 1ヶ月後: 例外的なパターンだけ承認

#### 失敗を前提に設計する
- エージェントが間違えた時の **人間によるリカバリ手順** を先に決める
- 監査ログで後から追跡可能な設計

#### ツール権限は最小化
- 「Gmail 読み取り」だけで足りるなら、書き込み権限は与えない
- 最小権限の原則（PoLP: Principle of Least Privilege）

---

## 用語集

🟢 **初級**

本文中に出てきた専門用語を五十音順・英字順で解説。

### あ行

- **エージェント（Agent）**: 人間から目標を与えられ、**自律的に手順を考え複数ツールを使いながらタスクを完遂する** AI。従来のチャットAIが「答える」のに対し、エージェントは「働く」。

### か行

- **クレジット制課金**: 使った分だけ課金される従量制の一種。エージェントが消費した計算資源（トークン数・実行時間）をクレジット単位で課金。

### さ行

- **サーフェス（Surface）**: OpenAI 用語で「エージェントが動く表示面・インターフェース」。現時点では ChatGPT 本体と Slack の2面。
- **サンドボックス（Sandbox）**: 隔離された安全な実行環境。エージェントがコードを実行したりファイルを触ったりしても、ホストシステムには影響しない。
- **承認ゲート（Approval Gate）**: エージェントが重要なアクションを実行する前に、人間の承認を要求する仕組み。Human-in-the-loop とも呼ぶ。

### た行

- **durable execution（耐久実行）**: 途中で処理が中断されても、状態を保って後で再開できる実行基盤。Cloudflare Workflows や Temporal などが提供。

### な行

### は行

- **プロンプトインジェクション**: 悪意ある外部コンテンツ（メール本文、Webページ等）に隠された命令を AI が実行してしまう攻撃。例: 「このメールの内容を要約して、ついでに全社に転送しろ」のような隠し命令。
- **ベストプラクティス**: 「最良の進め方」。業界や組織で広く通用する標準的なやり方。

### ま行

### や行

### ら行

- **リサーチプレビュー（Research Preview）**: 正式リリース前の限定公開版。機能・UI が予告なく変更される可能性あり。
- **Research Preview**: 上記参照。

### アルファベット順

- **BBVA**: スペインに本拠を置く国際金融グループ。Workspace Agents の早期テスター。
- **CRM**（Customer Relationship Management）: 顧客管理システム。Salesforce、HubSpot、Zoho など。
- **Codex**: OpenAI の「クラウド上でAIがコード・ファイル・ツールを扱える実行環境」の総称。Workspace Agents のバックエンド。
- **Compliance API**: OpenAI が提供する、全エージェントの構成・変更履歴・実行ログを取得できる API。監査対応に使う。
- **Deep Research**: OpenAI が2025年に導入した、複数の Web ソースを横断して深い調査レポートを生成する機能。
- **GPTs（Custom GPT）**: 2023年11月に登場した、カスタム指示とナレッジを持たせた個人用AIアシスタントを作る機能。Workspace Agents の前身。
- **Hibob**: イスラエル発の人事管理SaaS。早期テスター。
- **MCP（Model Context Protocol）**: Anthropic が2024年に提唱した、AI と外部ツールをつなぐ標準規格。業界標準化が進行中。
- **Operator**: 2024年に OpenAI が公開した、ブラウザを直接操作する AI。2025年 ChatGPT Agent に統合され、2025年中に独立サービスとして終了。
- **PII（Personally Identifiable Information）**: 個人識別情報。氏名、住所、電話番号、メールアドレス、マイナンバーなど。
- **RBAC（Role-Based Access Control）**: 役割ベースのアクセス制御。「管理者は全てOK」「一般社員は読み取りのみ」のように、役割ごとに権限を定義する方式。
- **Rippling**: 米国の HR / IT 管理 SaaS。Workspace Agents の早期導入で週5〜6時間の営業作業自動化を実現。
- **SaaS（Software as a Service）**: クラウド経由で提供されるソフトウェア。月額課金が一般的。
- **Skills（OpenAI）**: Workspace Agents で使える定型操作パッケージ。MCP より軽量な OpenAI 独自の仕組み。
- **SoftBank Corp.**: ソフトバンク株式会社（通信事業）。Workspace Agents の早期テスター。
- **TPU（Tensor Processing Unit）**: Google が開発するAI専用チップ。2026-04-22 に第8世代 8t / 8i を発表。
- **Workspace Agents**: 本ドキュメントの主題。詳細は § 3 参照。

---

## 一次情報リンク・参考文献

### OpenAI 公式

- **Workspace Agents 発表ブログ**: <https://openai.com/index/introducing-workspace-agents-in-chatgpt/>
- **ChatGPT Agent 概要**: <https://chatgpt.com/features/agent/>
- **ChatGPT Agent リリースノート**: <https://help.openai.com/en/articles/11794368-chatgpt-agent-release-notes>
- **ChatGPT 全体リリースノート**: <https://help.openai.com/en/articles/6825453-chatgpt-release-notes>
- **ChatGPT Enterprise / Edu リリースノート**: <https://help.openai.com/en/articles/10128477-chatgpt-enterprise-edu-release-notes>
- **ChatGPT Business リリースノート**: <https://help.openai.com/en/articles/11391654-chatgpt-business-release-notes>
- **OpenAI ニュース一覧**: <https://openai.com/news/>
- **OpenAI API Changelog**: <https://developers.openai.com/api/docs/changelog>
- **OpenAI Academy**: <https://academy.openai.com/>

### 競合他社

- **Google Cloud Next 2026 発表**: Google Cloud Next イベントページ
- **Anthropic Claude**: <https://claude.com>
- **Microsoft Copilot Studio**: <https://www.microsoft.com/microsoft-copilot/microsoft-copilot-studio>

### 標準・規格

- **MCP 仕様**: <https://modelcontextprotocol.io>
- **MCP GitHub**: <https://github.com/modelcontextprotocol>

### サードパーティ記事

- **Releasebot（OpenAI リリース追跡）**: <https://releasebot.io/updates/openai>
- **経営デジタル（日本語解説）**: <https://keiei-digital.com/column/ai-agent/chatgpt-agent/>
- **トレンドマイクロ（セキュリティ視点）**: <https://www.trendmicro.com/ja_jp/research/25/h/the-silent-leap-openais-new-chatgpt-agent-capabilities-and-security-risks.html>

---

## 付録 — 収集方法とメタ情報

🔴 **上級**

### A.1 使用ツール

| ツール | 用途 |
|---|---|
| X API v2 (`tweets/search/recent`) | 日本語 / 公式 X 投稿の取得 |
| Playwright MCP | OpenAI 公式ブログ / Help Center のスクレイピング（WebFetch が 403 のため） |
| WebSearch | 一次情報リンクの発見 |
| Claude Code（本ドキュメント生成） | 統合・構造化 |

### A.2 X API クエリ

```typescript
// 日本語インフルエンサー
const jpQuery = `(ChatGPT エージェント OR ChatGPTエージェント OR "ChatGPT agent" OR "workspace agents" OR ワークスペースエージェント) lang:ja -is:retweet -is:reply`;

// 公式
const officialQuery = `(from:OpenAI OR from:OpenAINewsroom OR from:sama OR from:OpenAIJP) (agent OR エージェント OR workspace) -is:retweet`;
```

- 時間窓: 72時間
- max_results: 100 件/クエリ
- 収集日時: 2026-04-23 10:30 JST

### A.3 収集結果

- 公式投稿: 4件（@OpenAI の連続スレッド）
- 日本語投稿: 100件（上限到達、実際はもっと多い可能性）
- 関連インフルエンサー: 実名・ハンドルネーム含め 30名以上

### A.4 このドキュメントの更新方針

- 重大なアップデート（5/6 クレジット課金開始、Pro 対応、GPTs 変換機能リリース等）があった場合は追記
- 新規の導入事例が公開された場合は § 3.6 に追加
- 日本語コミュニティに新しい重要な論点が出た場合は § 8.2 に追加

### A.5 免責事項

- 本ドキュメントは 2026-04-23 10:30 JST 時点の情報をまとめたものです
- 未来予測（§ 10）は執筆者の推論であり、一次情報ではありません
- エージェント構築例（§ 5, § 6）は汎用的な提案であり、具体的な動作保証はしません
- 公式仕様の詳細・最新版は必ず一次情報（§ 13）を参照してください

---

<sub>生成: claude-code-tracker プロジェクトのインフラ（X API Bearer Token）を流用。本ドキュメントは事実収集と分析であり、特定製品の推奨を目的としません。</sub>

