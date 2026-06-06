# Learner Workflows

## Standard Manual Workflow

1. Double-click `C_Learner_Start.cmd`.
2. Select AI provider: ChatGPT, Claude, or Gemini.
3. Select subject.
4. Select input method.
5. Enter a question or prepare an image prompt.
6. Create the prompt.
7. Copy the prompt and paste it into the selected AI.
8. Paste the AI answer back into Learner.
9. Use Step4 follow-up options if needed.
10. Continue to the next question or finish.

## API Workflow

This is optional and not the normal path.

1. Set `OPENAI_API_KEY` in the environment.
2. Run `01_START_LEARNER.cmd`.
3. Open `http://localhost:8787/C_Learner_Index.html` if the browser does not open.
4. Use `ChatGPT APIで直接質問`.

## Step4 Follow-Up Workflow

Step4 assumes the user usually keeps the same AI chat open.

- Follow-up prompt should be copied only.
- Do not open a new AI chat for follow-up prompts.
- `前回回答を追加依頼に含める` is useful only when continuing later in a new chat.
- `[解説を詳しく説明してほしい]` should ask which part needs more detail before creating a prompt.

## Finish Workflow

When `[終了]` is selected:

- Hide the normal operation UI.
- Hide `AIに送る文面`.
- Show only `お疲れ様でした。ご利用ありがとうございます。画面を閉じてください。`

## Removed Reference-Material Workflow

The reference-material workflow was removed intentionally.

Do not restore these behaviors unless explicitly requested:

- Opening Excel or PowerPoint files from the HTML.
- Showing a reference-material panel.
- Adding `# 参考資料` content to generated prompts.
- Adding `Open_...Reference.cmd` launchers.
