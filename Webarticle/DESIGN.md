# Design: Webarticle

## User Experience Principle

The tool should feel like a guided writing desk, not an API console. The user should be able to proceed manually with ChatGPT Plus and NotebookLM without needing paid API calls.

## Standard Flow

The standard workflow is:

1. Enter keyword and article settings.
2. Optionally gather basic knowledge with NotebookLM and source materials.
3. Generate prompts for each step.
4. Paste prompts into ChatGPT or NotebookLM.
5. Paste outputs back into the matching fields.
6. Approve the synopsis before later writing steps.
7. Export the draft as Markdown.

## Knowledge And Source Material Model

The basic knowledge step has two inputs:

- `knowledgeMemo`: NotebookLM output.
- `sourceMaterials`: imported or pasted source material.

Both are rendered in prompts through `knowledgeSection(fields)`.

Any prompt that makes decisions about content, structure, claims, or wording should include `knowledgeSection(fields)`.

## Cost Model

The standard path costs no OpenAI API usage. API generation is available only as an optional backup.

Cost-sensitive decisions:

- Keep API buttons hidden unless `API生成の詳細設定` is open.
- Prefer prompt creation over generation.
- Keep model choices to low-cost models defined in `modelPrices`.
- Never remove cost cap checks from `generate()`.

## UI Rules

- Keep workflow tabs visible and simple.
- Use compact labels and avoid explanatory overload inside the UI.
- Preserve the right-side draft preview.
- Avoid adding nested cards or broad visual redesigns unless the user asks for a UI redesign.

## Data Persistence

The browser stores field values in local storage. Any new field that should persist must be added to `ids` in `public/app.js`.

