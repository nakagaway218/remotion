# Workflows: Webarticle

## Article Creation

1. Fill in keyword, target length, body allocation, article purpose, and tone.
2. If the topic is specialized, use `NotebookLM用プロンプト`.
3. Paste NotebookLM notes into `NotebookLMで作成した基礎知識メモ`.
4. Import or paste source materials into `インポートした文献・資料`.
5. Create and paste prompts step by step:
   - 検索意図
   - 構成
   - あらすじ
   - タイトル
   - 本文前チェック
   - リード文
   - 本文
   - まとめ
6. Review the synopsis and click `このあらすじを採用`.
7. Build body sections by pasting the target h2/h3 block into `出力したい見出し`.
8. Copy or save the final Markdown from the preview.
9. Click `プロジェクト保存` to write structured intermediate artifacts into `article-projects/`.

## Rakko CSV Workflow

1. Download headline CSV manually from Rakko Keyword.
2. In the `構成` step, click `CSV読込`.
3. Confirm the formatted top article outlines appear in `検索上位5記事の構成`.
4. Create the outline prompt.

## Rakko API Workflow

1. Start the server with `RAKKO_API_KEY`.
2. Click `ラッコから取得`.
3. Confirm the credit usage message.
4. Continue with the outline prompt.

## Source Material Workflow

1. Prepare `txt`, `md`, or `csv` files, or copy excerpts from PDFs/Word files.
2. Click `資料読込`, or paste excerpts directly.
3. Keep source labels such as title, URL, author, date, and excerpt when possible.
4. Avoid pasting excessively long full documents unless needed, because downstream prompts become longer.

## Verification Workflow

Run:

```powershell
npm run check
node --check public/app.js
```

For prompt checks:

1. Start the server with a temporary `PORT`.
2. Send sample data to `/api/prompt`.
3. Confirm `NotebookLMで作成した基礎知識メモ` and `インポートした文献・資料` appear in affected downstream prompts.

## Project Save Workflow

Click `プロジェクト保存` from the preview pane to save the current article state.

The tool writes:

- `request.json`
- `knowledge.md`
- `sources.md`
- `search-intent.md`
- `serp-analysis.md`
- `outline.md`
- `synopsis.md`
- `preflight-check.md`
- `article-plan.json`
- `draft.md`
- `review.json`

These files are the first step toward a commander plus small-skill workflow.
