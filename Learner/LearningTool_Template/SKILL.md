# Skill: Learning Tool Maintenance

Use this skill when creating or editing a learning tool based on this template.

## Before Editing

1. Check worktree state with `git status --short`.
2. Read `TOOL_BRIEF.md`, `AI_CONTEXT.md`, and `WORKFLOWS.md`.
3. Keep changes focused on the requested tool.
4. Do not modify neighboring projects unless explicitly requested.

## Product Priorities

- Preserve a simple direct-open path for PC users.
- Preserve a browser-open path for mobile users.
- Keep manual prompt transfer as the normal path.
- Keep API generation optional and secondary.
- Avoid adding many similarly named launchers.
- Avoid automatic reference-material insertion unless explicitly requested.

## Common Task Areas

### Step Flow Changes

- Keep Step labels clear.
- Preserve `[ラベル]` style if the tool uses button-like text.
- Keep follow-up prompts copy-only when the user is expected to keep the same AI chat open.

### Prompt Changes

- Keep the generated prompt subject-specific.
- Do not include math/science-specific instructions for language tools.
- Do not include language-specific instructions for math/science tools.
- Keep initial answers readable.
- Separate explanation and model answer when useful.

### UI Changes

- PC and mobile can share logic, but mobile should have its own entry file when distributing to others.
- Keep buttons large enough for touch on mobile.
- Keep textareas readable and avoid tiny font sizes on mobile.

### Distribution Changes

- Make separate zip files when the target users differ:
  - PC zip
  - Mobile zip
  - All-in-one zip
- Include a short README in every distribution.

## Verification

Run JavaScript syntax checks if the HTML includes inline scripts.

Open the PC and mobile HTML files and run through the main workflow manually before sharing.

