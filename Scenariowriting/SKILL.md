# Skill: Scenariowriting Maintenance

Use this skill when editing the Scenariowriting tool.

## Before Editing

1. Check worktree state with `git status --short`.
2. Read `AI_CONTEXT.md`, `DESIGN.md`, and `WORKFLOWS.md`.
3. Identify which workflow is affected:
   - 一人語り
   - 対話形式
   - 一人語りから対話形式への変換

## Common Task Areas

### Prompt Changes

- Edit prompt builders in `server.mjs`.
- Preserve `knowledgeSection(fields)` in planning, writing, and rewrite prompts.
- Preserve trusted-source discovery before NotebookLM memo creation for specialized topics.
- Preserve normal synopsis approval and rewrite synopsis approval.
- Preserve the preflight check behavior and pass `preflightCheck` into intro/ending, body, and dialogue rewrite prompts.
- Keep manual ChatGPT and NotebookLM prompt transfer as the main path.

### UI Changes

- Edit `public/index.html` for fields and panels.
- Add persistent input ids to `ids` in `public/app.js`.
- Keep script-type switching behavior intact.
- Keep API generation secondary.

### Source And CSV/JSON Import Changes

- Source material import logic lives in `public/app.js`.
- Outline CSV/JSON import logic also lives in `public/app.js`.
- Rakko GPTs pasteback parsing also lives in `public/app.js`.
- Rakko headings in Scenariowriting are viewer-need and topic-candidate material; do not treat them as a finished video outline.
- Any new imported content must be included in `fields()`.

### Cost And API Changes

- Never remove cost cap checks.
- Keep API generation optional.
- Update documentation if setup or environment variables change.

### Project Save Changes

- Project save logic lives in `server.mjs` at `/api/project/save`.
- The preview button in `public/index.html` calls `saveProject()` in `public/app.js`.
- Keep saved artifacts structured and readable for future small skills and sub-agents.

## Verification

Run:

```powershell
npm run check
node --check public/app.js
```

If prompt behavior changed, verify `/api/prompt` manually with sample fields for the affected workflow.
