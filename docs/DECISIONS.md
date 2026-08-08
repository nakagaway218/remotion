# Decisions

This file records repository-wide decisions that should be shared by Codex, Claude Code, Antigravity, and future assistants.

## 2026-08-09 - Keep AI-specific entry files thin

`AGENTS.md` and `CLAUDE.md` should act as entry points, not separate long rulebooks with duplicated content.

Shared rules, project context, decisions, and task state should live in common Markdown files such as:

- `docs/PROJECT_CONTEXT.md`
- `docs/WORKFLOW.md`
- `docs/DECISIONS.md`
- `tasks/`
- `AI_CONTEXT.md`
- `DESIGN.md`
- `SKILL.md`

Reason: duplicated instructions drift over time and make it harder to move work between AI tools.

## 2026-08-09 - Use task Markdown as durable handoff state

When work needs to move between ChatGPT/Codex, Claude Code, Antigravity, or another assistant, the task state should be written to `tasks/` instead of relying only on chat logs.

Reason: repository files are visible to every assistant and remain available after a chat session ends.

## 2026-08-09 - Do not invent paused Antigravity tasks

Existing Antigravity and recovery notes should be used to create paused task files only when the unfinished task is clear from repository files or user instructions.

Reason: a guessed task file can become misleading shared memory.

## 2026-08-09 - Treat Markdown as the source of truth before chat compression

When a conversation becomes long, important task state should be written into repository Markdown before relying on automatic chat summaries.

Reason: automatic compression can preserve the broad story while losing small but important judgments, such as why a file was left untouched or which next step is safest.
