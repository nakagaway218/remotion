# Research Library context

This workspace is the shared research-library layer for Zotero, Obsidian-ready literature notes, and later Notion article-progress tracking.

## Current role split

- Zotero is the source of truth for bibliographic records.
- `zotero/zotero-export.json` is the main Better CSL JSON / CSL JSON export used by Codex automation.
- `zotero/zotero-library.bib` is the BibTeX export for citation workflows.
- `outputs/obsidian-zotero-notes/` is generated output for Obsidian-ready Markdown notes and is intentionally ignored by Git.
- `raw/` stores lightweight source/index metadata.
- `wiki/` stores durable operating context and processed knowledge.
- `reports/` stores migration notes, decisions, and validation logs.

## Automation

The Codex automation named `Zotero文献をObsidianへ同期` should target this project, not the older `Forest Circularity` folder.

It should run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\scripts\run-zotero-obsidian-sync.ps1"
```

If there are no new Zotero items and no user action is needed, do not post a report.

## Safety rules

- Do not commit generated Obsidian note outputs under `outputs/`.
- Do not commit PDFs, credentials, tokens, `.env` files, or local-only secrets.
- Do not stage unrelated changes from sibling folders such as `Forest Crcularity` or `Forest Circularity`.
- Notion sync is dry-run by default. Do not enable live Notion writes unless the user explicitly asks for it and credentials are configured.

## Important paths

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-export.json
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\zotero\zotero-library.bib
C:\Users\nakag\Desktop\GitHub\Myownproject\Research Library\outputs\obsidian-zotero-notes\00_sources\zotero
```
