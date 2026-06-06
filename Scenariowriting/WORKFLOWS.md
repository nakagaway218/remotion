# Workflows: Scenariowriting

## Launch

- Double-click `B_Scenariowriting_Start.cmd` to start the local server and open the browser.
- Use `B_Scenariowriting_Index.html` only when the server is already running.
- The app opens at `http://localhost:4174`.

## Shared Knowledge Workflow

1. Enter the video title and script settings.
2. For specialized topics, create an `情報ソース候補プロンプト`.
3. Paste trusted source candidates into `重要情報ソースリスト`.
4. Import or paste source materials into `インポートした文献・資料`.
5. If URLs are available from CSV/JSON, trusted sources, reference videos, or source materials, click `リサーチセット作成` and paste the generated research set into NotebookLM.
6. Load high-priority sources into NotebookLM.
7. Paste NotebookLM output into `NotebookLMで作成した基礎知識メモ`.
8. Continue into the script workflow.

The knowledge memo and source materials should be reflected in all three script workflows.
The trusted source list should also be reflected in all three script workflows.

## Trusted Source Workflow

1. In `基礎知識`, click `情報ソース候補プロンプト`.
2. Paste the prompt into ChatGPT.
3. Paste the returned list into `重要情報ソースリスト`.
4. Separate sources for:
   - fact checking
   - basic knowledge
   - structure reference
   - speaking-style reference
   - dialogue-conversion reference
5. Use `リサーチセット作成` to prepare the NotebookLM request.
6. Load the high-priority sources into NotebookLM.
7. Paste NotebookLM's source-grounded memo into `NotebookLMで作成した基礎知識メモ`.

## 一人語り Workflow

1. Set `台本タイプ` to `一人語り系`.
2. Fill speaker role, tone, and rules.
3. Run:
   - 検索意図
   - 視聴者理解
   - 目次構成
   - あらすじ確認
4. Approve the synopsis.
5. Run 台本前チェック.
6. Generate 冒頭・締め and 本文.

## 対話形式 Workflow

1. Set `台本タイプ` to `対談系`.
2. Fill character A/B settings and relationship.
3. Run:
   - 検索意図
   - 視聴者理解
   - 目次構成
   - あらすじ確認
4. Approve the synopsis.
5. Run 台本前チェック.
6. Generate 冒頭・締め and 本文 as dialogue.

## 一人語りから対話形式への変換 Workflow

1. Paste one-person transcript into `元の書き起こし`.
2. Run `書き起こし整形`.
3. Run `対話化設計`.
4. Run `リライトあらすじ`.
5. Approve the rewrite synopsis.
6. Run 台本前チェック.
7. Run `対話リライト`.

## Source Material Workflow

1. Prepare `txt`, `md`, or `csv` files, or copy excerpts from PDFs/Word files.
2. Click `資料読込`, or paste excerpts directly.
3. Include source labels such as title, URL, author, date, and excerpt when possible.
4. Avoid excessive full-document paste unless needed, because prompts become longer.

## Outline CSV/JSON Workflow

1. Export search competitor headlines from Rakko Keyword as CSV or JSON.
2. In `目次構成`, click `CSV/JSON読込`.
3. The tool converts h2/h3 into `中見出し` and `小見出し`.
4. URLs from the imported file are also used by `リサーチセット作成`.
5. Treat imported headings as viewer needs and topic candidates, not as the final script outline.

## Rakko GPTs Workflow

1. In `目次構成`, click `ラッコGPTs用プロンプト`.
2. Paste the prompt into the user's ChatGPT GPTs that has Rakko Keyword API Actions configured.
3. Paste the returned JSON or h2/h3 text into `ラッコGPTs結果`.
4. Click `GPTs結果を反映`.
5. Confirm the converted `中見出し` and `小見出し` appear in `検索上位記事の目次構成`.
6. Use the outline prompt to reorganize the material for video flow.
7. Run `台本前チェック` to separate:
   - viewer needs to pick up
   - topic candidates to use
   - points not to cover in the video
   - anxieties or questions usable in the opening

## Verification Workflow

Run:

```powershell
npm run check
node --check public/app.js
```

For prompt checks:

1. Start the server with a temporary `PORT`.
2. Send sample data to `/api/prompt`.
3. Confirm `NotebookLMで作成した基礎知識メモ` and `インポートした文献・資料` appear in affected prompts.

## Project Save Workflow

Click `プロジェクト保存` from the preview pane to save the current script state.

The tool writes:

- `request.json`
- `characters.json`
- `trusted-sources.md`
- `knowledge.md`
- `sources.md`
- `rakko-gpts.md`
- `search-intent.md`
- `serp-analysis.md`
- `outline.md`
- `synopsis.md`
- `preflight-check.md`
- `intro-ending.md`
- `body.md`
- `transcript.md`
- `rewrite-analysis.md`
- `rewrite-synopsis.md`
- `dialogue-rewrite.md`
- `draft.md`
- `review.json`

These files support future commander plus small-skill workflows.
