# Workflow

## Basic Principle

Use GitHub and Markdown files as the shared working memory between ChatGPT/Codex, Claude Code, Antigravity, and any future assistant.

Chat history can provide context, but repository files should hold the durable state.

## Starting Work

1. Check the current Git state.
2. Read `AGENTS.md`.
3. Read `docs/PROJECT_CONTEXT.md` and `docs/DECISIONS.md` when the task touches repository-wide behavior.
4. Check `tasks/README.md` and the relevant task folder.
5. Read project-local handoff files such as `ANTIGRAVITY.md`, `RECOVERY_NOTE.md`, or `WORKFORCE_SPEC.md` when present.

## During Work

- Keep edits focused on the requested task.
- Do not rewrite existing project structure unless the task requires it.
- Preserve user changes and previous-agent work.
- When new context is discovered, prefer updating a task note or worklog rather than scattering important details across chat only.

## Before Chat Context Gets Compressed

Automatic chat compression is useful, but it can lose small judgment details. When a conversation becomes long or a handoff is likely, write the durable facts into Markdown before relying on the chat summary.

Prefer recording:

- Why the current approach was chosen.
- Which files were changed and which existing changes were intentionally left alone.
- What is complete, what remains, and what is uncertain.
- The next concrete action for the next assistant.
- Any caution that would be costly to rediscover.

Use `tasks/active/` for work that will continue soon, `tasks/paused/` for interrupted work, `tasks/done/` for completed handoff notes, and `docs/DECISIONS.md` for repository-wide decisions.

## Handoff Between AI Tools

Before switching from one assistant to another:

1. Confirm the Git state and changed files.
2. Update or create a task Markdown file under `tasks/active/` or `tasks/paused/`.
3. Record:
   - Objective
   - Current state
   - Completed work
   - Remaining work
   - Known risks or unclear points
   - Suggested next step
4. Commit or otherwise clearly preserve the state when appropriate.

## Task Folder Use

- `tasks/active/` - work currently intended to continue soon.
- `tasks/paused/` - interrupted or waiting work, including recoverable Antigravity work when identifiable.
- `tasks/done/` - completed task notes worth preserving.

Avoid creating speculative task files. If the current state cannot be confirmed from repository files or user instructions, record the uncertainty in a README or worklog instead.

## Suggested Task Template

```markdown
# Task: <short title>

## Objective

## Current State

## Completed

## Remaining

## Known Issues / Risks

## Next Step

## Last Updated
YYYY-MM-DD
```
