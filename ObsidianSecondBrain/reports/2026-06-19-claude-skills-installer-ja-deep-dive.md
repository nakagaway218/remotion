---
type: investigation
status: reviewed
date: 2026-06-19
topic: claude-skills-installer-ja 詳細確認
source_url: https://github.com/fuuuuuuma/claude-skills-installer-ja
tags: [github, tool, skills, codex, automation, review]
---

# claude-skills-installer-ja 詳細確認

`fuuuuuuma/claude-skills-installer-ja` をREADMEだけでなく、主要ファイルまで確認した記録です。

## 確認したファイル

- `README.md`
- `AGENTS.md`
- `catalog/skills.json`
- `catalog/catalog.md`
- `install/install.md`
- `profiles/planning.md`
- `profiles/docs-creation.md`
- `profiles/writing.md`
- `profiles/data.md`
- `profiles/dev-baseline.md`

## 結論

このリポジトリは、Claude Skillsを一括導入するための単純な配布物ではなく、業務をヒアリングし、必要なskillだけを選び、安全確認してから正しい場所へ配置するためのカタログ兼手順書です。

Codexで使う場合は、そのまま `~/.claude/skills/` に入れるのではなく、必要な手順を `AGENTS.md` や `.codex/` 配下の文脈ファイルに移植する運用が前提になります。

## カタログ概要

`catalog/skills.json` 上の集計:

| 項目 | 数 |
| --- | ---: |
| skill総数 | 70 |
| 公式 | 13 |
| 非公式 | 57 |
| 同梱skill | 5 |

カテゴリ別:

| カテゴリ | 数 |
| --- | ---: |
| business | 3 |
| code | 15 |
| design | 12 |
| meta | 3 |
| multiagent | 3 |
| office | 7 |
| original | 5 |
| planning | 9 |
| tooling | 4 |
| writing | 9 |

同梱skill:

- `planning-sprint`
- `document-processor`
- `research-to-writing`
- `mtg-notes`
- `read-invoices`

## AGENTS.mdの重要点

- いきなり全部入れない。
- まず業務内容、毎日繰り返している作業、開発者か非開発者かを確認する。
- 候補は3〜5個に絞って提示する。
- 非公式skillは導入前に中身を確認する。
- `rm -rf`、破壊的git操作、外部送信、難読化コードなどを確認する。
- `known_renames` を確認し、古いskill名のまま導入しない。
- 最後に、入れたもの、入れなかったもの、置いた場所、次の一手を報告する。

## Codex環境での扱い

`install/install.md` では、Codexは `AGENTS.md` 階層と `.codex/` 配下の設定で振る舞いを定義するとされている。各 `SKILL.md` の本文を、対象プロジェクトの `AGENTS.md` や `.codex/` 配下へ移植する運用が基本。

つまり、Codexでは次の扱いが妥当です。

- Claude Code用のskillをそのまま大量導入しない。
- 必要なものだけ読み、既存のCodex用スキルやプロジェクト文脈へ統合する。
- `ObsidianSecondBrain` では、すでに `source-index-sync` や `middle-school-english-workbook` のような実運用スキルがあるため、追加導入は慎重に行う。

## 現在のMyownprojectに合いそうな候補

すぐ導入ではなく、必要になった時の候補として記録する。

| 候補 | 用途 | 判断 |
| --- | --- | --- |
| Skill Creator | 既存運用をskill化する | 既にCodex標準スキルとして存在。必要時に使う |
| Obsidian Vault | Obsidian Vault運用 | 現在のObsidianSecondBrain運用と近いが、既存構造と競合しないか確認が必要 |
| Doc Co-Authoring | 記事・文書作成 | WebarticleやScenariowritingで有用な可能性 |
| Edit Article | 記事の構造編集 | 長文記事・プロフィール文の再構成に使える可能性 |
| Content Researcher | 調査結果整理 | Codex調査メモと相性がよい可能性 |
| XLSX | Excel教材・管理表 | 既にSpreadsheet系スキルと重なる。追加不要の可能性が高い |
| PDF | PDF読み取り・処理 | 既にPDFプラグインがあるため追加不要の可能性が高い |
| document-processor | PDF/Word/Excel混在処理 | 教材・資料整理で候補。ただし中身確認が必要 |
| research-to-writing | 調査から執筆 | Webarticle向け候補 |
| planning-sprint | 企画壁打ち | 新規プロジェクト立ち上げ時の候補 |

## 導入判断

現時点では、追加インストールは不要です。

理由:

- Codex側にはすでに `source-index-sync`、`skill-creator`、Google Drive、Documents、Spreadsheets、PDFなどの機能がある。
- 今回の目的はGitHubリポジトリの中身確認であり、skill導入ではない。
- このリポジトリ自身も「全部入れるな」「必要なものだけ選べ」としている。
- 非公式skillが多いため、導入前の個別確認が必要。

次に進めるなら、導入ではなく「候補比較」から始める。

## 次に進める場合

1. 目的を1つ決める。
   - 例: Web記事作成、教材Excel、Google Drive素材整理、企画壁打ち
2. 対応するprofileを1つだけ読む。
3. 候補skillを3〜5個に絞る。
4. 実際の `SKILL.md` を確認する。
5. 危険な処理がないか確認する。
6. 既存Codexスキルと重複していないか確認する。
7. 必要なら、インストールではなく `AGENTS.md` / `wiki/` / `reports/` に運用ルールとして取り込む。

## 参照元

- GitHub: https://github.com/fuuuuuuma/claude-skills-installer-ja
- AGENTS.md: https://github.com/fuuuuuuma/claude-skills-installer-ja/blob/main/AGENTS.md
- skills.json: https://github.com/fuuuuuuma/claude-skills-installer-ja/blob/main/catalog/skills.json
- catalog.md: https://github.com/fuuuuuuma/claude-skills-installer-ja/blob/main/catalog/catalog.md
- install.md: https://github.com/fuuuuuuma/claude-skills-installer-ja/blob/main/install/install.md
- profiles: https://github.com/fuuuuuuma/claude-skills-installer-ja/tree/main/profiles
