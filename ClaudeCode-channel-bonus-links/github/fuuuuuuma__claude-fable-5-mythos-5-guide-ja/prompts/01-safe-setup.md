# 01 — Fable 5 を安全に使う環境を「AIに作ってもらう」

このリポジトリの目玉です。下のプロンプトを **Claude Code（または Codex 等のAIエージェント）にそのまま貼るだけ**で、
AGENTS.md の手順に従って、あなた専用のフォルダ構造・運用ルール・コード例一式を組んでくれます。

## コピペするプロンプト

```text
このリポジトリの AGENTS.md に従って、私の環境に Claude Fable 5 用のセットアップを作ってください。
https://github.com/fuuuuuuma/claude-fable-5-mythos-5-guide-ja
わからないことは先に質問してください。
```

## 何ができあがるか（例）

```
fable5-workspace/
├── CLAUDE.md           # Fable 5 向けの運用ルール（あなた用に調整済み）
├── memory/lessons.md   # 学びの記録（Fable 5 はこれがあると特に強い）
├── progress.txt        # 長時間タスクの進捗ノート
├── tests.json          # 構造化した状態管理
└── examples/           # （API開発を選んだ場合）フォールバック実装例
```

## うまくいかないとき

- エージェントがリポジトリを読めない場合 → リポジトリを `git clone` してから、そのフォルダで同じプロンプトを実行
- 質問されずにいきなり作り始めた場合 → 「先に AGENTS.md の『まず最初にやること』の質問をして」と言う
