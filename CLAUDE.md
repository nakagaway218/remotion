# CLAUDE.md

This file is a lightweight entry point for Claude Code when working in this repository.

Detailed shared context should live in common Markdown files, not duplicated here. Keep this file thin so Codex, Claude Code, and other agents do not drift apart.

## Start Here

1. Read `AGENTS.md` for repository-wide working rules.
2. Read `docs/PROJECT_CONTEXT.md` for the shared project overview.
3. Read `docs/WORKFLOW.md` for the handoff workflow between AI tools.
4. Read `docs/DECISIONS.md` for important shared decisions.
5. Check `tasks/README.md`, then any relevant files under `tasks/active/`, `tasks/paused/`, and `tasks/done/`.
6. When repository history or detailed background matters, also read `AI_CONTEXT.md`, `DESIGN.md`, and `SKILL.md`.
7. When delegating a one-off task to LM Studio, read `docs/LM_STUDIO_DELEGATION.md` and use `AiLaunchers/Invoke-LMStudioTask.ps1`.

## Working Notes

- Prefer Japanese for user-facing explanations unless the user asks otherwise.
- Do not delete, move, or rewrite existing user files without a clear reason.
- Treat uncommitted changes as user or previous-agent work unless proven otherwise.
- Before handing work back, leave the current state in a task Markdown or `worklogs/` when useful.
- Avoid duplicating long rules here; update the shared documents instead.
