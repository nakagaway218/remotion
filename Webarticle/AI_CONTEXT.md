# AI Context: Webarticle

## Purpose

This folder contains a local tool for turning the Excel workflow `Web記事作成.xlsx` into a browser-based article writing workflow.

The default operation is manual prompt transfer:

- The user has ChatGPT Plus.
- The standard mode should create prompts that the user pastes into an AI tool. NotebookLM is optional for extra source-document reading.
- OpenAI API generation is a secondary option, hidden under `API生成の詳細設定`.
- Avoid making API generation the main path.

## Current Workflow

1. 基礎知識
2. 検索意図
3. 構成
4. あらすじ
5. タイトル
6. 本文前チェック
7. リード文
8. 本文
9. まとめ

## Important Product Decisions

- `重要情報ソースリスト`, `AI調査メモ`, `NotebookLMで作成した基礎知識メモ`, and `インポートした文献・資料` are optional, but when present they must be included in downstream prompts.
- The knowledge step must not require OpenAI API usage.
- Specialized topics should support a AI research step as the standard path, with trusted-source discovery and NotebookLM memo creation as optional additions.
- Imported source materials currently support text-like files such as `txt`, `md`, and `csv`.
- PDF and Word files should be handled by copying text into the source materials field or by converting to text first, unless a future feature explicitly adds parsing.
- The synopsis approval step is intentional. Downstream prompts should use `approvedSynopsis` first, then fall back to `synopsisOutput`.
- The preflight check step is intentional. Body and summary prompts should use it when present to preserve title promises, h2 boundaries, and summary design.
- Rakko keyword integration supports manual CSV/JSON import, ChatGPT GPTs Actions handoff, and API-based headline fetching. CSV/JSON import and GPTs handoff are the preferred low-cost paths.
- API calls must keep cost guardrails: `OPENAI_COST_CAP_USD`, `OPENAI_MAX_OUTPUT_TOKENS`, and saved usage in `data/usage.json`.
- `プロジェクト保存` writes structured intermediate artifacts under `article-projects/` so future skills or sub-agents can resume without relying on chat history.

## Main Files

- `server.mjs`: local server, prompt builders, OpenAI API generation, Rakko API integration, cost guardrails.
- `public/index.html`: UI structure and workflow panels, including Rakko GPTs pasteback controls.
- `public/app.js`: UI behavior, local storage, CSV/source import, Rakko GPTs result parsing, prompt creation calls.
- `public/styles.css`: visual design.
- `README.md`: user-facing usage guide.
- `ANTIGRAVITY.md`: handoff notes for Antigravity.
- `article-projects/`: saved per-article intermediate artifacts.

## Verification

Use these checks after changes:

```powershell
npm run check
node --check public/app.js
```

For behavior checks, run the server with a temporary port and call `/api/prompt` for affected steps.
