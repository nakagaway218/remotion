# DESIGN.md

## Repository Layout

```text
Myownproject/
  AGENTS.md
  AI_CONTEXT.md
  CLAUDE.md
  DESIGN.md
  SKILL.md
  MyConversion/
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

Article conversion workflows should live in `MyConversion/`:

```text
MyConversion/
  README.md
  *_replay.py
  *_再現手順.md
```

Keep reusable scripts and process notes in Git. Keep generated deliverables, private source documents, temporary extraction folders, and render-check images out of Git unless the user explicitly asks to publish them.

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

## Markdown File Selection Policy

Before pushing, decide whether each `.md` file should be public project knowledge.

Commit `.md` files when they contain:

- project rules for AI agents, such as `AGENTS.md`, `CLAUDE.md`, or `SKILL.md`
- reusable project context or decisions, such as `AI_CONTEXT.md`
- repository structure, design, or file-management policy, such as `DESIGN.md`
- user-facing tool instructions, such as a tool `README.md`
- reproducible workflow notes that will be useful again

Do not commit `.md` files when they contain:

- private personal notes
- temporary drafts or scratch logs
- customer, client, or case-specific confidential information
- passwords, API keys, account details, or other secrets
- generated one-time logs that are not useful as reusable project knowledge

When uncertain, ask the user before staging the file.

Recommended flow:

```bash
git status
git add <files>
git commit -m "Short English message"
git push
```

Before committing, review whether each changed file should be public on GitHub.
