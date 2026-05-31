# Skill: Webarticle Maintenance

Use this skill when editing the Webarticle tool.

## Before Editing

1. Check worktree state with `git status --short`.
2. Read `AI_CONTEXT.md`, `DESIGN.md`, and `WORKFLOWS.md`.
3. Keep changes focused on the requested workflow.

## Common Task Areas

### Prompt Changes

- Edit prompt builders in `server.mjs`.
- Preserve `knowledgeSection(fields)` in downstream prompts.
- Preserve synopsis approval behavior.
- Preserve the preflight check behavior and pass `preflightCheck` into body and summary prompts.
- Keep prompt output labels clear for manual ChatGPT or NotebookLM transfer.

### UI Changes

- Edit `public/index.html` for fields and panels.
- Add persistent input ids to `ids` in `public/app.js`.
- Keep the preview pane intact.
- Avoid making API generation more prominent than manual prompt mode.

### Import Changes

- CSV and source material import logic lives in `public/app.js`.
- Rakko API logic lives in `server.mjs`.
- New source-material fields must be included in `fields()`.

### Project Save Changes

- Project save logic lives in `server.mjs` at `/api/project/save`.
- The preview button in `public/index.html` calls `saveProject()` in `public/app.js`.
- Keep saved artifacts structured and readable for future small skills and sub-agents.

### Cost And API Changes

- Never remove cost cap checks.
- Keep API generation optional.
- Update README and ANTIGRAVITY if setup or environment variables change.

## Verification

Run:

```powershell
npm run check
node --check public/app.js
```

If prompt behavior changed, verify `/api/prompt` manually with sample fields.
