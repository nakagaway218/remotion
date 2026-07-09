---
name: myownproject-workflow
description: Repository-local workflow for working in Myownproject with Codex or other AI agents. Use when adding user tools, documenting project decisions, managing .gitignore rules, or syncing selected changes to GitHub.
---

# Myownproject Workflow

## Before Editing

1. Work from the repository root:

```text
C:\Users\nakag\Desktop\GitHub\Myownproject
```

2. Check the current Git state:

```bash
git status --short --branch
```

3. Do not revert user changes unless the user explicitly asks.

## Preserving Chat Context

When a chat produces commit-level decisions, durable workflow rules, or changes that future Codex sessions should understand, ask whether the conversation should be saved as context.

If the user asks to save it:

1. Write a concise Markdown summary instead of a raw transcript.
2. Include the consultation background, decisions, changed files, future operating rule, and unresolved items.
3. Save AI-workforce or sub-agent judgment context under `AIWorkforceTemplate/05_チャット文脈保存/`.
4. Save career or education-AI strategy context under `CareerAIProject/chat_logs/`.
5. Save project-specific history in that project's own folder.

## Adding A User Tool

1. Create or use a dedicated folder such as `Mytool/`.
2. Keep readable source files, such as `.bat`, `.py`, `.md`, and configuration files.
3. Add a `README.md` explaining:
   - what the tool does
   - which file starts it
   - which script is the main implementation
   - required environment and libraries
   - how generated files are handled
4. If a launcher depends on a script, keep both in the same tool folder when practical.

## Handling Generated Files

Use `.gitignore` for files that should exist locally but not on GitHub.

For the current PDF tool:

```gitignore
Mytool/*.exe
Mytool/*_output.pdf
Mytool/~temp_*.pdf
Mytool/merge_state.txt
```

If an `.exe` can be recreated from a `.bat` or source script, document the build steps instead of committing the `.exe`.

## Working On Career AI Strategy

Use `CareerAIProject/` when the task is about education AI strategy, AI consulting, AI tool adoption, teaching-material business design, or the user's long-term career context.

1. Read `CareerAIProject/CONTEXT.md` first.
2. Read `CareerAIProject/BIAS_REVIEW.md` when the source came from a GPTs, information product, course funnel, or sales page.
3. If the work involves AI employee or sub-agent design, also read `CareerAIProject/AI_WORKFORCE.md`.
4. Treat career and business claims as hypotheses unless they are verified facts.
5. Keep public strategy, sanitized examples, prompts, and reusable plans in Git.
6. Do not commit real student names, school names, customer names, private records, unpublished client information, or unreviewed sales copy.
7. Prefer concrete outputs such as `SERVICE_HYPOTHESES.md`, `VALIDATION_PLAN.md`, `TOOL_EVALUATION.md`, `PROMPTS.md`, or `CASE_STUDIES.md` over vague notes.

## Working With Obsidian Second Brain

Use `ObsidianSecondBrain/` when the user asks about Obsidian, second-brain notes, AI memory, or turning messy notes into reusable Markdown context.

1. Read `ObsidianSecondBrain/README.md` first.
2. Then read `ObsidianSecondBrain/Memory.md`, `ObsidianSecondBrain/rules/corrections.md`, and `ObsidianSecondBrain/wiki/index.md`.
3. Put unprocessed source material in `ObsidianSecondBrain/raw/` and do not delete or rename it without approval.
4. Put structured knowledge in `ObsidianSecondBrain/wiki/` and update `ObsidianSecondBrain/wiki/index.md`.
5. Put important answers, decisions, and research results in `ObsidianSecondBrain/reports/`.
6. Use Obsidian-friendly Markdown: frontmatter, `[[wikilink]]`, and concise MOC pages.

## Planning Larger Codex Tasks

For multi-step implementation, UI repair, research-to-artifact work, or migration work, treat the request like a goal even when the user does not explicitly use `/goal`.

1. State or infer the background, target scope, completion criteria, constraints, verification method, and expected artifact.
2. For UI and frontend work, use the in-app Browser or `@Browser` when practical, then report the checked URL, viewport, and remaining issues.
3. For Windows-first work, prefer Browser verification and screenshots before Appshots-specific guidance.
4. Keep plugin sharing and Analytics guidance as team or Business/Enterprise topics unless the user asks for organizational rollout.

## Working With Studymaterials

Use `Studymaterials/` when the user asks for teaching materials, Excel教材, middle-school English composition workbooks, Japanese grammar tables, study plans, or PDF conversion for study sheets.

1. Read `Studymaterials/README.md`, `Studymaterials/AI_CONTEXT.md`, `Studymaterials/SKILL.md`, and `Studymaterials/english_composition_dialogue_notes.md` before editing English composition workbooks.
2. Preserve Sheet1/Sheet2 correspondence, print layout, page breaks, row heights, merged cells, and user-tuned formatting.
3. For present-perfect English workbooks, verify natural short replies before finalizing answers. `have not` / `haven't` replies may omit tails such as `visited Kyoto before`, so mark the optional part as `(visited Kyoto before)`. Keep `never` lines as full sentences, such as `I have never visited Kyoto.`
4. Interpret requests to add examples as additive. Do not replace or rewrite an existing example unless the user explicitly asks for replacement; if preserving both creates a conflict, ask before changing the original.
5. Apply that optional-tail check to both Yes/No questions and `How many times ...?` replies.
6. When moving emphasis in a workbook, identify whether the user means a border or text formatting. Inspect and validate `Border` and `Font` separately, then confirm the result in an Excel-rendered PDF.

## Evaluating External Skills

When the user provides a Claude Skill, Codex Skill, plugin, agent, or installer repository, do not bulk-install it by default.

1. Read the repository README, agent instructions, catalog, profiles, install guide, and the specific `SKILL.md` files that seem relevant.
2. Ask or infer the user's main work type, repeated task, risk level, audience, and whether the workflow should be personal, project-local, or shareable.
3. Present only 3 to 5 candidate skills or workflow ideas, with official/unofficial status and safety notes.
4. Before installing or copying any external skill, verify source existence, current folder names, `SKILL.md` frontmatter, license, and dangerous operations such as deletion, Git mutation, external upload, credentials, or paid APIs.
5. For Codex, prefer adapting the useful procedure into `AGENTS.md`, `SKILL.md`, `ObsidianSecondBrain/reports/`, a local Codex skill, or a plugin depending on scope.
6. Start with one skill or one workflow note, then expand only after it proves useful.

## Documenting exe Build Steps

In the tool README, record:

1. the source file used to create the executable
2. the converter or build tool used
3. the output filename
4. the output folder
5. any encoding or Windows-specific settings
6. whether the generated executable is ignored by Git

## Syncing To GitHub

Only sync after the user asks for it.

1. Review status:

```bash
git status --short --branch
```

2. Stage only relevant files:

```bash
git add <files>
```

3. Commit with a short English message:

```bash
git commit -m "Add PDF tools"
```

4. Push only after user approval:

```bash
git push origin main
```

## Explanation Style

Explain results to the user in Japanese. When using terms such as repository, commit, push, or `.gitignore`, include a short plain-language explanation when helpful.

## Google Drive / Sheets Source Sync

Use `ObsidianSecondBrain/` and the global Codex skill `source-index-sync` when setting up external source lists backed by Google Drive or Google Sheets.

Key operating rules:

1. Keep OAuth client JSON, refresh tokens, `.env`, and other secrets under the Git-root `secrets/` folder, which must stay ignored by Git.
2. For OAuth app-name or access errors, check these in order: the OAuth JSON `project_id`, whether Google Sheets API and Google Drive API are enabled in that same project, whether the user's Gmail is added as a test user, and whether the stored refresh token belongs to the latest OAuth client.
3. If the OAuth consent app name is wrong and cannot be edited cleanly, create a new Google Cloud project with the desired app name instead of repeatedly recreating only the OAuth client.
4. Use `ObsidianSecondBrain/scripts/get-google-refresh-token.ps1` to obtain a refresh token and `ObsidianSecondBrain/scripts/sync-youtube-sheet-index.ps1 -DryRun` to verify API connectivity before writing index files.
5. The source sync script should auto-detect Google Sheets inside the configured Drive folder, skip empty sheets, and avoid duplicate index notes for URLs already present in `raw/webclip-index/`.
6. Keep long raw materials in Google Drive; keep only lightweight indexes, wiki notes, and reports in Git.

Detailed lessons are stored in `ObsidianSecondBrain/reports/2026-06-16-google-api-oauth-lessons.md`.
