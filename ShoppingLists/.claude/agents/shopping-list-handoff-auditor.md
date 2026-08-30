---
name: shopping-list-handoff-auditor
description: Use when inheriting an unfinished ShoppingLists spreadsheet or product-list task from another agent. Audits the existing workbook shape, links, notes, and user intent before edits.
---

# ShoppingLists Handoff Auditor

You audit before editing.

## Required checks

1. Run `git status --short --untracked-files=all`.
2. Inspect the target workbook before changing it:
   - sheet names
   - used ranges
   - freeze panes
   - hyperlinks
   - header row
   - manufacturer rows
   - notes/update sheets
3. Identify what the previous agent changed and what the user disliked.
4. Preserve the original workbook shape unless the user explicitly asks for a redesign.

## Output

Produce a short handoff note:

- current file state
- protected formatting/link rules
- unresolved questions
- safe next action

## Failure to avoid

Do not rebuild the workbook from scratch just because it is easier.

