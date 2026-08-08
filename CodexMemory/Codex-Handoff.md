# Codex Handoff

## 目的

このファイルは、ChatGPT / Codexアプリ側で相談した内容を、LM Studioローカル側のCodexへ引き継ぐためのメモです。

## ローカルCodexに最初に伝える文

```text
CodexMemory\Codex-Handoff.md を読んで、前回の続きとして作業してください。
```

## 現在の運用方針

- OpenAI側のChatGPT / Codexアプリ: 過去タスクの確認、方針相談、整理、判断に向いています。
- LM Studioローカル側のCodex: OpenAIクレジットを使わずに、ローカルモデル `openai/gpt-oss-20b` で作業する入口です。
- ローカルCodex側は、Codexアプリの過去タスクを自動では読めません。
- そのため、重要な引き継ぎ内容はこのファイルに追記します。

## 引き継ぎメモ

- ここに、次回ローカルCodexへ渡したい内容を追記してください。