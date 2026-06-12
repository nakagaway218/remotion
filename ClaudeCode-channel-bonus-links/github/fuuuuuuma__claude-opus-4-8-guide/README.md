# Claude Opus 4.8 完全ガイド

> Anthropic が **2026年5月28日** にリリースした最新フラッグシップモデル **Claude Opus 4.8** の要点を、公式情報・主要メディア・X（旧Twitter）の一次情報から整理した日本語まとめです。
>
> **最終更新:** 2026-05-29 ／ **対象:** Claude Opus 4.8（API名 `claude-opus-4-8`）

---

## ⚠️ この資料の読み方（確度について）

新しいモデルの情報は短時間で更新されるため、本資料では出典の強さを区別しています。

- **［確定］** … 公式サイト・公式アカウント・複数メディアで一致
- **［報道］** … 主要メディア報道ベース（公式の数値裏取りは部分的）
- **［X由来・未確認］** … X上の集計・個人投稿のみ。鵜呑みにしないこと

数値を引用する際は必ずこのタグを確認してください。

---

## TL;DR（3行）

- Opus 4.7 のわずか **41日後** に登場。**価格据え置き**で「判断力・正直さ・長時間の自律作業」を強化。［確定］
- 目玉は **Fast Mode（2.5倍速）**、**Dynamic Workflows（Claude Code で数百サブエージェント並列）**、**Effort（努力度）制御** の3本。［確定］
- 発表当日に **GitHub Copilot / Cursor / Lovable / Bubble / Higgsfield** などが続々対応。エコシステム全体が即日追従。［確定］

---

## 目次

1. [Claude Opus 4.8 とは](#1-claude-opus-48-とは)
2. [何が進化したのか（3本柱）](#2-何が進化したのか3本柱)
3. [ベンチマーク](#3-ベンチマーク)
4. [価格と Effort（努力度）](#4-価格と-effort努力度)
5. [新機能① Fast Mode](#5-新機能-fast-mode)
6. [新機能② Dynamic Workflows（Claude Code）](#6-新機能-dynamic-workflowsclaude-code)
7. [新機能③ Effort 制御 & API 変更](#7-新機能-effort-制御--api-変更)
8. [エコシステム連携まとめ](#8-エコシステム連携まとめ)
9. [開発者向け：使い始め方](#9-開発者向け使い始め方)
10. [出典](#10-出典)
11. [未確認・注意事項](#11-未確認注意事項)
12. [プロンプト実践ガイド（公式ベストプラクティス）](#12-プロンプト実践ガイド公式ベストプラクティス-日本語まとめ)

---

## 1. Claude Opus 4.8 とは

| 項目 | 内容 | 確度 |
|---|---|---|
| 発表日 | 2026年5月28日 | ［確定］ |
| API モデル名 | `claude-opus-4-8` | ［確定］ |
| 位置づけ | Anthropic の最上位（フラッグシップ）モデル。Opus 4.7 の後継 | ［確定］ |
| リリース間隔 | Opus 4.7 のわずか **41日後**（通常より速い更新サイクル） | ［報道：TechCrunch］ |
| 価格 | Opus 4.7 から **据え置き** | ［確定］ |
| 提供範囲 | Web / Claude Platform（API）/ 主要クラウド（Amazon Bedrock・Google Vertex AI・Microsoft Foundry）で **即日・全プラン** 提供 | ［確定］ |

Anthropic は Opus 4.8 を「**より鋭い判断力、自分の進捗に対するより高い正直さ、そして前モデルより長く自律的に作業できる能力**」を備えたモデルと説明しています。［確定］

---

## 2. 何が進化したのか（3本柱）

### ① 判断力（Sharper Judgement）
エージェント的タスクでの判断が改善。複雑な問題解決や大規模コードベースのナビゲーションで前モデルより明確に向上。

### ② 正直さ（Honesty）
- 自分の作業の不確実性を**自分から申告**し、根拠のない主張をしにくくなった。［確定］
- **コードの欠陥を見逃したまま放置する確率が約 4 分の 1（＝約4倍の改善）**。［確定：公式＋報道で一致］
- 投資運用の Bridgewater Associates は「分析の入力・出力の問題を**先回りで指摘**する点が他モデルと違う」と評価。［報道：TechCrunch］

### ③ 自律性（Longer Independent Work）
- 「経験豊富なエンジニアのように」リポジトリ内で長時間セッションを維持し、機能実装やバグ修正を**少ない確認で任せられる**。［確定：公式X］
- Claude Code と組み合わせると、数十万行規模のコードベース移行を「着手からマージまで」既存テストを基準に遂行できる。［報道：TechCrunch］

---

## 3. ベンチマーク

| 指標 | Opus 4.7 | Opus 4.8 | 測るもの | 確度 |
|---|---|---|---|---|
| SWE-bench Pro | 64.3% | **69.2%** | エージェント的コーディング | ［確定：公式X＋報道で一致］ |
| Online-Mind2Web | — | **84%** | ブラウザ/コンピュータ操作エージェント | ［確定：公式＋X］ |
| 学際的推論（ツール併用） | 54.7% | **57.9%** | ツールを使った横断推論 | ［報道］ |
| ナレッジワーク指標 | 1753 | **1890** | 知的労働タスクの総合スコア | ［報道］ |
| Legal Agent Benchmark | — | all-pass 基準で**初の10%超** | 法務エージェント | ［確定：公式（単独）］ |
| Terminal-Bench 2.1 | — | 74.6% | ターミナル操作 | ［X由来・未確認］ |

> 全体として **エージェント系ベンチで GPT-5.5 を上回った**との報告。ただし表中「報道」「X由来」の数値は公式の一次裏取りが部分的なため、引用時は注意。

---

## 4. 価格と Effort（努力度）

### 料金（per 100万トークン）

| モード | 入力 | 出力 | 備考 | 確度 |
|---|---|---|---|---|
| 通常 | **$5** | **$25** | Opus 4.7 から据え置き | ［確定］ |
| Fast Mode | $10 | $50 | 「2.5倍速・従来世代比3倍安」。実額は公式記事の記載ベース | ［公式記事／一部要確認］ |

### Effort（努力度）制御
- **claude.ai に Effort メニュー** が追加され、応答にかける「努力度」をユーザーが選べる（品質と速度のトレードオフ）。［確定：公式］
- Opus 4.8 は **デフォルトで high effort**。通常タスクなら 4.7 と同等のトークン消費で高精度。［確定：公式X］
- 長時間の非同期作業では **xhigh** が推奨。さらに **`ultracode` 設定**（Effort メニュー経由）で xhigh ＋ Dynamic Workflows 自動判断が有効になる。［確定：公式］

---

## 5. 新機能① Fast Mode

**Opus 4.8 の知能そのままに、出力トークン速度を 2.5 倍にした高速構成。**

| 項目 | 内容 |
|---|---|
| 速度 | 出力トークン速度 **2.5倍** ［確定］ |
| コスト | 従来世代の Fast Mode より **3倍安** ［確定：公式＋X］ |
| 対象モデル | Opus 4.8 ［確定］ |
| Claude Code での使い方 | **`/fast` コマンド**でトグル（追加利用枠を有効にした開発者向け、リサーチプレビュー） ［確定：公式X］ |
| API / Platform | アカウントマネージャーに連絡、または **waitlist** から申し込み ［確定］ |

> ⚠️ 公式 `claude.com/fast-mode` ページは本文に一部 **Opus 4.6 への言及が混在**しており、正式提供形態（一般提供 か waitlist か）の記述が出典間で揺れています。詳細は[未確認・注意事項](#11-未確認注意事項)を参照。

---

## 6. 新機能② Dynamic Workflows（Claude Code）

**Claude Code が、1セッション内で数十〜数百のサブエージェントを並列起動し、通常なら数週間かかる大規模タスクを数日で片づける機能（リサーチプレビュー）。**

### 何ができるか
- サービス全体にまたがるバグハント
- 数百〜数千ファイル規模の移行（フレームワーク乗り換え、API 廃止対応、言語ポート）
- 多角的なストレステストが必要な計画のレビュー
- レガシー/複雑なコードベースの監査・デッドコード検出

### 仕組み
1. プロンプトに応じて Claude が**オーケストレーションスクリプトを動的に生成**
2. タスクを分割し、複数サブエージェントへ**並列分配**
3. **自己検証** … あるエージェントが独立した角度から解き、別エージェントがそれを反証。**答えが収束するまで反復**
4. **進捗の永続化** … 作業は自動保存され、中断しても**再開（resume）**でき、最初からやり直さない
5. **実行前に確認** … 通常セッションより大幅にトークンを消費するため、プレビュー＋ユーザー確認を経て開始

### 使い方
- 直接指示：「**workflow を作って**」と頼む
- または **`ultracode` 設定**（Effort メニュー）を有効にし、Claude に適用判断を委ねる（auto モード推奨）

### 提供範囲
| 区分 | 内容 |
|---|---|
| サーフェス | Claude Code（CLI / Desktop / VS Code 拡張）、Claude API、Amazon Bedrock、Google Vertex AI、Microsoft Foundry |
| プラン | **Max / Team / Enterprise**（Enterprise は既定で無効、管理者が設定で有効化） |

### 実績として語られた例
- **Bun の書き換え**：Zig から Rust への **75万行**ポートを、既存テストスイート **99.8% パス**で **11日**で完了。［公式記事］
- Klarna（シニアエンジニアリングマネージャー Alessio Vallero 氏）：「大規模コードベースの**発見・レビュー**作業で特に有効。静的解析が見逃すデッドコードや整理機会を洗い出せた」。［公式記事］

---

## 7. 新機能③ Effort 制御 & API 変更

- **Effort（努力度）制御**：[第4章](#4-価格と-effort努力度)参照。claude.ai でユーザーが努力度を選択可能に。［確定］
- **System Entries（Messages API）**：Messages API が **messages 配列内に system エントリ**を受け付けるように。長時間セッションの**途中で指示を更新**できる。［確定：公式＋X］
- `claude-api` スキルにモデル移行コマンドが用意されている（4.7 → 4.8 などの乗り換え用）。［X由来：公式X言及］

---

## 8. エコシステム連携まとめ

発表（2026-05-28）当日から、開発・クリエイティブツール各社が Opus 4.8 への対応を相次いで発表しました。

| サービス | 対応内容 | 種別 | 確度 |
|---|---|---|---|
| **GitHub Copilot** | Opus 4.8 が **一般提供（GA）**。Pro+/Business/Enterprise 対象 | コーディング | ［確定：公式changelog］ |
| **Cursor** | Opus 4.8 を統合。CursorBench で効率向上・難タスクでの持続性向上 | コーディング | ［確定：公式X］ |
| **Lovable** | Opus 4.8 をサポート。発表から **約1時間**で対応 | AppビルダーAI | ［確定：公式X］ |
| **Bubble** | Bubble AI のアプリ生成が Opus 4.8 を**標準採用** | ノーコード | ［確定：公式X］ |
| **Higgsfield** | Higgsfield MCP 経由で、Claude が任意の動画を分析・再構成し、同一チャットで生成ツールを実行 | 動画生成 | ［確定：公式X］ |
| 主要クラウド | Amazon Bedrock / Google Vertex AI / Microsoft Foundry で提供 | 基盤 | ［確定］ |

### GitHub Copilot（詳細）
- **ステータス**：一般提供（GA）、2026-05-28。ロールアウトは段階的。
- **対象プラン**：Copilot Pro+ / Business / Enterprise。
- **対応面**：VS Code（chat / ask / edit / agent の全モード）、Visual Studio、Copilot CLI、Copilot クラウドエージェント、Copilot アプリ、github.com、GitHub Mobile（iOS/Android）、JetBrains、Xcode、Eclipse。
- **課金**：**2026年6月1日**の従量課金（Usage Based Billing）開始までは **15倍のプレミアムリクエスト乗数**。
- **組織設定**：Business / Enterprise は管理者が Copilot 設定で Opus 4.8 ポリシーを有効化する必要あり。

### Cursor（補足）
Cursor は同日に自社モデル **Composer 2.5** も発表し、SWE-Bench Multilingual で 79.8% を記録したとの集計あり（モデル競争が加速）。※この数値は［X由来・未確認］。

### Higgsfield（補足）
動画の構造・ショット・ペーシングを Claude が理解し、Higgsfield の生成ツールを**同じチャット内**で呼び出せる MCP 連携。38秒のデモ動画付きで告知。コーディング以外の領域でも Opus 4.8 連携が広がっている好例。

---

## 9. 開発者向け：使い始め方

```text
# API で使う
モデル名: claude-opus-4-8
料金: 入力 $5 / 出力 $25（per 100万トークン）

# Claude Code
/fast            … Fast Mode をトグル（リサーチプレビュー）
"workflow を作って" … Dynamic Workflows を起動（実行前に確認あり）
ultracode 設定    … xhigh effort ＋ workflow 自動判断（Max/Team/Enterprise）

# Effort（努力度）
デフォルト high。長時間の非同期作業は xhigh 推奨。
```

> Dynamic Workflows と Fast Mode はいずれも **リサーチプレビュー**段階。トークン消費が大きいため、本番運用前にコストを見積もること。

---

## 10. 出典

### 公式
- [Anthropic 公式発表：Introducing Claude Opus 4.8](https://www.anthropic.com/news/claude-opus-4-8)
- [Claude Opus 4.8 製品ページ](https://www.anthropic.com/claude/opus)
- [Fast Mode（claude.com）](https://claude.com/fast-mode)
- [Dynamic Workflows in Claude Code（claude.com blog）](https://claude.com/blog/introducing-dynamic-workflows-in-claude-code)
- [GitHub Changelog：Claude Opus 4.8 is generally available for GitHub Copilot](https://github.blog/changelog/2026-05-28-claude-opus-4-8-is-generally-available-for-github-copilot/)

### 公式アカウント（X）
- [@claudeai：Opus 4.8 発表](https://x.com/claudeai/status/2060042702150930686)
- [@ClaudeDevs：技術詳細スレッド（SWE-bench Pro 69.2% ほか）](https://x.com/ClaudeDevs/status/2060043208277811437)
- [@ClaudeDevs：Dynamic Workflows](https://x.com/ClaudeDevs/status/2060044853279617150)

### 連携各社（X）
- [@cursor_ai：Cursor が Opus 4.8 を統合](https://x.com/cursor_ai/status/2060044920237469872)
- [@github：Copilot に Opus 4.8 をロールアウト](https://x.com/github/status/2060050235754242178)
- [@Lovable：約1時間で Opus 4.8 対応](https://x.com/Lovable/status/2060044304140386550)
- [@bubble：Bubble AI が Opus 4.8 を標準採用](https://x.com/bubble/status/2060092323501945314)
- [@higgsfield_ai：Higgsfield MCP × Claude 動画分析](https://x.com/higgsfield_ai/status/2060061917754929568)

### 主要メディア
- [TechCrunch：Anthropic releases Opus 4.8 with new 'dynamic workflow' tool](https://techcrunch.com/2026/05/28/anthropic-releases-opus-4-8-with-new-dynamic-workflow-tool/)
- [9to5Mac：Anthropic upgrades Claude with new Opus 4.8 model](https://9to5mac.com/2026/05/28/anthropic-upgrades-claude-with-new-opus-4-8-model-heres-whats-new/)
- [MacRumors：Anthropic Launches Claude Opus 4.8 With Gains in Coding and Honesty](https://www.macrumors.com/2026/05/28/anthropic-claude-opus-4-8/)
- [Axios：Anthropic releases new model, Opus 4.8](https://www.axios.com/2026/05/28/anthropic-opus-release-mythos)

### 日本語コミュニティ（X・参考）
- [@oikon48 の関連投稿](https://x.com/oikon48/status/2060050619348697115)
- [@ClaudeCodeLog の関連投稿](https://x.com/ClaudeCodeLog/status/2060060912615121360)

---

## 11. 未確認・注意事項

- **Fast Mode の正式提供形態**：公式 `claude.com/fast-mode` ページに **Opus 4.6 への言及が混在**し、「一般提供」か「waitlist 限定」かの記述が出典間で揺れている。現時点の確実な事実は「Claude Code では `/fast` で利用可・リサーチプレビュー」「API/Platform は waitlist またはアカウントマネージャー経由」まで。
- **Fast Mode の実額（$10 / $50）**：公式記事からの抽出値。Anthropic の料金ページで最新の確認を推奨。
- **［報道］【X由来】タグの数値**（学際的推論 57.9% / ナレッジワーク 1890 / Terminal-Bench 2.1 74.6% / 自己エラー検出 19.7%→3.7% / Composer 2.5 79.8% など）は一次裏取りが部分的。引用時は出典に直接当たること。
- 本資料は **2026-05-29 時点**のスナップショット。モデル仕様・価格・提供範囲は更新される可能性が高い。

---

## 12. プロンプト実践ガイド（公式ベストプラクティス 日本語まとめ）

> 出典：Anthropic 公式ドキュメント [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)（Opus 4.8 / 4.7 / 4.6・Sonnet 4.6・Haiku 4.5 共通の公式リファレンス）。［確定：公式］
>
> 本章は上記公式ガイドの**日本語要約**です。解説文は日本語に再構成していますが、**コピペして使えるプロンプト例（コードブロック）は原文（英語）のまま**掲載しています。そのまま system プロンプト等に貼って使えます。

### 12-1. Opus 4.8 固有のチューニング

Opus 4.8 は長時間のエージェント作業・ナレッジワーク・vision・メモリに強く、4.7 向けのプロンプトはほぼそのまま動きます。下記は調整が必要になりやすい挙動です。

**応答の長さ（冗長性）**
タスクの複雑さに応じて長さを自動調整します（単純な調べ物は短く、自由記述の分析は長く）。固定的な長さ・文体に依存する製品ならチューニングが必要。冗長さを減らす例：

```text
Provide concise, focused responses. Skip non-essential context, and keep examples minimal.
```

「やってほしくない事」を並べるより、「適切な簡潔さで書けている良い例（positive example）」を示す方が効きます。

**effort（努力度）と思考の深さ**
effort は知能とトークン消費のトレードオフ。コーディング/エージェント用途は `xhigh`、知能が要る用途は最低 `high` から。

| effort | 用途 |
|---|---|
| `max` | 最難タスク向け。ただし overthinking 気味になることも |
| `xhigh` | コーディング/エージェントのベスト設定 |
| `high` | バランス型。知能重視の既定値 |
| `medium` | コスト重視（知能を多少犠牲に） |
| `low` | 短く範囲限定・低レイテンシ用途のみ |

4.8 は effort を厳格に守ります（特に低 effort）。複雑な問題で推論が浅いと感じたら、プロンプトで工夫するより effort を上げるのが先。低 effort 維持が必要な場合の補助：

```text
This task involves multi-step reasoning. Think carefully through the problem before responding.
```

thinking は既定オフ。`thinking: {type: "adaptive"}` で有効化します。思考しすぎを抑えるには：

```text
Thinking adds latency and should only be used when it will meaningfully improve answer quality — typically for problems that require multi-step reasoning. When in doubt, respond directly.
```

> `max`/`xhigh` で動かすときは出力トークン上限を大きめに（まず 64k から調整）。

**ツール使用のトリガー**
4.8 はツール呼び出しより推論を優先しがち（多くの場合これが良い結果に）。ツール使用を増やすには effort を上げる（`high`/`xhigh` でエージェント検索・コーディングのツール使用が大幅に増加）。あるいは「いつ・どのツールを・なぜ使うか」を明示します。

**ユーザー向け進捗アップデート**
長いエージェント実行中の報告が高品質化。「3 ツールごとに要約せよ」等の足場は外して構いません。形を変えたいなら具体的に指示＋例示します。

**より字義通りの指示追従**
4.8 は指示を字義通り・明示的に解釈します（特に低 effort）。ある項目の指示を勝手に他へ一般化せず、頼んでいない要求も推測しません。広く適用してほしいなら範囲を明示します（例：「Apply this formatting to every section, not just the first one」）。

**トーン・文体**
直接的で意見を持つ文体が既定で、過度な同調表現・絵文字は控えめ。温かい声色が必要なら：

```text
Use a warm, collaborative tone. Acknowledge the user's framing before answering.
```

**サブエージェントの生成制御**
4.8 は既定で生成数が少なめ。望むなら明示誘導します：

```text
Do not spawn a subagent for work you can complete directly in a single response (e.g. refactoring a function you can already see).

Spawn multiple subagents in the same turn when fanning out across items or reading multiple files.
```

**デザイン/フロントエンドの既定**
4.8 は強いデザイン感を持ち、既定で「クリーム色背景（~`#F4F1EA`）＋セリフ見出し＋テラコッタ/琥珀の差し色」のハウススタイルに寄ります。編集系・ポートフォリオには合いますが、ダッシュボード・開発ツール・フィンテック・医療・業務アプリでは浮きます。「クリームを使うな」等の漠然指示は別の固定色に移るだけ。確実なのは 2 つ：

1. **具体的な代替仕様を与える**（4.8 は明示仕様を正確に守る。配色 hex・余白・角丸・タイポを指定）
2. **作る前に複数案を提案させる**（既定を崩し、ユーザーに選ばせる）：

```text
Before building, propose 4 distinct visual directions tailored to this brief (each as: bg hex / accent hex / typeface — one-line rationale). Ask the user to pick one, then implement only that direction.
```

"AI slop" を避ける軽量スニペット（4.8 は旧モデルより少ない誘導で差別化できる）：

```text
<frontend_aesthetics>
NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white or dark backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character. Use unique fonts, cohesive colors and themes, and animations for effects and micro-interactions.
</frontend_aesthetics>
```

**対話型コーディング製品**
対話型（複数ターン）では、ユーザーターン後に多く推論するためトークンを多く使いがち。性能とトークン効率を両立するには `xhigh`/`high` ＋ auto モード等の自律機能＋ユーザー操作を減らす設計に。最初のターンでタスク・意図・制約を明確に伝えるほど自律性と知能が活きます（曖昧な指示を小出しにするのは非効率）。

**コードレビューのハーネス**
4.8 はバグ発見が大幅向上（recall・precision とも）。ただし旧モデル向けに「高深刻度のみ報告」等とチューニングしてあると、その指示を忠実に守って報告数が減ることがあります（＝能力低下ではなくハーネス効果）。発見段階では網羅性を優先させます：

```text
Report every issue you find, including ones you are uncertain about or consider low-severity. Do not filter for importance or confidence at this stage - a separate verification step will do that. Your goal here is coverage: it is better to surface a finding that later gets filtered out than to silently drop a real bug. For each finding, include your confidence level and an estimated severity so a downstream filter can rank them.
```

**Computer use**
最大解像度 2576px / 3.75MP まで対応。1080p が性能とコストのバランス良。コスト重視なら 720p / 1366×768 も有力。

### 12-2. 普遍原則（全モデル共通）

**明確かつ直接的に**
Claude を「自社の流儀を知らない優秀な新入社員」と考えます。望む出力形式・制約を具体的に。順序や網羅性が大事なら番号付き手順で。"above and beyond" な挙動が欲しいなら明示的に要求します。

> 黄金律：文脈をほとんど持たない同僚にプロンプトを渡して従ってもらう。彼らが戸惑うなら Claude も戸惑う。

例（アナリティクスダッシュボード作成）：

```text
Create an analytics dashboard. Include as many relevant features and interactions as possible. Go beyond the basics to create a fully-featured implementation.
```

**背景・動機を添えて性能を上げる**
なぜそうしてほしいかを説明すると、Claude が目的を理解しより的確に応答します（説明から一般化できる）。

```text
Your response will be read aloud by a text-to-speech engine, so never use ellipses since the text-to-speech engine will not know how to pronounce them.
```

**例を効果的に使う（few-shot / multishot）**
出力の形式・トーン・構造を誘導する最も確実な手段。例は ①関連性が高く（実ユースケースを模す）②多様（エッジケースを含み、意図しないパターンを学ばせない）③構造化（`<example>` / 複数なら `<examples>` タグで囲む）。3〜5 個が目安。例の関連性・多様性を Claude 自身に評価させたり追加生成させることも可能。

**XML タグで構造化**
指示・文脈・例・入力が混在するとき、種類ごとにタグで囲む（`<instructions>`, `<context>`, `<input>`）と誤読が減ります。タグ名は一貫＆説明的に。階層があればネスト（`<documents>` の中に `<document index="n">`）。

**ロールを与える**
system プロンプトでロールを与えると挙動とトーンが絞られます。一文でも効果あり：

```python Python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-opus-4-8",
    max_tokens=1024,
    system="You are a helpful coding assistant specializing in Python.",
    messages=[
        {"role": "user", "content": "How do I sort a list of dictionaries by key?"}
    ],
)
print(message.content)
```

**ロングコンテキスト（20k トークン以上）**
- **長文データはプロンプト上部に**（クエリ・指示・例より前）。複雑な複数文書では応答品質が最大 30% 向上することも
- **文書とメタデータを XML で構造化**：`<document>` → `<document_content>` / `<source>` サブタグで囲む
- **引用で接地させる**：長文タスクでは、先に関連箇所を引用させてから本題に入らせると、ノイズを抜けて精度が上がる（`<quotes>` タグ）

**モデルの自己認識**
アプリ内で正しく名乗らせる／モデル文字列を使わせるには：

```text
The assistant is Claude, created by Anthropic. The current model is Claude Opus 4.8.
```

```text
When an LLM is needed, please default to Claude Opus 4.8 unless the user requests otherwise. The exact model string for Claude Opus 4.8 is claude-opus-4-8.
```

### 12-3. 出力とフォーマット制御

**コミュニケーションスタイル**
最新モデルは簡潔・自然・事実ベース（自己礼賛的でなく、やや口語的）。ツール呼び出し後の要約を省くことがあります。可視性が欲しいなら：

```text
After completing a task that involves tool use, provide a quick summary of the work you've done.
```

**応答フォーマットの制御**（効果的な順）
1. 「やるな」より「こうしろ」（「マークダウン禁止」→「滑らかな散文段落で書け」）
2. XML 形式指定子を使う（「`<smoothly_flowing_prose_paragraphs>` タグで書け」）
3. プロンプトの文体を出力に合わせる（プロンプトからマークダウンを除くと出力のマークダウンも減る）
4. 詳細な指定を与える。マークダウンを抑えたい例：

````text
<avoid_excessive_markdown_and_bullet_points>
When writing reports, documents, technical explanations, analyses, or any long-form content, write in clear, flowing prose using complete paragraphs and sentences. Use standard paragraph breaks for organization and reserve markdown primarily for `inline code`, code blocks (```...```), and simple headings (###, and ###). Avoid using **bold** and *italics*.

DO NOT use ordered lists (1. ...) or unordered lists (*) unless : a) you're presenting truly discrete items where a list format is the best option, or b) the user explicitly requests a list or ranking

Instead of listing items with bullets or numbers, incorporate them naturally into sentences. This guidance applies especially to technical writing. Using prose instead of excessive formatting will improve user satisfaction. NEVER output a series of overly short bullet points.

Your goal is readable, flowing text that guides the reader naturally through ideas rather than fragmenting information into isolated points.
</avoid_excessive_markdown_and_bullet_points>
````

**LaTeX 出力**
数式は既定で LaTeX。プレーンテキストが良いなら：

```text
Format your response in plain text only. Do not use LaTeX, MathJax, or any markup notation such as \( \), $, or \frac{}{}. Write all math expressions using standard text characters (e.g., "/" for division, "*" for multiplication, and "^" for exponents).
```

**ドキュメント作成**
プレゼン・アニメ・ビジュアル文書が得意で、多くの場合初回から高品質：

```text
Create a professional presentation on [topic]. Include thoughtful design elements, visual hierarchy, and engaging animations where appropriate.
```

**prefill（応答の先読み）の廃止と移行**
Claude 4.6 系以降、**最後の assistant ターンの prefill は非対応**（リクエストは 400 エラー）。代替策：
- **出力形式の強制** → Structured Outputs、または単に形式を指示（新モデルは複雑なスキーマも従える）
- **前置きの除去** → system で「Respond directly without preamble. Do not start with phrases like 'Here is...', 'Based on...'」と指示／XML タグ／構造化出力。漏れたら後処理で除去
- **不適切な拒否の回避** → 現行モデルは適切に拒否するので user メッセージの明確化で十分
- **継続** → user メッセージに「Your previous response was interrupted and ended with `[previous_response]`. Continue from where you left off.」と入れる
- **コンテキスト再注入** → 旧 prefill リマインダは user ターンに入れる／ツールや圧縮時に注入

### 12-4. ツール使用

**ツール使用の明示**
「変更を提案して（suggest）」だと提案だけで終わることがあります。行動させたいなら明示動詞で：

```text
Change this function to improve its performance.
```

既定で行動的にするなら：

```text
<default_to_action>
By default, implement changes rather than only suggesting them. If the user's intent is unclear, infer the most useful likely action and proceed, using tools to discover any missing details instead of guessing. Try to infer the user's intent about whether a tool call (e.g., file edit or read) is intended or not, and act accordingly.
</default_to_action>
```

逆に慎重にさせるなら：

```text
<do_not_act_before_instructions>
Do not jump into implementation or change files unless clearly instructed to make changes. When the user's intent is ambiguous, default to providing information, doing research, and providing recommendations rather than taking action. Only proceed with edits, modifications, or implementations when the user explicitly requests them.
</do_not_act_before_instructions>
```

> 4.5/4.6 は system プロンプトへの反応が強い。旧モデル向けの「CRITICAL: You MUST use this tool when...」は overtrigger の原因。「Use this tool when...」程度に緩めます。

**並列ツール呼び出しの最適化**
最新モデルは並列実行が得意（研究での投機的検索、複数ファイルの同時読み、bash の並列実行）。成功率をほぼ 100% に高めるには：

```text
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies between the tool calls, make all of the independent tool calls in parallel. Prioritize calling tools simultaneously whenever the actions can be done in parallel rather than sequentially. For example, when reading 3 files, run 3 tool calls in parallel to read all 3 files into context at the same time. Maximize use of parallel tool calls where possible to increase speed and efficiency. However, if some tool calls depend on previous calls to inform dependent values like the parameters, do NOT call these tools in parallel and instead call them sequentially. Never use placeholders or guess missing parameters in tool calls.
</use_parallel_tool_calls>
```

### 12-5. 思考（Thinking）と推論

**考えすぎ・過剰な徹底の抑制**
4.6 は高 effort で事前探索を多く行います（多くは結果改善に寄与するが、過剰なことも）。旧プロンプトで「徹底せよ」と促していたら調整を：
- 包括的な既定（「常に〇〇を使え」）→ 的を絞った指示（「理解が深まるときに使え」）へ
- 過剰トリガーの原因（「迷ったら〇〇を使え」）を除去
- それでも過剰なら effort を下げる

1 つの方針に決めて進ませる例：

```text
When you're deciding how to approach a problem, choose an approach and commit to it. Avoid revisiting decisions unless you encounter new information that directly contradicts your reasoning. If you're weighing two approaches, pick one and see it through. You can always course-correct later if the chosen approach fails.
```

**thinking / interleaved thinking の活用**
4.6・Sonnet 4.6 は adaptive thinking（`thinking: {type: "adaptive"}`）。effort とクエリ複雑度で思考量を自動調整します。ツール後の反省や多段推論に有効：

```text
After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.
```

extended thinking（`budget_tokens`）からの移行例：

```python Python
client.messages.create(
    model="claude-opus-4-8",
    max_tokens=64000,
    thinking={"type": "adaptive"},
    output_config={"effort": "high"},  # or "max", "xhigh", "medium", "low"
    messages=[{"role": "user", "content": "..."}],
)
```

- 細かい手順より「think thoroughly」等の一般指示が良い結果を生むことが多い
- few-shot 例に `<thinking>` タグを入れると推論パターンを学ぶ
- thinking オフ時も `<thinking>`/`<answer>` で段階推論を促せる
- 「終える前に〇〇基準で検証して」で誤りを捕捉（コーディング・数学で特に有効）

> thinking オフ時、4.5 は "think" という語に敏感。"consider" "evaluate" "reason through" などを使う。

### 12-6. エージェントシステム

**長期推論と状態管理**
複数のコンテキストウィンドウをまたぐ作業に強く、状態を保存して新しいウィンドウで継続できます。圧縮や外部ファイル保存があるなら明示します：

```text
Your context window will be automatically compacted as it approaches its limit, allowing you to continue working indefinitely from where you left off. Therefore, do not stop tasks early due to token budget concerns. As you approach your token budget limit, save your current progress and state to memory before the context window refreshes. Always be as persistent and autonomous as possible and complete tasks fully, even if the end of your budget is approaching. Never artificially stop any task early regardless of the context remaining.
```

複数ウィンドウのコツ：①最初のウィンドウは枠組み作り（テスト作成・セットアップ）に使う ②テストを `tests.json` 等の構造化形式で管理（「テストを削除/改変するな」と念押し）③`init.sh` 等の QoL スクリプトを作らせる ④圧縮より「新規ウィンドウ＋ローカル状態の再発見」が有効な場合も（`pwd`・`progress.txt`・git log を見させる）⑤Playwright MCP 等の検証ツールを与える ⑥コンテキストを使い切らせる：

```text
This is a very long task, so it may be beneficial to plan out your work clearly. It's encouraged to spend your entire output context working on the task - just make sure you don't run out of context with significant uncommitted work. Continue working systematically until you have completed this task.
```

状態管理：構造化データは JSON、進捗メモは自由記述テキスト、状態追跡に git を活用、漸進的な進捗を重視。

**自律性と安全性のバランス**
4.6 は無誘導だと取り消しにくい/共有システムに影響する操作（ファイル削除・force-push・外部投稿）を取ることがあります。確認させたいなら：

```text
Consider the reversibility and potential impact of your actions. You are encouraged to take local, reversible actions like editing files or running tests, but for actions that are hard to reverse, affect shared systems, or could be destructive, ask the user before proceeding.

Examples of actions that warrant confirmation:
- Destructive operations: deleting files or branches, dropping database tables, rm -rf
- Hard to reverse operations: git push --force, git reset --hard, amending published commits
- Operations visible to others: pushing code, commenting on PRs/issues, sending messages, modifying shared infrastructure

When encountering obstacles, do not use destructive actions as a shortcut. For example, don't bypass safety checks (e.g. --no-verify) or discard unfamiliar files that may be in-progress work.
```

**リサーチ・情報収集**
①成功基準を明確に ②複数ソースで検証させる ③複雑なリサーチは構造化アプローチで：

```text
Search for this information in a structured way. As you gather data, develop several competing hypotheses. Track your confidence levels in your progress notes to improve calibration. Regularly self-critique your approach and plan. Update a hypothesis tree or research notes file to persist information and provide transparency. Break down this complex research task systematically.
```

**サブエージェントのオーケストレーション**
ネイティブな委譲能力が向上し、明示指示なしで適切に委譲します。ただし 4.6 はサブエージェント好きで、直接 grep で済む探索にまで生成することも。過剰なら：

```text
Use subagents when tasks can run in parallel, require isolated context, or involve independent workstreams that don't need to share state. For simple tasks, sequential operations, single-file edits, or tasks where you need to maintain context across steps, work directly rather than delegating.
```

**複雑なプロンプトの連鎖**
多段推論の多くは内部で処理されますが、中間出力を検査したい/特定のパイプラインを強制したいときは明示的なチェーンが有効。最も多いのは**自己修正**（下書き → 基準でレビュー → 改善）。各ステップを別 API 呼び出しにすると、ログ・評価・分岐ができます。

**エージェントコーディングのファイル作成削減**
一時ファイルを scratchpad に使うことがあります（多くは結果改善に寄与）。net new を抑えたいなら：

```text
If you create any temporary new files, scripts, or helper files for iteration, clean up these files by removing them at the end of the task.
```

**過剰実装（overengineering）**
4.5/4.6 は余分なファイル・不要な抽象化・頼んでいない柔軟性を作りがち。抑えるには：

```text
Avoid over-engineering. Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused:

- Scope: Don't add features, refactor code, or make "improvements" beyond what was asked. A bug fix doesn't need surrounding code cleaned up. A simple feature doesn't need extra configurability.

- Documentation: Don't add docstrings, comments, or type annotations to code you didn't change. Only add comments where the logic isn't self-evident.

- Defensive coding: Don't add error handling, fallbacks, or validation for scenarios that can't happen. Trust internal code and framework guarantees. Only validate at system boundaries (user input, external APIs).

- Abstractions: Don't create helpers, utilities, or abstractions for one-time operations. Don't design for hypothetical future requirements. The right amount of complexity is the minimum needed for the current task.
```

**テスト通過への固執・ハードコードの回避**

```text
Please write a high-quality, general-purpose solution using the standard tools available. Do not create helper scripts or workarounds to accomplish the task more efficiently. Implement a solution that works correctly for all valid inputs, not just the test cases. Do not hard-code values or create solutions that only work for specific test inputs. Instead, implement the actual logic that solves the problem generally.

Focus on understanding the problem requirements and implementing the correct algorithm. Tests are there to verify correctness, not to define the solution. Provide a principled implementation that follows best practices and software design principles.

If the task is unreasonable or infeasible, or if any of the tests are incorrect, please inform me rather than working around them. The solution should be robust, maintainable, and extendable.
```

**ハルシネーション最小化（エージェントコーディング）**

```text
<investigate_before_answering>
Never speculate about code you have not opened. If the user references a specific file, you MUST read the file before answering. Make sure to investigate and read relevant files BEFORE answering questions about the codebase. Never make any claims about code before investigating unless you are certain of the correct answer - give grounded and hallucination-free answers.
</investigate_before_answering>
```

### 12-7. 能力別 Tips

**vision の向上**
4.5/4.6 は画像処理・データ抽出が向上（特に複数画像が文脈にある場合）。computer use のスクリーンショット解釈も改善。動画はフレーム分割で分析可能。crop ツールやスキルを与えて関心領域に「ズーム」させると、画像評価で一貫した向上が見られます。

**フロントエンドデザイン**
4.5/4.6 は複雑な実アプリ構築に強い一方、無誘導だと "AI slop" 美学に寄ります。差別化のための system プロンプトスニペット：

```text
<frontend_aesthetics>
You tend to converge toward generic, "on distribution" outputs. In frontend design, this creates what users call the "AI slop" aesthetic. Avoid this: make creative, distinctive frontends that surprise and delight.

Focus on:
- Typography: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics.
- Color & Theme: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes. Draw from IDE themes and cultural aesthetics for inspiration.
- Motion: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions.
- Backgrounds: Create atmosphere and depth rather than defaulting to solid colors. Layer CSS gradients, use geometric patterns, or add contextual effects that match the overall aesthetic.

Avoid generic AI-generated aesthetics:
- Overused font families (Inter, Roboto, Arial, system fonts)
- Clichéd color schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

Interpret creatively and make unexpected choices that feel genuinely designed for the context. Vary between light and dark themes, different fonts, different aesthetics. You still tend to converge on common choices (Space Grotesk, for example) across generations. Avoid this: it is critical that you think outside the box!
</frontend_aesthetics>
```

### 12-8. 移行時の考慮

旧世代から 4.6 系への移行ポイント：①望む挙動を具体的に記述 ②修飾語で品質・詳細を引き上げる（「ダッシュボードを作れ」→「機能を可能な限り盛り込み、基本を超えた完全実装を」）③アニメ・インタラクティブ要素は明示的に要求 ④thinking は adaptive ＋ effort へ ⑤prefill から移行（[12-3](#12-3-出力とフォーマット制御) 参照）⑥「怠けるな」系プロンプトは緩める（overtrigger 防止）。

**Sonnet 4.5 → 4.6**：4.6 は既定 effort `high`（4.5 は effort パラメータなし）。明示しないと高レイテンシになりがち。推奨は大半 `medium`、高頻度/低レイテンシは `low`、64k 出力上限を確保。最難・最長ホライズンのタスクは引き続き Opus 4.8 が適。extended thinking なしなら 4.6 でも継続可（effort を明示）。adaptive thinking 移行例：

```python Python
client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=64000,
    thinking={"type": "adaptive"},
    output_config={"effort": "high"},
    messages=[{"role": "user", "content": "..."}],
)
```

> 詳細な移行手順は公式 [Migration guide](https://platform.claude.com/docs/en/about-claude/models/migration-guide) を参照。

---

<sub>本資料は公開情報（Anthropic 公式・主要メディア・各社公式 X アカウント）をもとに作成した非公式まとめです。正確性には努めていますが、最終的な判断は一次情報をご確認ください。</sub>
