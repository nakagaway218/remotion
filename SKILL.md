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
2. If the work involves AI employee or sub-agent design, also read `CareerAIProject/AI_WORKFORCE.md`.
3. Keep public strategy, sanitized examples, prompts, and reusable plans in Git.
4. Do not commit real student names, school names, customer names, private records, or unpublished client information.
5. Prefer concrete outputs such as `SERVICE_MENU.md`, `ROADMAP_2026.md`, `PROMPTS.md`, or `CASE_STUDIES.md` over vague notes.

## Working With Obsidian Second Brain

Use `ObsidianSecondBrain/` when the user asks about Obsidian, second-brain notes, AI memory, or turning messy notes into reusable Markdown context.

1. Read `ObsidianSecondBrain/README.md` first.
2. Then read `ObsidianSecondBrain/Memory.md`, `ObsidianSecondBrain/rules/corrections.md`, and `ObsidianSecondBrain/wiki/index.md`.
3. Put unprocessed source material in `ObsidianSecondBrain/raw/` and do not delete or rename it without approval.
4. Put structured knowledge in `ObsidianSecondBrain/wiki/` and update `ObsidianSecondBrain/wiki/index.md`.
5. Put important answers, decisions, and research results in `ObsidianSecondBrain/reports/`.
6. Use Obsidian-friendly Markdown: frontmatter, `[[wikilink]]`, and concise MOC pages.

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
