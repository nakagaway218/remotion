---
type: source_summary
status: 要約済み
date: 2026-06-24
source_type: youtube
source: [[raw/webclip-index/2026-06-24-youtube-palmier-ai-video-editor]]
tags: [youtube, codex, claude, video-editing, mcp]
---

# PalmierをCodex/Claudeから操作するAI動画編集

## 要約

- PalmierはAIファーストな動画編集アプリとして紹介され、CodexやClaude CodeからMCPサーバー経由で操作できる。
- 例では、タイムライン上の動画に対して、フィラーワード削除、無音部分カット、ジェットカット、テロップ挿入を自然言語で依頼している。
- 一回で完璧に仕上げるのではなく、検証用サブエージェント、修正用サブエージェントを使い、カット漏れや切りすぎを反復修正する考え方が示されている。
- Palmier内のAI機能にはAnthropic APIキーを使うものもあるが、動画ではCodex側から操作する方法が中心。
- 無料版でもカット、字幕、MP4/XML書き出しなどは試せるが、動画生成・音楽生成などは有料機能として説明されている。

## 自分の運用への反映

- 動画編集の定型処理は、Record & ReplayやMCP操作と相性がよい。
- 実務導入する場合は、素材の保存先、書き出し先、確認工程、やり直し基準を先に決める必要がある。
- このVaultでは、ツール導入判断として `ツール参考リスト` に登録し、公開リポジトリや公式情報を確認してから使う。

## 注意点

- 動画時点ではMac中心の説明であり、Windows対応や機能名は要確認。
- APIキーをアプリやCodexに貼り付ける運用は危険なので、環境変数やローカル secrets 管理を使う。
