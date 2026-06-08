# AI Context: Learner

## Purpose

This folder contains a local HTML helper for a high-school learning QA workflow.

The tool is a prompt-operation panel for students and teachers. It guides the user through:

1. AI provider selection
2. Subject selection
3. Text or image input choice
4. Question prompt creation
5. AI answer pasteback
6. Step4 follow-up options
7. Next-question or finish flow

The default operation is manual prompt transfer:

- The user opens the HTML locally.
- The user chooses ChatGPT, Claude, or Gemini.
- The tool creates a prompt.
- The user copies it into the selected AI chat.
- The user pastes the AI answer back into the tool before using Step4 follow-up options.

OpenAI API direct answering is a secondary future-ready option. It exists in the UI and server, but should not replace the manual ChatGPT / Claude / Gemini flow unless the user explicitly asks for API-first behavior.

## Current Product Decisions

- Main entry point: `C_Learner_Start.cmd`.
- Main HTML file: `C_Learner_Index.html`.
- Server file for future API mode: `C_Learner_Server.cjs`.
- Normal usage should open the HTML directly with `C_Learner_Start.cmd`.
- `01_START_LEARNER.cmd` is only for server/API mode.
- The old reference-material feature that opened Excel / PowerPoint files directly was intentionally removed after it caused Windows file-opening problems.
- Do not re-add direct Excel / PowerPoint opening from the HTML.
- Basic reference materials may be used only as extracted, embedded prompt notes so the direct-open HTML workflow stays stable.
- Current embedded basic materials:
  - 数学: `三角比改訂版_改善版.pptx` -> `materials/math_trigonometry.md`
  - 英語: `英語助動詞表現.xlsx` -> `materials/english_modals.md`
  - 古文: `日本語助動詞一覧.xlsx` -> `materials/japanese_auxiliary_verbs.md`
- The user wants a simple, stable, high-completion interface more than broad file integration.

## Active Features

- AI provider choices: ChatGPT, Claude, Gemini.
- Subject choices: 数学, 英語, 物理, 化学, 生物, 地学, 古文, 漢文.
- Voice input through Chrome Web Speech API.
- Automatic prompt creation with `出力の深さ：解答解説を教えてほしい`.
- Subject-linked basic materials are appended to first-question prompts for 数学, 英語, and 古文.
- Prompt wording asks the AI for problem-book style explanations, not just answers.
- First answers should stay readable: usually 300-450 Japanese characters, with 600-700 characters allowed for difficult math, advanced science, English long-form tasks, or classical text structure analysis.
- Math and science answers should include a concise `模範解答` section that reads like an answer sheet, separate from the explanatory section.
- AI answer pasteback area before Step4 follow-up.
- Step4 follow-up options:
  - 数学・理科: `[別解を知りたい]`, `[解説を詳しく説明してほしい]`, `[次に進む]`
  - 英語: `[解説を詳しく説明してほしい]`, `[構造分析をしてほしい]`, `[次に進む]`
  - 古文: `[解説を詳しく説明してほしい]`, `[品詞分解をしてほしい]`, `[次に進む]`
  - 漢文: `[解説を詳しく説明してほしい]`, `[書き下しをしてほしい]`, `[品詞分解をしてほしい]`, `[次に進む]`
- Step4 follow-up prompts hide `コピーしてAIを開く`; they only need copying into the already-open chat.
- Math and science follow-up prompts, especially `[別解を知りたい]`, should also require a model-answer style section, not just explanatory prose.
- `[解説を詳しく説明してほしい]` asks the user which part needs more detail.
- Optional checkbox: include previous answer in follow-up prompt for later resumed chats.
- Back and forward navigation.
- Finish state shows only: `お疲れ様でした。ご利用ありがとうございます。画面を閉じてください。`

## GPTs Prompt Decisions

The embedded setup prompt in `getSetupPrompt()` mirrors the intended GPTs instruction.

Important behavior to preserve:

- Step guidance should return button-like labels in `[ラベル]` form.
- Learning answers should use a high-school friendly schema.
- Math and science should include reasoning, formulas, intermediate steps, why the method is chosen, and a clean model-answer section.
- English composition should provide formal and casual versions, nuance differences, and unnatural-expression warnings.
- 古文・漢文 should include original source names when applicable.
- Hidden warning rules about homework dumping and repeated formula/word-meaning questions should stay in the GPTs prompt if the user asks for them, but they should not appear as visible UI controls.
- Finish text must match the UI finish text.

## Main Files

- `C_Learner_Index.html`: single-page UI, prompt builders, state machine, voice input, Step flow.
- `C_Learner_Start.cmd`: stable direct-HTML entry point.
- `C_Learner_Server.cjs`: optional local server for `/api/chat` using `OPENAI_API_KEY`.
- `01_START_LEARNER.cmd`: server/API-mode launcher.
- `02_OPEN_HTML_DIRECT.cmd`: older direct-open fallback, kept only as a backup.
- `00_Learner_Click_Test.cmd`: diagnostic click test, not part of normal usage.

## Verification

Use these checks after changes:

```powershell
$html = Get-Content -LiteralPath C_Learner_Index.html -Raw
$script = [regex]::Match($html, '(?s)<script>(.*)</script>').Groups[1].Value
$tmp = Join-Path $env:TEMP 'learner-inline-script.js'
Set-Content -LiteralPath $tmp -Value $script -Encoding UTF8
node --check $tmp

node --check C_Learner_Server.cjs
```

Manual smoke test:

1. Double-click `C_Learner_Start.cmd`.
2. Choose ChatGPT.
3. Choose 数学.
4. Choose 質問を直接入力.
5. Enter `1から500までの整数で、7で割り切れるかつ11で割り切れる整数の個数を求めたい`.
6. Confirm the generated prompt asks for 解答解説 and problem-book style explanation.
7. After pasteback, choose `[別解を知りたい]` and confirm `コピーしてChatGPTを開く` is hidden.
8. Choose `[終了]` and confirm only the finish message is displayed.
