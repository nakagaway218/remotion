---
type: source_summary
status: 要約済み
date: 2026-07-03
source_type: tool
source: [[raw/webclip-index/2026-07-03-tool-フォローシート-お店の改善提案書をclaudecodeで作る]]
tags: [tool, claude-code, proposal, template]
---

# フォローシート / お店の改善提案書をClaudeCodeで作る

## 要約

- Claude Codeで店舗改善提案書を作るための実践用フォローシート。
- まず `SHOP.md` に店舗名、業態、顧客層、売上状況、店主の悩み、強みなどを整理する。
- 次に `genjou_bunseki.md` として現状分析やSWOTを作る。
- その分析から、店主の悩みに対応するAI・ツール活用の改善策を `kaizen_sisaku.md` に整理する。
- 最後に、表紙、目的、現状分析、課題、改善策、スケジュール、費用感を含む `teian_sho.md` を作る。
- さらに `TEMPLATE.md` を作れば、別店舗にも同じ流れを再利用できる。

## 自分の運用への反映

- `SHOP.md` から分析、改善策、提案書、テンプレートへ進む流れは、Codexでもそのまま応用できる。
- このリポジトリでは、実案件の生データはGitに入れず、フォーマットや手順だけを `wiki/` や `reports/` に残すのがよい。
- 提案書テンプレート化は、将来のAIエージェント化やスキル化の候補になる。

## 注意点

- フォローシート内の外部インストールコマンドは、実行前に公式情報と安全性を確認する。
- `irm | iex` や `curl | bash` 型のコマンドは、内容を確認せず自動実行しない。
