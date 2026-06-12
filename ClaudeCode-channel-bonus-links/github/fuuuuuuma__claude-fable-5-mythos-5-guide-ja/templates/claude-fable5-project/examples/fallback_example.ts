// Claude Fable 5 — refusal フォールバック実装例（TypeScript）
// 公式: https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback
//
// ポイント:
// - Fable 5 の拒否はエラーではなく HTTP 200 + stop_reason="refusal" で返る
// - SDK ミドルウェアを使うと、拒否時に Opus 4.8 へ自動リトライされる
// - BetaFallbackState を会話で共有すると、続きのターンが受理モデルに固定される
//
// 事前準備: npm i @anthropic-ai/sdk / 環境変数 ANTHROPIC_API_KEY を設定（直書き禁止）

import Anthropic, {
  BetaFallbackState,
  betaRefusalFallbackMiddleware,
} from "@anthropic-ai/sdk";

const client = new Anthropic({
  middleware: [betaRefusalFallbackMiddleware([{ model: "claude-opus-4-8" }])],
});

// 会話単位で1つ共有する（受理したモデルへのピン留め）
const fallbackState = new BetaFallbackState();

const messages = [{ role: "user" as const, content: "Hello, Claude" }];

// ストリーミング: 拒否時はフォールバックモデルのイベントが同じストリームに継がれる
const stream = client.beta.messages.stream(
  { model: "claude-fable-5", max_tokens: 1024, messages },
  { fallbackState }
);
stream.on("text", (text) => process.stdout.write(text));

const finalMessage = await stream.finalMessage();
console.log("\nserved by:", finalMessage.model); // どのモデルが答えたか

// --- サーバー側フォールバック（単発リクエスト版・ミドルウェアと併用しない） ---
// const response = await client.beta.messages.create({
//   model: "claude-fable-5",
//   max_tokens: 1024,
//   messages,
//   fallbacks: [{ model: "claude-opus-4-8" }],
//   betas: ["server-side-fallback-2026-06-01"],
// });

// --- 監視の注意 ---
// refusal は HTTP 200 なのでエラーレート監視には映らない。
// refusal 発生と fallback 応答（usage.iterations の "fallback_message"）を
// 専用イベントとして計測し、差分を見張ること。
