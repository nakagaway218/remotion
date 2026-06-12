# Claude Fable 5 — refusal フォールバック実装例（Python）
# 公式: https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback
#
# ポイント:
# - Fable 5 の拒否はエラーではなく HTTP 200 + stop_reason="refusal" で返る
# - SDK ミドルウェアを使うと、拒否時に Opus 4.8 へ自動リトライされる
#   （fallback-credit ヘッダも自動付与＝プロンプトキャッシュ二重払い回避）
# - BetaFallbackState を会話で共有すると、続きのターンが「受理したモデル」に固定される
#
# 事前準備: pip install anthropic / 環境変数 ANTHROPIC_API_KEY を設定（直書き禁止）

from anthropic import Anthropic, BetaFallbackState, BetaRefusalFallbackMiddleware

client = Anthropic(
    middleware=[BetaRefusalFallbackMiddleware([{"model": "claude-opus-4-8"}])],
)

state = BetaFallbackState()  # 会話の続きを受理モデルにピン留め

messages = [{"role": "user", "content": "Hello, Claude"}]

# ストリーミング: 拒否されるとフォールバックモデルのイベントが同じストリームに継がれる
with (
    state,
    client.beta.messages.stream(
        max_tokens=1024,
        model="claude-fable-5",
        messages=messages,
    ) as stream,
):
    for event in stream:
        if event.type == "text":
            print(event.text, end="", flush=True)
    final_message = stream.get_final_message()

print(f"\nserved by: {final_message.model}")  # どのモデルが答えたか

# --- サーバー側フォールバック（ミドルウェアを使わない場合の単発リクエスト版） ---
# response = client.beta.messages.create(
#     model="claude-fable-5",
#     max_tokens=1024,
#     messages=messages,
#     fallbacks=[{"model": "claude-opus-4-8"}],
#     betas=["server-side-fallback-2026-06-01"],
# )
# ※ ミドルウェアとサーバー側 fallbacks は併用しない（どちらか一方）

# --- 監視の注意 ---
# refusal は HTTP 200 なのでエラーレート監視には映らない。
# refusal 発生と、フォールバック応答（usage.iterations 内の "fallback_message"）を
# それぞれ専用イベントとして計測し、差分を見張ること。
