# AI_CONTEXT.md

## Project Background

This repository is currently used as the user's main Codex/GitHub workspace. It was originally based on a Remotion repository, but the user is also using it to manage their own tools and project files.

The project root is:

```text
C:\Users\nakag\Desktop\GitHub\Myownproject
```

The previous nested `remotion/` folder was flattened into `Myownproject/`. The `.git` folder was moved with it, so Git history and GitHub remote settings were preserved.

## Current GitHub Remote

```text
origin   https://github.com/nakagaway218/remotion.git
upstream https://github.com/remotion-dev/remotion.git
```

The local folder name is `Myownproject`, but the GitHub repository is still named `remotion`.

## Important Decisions

- `AGENTS.md` is the main Codex work-rule file.
- `CLAUDE.md` points Claude Code to the same project context.
- `AI_CONTEXT.md` records background and decisions from the conversation.
- `DESIGN.md` records structure and file-management policy.
- `SKILL.md` records repeatable workflows for this repository.
- Files outside `Myownproject/` are not automatically reflected on GitHub.
- Files that should be reflected on GitHub should be moved or copied into `Myownproject/`.
- Files that should not be reflected on GitHub should be ignored with `.gitignore`.

## User Preferences

- Explain work in Japanese.
- Use beginner-friendly explanations for Git, GitHub, repository, commit, push, and `.gitignore`.
- Do not push to GitHub unless the user explicitly asks.
- Before GitHub sync, check changed files and avoid including unrelated or private files.

## Current User Tool Area

The user's PDF tool is stored in:

```text
Mytool/
```

It contains `.bat` launchers, Python scripts, and a README. Generated `.exe` files are intentionally ignored by Git.
