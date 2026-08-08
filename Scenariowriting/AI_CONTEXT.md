# AI Context: Scenariowriting

## Purpose

This folder contains a local tool for creating YouTube scripts from `YouTube台本作成.xlsx`.

The tool supports three script workflows:

- 一人語り
- 対話形式
- 一人語りから対話形式への変換

The broader system now treats this as part of a four-flow content workspace together with Webarticle:

1. Web記事作成
2. 一人語り
3. 対話形式
4. 一人語りから対話形式への変換

## Default Operation

- The user has ChatGPT Plus.
- The standard mode is manual prompt transfer to an AI tool. NotebookLM is optional for extra source-document reading.
- OpenAI API generation is optional and hidden under `API生成の詳細設定`.
- Avoid making API usage the main path.

## Current Workflow

1. 基礎知識
2. 検索意図
3. 視聴者理解
4. 目次構成
5. あらすじ確認
6. 台本前チェック
7. 冒頭・締め
8. 本文
9. 書き起こし整形
10. 対話化設計
11. リライトあらすじ
12. 対話リライト

## Important Product Decisions

- `重要情報ソースリスト`, `AI調査メモ`, `NotebookLMで作成した基礎知識メモ`, and `インポートした文献・資料` are optional but should feed all relevant script prompts.
- The knowledge step applies to all three script workflows.
- Specialized topics should support a AI research step as the standard path, with trusted-source discovery and NotebookLM memo creation as optional additions.
- Trusted sources for scripts should distinguish fact-checking sources from structure, speaking-style, and dialogue-conversion references.
- `リサーチセット作成` builds an optional NotebookLM research prompt and URL list from imported outline/source fields.
- Rakko CSV/JSON and Rakko GPTs results should be treated as viewer needs and topic candidates for scripts, not as the final script outline.
- The preflight check should explicitly review which Rakko-derived topics to pick up, which to exclude, and which anxieties/questions can be used in the opening.
- Imported source materials currently support `txt`, `md`, and `csv`.
- PDF and Word files should be copied or converted to text unless parsing is added later.
- Synopsis approval is intentional:
  - Normal script flow uses `approvedSynopsis` first.
  - Dialogue rewrite uses `approvedRewriteSynopsis` first.
- The preflight check step is intentional. Intro/ending, body, and dialogue rewrite prompts should use it when present to preserve title promises, heading boundaries, speaker roles, and ending design.
- API generation must keep cost guardrails.
- `プロジェクト保存` writes structured intermediate artifacts under `script-projects/` so future skills or sub-agents can resume without relying on chat history.

## Main Files

- `server.mjs`: local server, prompt builders, trusted-source discovery, OpenAI API generation, Rakko GPTs prompt, cost guardrails.
- `public/index.html`: UI structure and workflow panels, including Rakko GPTs pasteback controls.
- `public/app.js`: UI behavior, local storage, CSV/JSON/source import, Rakko GPTs result parsing, prompt calls.
- `public/styles.css`: visual design.
- `package.json`: scripts.
- `script-projects/`: saved per-script intermediate artifacts.

## Verification

Use these checks after changes:

```powershell
npm run check
node --check public/app.js
```

For behavior checks, run the server with a temporary port and call `/api/prompt` for affected steps.
