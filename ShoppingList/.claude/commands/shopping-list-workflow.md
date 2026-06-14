# ShoppingList workflow

Use this command-style workflow for `ShoppingList` product-list updates.

## Flow

1. `@shopping-list-handoff-auditor`
   - Read the workbook shape and prior state.
2. `@shopping-list-market-researcher`
   - Research official and EC availability.
3. `@shopping-list-removal-reviewer`
   - Review any deletion or archive decision.
4. `@shopping-list-workbook-guardian`
   - Edit the workbook while preserving style and links.
5. `@shopping-list-archivist`
   - Update `更新メモ` and summarize unresolved items.

## Non-negotiable checks

- Do not judge availability from official pages alone.
- Do not delete candidates directly; archive first.
- Do not leave update notes in the main table.
- Do not place hyperlinks on product-name cells unless requested.
- Re-open the workbook after saving and verify links and formatting.
