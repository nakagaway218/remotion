# Task: AI agent shared memory setup

## Objective

Create a minimal Markdown-based handoff structure so ChatGPT/Codex, future Claude Code, Antigravity, and other assistants can share project context without relying only on chat history.

## Current State

The initial setup is complete.

The repository now has shared documentation under `docs/` and task handoff folders under `tasks/`. `CLAUDE.md` is a thin entry point that points to shared files instead of duplicating long rules.

## Completed

- Checked the existing repository-level context files, including `AGENTS.md`, `README.md`, `AI_CONTEXT.md`, `DESIGN.md`, and `SKILL.md`.
- Added `docs/PROJECT_CONTEXT.md` for shared repository context.
- Added `docs/WORKFLOW.md` for AI handoff workflow.
- Added `docs/DECISIONS.md` for shared decisions.
- Added `tasks/active/`, `tasks/paused/`, and `tasks/done/`.
- Added README files for the task folders.
- Updated `CLAUDE.md` as a lightweight future Claude Code entry point.
- Checked existing Antigravity and recovery notes, including `Webarticle/ANTIGRAVITY.md`, `Webarticle/RECOVERY_NOTE.md`, and `Scenariowriting/RECOVERY_NOTE.md`.

## Important Judgments

- The root `README.md` still appears to come from the original Remotion upstream project, so it was left unchanged.
- Existing uncommitted changes that appeared unrelated were not reverted or edited.
- No definite abandoned Antigravity task could be confirmed from existing files, so no speculative paused task file was created.
- Chat history should be treated as helpful context, while repository Markdown should be treated as the durable handoff state.

## Existing Uncommitted Changes Not Owned By This Task

These were already present or unrelated and should not be assumed to belong to this setup work:

- `.codex/worklog.md`
- `Mytools/README.md`
- `Mytools/Codex GPT-OSS-20B 起動ツール.bat`

## Remaining

- Review the new docs and task structure.
- Commit this setup when the user is ready.
- As future work appears, create concrete task files under `tasks/active/`, `tasks/paused/`, or `tasks/done/`.

## Next Step

If this setup looks good, make a Git commit before starting unrelated work so this becomes a clean restore point.

## Last Updated

2026-08-09
