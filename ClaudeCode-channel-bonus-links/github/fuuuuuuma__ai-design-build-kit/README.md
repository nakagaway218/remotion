# AIでWebサイト・アプリ・LPを作り込むための設計キット

**— ファイル構造 / `design.md` / おすすめプラグイン・スキル / デザイン系プロンプト100選 / OpenAI Codex 最新アップデート解説**

> AIコーディングエージェント（Claude Code・Codex など）に「Webサイト・アプリ・LP・ヘルプページ・スライド」を高い完成度で作らせるための"土台"を1か所にまとめたキットです。
> 「毎回ゼロから指示して、毎回バラバラの見た目になる」を卒業し、**ファイル構造とデザインのルールを先に置いてから作る**やり方に切り替えます。
> 対象は初心者〜中級者。コードが書けなくても「どう頼めば崩れないか」が分かるように書いています。プロンプト100選（[`prompts.json`](./prompts.json)）も同梱。

---

## ⚠️ この資料の読み方（確度について）

- **作成日**: 2026-06-03 時点の情報です。AIツールの仕様は週単位で変わります。最終確認は必ず公式で。
- **確度マーク**: ✅ 公式・複数ソースで確認済み ／ 🔶 一次情報はあるが流動的 ／ ⚠️ 未確認・推測
- 本資料は非公式まとめです。OpenAI / Anthropic / Google / Vercel 各社とは無関係です。
- ファイル構造・design.md・プロンプトは「型のたたき台」です。プロジェクトに合わせて必ず手を入れてください。コピペして終わり、にはしないこと。

## TL;DR（3行）

- **作る前に"置く"**: `CLAUDE.md`／`AGENTS.md`（働き方）・`DESIGN.md`（見た目の正典）・`SKILL.md`（再利用する手順）の3〜4ファイルを最初に用意するだけで、AIの出力がブレなくなる。✅
- **`design.md` は2026年の実在フォーマット**: 色・タイポ・余白などの"デザイントークン"をYAML＋Markdownで書き、リポジトリのルートに置くと、エージェントが毎回それを読んでUIを揃えてくれる（[Google Labs公式仕様](https://github.com/google-labs-code/design.md)あり）。✅
- **最新トピック**: 2026/6/2、OpenAIが Codex に「**Sites**（アイデアをURL共有できるWeb/アプリに変換）」と「**6つのロール特化プラグイン**（product design・creative production など）」を追加。"非エンジニアがCodexでモノを作る"方向に大きく舵を切った。✅

## 目次

1. [このキットの全体像 — 「3層モデル」で考える](#1-このキットの全体像--3層モデルで考える)
2. [【2026年6月最新】OpenAI Codex 大型アップデート解説（添付5ポスト）](#2-2026年6月最新openai-codex-大型アップデート解説添付5ポスト)
3. [なぜ「ファイル構造」から始めるのか](#3-なぜファイル構造から始めるのか)
4. [完璧に近づけるファイル構造テンプレート（Webサイト / アプリ / LP）](#4-完璧に近づけるファイル構造テンプレートwebサイト--アプリ--lp)
5. [`design.md` ベストプラクティス（このキットの中核）](#5-designmd-ベストプラクティスこのキットの中核)
6. [デザイン品質の原則 — "AIっぽさ"を消す](#6-デザイン品質の原則--aiっぽさを消す)
7. [おすすめプラグイン / MCP](#7-おすすめプラグイン--mcp)
8. [おすすめスキル](#8-おすすめスキル)
9. [デザイン系プロンプト100選](#9-デザイン系プロンプト100選)
10. [使い方（初心者基準）— 悩み → こう頼むだけ](#10-使い方初心者基準-悩み--こう頼むだけ)
11. [もう一歩進んだ使い方](#11-もう一歩進んだ使い方)
12. [出典](#12-出典)
13. [未確認・注意事項](#13-未確認注意事項)

---

## 1. このキットの全体像 — 「3層モデル」で考える

AIに何かを作らせるとき、指示を毎回プロンプトに全部書くと「先週と今週で見た目が違う」「3ページ目から急にデザインが崩れる」ということが起きます。原因はシンプルで、**AIは前回の文脈を覚えていない**からです。

そこで2026年に定着してきたのが、指示を「3つの層」に分けてファイルとして置いておく考え方です。料理に例えると、**毎回シェフに口頭で全部伝える**のではなく、**お店のルールブックを厨房に貼っておく**イメージです。

| 層 | ファイル | 役割（料理の例え） | いつ読まれる |
|---|---|---|---|
| ① 働き方 | `CLAUDE.md` / `AGENTS.md` | 「うちの厨房のルール」。言語・コミット規約・禁止事項・使うコマンド | セッション開始時に毎回 |
| ② 見た目 | `DESIGN.md` | 「盛り付けの正典」。色・フォント・余白・角丸・コンポーネントの形 | UIを作るたびに毎回 |
| ③ 手順 | `SKILL.md`（スキル） | 「定番レシピ」。再利用する作業手順（例: スライド生成、PDF整形） | その作業のときだけ |

> この「AGENTS.md / SKILL.md / DESIGN.md の3層」という整理は、2026年に複数メディアで取り上げられた考え方です（[DEV Community: AGENTS.md, SKILL.md, DESIGN.md](https://dev.to/aws-builders/agentsmd-skillmd-designmd-how-ai-instructions-split-into-three-layers-d0g)）。🔶

このキットは主に **②見た目（DESIGN.md）** と **そこに到達するためのファイル構造・プロンプト** を扱います。①③については「おすすめスキル」「もう一歩進んだ使い方」で触れます。

---

## 2. 【2026年6月最新】OpenAI Codex 大型アップデート解説（添付5ポスト）

依頼に添付された5件のOpenAI公式ポスト（2026/6/2）は、すべて**Codexの「非エンジニア向け・モノ作り」方向の大型アップデート**に関するものでした。X本文はペイウォール（HTTP 402）で直接引用できないため、内容は公式発表ページと複数の報道で裏取りした範囲を記載します。

> 一次情報の主軸: [OpenAI「Codex for every role, tool, and workflow」](https://openai.com/index/codex-for-every-role-tool-workflow/)（公式・2026/6/2）。報道: [TechCrunch](https://techcrunch.com/2026/06/02/openai-launches-new-codex-tools-for-white-collar-work/) / [VentureBeat](https://venturebeat.com/orchestration/openais-codex-update-lets-agents-build-interactive-enterprise-workspaces-via-sites-and-role-specific-plugins) / [9to5Mac](https://9to5mac.com/2026/06/02/openai-putting-codex-inside-chatgpt-app-everywhere-releasing-6-business-plugins/)。

この発表は大きく**3本柱**です。

### ① Sites — アイデアをURL共有できる「Webサイト/アプリ」に変換 ✅

> 原文の要旨（ポスト1）: "Building apps has never been easier. With Sites, Codex can turn your work, ideas, and plans into an interactive website or app your team can explore, use, and share with a URL."

- 仕事・アイデア・計画を、チームが**触って・使って・URLで共有できる**インタラクティブなWebサイト/アプリにCodexが変換する機能。
- 提供範囲: まず **Business / Enterprise プラン**にロールアウトし、その後より広く展開予定。🔶（一般提供時期は未確定）
- **このキットとの関係**: 「URLを共有するだけのLP・社内ツール・ダッシュボード」を作るハードルが下がる。ただし"それっぽく動く"ものと"ブランドとして整った"ものは別物。だからこそ後述の `DESIGN.md` で見た目を縛る価値が上がる。

### ② 6つのロール特化プラグイン — 1クリックで「専門家化」 ✅

> 原文の要旨（ポスト2）: 単一ツールを超えて、Codexを"ロール特化の専門家"にする新プラグイン。**コーディング不要・1インストール**。62の人気アプリ・110のスキルにアクセス。

公式・報道で確認できた6プラグイン（白いカラー＝ビジネス職向け）:

| プラグイン | できること | 連携ツール（報道ベース） | 確度 |
|---|---|---|---|
| **Product Design** | プロトタイプ作成・デザイン方向付け | （詳細は流動的） | 🔶 |
| **Creative Production** | ブリーフ → レビュー可能なアセット化、キャンペーンボード、表示広告のバリエーション、商品ライフスタイル写真／EC向け画像セット | Figma, Canva, Shutterstock, Picsart, Fal | ✅ |
| **Data Analytics** | データで質問に回答、指標変動の説明、レポート／ダッシュボード作成 | Snowflake, Databricks Genie, Hex, Tableau | ✅ |
| **Sales** | 営業職向けの調査・資料作成 | （詳細は流動的） | 🔶 |
| **Public Equity Investing** | 公開株式の調査・分析 | （詳細は流動的） | 🔶 |
| **Investment Banking** | 投資銀行業務の調査・資料 | （詳細は流動的） | 🔶 |

> ポスト3（OpenAIDevs）の要旨: "Plugins for Data Analytics, Creative Production, and Product Design give Codex the tools and context to create reports, creative directions, and prototypes. **Built and used by OpenAI teams.**"（OpenAI社内チームが実際に使っているものを外部提供）
> ポスト4: "Bring your briefs to life. The creative production plugin for Codex."（ブリーフを形にする＝クリエイティブ制作プラグイン）
> ポスト5: "Translate data into answers. The data analytics plugin for Codex."（データを答えに変える＝データアナリティクスプラグイン）

### ③ Annotations（注釈）— 成果物に直接フィードバック 🔶

- 生成された成果物に注釈（コメント）を付けて修正を依頼できる新機能、と複数報道が言及。詳細仕様は流動的のため🔶。

### 数字と意味づけ

- Codex の**週間アクティブユーザーは500万人超**、デスクトップアプリ提供開始（2026年2月）から**約6倍**に増加。✅
- **意味**: OpenAIは「Codex＝開発者のコード支援」から「Codex＝**あらゆる職種がモノ（資料・サイト・プロト）を作る場所**」へ拡張しようとしている。Anthropic の Claude Code が「スキル／プラグイン／MCP」で同じ方向を強めているのと合わせて、2026年は**"作りたい人がAIに環境を渡して作らせる"**のが主流になりつつある、と読めます。

---

## 3. なぜ「ファイル構造」から始めるのか

「完璧なWebサイトを作って」と一言だけ頼むと、AIは**毎回ちがう前提で動きます**。フォルダ構成がバラバラだと、後から「ここ直して」が通らず、修正のたびに崩れます。

逆に、**置き場所が決まっている**と次の3つが手に入ります。

1. **一貫性** — 「ボタンは `components/ui/` にある」と決まっていれば、AIも人も同じ場所を触る。
2. **再現性** — 同じ構造に同じ `DESIGN.md` を置けば、別ページでも同じ見た目が出る。
3. **頼みやすさ** — 「`app/pricing/page.tsx` を作って」と**ファイル単位**で頼めるので、指示が短く・正確になる。

ポイントは「凝った構造を作ること」ではなく「**最初に決めて、ブレさせないこと**」です。

---

## 4. 完璧に近づけるファイル構造テンプレート（Webサイト / アプリ / LP）

以下は **Next.js（App Router）+ TypeScript + Tailwind + shadcn/ui** を例にした、2026年時点で扱いやすい構成です。フレームワークが違っても「考え方」は流用できます。

### 共通: リポジトリのルートに必ず置く"司令塔"ファイル

```text
my-project/
├─ CLAUDE.md          # Claude Code 用の働き方ルール（言語・規約・禁止事項）
├─ AGENTS.md          # 汎用エージェント（Codex 等）用。CLAUDE.md と内容を揃える
├─ DESIGN.md          # ★見た目の正典（§5で詳説）。ルート直下が定石
├─ README.md          # 人間向けの説明
├─ .env.example       # 環境変数の見本（実キーは絶対に置かない／コミットしない）
└─ .gitignore         # .env, node_modules などを除外
```

> `DESIGN.md` を**ルートに置き、`AGENTS.md` から参照させる**のが推奨パターンです（[design.md公式](https://github.com/google-labs-code/design.md) / [TDP解説](https://designproject.io/blog/design-md-file/)）。✅

### A. Webサイト（コーポレート / メディア / ブログ）

```text
src/
├─ app/                      # ルーティング（App Router）
│  ├─ layout.tsx             # 全ページ共通の枠（ヘッダー/フッター/フォント）
│  ├─ page.tsx               # トップ
│  ├─ about/page.tsx
│  ├─ blog/
│  │  ├─ page.tsx            # 記事一覧
│  │  └─ [slug]/page.tsx     # 記事個別（動的ルート）
│  ├─ contact/page.tsx
│  └─ globals.css            # デザイントークン（CSS変数）はここに集約
├─ components/
│  ├─ ui/                    # shadcn/ui の基本部品（button, card, input…）
│  ├─ layout/                # header, footer, nav
│  └─ sections/              # hero, features, cta などページの"塊"
├─ content/                  # MDX・記事データ（CMSを使わない場合）
├─ lib/                      # utils.ts（cn()）, fetcher, 定数
└─ public/                   # 画像・OGP・favicon
```

### B. アプリ / SaaS（ダッシュボード / 管理画面）

```text
src/
├─ app/
│  ├─ (marketing)/           # 未ログイン向け（LP・料金）= ルートグループ
│  │  ├─ page.tsx
│  │  └─ pricing/page.tsx
│  ├─ (app)/                 # ログイン後の本体
│  │  ├─ layout.tsx          # サイドバー付きシェル
│  │  ├─ dashboard/page.tsx
│  │  ├─ settings/page.tsx
│  │  └─ [resource]/…        # CRUD 画面
│  └─ api/                   # サーバー処理（Route Handlers）
├─ components/
│  ├─ ui/                    # shadcn 基本部品
│  ├─ dashboard/             # 画面固有の複合部品
│  └─ forms/                 # 入力フォーム群
├─ lib/                      # auth, db クライアント, utils, validations(zod)
├─ hooks/                    # useXxx（状態・データ取得のフック）
└─ types/                    # 型定義
```

> shadcn/ui は「ライブラリ」ではなく**ソースコードをコピーして使う**方式で、`components/ui/` に部品が入り、`lib/utils.ts` の `cn()` で class を合成し、テーマは `globals.css` のCSS変数で管理します（[shadcn docs](https://ui.shadcn.com/docs)）。✅

### C. LP（ランディングページ / 1ページ完結の訴求）

LPは「1本の物語」。**セクションを上から積む**設計が一番崩れません。

```text
src/
├─ app/
│  ├─ page.tsx               # LP本体（sections を縦に並べるだけ）
│  ├─ layout.tsx             # メタ情報・OGP・計測タグ
│  └─ globals.css
├─ components/
│  └─ sections/              # ↓ この順番がそのまま画面の流れになる
│     ├─ Hero.tsx            # 1画面目（3秒で価値が伝わる）
│     ├─ ProblemAgitate.tsx  # 悩みの言語化
│     ├─ Solution.tsx        # 解決策
│     ├─ Features.tsx        # 機能・特徴
│     ├─ SocialProof.tsx     # 実績・お客様の声
│     ├─ Pricing.tsx         # 料金
│     ├─ FAQ.tsx             # よくある質問
│     └─ FinalCTA.tsx        # 最後の一押し
└─ public/
```

> LPは「セクション＝ファイル」に分けておくと、AIに「`SocialProof.tsx` だけ作り直して」と**部分修正**を頼みやすく、全体崩壊を防げます。

### （番外）ヘルプ / ドキュメントサイト

ヘルプセンター・FAQ・サポート系は「探しやすさ」が命。`docs/[category]/[article]` の階層 ＋ 検索 ＋ 目次（TOC）を基本形に。Next.js なら **Nextra**、ドキュメント特化なら **Docusaurus / Mintlify** などのテンプレを土台にすると速いです。🔶

### （番外）スライド / プレゼン

「1枚の自己完結HTML」で作るのが配布・修正ともに最速です。`1280×720`（16:9）のキャンバスに `.slide` を並べ、`showSlide(n)` で切り替える方式。配色・フォント・共通パーツ（ロゴ・ページ番号・ナビ）を最初に固めると、30枚でも統一感が出ます。

---

## 5. `design.md` ベストプラクティス（このキットの中核）

### `design.md` とは何か ✅

**デザインシステムを、AIエージェントが読める形に書き直したMarkdownファイル**です。色・タイポgrafi・余白・コンポーネントの形と、その"理由"を1ファイルにまとめ、リポジトリのルートに置きます。エージェントはUIを生成するたびにこれを読むので、**毎回プロンプトでブランドを説明し直さなくても出力が揃います**。

> "It's a markdown file that gives coding agents persistent context about a design system — colors, typography, spacing, components, plus prose explaining how to apply them."（[WaveSpeed Blog](https://wavespeed.ai/blog/posts/what-is-design-md-for-coding-agents/)）

### 公式フォーマット（Google Labs仕様）✅

[google-labs-code/design.md](https://github.com/google-labs-code/design.md) の仕様では、`design.md` は **2層構造**です。

1. **YAML フロントマター** — 機械が読む"デザイントークン"（`---` で囲む）
2. **Markdown 本文** — 人間が読む"デザインの理由・ルール"（`##` 見出し）

YAML側のスキーマ（要点）:

```yaml
---
version: alpha
name: <デザインシステム名>
description: <一言説明>
colors:
  <トークン名>: <CSSカラー>      # 例: "#1A1C1E" / "oklch(62% 0.18 250)"
typography:
  <トークン名>:                   # 例: h1, body-md, label-caps
    fontFamily: <フォント>
    fontSize: <サイズ>            # 例: 3rem
    fontWeight: <太さ>
    lineHeight: <行間>
    letterSpacing: <字間>         # 例: -0.02em
rounded:
  sm: 4px
  md: 8px
spacing:
  sm: 8px
  md: 16px
components:
  <部品名>:
    backgroundColor: "{colors.primary}"   # 他トークンを {path} で参照できる
    textColor: "{colors.neutral}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
---
```

Markdown本文の**標準セクション順**（公式の正準順序）:

```text
## Overview            … 何の/誰のためのプロダクトか、トーン
## Colors              … 配色の意図（高コントラスト中立色＋アクセント等）
## Typography          … 見出し/本文の使い分け
## Layout              … グリッド・余白・配置の原則
## Elevation & Depth   … 影・重なりの設計
## Shapes              … 角丸・形状
## Components          … 部品ごとの見た目
## Do's and Don'ts     … やること/避けること
```

### 最小サンプル（コピペして書き換える用）

```markdown
---
version: alpha
name: Heritage
colors:
  primary: "#1A1C1E"
  secondary: "#6C7278"
  accent: "#B8422E"
  neutral: "#F7F5F2"
typography:
  h1: { fontFamily: Public Sans, fontSize: 3rem, fontWeight: 700, lineHeight: 1.1 }
  body-md: { fontFamily: Public Sans, fontSize: 1rem, lineHeight: 1.6 }
rounded: { sm: 4px, md: 8px }
spacing: { sm: 8px, md: 16px, lg: 32px }
---

## Overview
建築的なミニマリズムと、報道的な重厚さを掛け合わせた信頼感のある表現。対象は意思決定者。
原則: ①密度より明快さ ②モーションは控えめに ③データ画面は高コントラスト。

## Colors
高コントラストな中立色を基調に、アクセント（accent）は1箇所の強調だけに使う。

## Do's and Don'ts
- Do: 余白を恐れない。1画面1メッセージ。
- Don't: アクセント色を複数同時に使う。紫グラデを多用する。
```

### 書き方のコツ（ベストプラクティス）

- **冒頭3〜5文＋原則3〜5個**: "何の/誰のためか・トーン"を数文で書き、「clarity over density（密度より明快さ）」のような原則を3〜5個。これがAIの判断基準になる（[Department of Product](https://departmentofproduct.substack.com/p/designmd-explained-the-format-reshaping)）。
- **実在する値だけ書く**: テーマに無い色やリネーム済みの部品名を書かない。**エンジニアに同席してもらって**、コードと食い違うトークンを潰すと精度が上がる（[TDP](https://designproject.io/blog/design-md-file/)）。
- **トークン参照を使う**: `{colors.primary}` のように参照させ、ハードコードのhex値を本文にばらまかない。
- **`Do's and Don'ts` を必ず書く**: 「紫グラデ多用しない」「アクセントは1色」など"やらないこと"がブランド崩壊を一番よく防ぐ。

### 実例集から学ぶ（ショートカット）

ゼロから書くのが難しければ、ブランド別 `DESIGN.md` の実例集 [VoltAgent/awesome-design-md](https://github.com/voltagent/awesome-design-md)（Claude / OpenAI / Vercel / Linear / Stripe / Apple / Nike / Tesla など72件以上）から近いものをコピーし、自分のブランドに合わせて値を書き換えるのが速いです。使い方は「`DESIGN.md` をルートに置く → "これに合わせてこのページを作って" と頼む」だけ。✅
生成補助には [getdesign.md](https://getdesign.md/) や [design.dev のジェネレータ](https://design.dev/ai/design-md-generator/) も使えます。🔶

### `design.md` vs デザイントークン（JSON）

`design.md` は**人間の意図（なぜ）＋機械の値（何を）**を1ファイルに同居させるのが強み。一方、Style Dictionary 等の**デザイントークン（JSON）**は「複数プラットフォームに値を配る」のが強み。**併用**が理想で、`design.md` を"正典"に、ビルド用トークンを派生させる運用が現実的です（[WaveSpeed: design.md vs tokens](https://wavespeed.ai/blog/posts/design-md-vs-design-tokens-ai-workflows/)）。🔶

---

## 6. デザイン品質の原則 — "AIっぽさ"を消す

ファイル構造と `design.md` で"土台"を作っても、**美意識のルール**が無いと「いかにもAI生成」な凡庸な見た目になります。ここは Anthropic 公式の `frontend-design` スキルと、Vercel の `shadcn` スキルの指針が実用的です。

### Anthropic `frontend-design` の原則（要約・✅公式）

- **まず方向性を1つに決め切る**: brutally minimal / maximalist / retro-futuristic / editorial / luxury など"極"を選び、最後まで一貫させる。中途半端が一番ダサい。
- **避けるべき"AI slop"**: `Inter`/`Roboto`/`Arial`/システムフォントの多用、**白背景に紫グラデ**、予測可能なレイアウト、文脈の無いコピペ的デザイン。
- **タイポグラフィ**: 特徴的な見出しフォント × 上品な本文フォントの組み合わせ。
- **色とテーマ**: CSS変数で一貫管理。支配色＋鋭いアクセント（全色を均等に散らさない）。
- **モーション**: 派手に散らすより、**ページロード時の段階表示（stagger）**など"決め所"に集中。
- **余白と構図**: 非対称・重なり・グリッド崩しなど、意図ある配置で記憶に残す。

### shadcn / プロダクトUIの実装則（✅）

- ダッシュボード・管理画面・AIアプリは `new-york` スタイル＋**ダークモード基準**が無難。コンテンツ主体・読み物系のみライトモード。
- ベース配色は `zinc / neutral / slate` のどれか1つ、アクセントは `--color-primary` 1色。基礎面は `bg-background` `bg-card` `text-foreground` などの**トークン**で塗り、場当たりのhexを避ける。
- 角丸は統一（既定 `--radius: 0.625rem` が良い基準）。アイコンは Lucide を `h-4 w-4` 等で静かに揃える。
- **避けるパターン**: カードのネスト地獄、全面にグラデ＋ガラス効果、アクセント色を複数衝突、空/読み込み/エラー状態を未デザインで放置、破壊的操作に `Dialog`（正しくは `AlertDialog`）。

> まとめると「①方向性を1つに決める → ②`design.md`/トークンで縛る → ③空・エラー状態まで設計する」の3点を守るだけで、凡庸さはかなり消えます。

---

## 7. おすすめプラグイン / MCP

AIに"手と目"を与える拡張です（◎=まず入れたい）。

| 名前 | 種類 | 何ができる | 使いどころ | 確度 |
|---|---|---|---|---|
| **shadcn/ui**（+ shadcn skill）◎ | CLI/レジストリ/スキル | アクセシブルなReact部品をソースごと導入、テーマ・プリセット管理 | アプリ/ダッシュボードの土台 | ✅ |
| **Figma MCP** ◎ | MCP | Figmaのデザイン↔コードを双方向に。デザインからコード生成、コードからFigmaへ | デザインを実装に落とす | ✅ |
| **Playwright MCP / ブラウザ検証** ◎ | MCP | 実ブラウザでページを開き、クリック・入力・スクショで**実機検証** | 「動きます」を証明する | ✅ |
| **Context7 MCP** ◎ | MCP | ライブラリ公式ドキュメントを最新で取得（Next.js, Tailwind 等） | 古い記憶で書かせない | ✅ |
| **Canva MCP / Adobe MCP** | MCP | デザイン素材・テンプレ生成、画像加工 | バナー・SNS・素材 | 🔶 |
| **v0 / AI Elements レジストリ** | レジストリ | shadcn互換でAI系UI部品やテンプレを追加 | AIチャットUI等を即構築 | ✅ |
| **OpenAI Codex Product Design / Creative Production プラグイン** | Codexプラグイン | プロト作成・クリエイティブ制作（§2） | Codex派の人 | 🔶（提供範囲流動的） |

> MCP（Model Context Protocol）= AIに外部ツール（ブラウザ・Figma・DB等）を触らせる共通規格。"AIに目と手を生やす"イメージ。

---

## 8. おすすめスキル

スキル＝「定番作業の手順書」をAIに渡しておく仕組み（Anthropic公式・プラグイン由来など）。

| スキル | 何をする | おすすめ理由 |
|---|---|---|
| **frontend-design**（Anthropic公式）◎ | 凡庸さを避けた高品質UIを生成 | "AIっぽさ"を消す原則が中身（§6） |
| **shadcn**（Vercel）◎ | shadcn/uiの正しい使い方・最新API | コンポーネント実装の精度が段違い |
| **anthropic-skills: pptx / docx / pdf / xlsx** | スライド/文書/PDF/表計算の生成・編集 | 資料・配布物まで一気通貫 |
| **skill-creator**（Anthropic公式） | 自分専用スキルを作る/改善する | 繰り返す作業を"型"にできる |
| **figma-generate-design / figma-use** | Figmaへ/からデザインを生成・編集 | デザイン↔コードの橋渡し |
| **brainstorming / writing-plans**（superpowers） | 作る前に要件と設計を詰める | いきなり実装→崩壊を防ぐ |
| **verification / preview 系** | 実機で開いて検証してから完了 | "動くつもり"を潰す |

> 使い分けの基本: **作る前 → brainstorming**、**作る → frontend-design + shadcn**、**確かめる → preview/verification**、**配る → pptx/pdf**。

---

## 9. デザイン系プロンプト100選

そのままコピペで使える英語プロンプト集（英語の方がエージェントの精度が安定しやすい）。**構造化データは [`prompts.json`](./prompts.json) に同梱**。各プロンプトは「ファイル構造と `design.md` がある前提」で書くと最も効きます。

> 共通の前置き（毎回足すと効果大）:
> `"Read DESIGN.md and AGENTS.md first. Follow the design tokens and Do's/Don'ts. Match the existing file structure. After building, verify in a browser and show a screenshot."`

### A. Webサイト（1–16）

1. **トップページ生成** — `Build a homepage hero + features + social proof + CTA, following DESIGN.md. Avoid generic AI aesthetics.`
2. **企業サイト一式** — `Generate a corporate site: Home, About, Services, Contact, using the App Router file structure in this repo.`
3. **ヒーロー刷新** — `Redesign only the Hero section to lead with one clear value prop readable in 3 seconds.`
4. **ブログ一覧＋個別** — `Create /blog list and /blog/[slug] detail pages with MDX content and a reading-time badge.`
5. **ナビ/ヘッダー** — `Build a sticky responsive header with mobile Sheet nav and active-link states.`
6. **フッター** — `Design a footer with sitemap columns, social links, and a newsletter input.`
7. **会社概要** — `Build an About page with timeline, team grid, and values cards.`
8. **お問い合わせ** — `Create a Contact page with a validated form (zod), success/error states, and accessible labels.`
9. **料金ページ** — `Build a pricing page with 3 tiers, a most-popular highlight, and a monthly/yearly toggle.`
10. **OGP/メタ** — `Add per-page metadata, Open Graph, Twitter cards, and a dynamic OG image route.`
11. **ダークモード** — `Add a theme toggle (light/dark) using CSS variables; persist the choice.`
12. **多言語化** — `Add i18n routing for ja/en and externalize all UI strings.`
13. **アニメ強化** — `Add a single orchestrated page-load animation with staggered reveals; keep it tasteful.`
14. **404/エラー** — `Design custom 404 and error pages consistent with DESIGN.md.`
15. **検索** — `Add a Cmd+K command palette to search pages and content.`
16. **パフォーマンス** — `Audit and optimize Core Web Vitals: image sizing, font loading, and lazy sections.`

### B. アプリ / SaaS（17–32）

17. **ダッシュボード** — `Build a dashboard: summary cards + chart + recent table, using shadcn (new-york, dark).`
18. **サイドバーシェル** — `Create an (app) layout with collapsible sidebar, breadcrumb, and user menu.`
19. **設定画面** — `Build a settings page with Tabs + Card groups + a predictable save flow.`
20. **CRUDテーブル** — `Create a data table with sorting, filtering, row actions (DropdownMenu), and a Sheet editor.`
21. **認証画面** — `Build sign-in/sign-up with centered Card, inline Alert errors, and social separators.`
22. **オンボーディング** — `Design a 3-step onboarding wizard with progress and skip option.`
23. **空状態** — `Design empty, loading (Skeleton), and error states for every list view.`
24. **通知** — `Add a notifications popover with read/unread states and a mark-all-read action.`
25. **課金** — `Build a billing page: current plan, usage meters, invoices table, upgrade dialog.`
26. **権限/ロール** — `Add role-based UI: hide/disable actions by permission with clear tooltips.`
27. **検索/フィルタ** — `Add a filter bar (Select + Sheet on mobile) that updates the URL query.`
28. **詳細ページ** — `Build an entity detail page: header + status Badge + main Card + side Card + AlertDialog for delete.`
29. **フォーム検証** — `Implement robust form validation (zod) with field-level errors and disabled submit.`
30. **チャートUI** — `Add accessible charts (line/bar) with tokens for color; include a no-data state.`
31. **モバイル最適化** — `Make the app shell fully responsive; convert desktop sidebar to a mobile Sheet.`
32. **キーボード操作** — `Add keyboard shortcuts and visible focus rings throughout the app.`

### C. ヘルプ / ドキュメント（33–46）

33. **ヘルプセンター** — `Build a help center: category grid, article pages, search, and "was this helpful?".`
34. **FAQ** — `Create an accessible FAQ accordion grouped by topic with deep-linkable items.`
35. **ドキュメントサイト** — `Scaffold a docs site (sidebar nav + TOC + prev/next) with MDX.`
36. **検索付きドキュメント** — `Add full-text search to docs with keyboard navigation.`
37. **APIリファレンス** — `Generate an API reference layout with endpoint, params, and copyable examples.`
38. **オンボーディングガイド** — `Write a getting-started guide with numbered steps and copy buttons.`
39. **トラブルシュート** — `Create a troubleshooting page: symptom → cause → fix tables.`
40. **用語集** — `Build a glossary with anchor links and inline definitions on hover.`
41. **変更履歴** — `Design a changelog page grouped by date with tags (new/fix/breaking).`
42. **問い合わせ導線** — `Add a "still need help?" contact CTA at the end of every article.`
43. **バージョン切替** — `Add a docs version switcher that swaps the content set.`
44. **コードブロック** — `Add syntax-highlighted code blocks with copy buttons and filename tabs.`
45. **目次自動生成** — `Auto-generate an in-page table of contents from headings with scroll-spy.`
46. **フィードバック収集** — `Add thumbs up/down feedback with an optional comment box per article.`

### D. スライド / プレゼン（47–60）

47. **デッキ一括生成** — `From this transcript, build a single self-contained HTML deck (1280×720, 16:9).`
48. **テーマ統一** — `Apply a consistent theme: navy + accent, one display + one body font, page numbers.`
49. **ナビ実装** — `Add keyboard navigation (←/→/Space) and a slide counter.`
50. **タイトル/章扉** — `Create title and section-divider slide templates.`
51. **箇条書き整形** — `Convert these bullets into clean check-list and step-list slide components.`
52. **比較表スライド** — `Build a comparison-table slide that stays readable on 16:9.`
53. **組織図** — `Create an org-chart slide (boxes + connectors) that doesn't overflow.`
54. **タイムライン** — `Make a horizontal timeline slide with date badges.`
55. **数字強調** — `Design a big-number/metric slide with one hero figure and a caption.`
56. **2/3カラム** — `Provide two-col and three-col content slide layouts.`
57. **まとめスライド** — `Create a summary slide that restates the 3 key takeaways.`
58. **CTAスライド** — `Add a closing CTA slide (URL/QR placeholder, single action).`
59. **PPTX書き出し** — `Convert this HTML deck into a .pptx preserving layout (use the pptx skill).`
60. **実機検証** — `Serve the deck locally, open in a browser, screenshot slides 1/n/last, and fix any overflow.`

### E. design.md / デザインシステム / トークン（61–74）

61. **design.md 生成** — `Generate a DESIGN.md (YAML tokens + prose) for a [brand] with tone [x]; include Do's/Don'ts.`
62. **既存サイトから抽出** — `Inspect this site's CSS and produce a DESIGN.md capturing its colors, type, spacing.`
63. **トークン整備** — `Extract all hardcoded colors/spacings into CSS variables and a tokens file.`
64. **配色設計** — `Propose an accessible palette (WCAG AA) with primary, neutral ramp, and one accent.`
65. **タイポスケール** — `Define a modular type scale and map it to h1–h6 + body/caption tokens.`
66. **スペーシング** — `Define a spacing scale (4px base) and refactor components to use it.`
67. **角丸/影** — `Standardize radius and elevation tokens; remove ad-hoc shadows.`
68. **コンポーネント定義** — `Document button/input/card variants in DESIGN.md components section.`
69. **ダーク対応トークン** — `Add dark-mode token values and verify contrast in both themes.`
70. **ブランド適用** — `Apply awesome-design-md's [brand].md to this project and reconcile conflicts.`
71. **一貫性監査** — `Audit the app for off-token colors/spacing and list violations with fixes.`
72. **Figma同期** — `Sync DESIGN.md tokens with Figma variables (via Figma MCP).`
73. **Storybook** — `Set up a component gallery showing every variant from DESIGN.md.`
74. **トークン配布** — `Generate platform tokens (web/iOS/Android) from DESIGN.md via Style Dictionary.`

### F. LP / コンバージョン（75–88）

75. **LP一気構築** — `Build a single-page LP: Hero→Problem→Solution→Features→Proof→Pricing→FAQ→CTA.`
76. **ヒーロー最適化** — `Write 3 hero headline variants (benefit-led) and implement an A/B-ready switch.`
77. **悩み言語化** — `Build a Problem/Agitate section with relatable pain points and visuals.`
78. **ベネフィット** — `Turn features into benefit statements (so-that framing) in a 3-col grid.`
79. **社会的証明** — `Add testimonials, logos, and a metrics bar (e.g., "5M+ users") section.`
80. **比較表** — `Add a "us vs alternatives" comparison table that's honest and readable.`
81. **FAQで反論処理** — `Write a FAQ that handles the top 6 objections before purchase.`
82. **CTA設計** — `Design a sticky CTA and a final CTA; one primary action, no distractions.`
83. **フォーム最小化** — `Reduce the signup form to the fewest fields; add inline validation.`
84. **信頼バッジ** — `Add trust signals (security, guarantees, payment logos) near the CTA.`
85. **モバイルCV** — `Optimize the LP for mobile: tap targets, sticky CTA, fast first paint.`
86. **計測** — `Add analytics events for hero CTA, pricing clicks, and form submit.`
87. **表示速度** — `Optimize LCP: preload hero image/font, defer non-critical JS.`
88. **ヒートマップ前提** — `Annotate sections with data-attributes for heatmap/AB tooling.`

### G. QA / 改善 / レスポンシブ / アクセシビリティ（89–100）

89. **a11y監査** — `Run an accessibility pass: alt text, labels, contrast, focus order, ARIA.`
90. **キーボード操作** — `Make the whole UI keyboard-navigable with visible focus states.`
91. **レスポンシブ点検** — `Test at 360/768/1024/1440; fix overflow and tap-target issues.`
92. **空/エラー状態** — `Add designed empty, loading, and error states everywhere they're missing.`
93. **コピー改善** — `Rewrite UI copy to be concise, human, and consistent in voice.`
94. **整合性** — `Find and fix off-token colors, spacings, and radii against DESIGN.md.`
95. **画像最適化** — `Convert images to next/image with correct sizes and lazy loading.`
96. **SEO** — `Add semantic headings, metadata, sitemap, and structured data.`
97. **実機検証** — `Open the page in a real browser, click through key flows, screenshot, report issues.`
98. **パフォーマンス** — `Profile and fix the slowest 3 things hurting Core Web Vitals.`
99. **クロスブラウザ** — `Verify layout in Chromium/WebKit and fix divergences.`
100. **リファクタ** — `Refactor repeated div+border+padding blocks into shadcn Card/Tabs/Sheet.`

---

## 10. 使い方（初心者基準）— 悩み → こう頼むだけ

コードが分からなくても大丈夫。あなたは**監督**です。AIが現場、あなたは「こういう作品にしたい」を伝える人。最初に台本（`DESIGN.md`）を渡しておけば、毎回説明し直さずに済みます。

| こんな悩み | こう頼むだけ |
|---|---|
| 毎回見た目がバラバラ | 「まず `DESIGN.md` を作って。ブランドは〇〇、トーンは△△。色は□□系で」 |
| いかにもAIっぽくてダサい | 「`frontend-design` の原則で。紫グラデと Inter は禁止。方向性は"editorial（雑誌風）"で統一して」 |
| LPを作りたい | 「Hero→悩み→解決→特徴→実績→料金→FAQ→CTA の順で1ページLP。各セクションは別ファイルに」 |
| 修正したら別の所が崩れた | 「`Hero.tsx` **だけ**直して。他は触らないで」 |
| 本当に動くのか不安 | 「ブラウザで開いて、主要な操作をクリックして、スクショを見せて」 |
| 資料も欲しい | 「この内容で `1280×720` の単一HTMLスライドにして。最後に実機で崩れを確認して」 |

**最初の3ステップ（これだけでOK）**

1. `DESIGN.md` を作らせる（§5のサンプルを渡す or [awesome-design-md](https://github.com/voltagent/awesome-design-md) から近いブランドをコピー）。
2. §4の構造で「枠（layout）」と「トップ1枚」を作らせる。
3. 「ブラウザで開いてスクショ見せて」で確認 → 気に入らない所だけ**ファイル名を指定して**直させる。

---

## 11. もう一歩進んだ使い方

ここからは開発寄り。必要な人だけどうぞ。

- **3層を全部置く**: `AGENTS.md`（働き方）＋`DESIGN.md`（見た目）＋プロジェクト固有 `SKILL.md`（定番手順）をルートに。Codex も Claude Code も同じ土台で動かせる。
- **トークンの単一の正典化**: `DESIGN.md` を正典にして Style Dictionary 等で web/iOS/Android 用トークンを派生。手書きhexをCIで検出して弾く。
- **検証を自動化**: Playwright MCP で「主要フローのクリック → スクショ → 差分」を回し、"動くつもり"を毎回潰す。
- **レジストリ運用**: 自社の `components/ui` を shadcn のカスタムレジストリ／プリセットにして、全プロジェクトで同じ部品・同じテーマを配る。
- **Codex Sites / プラグイン**（§2）: 社内ツールやプロトを"URL共有"で素早く。ただし外向けブランドは `DESIGN.md` で必ず縛る。

---

## 12. 出典

**OpenAI Codex アップデート（2026/6/2）**
- 公式: [Codex for every role, tool, and workflow — OpenAI](https://openai.com/index/codex-for-every-role-tool-workflow/)
- [TechCrunch: OpenAI launches new Codex tools for white-collar work](https://techcrunch.com/2026/06/02/openai-launches-new-codex-tools-for-white-collar-work/)
- [VentureBeat: Codex update — Sites and role-specific plugins](https://venturebeat.com/orchestration/openais-codex-update-lets-agents-build-interactive-enterprise-workspaces-via-sites-and-role-specific-plugins)
- [9to5Mac: Codex inside ChatGPT, six business plugins](https://9to5mac.com/2026/06/02/openai-putting-codex-inside-chatgpt-app-everywhere-releasing-6-business-plugins/)
- 添付X（本文はペイウォール/HTTP 402のため要旨のみ・🔶）: [1](https://x.com/OpenAI/status/2061845949170045346) / [2](https://x.com/OpenAI/status/2061887650391625870) / [3](https://x.com/OpenAIDevs/status/2061888366791246071) / [4](https://x.com/OpenAI/status/2061887828058075190) / [5](https://x.com/OpenAI/status/2061887715520721151)

**design.md / デザインシステム**
- 公式仕様: [google-labs-code/design.md](https://github.com/google-labs-code/design.md)（Google Stitch由来）
- 実例集: [VoltAgent/awesome-design-md](https://github.com/voltagent/awesome-design-md)
- 解説: [TDP](https://designproject.io/blog/design-md-file/) / [Department of Product](https://departmentofproduct.substack.com/p/designmd-explained-the-format-reshaping) / [WaveSpeed](https://wavespeed.ai/blog/posts/what-is-design-md-for-coding-agents/) / [WaveSpeed: design.md vs tokens](https://wavespeed.ai/blog/posts/design-md-vs-design-tokens-ai-workflows/) / [DEV: AGENTS.md/SKILL.md/DESIGN.md](https://dev.to/aws-builders/agentsmd-skillmd-designmd-how-ai-instructions-split-into-three-layers-d0g)
- ジェネレータ: [getdesign.md](https://getdesign.md/) / [design.dev](https://design.dev/ai/design-md-generator/)

**デザイン品質・実装**
- Anthropic `frontend-design` スキル（公式プラグイン同梱）
- [shadcn/ui docs](https://ui.shadcn.com/docs) / Vercel `shadcn` スキル
- [Fixing Visual AI Slop（Trilogy）](https://trilogyai.substack.com/p/fixing-visual-ai-slop)

## 13. 未確認・注意事項

- ⚠️ 添付の5つのXポストは**本文がペイウォール（HTTP 402）で直接取得不可**。内容は公式発表ページ＋複数報道＋X検索で再構成した「要旨」であり、原文の細かな言い回しは確認しきれていません。
- 🔶 Codex 各プラグインの**正確な対応ツール・提供プラン・一般提供時期**は流動的。特に Product Design / Sales / Investing 系プラグインの詳細仕様は本資料では裏取り不十分（🔶）。Sites は当初 Business/Enterprise 限定で順次拡大、の段階。
- 🔶 Codex「Annotations」機能は報道ベースの言及にとどまり、詳細仕様は未確認。
- 🔶 `design.md` は2026年時点で急速に普及中の事実上の標準で、正式仕様は `version: alpha`。今後フォーマットが変わる可能性があります。
- ⚠️ 本キットのファイル構造・プロンプトは Next.js 系を主例にした"型"です。あなたのフレームワーク・要件に合わせて必ず調整してください。コピペそのままで「完璧」にはなりません。
- 値段・契約・提供範囲に関わる判断は、必ず各社公式の最新情報で確認してください。

---

*このキットは AI収益化ラボ（河村風真）の解説用に作成した非公式まとめです。改善提案・誤り報告は歓迎します。*
