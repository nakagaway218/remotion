# Claude Fable 5 スターターキット 🎁

**「AIに投げるだけ」で Fable 5 を安全・快適に使い始められる**、視聴者プレゼント用のリポジトリです。
解説動画の補足資料 ＋ コピペで使えるプロンプト集 ＋ AIエージェントが読んで動くセットアップ指示書（AGENTS.md）が入っています。

> 非公式の解説資料です。Anthropic 公式とは無関係です（2026-06-10 時点の情報）。

---

## 🚀 一番かんたんな使い方（30秒）

Claude Code（または Codex 等のAIエージェント）に、これを貼るだけ:

```text
このリポジトリの AGENTS.md に従って、私の環境に Claude Fable 5 用のセットアップを作ってください。
https://github.com/fuuuuuuma/claude-fable-5-mythos-5-guide-ja
わからないことは先に質問してください。
```

→ あなたの用途（コーディング / API開発 / チャット中心）を聞いたうえで、
**Fable 5 を安全に使うためのフォルダ構造・運用ルール・コード例**を組み上げてくれます。

```
fable5-workspace/            ← できあがるものの例
├── CLAUDE.md                # Fable 5 向け運用ルール（あなた用に調整済み）
├── memory/lessons.md        # 学びの記録（Fable 5 はこれがあると特に強い）
├── progress.txt             # 長時間タスクの進捗ノート
├── tests.json               # 構造化した状態管理
└── examples/                # フォールバック実装例（API開発の場合）
```

---

## 📦 中身

| 場所 | 内容 |
|---|---|
| [AGENTS.md](AGENTS.md) | **AIエージェント用の指示書**。これを読んだAIがあなたの環境をセットアップする |
| [prompts/](prompts/) | **コピペで使えるプロンプト集**（下の一覧） |
| [templates/claude-fable5-project/](templates/claude-fable5-project/) | セットアップの雛形（CLAUDE.md・メモリ・フォールバック実装例） |
| [docs/](docs/) | 徹底解説資料（HTML版・下記リンクからブラウザで読めます） |

### プロンプト集の一覧

| # | ファイル | こんなときに |
|---|---|---|
| 01 | [safe-setup](prompts/01-safe-setup.md) | **まずこれ**。環境構築をAIに丸ごと任せる |
| 02 | [fallback-python](prompts/02-fallback-python.md) | Python で拒否時の自動フォールバックを実装する |
| 03 | [fallback-typescript](prompts/03-fallback-typescript.md) | TypeScript で同上 |
| 04 | [long-run-agent](prompts/04-long-run-agent.md) | 数時間級の自律作業を安心して任せる「3点セット」 |
| 05 | [effort-guide](prompts/05-effort-guide.md) | effort の使い分け／「やりすぎ」を抑える |
| 06 | [migration-check](prompts/06-migration-check.md) | 既存プロジェクトを Fable 5 へ移行する前のチェック |
| 07 | [usecases](prompts/07-usecases.md) | **事例集**：悩み→貼るだけプロンプト対応表 |

---

## 📖 徹底解説資料（読みもの）

ベンチマーク・安全設計（なぜ拒否されるのか／どう回避するか）・料金・使い方・業界の反応まで、
約2万字でまとめた解説はこちら:

**→ https://fuuuuuuma.github.io/claude-fable-5-mythos-5-guide-ja/**

---

## ⚡ Fable 5 ざっくり3行

- Anthropic が「これまでで最も高性能」と位置づける新モデル（2026-06-09公開・$10/$50 per Mトークン・1Mコンテキスト）
- サイバー・生物などの高リスク要求は拒否ではなく **Opus 4.8 が代わりに応答**する新しい安全設計（正当な作業でも作動しうるので、フォールバック実装が公式推奨）
- 使い方のコツは「監督」から「**方向づけ＋検証**」へ。ゴールと背景を渡して任せ切る（詳しくは prompts/ と解説資料へ）

## ⚠️ 注意

- 確度マーク（✅公式確認済み／🔶一次情報あり・流動的／⚠️未確認）で情報の信頼度を区別しています。仕様は変わるため、最終確認は必ず公式情報で行ってください
- API キー・トークンは `.env` などに置き、ファイルやチャットに直書きしないでください
