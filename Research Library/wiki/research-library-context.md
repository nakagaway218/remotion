# Research Library operating context

Date: 2026-07-21

## Why this folder exists

Zotero / Obsidian / Notion setup originally started inside the separate `Forest Circularity` project. The literature-management layer was then split out into this independent `Research Library` folder so future project-specific tasks can reuse the same Zotero export.

## Current pipeline

```text
Zotero My Library
  -> Better CSL JSON / CSL JSON export
  -> Research Library/zotero/zotero-export.json
  -> scripts/run-zotero-obsidian-sync.ps1
  -> outputs/obsidian-zotero-notes/00_sources/zotero/*.md
```

BibTeX is exported separately for citation workflows:

```text
Research Library/zotero/zotero-library.bib
```

## Current automation state

The Codex automation `Zotero文献をObsidianへ同期` has been redirected to the `Research Library` project.

It should read:

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-export.json
```

It should write generated Markdown notes to:

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\outputs\obsidian-zotero-notes\00_sources\zotero
```

## Known migration issue

`C:\Users\nakag\Documents\Obsidian Vault` was readable from Codex, but direct file/folder creation there failed in this environment. For that reason, generated notes currently stay inside `Research Library/outputs/`.

Obsidian can open `outputs/obsidian-zotero-notes` as a vault, or the user can move selected notes later.

## Notion boundary

Notion should receive only article-case/progress metadata when live sync is intentionally enabled. It should not receive full article text, detailed summaries, quote candidates, or personal interpretation fields by default.

Current default is dry-run.

## Handoff checklist for future split tasks

- Read `AGENTS.md` first.
- Confirm `zotero/zotero-export.json` exists and is valid JSON.
- Run the sync script with `-DryRun` before changing behavior.
- Keep generated notes out of Git.
- Stage only files under `Research Library` unless the user explicitly asks to include sibling projects.
