---
type: source_summary
status: 要約済み
date: 2026-06-24
source_type: youtube
source: [[raw/webclip-index/2026-06-24-youtube-gpt-realtime-2-codex-translation]]
tags: [youtube, codex, realtime-api, browser-control, voice-input]
---

# Codexのブラウザ操作・音声入力・リアルタイム翻訳

## 要約

- 動画では、CodexのChrome操作、音声入力、OpenAIのRealtime系モデルを使った翻訳アプリ作成が紹介されている。
- CodexのChrome拡張を使うと、問い合わせフォーム入力、複数タブの情報収集、スプレッドシート操作などをブラウザ上で進められる。
- ブラウザ操作で難しい部分はComputer Useに切り替わることがあり、Web操作とデスクトップ操作を使い分ける考え方が示されている。
- Codexの音声入力は、Codexアプリ内だけでなく他アプリにも入力できると説明されている。
- Realtime APIを使い、日本語音声をリアルタイム文字起こし、英訳、読み上げまで行うWebアプリをCodexで作る例が紹介されている。

## 自分の運用への反映

- ブラウザ操作とDrive/Sheets API操作は用途を分ける。安定処理はAPI、UI依存の手作業はRecord & Replayやブラウザ操作が向く。
- 音声入力は、長い指示やスキル改善指示の作成に使える可能性がある。
- Realtime API系の試作は、APIキー管理、料金、保存データの扱いを先に決める必要がある。

## 注意点

- 動画内でAPIキーを直接貼る例があるが、このVaultでは禁止。`secrets/` と環境変数で扱う。
- モデル名や機能名は公開時点の情報として扱い、実装前には公式ドキュメントで確認する。
