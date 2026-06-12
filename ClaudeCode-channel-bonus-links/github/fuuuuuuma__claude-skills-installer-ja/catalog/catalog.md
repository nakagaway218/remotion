# カタログ（人間可読版）

機械可読の正典は [`skills.json`](skills.json)。本ファイルは一覧把握用。計 **70件**（独自・同梱5件を含む）。

凡例: 🟢=公式(anthropics) ・ ⚪=非公式 ・ 📦=本repo同梱 ・ 🧑‍💻=開発者向け
`source` の名称は出典記事時点のもの。**改名・廃止あり**（[`skills.json`](skills.json) の `known_renames` を必ず参照）。

---

## メタ（skillを作る/探す）

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| Skill Creator | 🟢 | 実行結果に基づき新skillの作成・改善・トリガー最適化。まず最初の土台 | [link](https://github.com/anthropics/skills/tree/main/skills/skill-creator) |
| Write a Skill | ⚪ | 構造・段階的開示・バンドルを備えたskillの書き方をガイド | [link](https://github.com/mattpocock/skills/tree/main/write-a-skill) |
| Find Skills | ⚪ | マーケットプレイスから合うskillを検索（作る前に探す） | [link](https://skillsmp.com) |

## 企画・設計

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| Grill Me | ⚪ | 計画の考慮漏れを質問攻めで潰す | [link](https://github.com/mattpocock/skills/tree/main/grill-me) |
| Write a PRD | ⚪ | 会話の文脈から直接PRDを生成 ※実repoは `to-prd` | [link](https://github.com/mattpocock/skills/tree/main/to-prd) |
| PRD to Plan | ⚪ | PRDを2〜5分単位の実装計画へ ※superpowersの`writing-plans`相当 | [link](https://github.com/obra/superpowers) |
| PRD to Issues | ⚪ | PRDを着手可能なイシューへ分解 ※実repoは `to-issues` | [link](https://github.com/mattpocock/skills/tree/main/to-issues) |
| Design an Interface | ⚪ | 1モジュールに3〜5個の異なる設計案を並列生成 | [link](https://github.com/mattpocock/skills/tree/main/design-an-interface) |
| Request Refactor Plan | ⚪🧑‍💻 | 小コミット単位のリファクタ計画 ※**廃止**→`diagnose`/`zoom-out` | [link](https://github.com/mattpocock/skills/tree/main/request-refactor-plan) |
| Brainstorming | ⚪ | 9ステップで設計書まで。承認までコードを書かない | [link](https://github.com/obra/superpowers/tree/main/skills/brainstorming) |
| Domain Name Brainstormer | ⚪ | プロダクト名生成＋ドメイン空き確認 | [link](https://github.com/Microck/ordinary-claude-skills/tree/main/skills_all/domain-name-brainstormer) |
| Idea Mining / YouTube | ⚪ | YouTubeからアイデア・トレンド収集 | [link](https://github.com/AgriciDaniel/claude-youtube) |

## コード開発

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| TDD | ⚪🧑‍💻 | テストファースト red-green-refactor を強制 | [link](https://github.com/mattpocock/skills/tree/main/tdd) |
| Triage Issue | ⚪🧑‍💻 | 原因不明バグの根本原因特定→修正計画イシュー化 ※実repoは `triage` | [link](https://github.com/mattpocock/skills/tree/main/triage) |
| QA | ⚪🧑‍💻 | 機能へのフルQAパス。PR前のエッジケース洗い出し | [link](https://github.com/mattpocock/skills/tree/main/qa) |
| Improve Codebase Architecture | ⚪🧑‍💻 | ホットスポット特定＋リファクタ戦略提案 | [link](https://github.com/mattpocock/skills/tree/main/improve-codebase-architecture) |
| Systematic Debugging | ⚪🧑‍💻 | 4段階デバッグ。3回失敗で設計見直し | [link](https://github.com/obra/superpowers/tree/main/skills/systematic-debugging) |
| Auto-Commit Messages | 🟢🧑‍💻 | diffからConventional Commitを自動生成 | [link](https://github.com/anthropics/skills/tree/main/skills/auto-commit) |
| Code Review | ⚪🧑‍💻 | 体系的レビュー（観点指定可） | [link](https://github.com/obra/superpowers) |
| Superpowers | ⚪🧑‍💻 | TDD・デバッグ・計画など実戦skill一式 | [link](https://github.com/obra/superpowers) |
| Change Log Generator | ⚪🧑‍💻 | コミット履歴からリリースノート生成 | [link](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/changelog-generator) |
| Simplification Cascade | ⚪🧑‍💻 | 複雑なコードを段階的に簡素化 | [link](https://mcpmarket.com/tools/skills/simplification-cascades-1) |
| React Best Practices | ⚪🧑‍💻 | Reactのベストプラクティスを自動適用 | [link](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) |
| File Search | ⚪🧑‍💻 | 大規模リポジトリのファイル検索を最適化 | [link](https://github.com/massgen/massgen) |
| Context Optimization | ⚪🧑‍💻 | 長セッションのコンテキスト管理を最適化 | [link](https://github.com/muratcankoylan/agent-skills-for-context-engineering) |
| Migrate to Shoehorn | ⚪🧑‍💻 | フレームワーク移行を段階支援 | [link](https://github.com/mattpocock/skills/tree/main/migrate-to-shoehorn) |
| Scaffold Exercises | ⚪🧑‍💻 | コード演習・チュートリアル素材を生成 | [link](https://github.com/mattpocock/skills/tree/main/scaffold-exercises) |

## ツール・セットアップ

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| Setup Pre-Commit | ⚪🧑‍💻 | Husky+lint-staged+Prettier+型+テストのpre-commit構築 | [link](https://github.com/mattpocock/skills/tree/main/setup-pre-commit) |
| Git Guardrails | ⚪🧑‍💻 | 危険なgitを実行前ブロック。本番repoの必須セーフティ | [link](https://github.com/mattpocock/skills/tree/main/git-guardrails-claude-code) |
| Dependency Auditor | ⚪🧑‍💻 | 古い・脆弱・放棄パッケージをスキャン | [link](https://github.com/ComposioHQ/awesome-claude-skills) |
| Git Work Trees | ⚪🧑‍💻 | 複数ブランチ並列作業のworktree環境構築 ※`using-git-worktrees` | [link](https://github.com/obra/superpowers/tree/main/skills/using-git-worktrees) |

## 文書・ナレッジ

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| Edit Article | ⚪ | 情報依存グラフで再構成。1段落最大240字 | [link](https://github.com/mattpocock/skills/tree/main/edit-article) |
| Ubiquitous Language | ⚪ | 会話からDDD用語集を抽出。用語の揺れ解消 | [link](https://github.com/mattpocock/skills/tree/main/ubiquitous-language) |
| API Documentation Generator | ⚪🧑‍💻 | ルートからOpenAPI/Swaggerを生成 | [link](https://github.com/ComposioHQ/awesome-claude-skills) |
| Obsidian Vault | ⚪ | Vaultの検索・作成・管理（wikilinks＋Index Note） | [link](https://github.com/mattpocock/skills/tree/main/obsidian-vault) |
| Doc Co-Authoring | 🟢 | 情報収集→ドラフト→読者テストの3段階共同執筆 | [link](https://github.com/anthropics/skills/tree/main/skills/doc-coauthoring) |
| Content Researcher | ⚪ | テーマからリサーチを構造化・分類 | [link](https://github.com/ComposioHQ/awesome-claude-skills/blob/master/content-research-writer/SKILL.md) |
| Claude SEO | ⚪ | テクニカルSEO監査・スキーマ・オンページ最適化 | [link](https://github.com/AgriciDaniel/claude-seo) |
| Custom YT Search | ⚪ | YouTube動画の高度検索・トレンド分析 | [link](https://github.com/ZeroPointRepo/youtube-skills) |
| Firecrawl | ⚪ | 複雑なサイトから構造化データ抽出 | [link](https://github.com/mendableai/firecrawl) |

## UI / デザイン / フロントエンド

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| Frontend Design | 🟢 | 言葉だけで本番品質UI。AIっぽさを避ける原則入り | [link](https://github.com/anthropics/skills/tree/main/skills/frontend-design) |
| Canvas Design | 🟢 | デザイン哲学を言語化→PNG/PDF表現の2段階 | [link](https://github.com/anthropics/skills/tree/main/skills/canvas-design) |
| Theme Factory | 🟢 | プロンプト1つで配色＋フォントを全ページ統一 | [link](https://github.com/anthropics/skills/tree/main/skills/theme-factory) |
| Web Artifacts Builder | 🟢🧑‍💻 | React/TS/TailwindでHTMLアーティファクト生成 | [link](https://github.com/anthropics/skills/tree/main/skills/web-artifacts-builder) |
| Brand Guidelines | 🟢 | ブランドカラー・フォントを成果物へ自動適用 | [link](https://github.com/anthropics/skills/tree/main/skills/brand-guidelines) |
| Algorithmic Art | 🟢 | p5.jsでスライダー付きアートをHTML出力 | [link](https://github.com/anthropics/skills/tree/main/skills/algorithmic-art) |
| Awesome-design | ⚪ | デザインのベストプラクティス集 | [link](https://github.com/VoltAgent/awesome-design-md) |
| Image Generator | ⚪ | 画像生成プロンプトを最適化 | [link](https://github.com/kingbootoshi/nano-banana-2-skill) |
| Local Image Gen | ⚪🧑‍💻 | ローカル環境で画像生成（機密向け） | [link](https://github.com/jezweb/claude-skills/blob/main/plugins/design-assets/skills/ai-image-generator/SKILL.md) |
| Image Optimizer | ⚪ | 画像の圧縮・変換・リサイズ自動処理 | [link](https://mcpmarket.com/tools/skills/image-optimizer) |
| Emotion | ⚪🧑‍💻 | CSS-in-JS（Emotion）を統一管理 | [link](https://github.com/wilwaldon/Claude-Code-Video-Toolkit) |
| Remotion Best Practices | ⚪🧑‍💻 | プログラマブル動画制作のベストプラクティス | [link](https://github.com/remotion-dev/remotion) |

## ビジネス / 営業 / マーケ

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| Stripe Integration | ⚪🧑‍💻 | 安全な決済フロー・Webhook・サブスク構築 | [link](https://github.com/wshobson/agents/tree/main/plugins/payment-processing/skills/stripe-integration) |
| Marketing Skills | ⚪ | CRO・コピー・メールフローなど20以上 | [link](https://github.com/coreyhaines31/marketingskills) |
| Lead Research Assistant | ⚪ | 企業名から事業・ニュース・競合を調査しレポート化 | [link](https://github.com/ComposioHQ/awesome-claude-skills/blob/master/lead-research-assistant/SKILL.md) |

## オフィス文書

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| PDF | 🟢 | 読み取り・抽出・結合・分割・OCR・暗号化 | [link](https://github.com/anthropics/skills/tree/main/skills/pdf) |
| DOCX | 🟢 | Word作成（JS）・編集（XML）・変更履歴 | [link](https://github.com/anthropics/skills/tree/main/skills/docx) |
| PPTX | 🟢 | PowerPoint生成・編集・抽出。画像で確認 | [link](https://github.com/anthropics/skills/tree/main/skills/pptx) |
| XLSX | 🟢 | Excel整理・グラフ・数式自動化＋再計算検証 | [link](https://github.com/anthropics/skills/tree/main/skills/xlsx) |
| Excel MCP Server | ⚪🧑‍💻 | MCP経由でExcelをプログラム操作 | [link](https://github.com/haris-musa/excel-mcp-server) |
| GWS (Google Workspace) | ⚪ | スプレッドシート/ドキュメント/スライド連携 | [link](https://github.com/googleworkspace/cli) |
| NotebookLM Integration | ⚪ | NotebookLMの情報源を参照して深いリサーチ | [link](https://github.com/PleasePrompto/notebooklm-skill) |

## マルチエージェント / 自動操作

| skill | 種別 | 何ができる | source |
|---|---|---|---|
| Stochastic Multi-Agent Consensus | ⚪🧑‍💻 | 多数のサブエージェントで合意形成 | [link](https://github.com/hungv47/meta-skills) |
| Model-chat / Debate | ⚪ | 複数モデルをディベートさせ網羅的に分析 | [link](https://github.com/tommasinigiovanni/conclave) |
| Playwright CLI | ⚪🧑‍💻 | ブラウザ自動操作（テスト/スクレイピング） | [link](https://github.com/microsoft/playwright) |

## 独自・同梱（このrepoが配布元）

| skill | 種別 | 何ができる | 実体 |
|---|---|---|---|
| 企画壁打ちパック | 📦 | Brainstorming→Grill Me→Write a PRD を一気通貫 | [skills/planning-sprint](../skills/planning-sprint/SKILL.md) |
| ドキュメント一括処理パック | 📦 | PDF/Word/Excel混在を自動判定で処理 | [skills/document-processor](../skills/document-processor/SKILL.md) |
| リサーチ→執筆パック | 📦 | Doc Co-Authoring→Edit Article で調査〜校正 | [skills/research-to-writing](../skills/research-to-writing/SKILL.md) |
| Meeting Automation | 📦 | 会議→議事録・TODO・次回アジェンダ（要点版） | [skills/mtg-notes](../skills/mtg-notes/SKILL.md) |
| Invoice Reader | 📦 | 請求書PDF→構造化CSV＋計算検証（要点版） | [skills/read-invoices](../skills/read-invoices/SKILL.md) |

---

## おすすめ導入順序（出典記事ベース）

1. **メタから** — Write a Skill / Skill Creator / Find Skills（作る・探す能力を先に）
2. **Planning** — Grill Me / Write a PRD / PRD to Plan / Design an Interface（手戻りを防ぐ）
3. **コードの安全装置** — Git Guardrails / Setup Pre-Commit / TDD / Systematic Debugging / Triage
4. **Superpowers** をベースレイヤーに
5. **ビジネス系** — Marketing / Claude SEO / Lead Research
6. **穴埋め** — マーケットプレイスで都度検索

> 全部入れない。各カテゴリから1つ、まず1個。1週間使って「これ無しでは無理」になったら次を足す。
