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
- For substantial chats that produce commit-level decisions or workflow changes, save a concise context note in the relevant project folder before the context is lost.
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

## Career AI Project Context

Career and education-AI strategy context is stored in:

```text
CareerAIProject/
```

This folder records the user's long-term context for becoming an education AI strategist:

- career and strengths context in `CareerAIProject/CONTEXT.md`
- AI employee design for career and education-AI work in `CareerAIProject/AI_WORKFORCE.md`
- source conversation notes in `CareerAIProject/chat_logs/`

When the user asks about AI career strategy, education AI consulting, AI tool adoption, teaching-material business design, or sub-agent/AI-employee application in this domain, read `CareerAIProject/CONTEXT.md` first.

## Chat Context Preservation

When a chat contains enough decisions or file changes that a commit may be needed, ask whether the conversation should be saved as future context. If the user asks to save it, write a concise Markdown summary rather than a raw transcript.

Default destinations:

- AI workforce, sub-agent, multi-agent, and workflow judgment context: `AIWorkforceTemplate/05_チャット文脈保存/`
- Career or education-AI strategy context: `CareerAIProject/chat_logs/`
- Project-specific work history: the relevant project folder, using `handoff.md`, `log.md`, or `chat_logs/`

## Obsidian Second Brain Context

Obsidian活用のための初期Vault雛形は次に保存している:

```text
ObsidianSecondBrain/
```

This folder adapts `fuuuuuuma/ai-second-brain-kit` for the user's `Myownproject` workflow. It keeps a Codex-readable second-brain structure with `Memory.md`, `Home.md`, `raw/`, `wiki/`, `reports/`, `daily/`, `outputs/`, `rules/`, and `templates/`.

When the user asks about Obsidian, second-brain notes, personal knowledge management, or making AI remember project context, read `ObsidianSecondBrain/README.md`, `ObsidianSecondBrain/Memory.md`, and `ObsidianSecondBrain/rules/corrections.md` first.

## Google Drive / Sheets Source Sync

ObsidianSecondBrain now includes a source-index workflow for external materials:

- Google Drive stores heavy raw materials and source spreadsheets.
- `ObsidianSecondBrain/raw/webclip-index/` stores lightweight Markdown indexes.
- `ObsidianSecondBrain/scripts/sync-youtube-sheet-index.ps1` detects Google Sheets inside the configured Drive folder and creates index notes while avoiding duplicate URLs.
- OAuth credentials and tokens live under the Git-root `secrets/` folder and are ignored by Git.
- The OAuth app was rebuilt as `ObsidianSecondBrain Sync`; future OAuth failures should first check project mismatch, disabled APIs, missing test users, and stale refresh tokens.
- The detailed recovery log is `ObsidianSecondBrain/reports/2026-06-16-google-api-oauth-lessons.md`.
