# 03 — フォールバック実装を頼む（TypeScript）

内容は 02（Python）と同じ要件の TypeScript 版です。

## コピペするプロンプト

```text
TypeScript の @anthropic-ai/sdk で Claude Fable 5 を呼ぶコードを書いてください。要件:
- betaRefusalFallbackMiddleware で claude-opus-4-8 への自動フォールバックを設定
- BetaFallbackState を会話単位で共有して、続きのターンを受理モデルに固定
- ストリーミングで応答を表示し、最後に finalMessage.model（どのモデルが答えたか）を出す
- refusal の発生回数を専用メトリクスとして数える（HTTP 200 なのでエラー監視に映らない）
- APIキーは環境変数 ANTHROPIC_API_KEY から読む。コードに直書きしない
参考実装: templates/claude-fable5-project/examples/fallback_example.ts
```

## 単発リクエストならサーバー側フォールバックも可

```text
fallbacks: [{ model: "claude-opus-4-8" }] と
ベータヘッダ "server-side-fallback-2026-06-01" を使ったサーバー側フォールバック版も書いてください。
ミドルウェアとの併用はしないでください。
```

- 公式: https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback
