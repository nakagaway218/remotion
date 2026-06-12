# 02 — フォールバック実装を頼む（Python）

Fable 5 は、サイバー・生物・内部推論の書き出しに関わると判定した要求を**拒否**することがあります
（エラーではなく HTTP 200 + `stop_reason: "refusal"`）。正当な作業でも作動しうるため、
**Opus 4.8 への自動フォールバック**を最初から組み込んでおくのが公式推奨の使い方です。

## コピペするプロンプト

```text
Python の Anthropic SDK で Claude Fable 5 を呼ぶコードを書いてください。要件:
- BetaRefusalFallbackMiddleware で claude-opus-4-8 への自動フォールバックを設定
- BetaFallbackState を会話単位で共有して、続きのターンを受理モデルに固定
- どのモデルが応答したか（response.model）をログに出す
- refusal の発生回数を専用のメトリクスとして数える（エラー監視には映らないため）
- APIキーは環境変数 ANTHROPIC_API_KEY から読む。コードに直書きしない
参考実装: templates/claude-fable5-project/examples/fallback_example.py
```

## 知っておくと安心な仕様（公式）

- 出力が生成される**前**に拒否されたリクエストは**課金されない**（レート制限も消費しない）
- ミドルウェアは fallback credit ヘッダを自動付与し、プロンプトキャッシュの二重払いを回避
- サブエージェント内のモデル呼び出しにはフォールバック設定が**伝播しない**ので個別に設定
- 公式: https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback
