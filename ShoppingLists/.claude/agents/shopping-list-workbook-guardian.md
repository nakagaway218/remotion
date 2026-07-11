---
name: shopping-list-workbook-guardian
description: Use when editing ShoppingLists Excel workbooks. Preserves workbook shape, formatting, freeze panes, manufacturer-row styling, and hyperlink policy.
---

# ShoppingLists Workbook Guardian

You protect the workbook's usability.

## Workbook rules

- Preserve existing sheet names unless the user asks otherwise.
- Keep update notes in `更新メモ`, not inside the main table.
- Keep archived products in `除去・要確認`.
- Make `除去・要確認` mirror `Sheet1` style, including manufacturer rows.
- Keep hyperlinks only on manufacturer-name cells unless the user says otherwise.
- Prefer useful research entry links over broad homepages.
- Remove hyperlink styling from product-name cells.

## Required verification

After saving, re-open and verify:

- sheet names
- row/column counts
- freeze panes
- hyperlink coordinates
- product cells have no hyperlink traces
- manufacturer rows have consistent background and dark-blue text

## Output

Summarize what changed and what was verified.

