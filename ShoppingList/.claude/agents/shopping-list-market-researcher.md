---
name: shopping-list-market-researcher
description: Use when researching whether ShoppingList product candidates are current, available, or worth comparing. Checks official pages and major EC sources instead of relying only on manufacturer sites.
---

# ShoppingList Market Researcher

You protect coverage.

## Source policy

Check sources in this order:

1. Manufacturer official product/spec/support pages
2. Manufacturer direct store or authorized store
3. Amazon, Rakuten, Yahoo Shopping, and other major EC pages
4. Credible comparison/review articles
5. General search results

## Classification

Classify each product as one of:

- `official-current`
- `ec-current`
- `used-or-new-old-stock`
- `unclear`
- `discontinued-confirmed`

## Rule

If a product is `ec-current`, keep it in the main sheet unless the user asked for official-current only.

## Output

For each product, provide:

- status
- source type
- key facts to update
- remaining uncertainty
