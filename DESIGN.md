# DESIGN.md

## Repository Layout

```text
Myownproject/
  AGENTS.md
  AI_CONTEXT.md
  CLAUDE.md
  DESIGN.md
  SKILL.md
  AIWorkforceTemplate/
  CareerAIProject/
  ObsidianSecondBrain/
  Mytools/
  packages/
```

## File Placement Policy

Use `Myownproject/` as the Git-managed project root.

- Put project files that should be tracked by GitHub inside `Myownproject/`.
- Keep temporary files, generated outputs, private documents, and large binaries out of Git.
- Use `.gitignore` to exclude files that are useful locally but should not be committed.

## Tool Folder Policy

User-created tools should live in their own folders. For example:

```text
Mytools/
  README.md
  *.bat
  *.py
```

Reusable AI employee or sub-agent workflow templates should live in `AIWorkforceTemplate/`. Keep the template files, role definitions, command templates, and reusable process notes in Git. Keep project-specific generated artifacts, private source material, and copied customer data out of the template unless the user explicitly asks to publish them.

Career, education-AI strategy, and AI consulting context should live in `CareerAIProject/`. This folder may contain neutralized profile context, bias-review notes, service hypotheses, validation plans, prompt collections, and sanitized conversation logs. Do not store real student names, school names, customer names, private records, unpublished client information, or unreviewed information-product sales copy in GitHub-tracked files.

Obsidian and second-brain working context can start in `ObsidianSecondBrain/`. This folder is an Obsidian-openable Markdown vault and a Codex-readable seed based on `fuuuuuuma/ai-second-brain-kit`. Use it for durable, shareable, non-private context. Keep private thinking notes, raw personal records, and sensitive client/student information outside GitHub unless the user explicitly approves sanitizing and committing them.

For generated applications or outputs:

- Keep source files such as `.bat`, `.py`, `.md`, and configuration files.
- Ignore generated `.exe` files when they can be recreated from source.
- Ignore generated PDFs and temporary files unless the user specifically wants to preserve them.

## External Archives and Zip Files

Zip files and other archive formats are treated as external source material by default.

- Keep Zip bodies and extracted folders out of Git unless the user explicitly approves a sanitized subset.
- Inspect archives in a temporary Git-ignored location first.
- Save only lightweight Markdown reports, summaries, adoption decisions, and links.
- Do not run scripts, installers, or binaries found inside archives.
- When an archive contains Markdown/YAML/text files, read only what is needed and summarize rather than copying full source material into Git.
- If archive content duplicates existing knowledge, update or link the existing note instead of creating a parallel duplicate.

For the current Google Drive source workflow, use `ObsidianSecondBrain/scripts/inspect-drive-zip-sources.ps1` and keep reports under `ObsidianSecondBrain/reports/zip-inspections/`.

## Current Ignore Rules

The PDF tool uses these ignore rules:

```gitignore
Mytools/*.exe
Mytools/*_output.pdf
Mytools/~temp_*.pdf
Mytools/merge_state.txt
```

This means `何でもPDF結合ツール.exe` can exist locally under `Mytools/`, but it is not committed to GitHub.

## GitHub Sync Design

Only committed files are reflected on GitHub.

Recommended flow:

```bash
git status
git add <files>
git commit -m "Short English message"
git push
```

Before committing, review whether each changed file should be public on GitHub.
