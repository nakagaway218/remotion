# Learning Tool Workflows

## New Tool Creation Workflow

1. Copy `LearningTool_Template` to a new folder.
2. Rename template files to match the new tool.
3. Fill in `TOOL_BRIEF.md`.
4. Update `AI_CONTEXT.md`.
5. Update `SKILL.md`.
6. Update `WORKFLOWS.md`.
7. Customize `Template_Index.html`.
8. Customize `Template_Mobile.html`.
9. Update user README files.
10. Create distribution zip files.

## Standard Manual Workflow

1. User opens the tool.
2. User chooses an AI provider.
3. User enters or selects learning content.
4. Tool creates a prompt.
5. User copies the prompt to ChatGPT / Claude / Gemini.
6. User may paste the AI answer back into the tool.
7. Tool creates follow-up prompts if needed.

## API Workflow

API mode should be treated as optional.

Before implementing API mode, decide:

- Who pays for API usage.
- How the API key is stored.
- Whether Node.js or a server is acceptable for the target users.
- Whether there should be a separate API distribution.

## Distribution Workflow

For end users, prefer:

```text
ToolName_PC.zip
ToolName_Mobile.zip
ToolName_All.zip
```

Keep each zip small and obvious.

