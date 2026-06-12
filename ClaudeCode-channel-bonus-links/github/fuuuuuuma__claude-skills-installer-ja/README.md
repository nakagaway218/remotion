# Claude Skills Installer（カタログ＋自動インストーラ）

**このリポジトリのURLをAIエージェントに渡して「業務に必要な Skills を入れて」と言うだけ。**
エージェントが業務をヒアリングし、必要な skill だけを選び、あなたの環境（Claude Code / Codex / Cursor）の
**正しいファイル構造**へ自動配置します。

> ⚠️ このリポジトリは「skill 本体の倉庫」ではなく **カタログ＋導入手順書** です。
> 72選の多くは他者の外部リポジトリにあるため、**出典へのリンク＋導入コマンド**で管理し、
> 導入時にエージェントが実在と中身を確認してから配置します。あなたが権利を持つ独自 skill 5件だけは実体を同梱しています。

---

## 使い方（30秒）

お使いのAIエージェント（Claude Code など）に、こう言ってください：

```
このリポジトリの AGENTS.md に従って、私の業務に必要な Claude Skills を入れて。
まず私の作業環境とよくやる業務を質問して、必要なものだけ正しい場所に配置してください。
（このリポジトリのURL）
```

するとエージェントが [`AGENTS.md`](AGENTS.md) の手順に沿って：

1. **環境判定** — `.claude/` などを読み、Claude Code か Codex か Cursor かを判定
2. **業務ヒアリング** — 「主な業務は？」「毎日いちばん繰り返す作業は？」「開発者？」を質問
3. **候補提示** — 業務に合う skill を3〜5個（公式/非公式の別つき）で提案
4. **セキュリティ確認** — 非公式 skill は実在と中身を確認。怪しければ入れない
5. **配置** — 選んだ skill を `~/.claude/skills/<name>/` などへ配置し、構造を見せる
6. **報告** — 入れたもの／入れなかったもの／育て方

「全部入れる」ものではありません。**各カテゴリから1つ、まず1個**から。

---

## リポジトリ構成

```
.
├── README.md                  ← いまここ（人間向け）
├── AGENTS.md                  ← インストーラの頭脳（エージェントが従う手順0〜7）
├── catalog/
│   ├── skills.json            ← 機械可読カタログ（全skillのメタデータ・出典・導入コマンド・配置先）
│   └── catalog.md             ← 人間可読カタログ（カテゴリ別の一覧表）
├── profiles/                  ← 業務別プリセット束
│   ├── planning.md            ← 企画・壁打ち
│   ├── docs-creation.md       ← 資料作成
│   ├── writing.md             ← 文書・記事
│   ├── data.md                ← データ処理
│   └── dev-baseline.md        ← コード開発の安全装置
├── skills/                    ← 独自・同梱skillの実体（このrepoが配布元）
│   ├── planning-sprint/SKILL.md
│   ├── document-processor/SKILL.md
│   ├── research-to-writing/SKILL.md
│   ├── mtg-notes/SKILL.md
│   └── read-invoices/SKILL.md
└── install/
    └── install.md             ← 環境別の配置先（Claude Code / Codex / Cursor）
```

---

## Skills とは

skill とは **`SKILL.md` ファイルが入ったフォルダ**のこと。「特定の作業をどうやるか」が手順・制約・例・テンプレートとして
書かれていて、一度入れれば毎回説明し直す必要がなくなります。Claude Code はこれを設計者・レビュアー・デバッガー・
ドキュメントライターを兼ねた「開発チーム」のように使えます。

収録は **計70件**（カテゴリ別。出典記事「Claude Skills 72選」をベースに重複を整理し、独自・同梱5件を含む）。
内訳と各 skill の詳細は [`catalog/catalog.md`](catalog/catalog.md) を参照。

---

## 収録カテゴリ

| カテゴリ | 例 |
|---|---|
| メタ（作る/探す） | Skill Creator / Write a Skill / Find Skills |
| 企画・設計 | Brainstorming / Grill Me / Write a PRD / Design an Interface |
| コード開発 | TDD / Systematic Debugging / Code Review / Superpowers |
| ツール・セットアップ | Git Guardrails / Setup Pre-Commit / Dependency Auditor |
| 文書・ナレッジ | Doc Co-Authoring / Edit Article / Obsidian Vault / Claude SEO |
| UI / デザイン | Frontend Design / Theme Factory / Canvas Design / Brand Guidelines |
| ビジネス / マーケ | Stripe Integration / Marketing Skills / Lead Research |
| オフィス文書 | PDF / DOCX / PPTX / XLSX |
| マルチエージェント | Multi-Agent Consensus / Model Debate / Playwright |
| 独自・同梱 | 企画壁打ち / ドキュメント一括処理 / リサーチ→執筆 / 議事録 / 請求書 |

---

## ⚠️ 重要な注意（正確性・安全性）

- **出典リンクと導入コマンドは出典記事時点の情報**です。リポジトリ名や skill フォルダ名は改名・移動・廃止されることがあります。
  実際にいくつかズレが確認されています（例: `write-a-prd`→`to-prd`、`triage-issue`→`triage`、`request-refactor-plan`→廃止）。
  → だから **エージェントが導入時に実フォルダ名と中身を確認する**設計にしています（[`AGENTS.md`](AGENTS.md) 手順4・5）。
- **3つの主要ソースは実在を確認済み**（2026-06）：
  [anthropics/skills](https://github.com/anthropics/skills) /
  [mattpocock/skills](https://github.com/mattpocock/skills) /
  [obra/superpowers](https://github.com/obra/superpowers)。それ以外は未確認（`install_verified: false`）。
- **セキュリティ**：skill は SKILL.md でエージェントを動かします。非公式 skill を不用意に入れるのは危険です。
  本インストーラは導入前に中身を目視確認する手順を必須化しています。
- ビュー数・スター数などの宣伝的な数値は、出典記事の主張であり**本リポジトリには事実として載せていません**。

---

## 出典

- ベース記事: 「Claude Skills 72選」（Mr. Buzzoni 氏「Claude Skills 67選」の日本ビジネス向け再構成＋独自5件）
- 元ポスト: <https://x.com/polydao/status/2044317956893471081>
- 各 skill の一次配布元は [`catalog/skills.json`](catalog/skills.json) の `source` を参照。

## ライセンス

- 本リポジトリ独自の成果物（`skills/` 配下の同梱5件、`AGENTS.md`、`catalog/`、`profiles/`、`install/`）は [MIT](LICENSE)。
- カタログが参照する**外部 skill は各リポジトリのライセンス**に従います。導入前に各 source のライセンスを確認してください。
