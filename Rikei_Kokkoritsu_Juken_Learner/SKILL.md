# Skill: Learner Maintenance

Use this skill when editing the Learner tool.

## Before Editing

1. Check worktree state with `git status --short`.
2. Read `AI_CONTEXT.md`.
3. Keep changes focused on the Learner workflow.
4. Do not modify neighboring projects such as `Webarticle/` or `Scenariowriting/` unless the user explicitly asks.

## Product Priorities

- Preserve the simple direct-open path through `C_Learner_Start.cmd`.
- Preserve manual prompt transfer as the normal path.
- Keep API direct answering as optional and secondary.
- Do not reintroduce reference-material opening or Excel / PowerPoint integration unless explicitly requested.
- Prefer stability and clear student-facing flow over adding broad features.

## Common Task Areas

### Step Flow Changes

- Edit the state machine in `C_Learner_Index.html`.
- Step rendering functions are named like `renderProviderStep`, `renderSubjectStep`, `renderAfterAnswerStep`, and `renderNextActionStep`.
- Preserve `[ラベル]` style for choices.
- Keep Step4 follow-up prompts copy-only; do not show `コピーしてAIを開く` for follow-up prompts.
- When adding navigation behavior, keep `stack` and `forwardStack` consistent.

### Prompt Changes

- Main question prompt logic lives in `buildApiQuestion(question)`.
- GPTs setup prompt lives in `getSetupPrompt()`.
- Follow-up prompt logic lives in `buildFollowupPrompt(label)` and `buildDetailFollowupPrompt(detail)`.
- Student answers must ask for learning-oriented explanations, not answer-only output.
- If the finish message changes, update both the UI finish panel and `getSetupPrompt()`.

### UI Changes

- Keep the first screen as the usable tool, not a landing page.
- Keep controls compact and task-oriented.
- Use the existing panel and button classes.
- Voice input relies on Chrome Web Speech API; preserve the Chrome/microphone hint.
- Avoid adding visible controls for hidden warning rules.

### API Changes

- API server logic lives in `C_Learner_Server.cjs`.
- `/api/chat` uses `OPENAI_API_KEY` from the environment.
- Do not store API keys in HTML.
- If changing model or cost behavior, explain that OpenAI API usage is metered.

### Launcher Changes

- `C_Learner_Start.cmd` should remain the main launcher and should directly open `C_Learner_Index.html`.
- `01_START_LEARNER.cmd` may be used for server/API mode.
- Avoid adding many similarly named launchers; the user has already found multiple entry points confusing.

## Verification

Run:

```powershell
$html = Get-Content -LiteralPath C_Learner_Index.html -Raw
$script = [regex]::Match($html, '(?s)<script>(.*)</script>').Groups[1].Value
$tmp = Join-Path $env:TEMP 'learner-inline-script.js'
Set-Content -LiteralPath $tmp -Value $script -Encoding UTF8
node --check $tmp

node --check C_Learner_Server.cjs
```

If UI behavior changed, manually open:

```powershell
.\C_Learner_Start.cmd
```

Then test the affected Step flow.
