# CodexMemory

このフォルダは、ChatGPT / Codexアプリ側と、LM Studioローカル側のCodexをつなぐための「引き継ぎメモ」置き場です。

ローカル側のCodexは、Codexアプリ内の過去タスクを自動では読めません。そのため、重要な方針・決定・未完了タスクを `Codex-Handoff.md` に残しておき、ローカルCodex起動後にそれを読ませます。

## 使い方

1. ChatGPT / Codexアプリ側で、必要な内容をこのフォルダに追記します。
2. `Start-Codex-GPT-OSS-20B.cmd` または作業場所判定ランチャーの「Codexを開く」を起動します。
3. ローカルCodexが開いたら、次のように依頼します。

```text
CodexMemory\Codex-Handoff.md を読んで、前回の続きとして作業してください。
```