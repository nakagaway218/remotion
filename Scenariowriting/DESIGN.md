# Design: Scenariowriting

## User Experience Principle

The tool should guide the user through script creation without requiring API spend. It should behave as a prompt workstation for ChatGPT Plus and NotebookLM.

## Script Modes

### 一人語り

Uses `scriptType=solo`. The main speaker carries the script. Optional sub-character settings can be used sparingly.

### 対話形式

Uses `scriptType=dialogue`. Character A and B settings determine the roles, tone, and relationship.

### 一人語りから対話形式への変換

Starts from `rawTranscript`, creates `cleanedTranscript`, analyzes how to convert it, approves a rewrite synopsis, then generates dialogue.

## Knowledge And Source Material Model

The basic knowledge step has two inputs:

- `knowledgeMemo`: NotebookLM output.
- `sourceMaterials`: imported or pasted source material.

Both are rendered in prompts through `knowledgeSection(fields)`.

Any prompt that plans, writes, rewrites, or summarizes content should include `knowledgeSection(fields)`.

## Cost Model

The standard path costs no OpenAI API usage. API generation is an optional fallback.

Cost-sensitive decisions:

- Keep API buttons hidden unless `API生成の詳細設定` is open.
- Prefer prompt creation over API generation.
- Preserve `OPENAI_COST_CAP_USD`, `OPENAI_MAX_OUTPUT_TOKENS`, and usage tracking.

## UI Rules

- Keep tabs compact because this workflow has many steps.
- Do not split the three script workflows into separate apps unless the user asks.
- Keep the preview pane intact.
- Any persistent input must be added to `ids` in `public/app.js`.

