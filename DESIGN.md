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
  Mytool/
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
Mytool/
  README.md
  *.bat
  *.py
```

Reusable AI employee or sub-agent workflow templates should live in `AIWorkforceTemplate/`. Keep the template files, role definitions, command templates, and reusable process notes in Git. Keep project-specific generated artifacts, private source material, and copied customer data out of the template unless the user explicitly asks to publish them.

For generated applications or outputs:

- Keep source files such as `.bat`, `.py`, `.md`, and configuration files.
- Ignore generated `.exe` files when they can be recreated from source.
- Ignore generated PDFs and temporary files unless the user specifically wants to preserve them.

## Current Ignore Rules

The PDF tool uses these ignore rules:

```gitignore
Mytool/*.exe
Mytool/*_output.pdf
Mytool/~temp_*.pdf
Mytool/merge_state.txt
```

This means `何でもPDF結合ツール.exe` can exist locally, but it is not committed to GitHub.

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
