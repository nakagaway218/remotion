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

## Article Conversion Workflow

Use `MyConversion/` for the recorded article conversion process.

The current documented flow is:

```text
Google Document source article
-> reference-page-style HTML
-> Google Document submission DOCX
-> WordPress body HTML
```

Before changing this workflow, read:

- `MyConversion/README.md`
- `MyConversion/頭皮アートメイク_痛み記事_リライト_再現手順.md`

Current replay scripts:

- `MyConversion/html_to_google_docx_replay.py`
- `MyConversion/docx_to_wordpress_replay.py`

Keep generated DOCX, rendered QA images, private Google Document exports, and article source assets out of Git unless the user explicitly asks to publish them.

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
