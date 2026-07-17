---
type: source_summary
status: 整理済み
date: 2026-07-17
source_date: 2026-07-16
source_type: youtube
topic: Codex x NotebookLM x 第二の脳
tags: [summary, youtube, codex, notebooklm, obsidian, second-brain]
---

# Codex x NotebookLMで第二の脳を作る考え方

## 参照元

- 索引: [[raw/webclip-index/2026-07-16-youtube-obsidianは論外-第2の脳を作る-codex-notebooklm-の正しい使い方を徹底解説します|【Obsidianは論外...!?】第2の脳を作る " Codex × NotebookLM "の正しい使い方を徹底解説します]]
- 元動画: https://www.youtube.com/watch?v=UKJyfSNz8tA
- 文字起こしDocs: Google Drive側で管理

## 要点

- 動画の主張は、Obsidianだけに知識管理を寄せるのではなく、NotebookLMを「出典つきで答える知識倉庫」として使い、Codexを「考えて実行する作業者」として組み合わせること。
- NotebookLMは投入した資料に基づいて回答し、出典を示せる点が強み。大量のPDF、書籍、プロンプト、スキル資料などを扱う場合、ローカルGitに全文を置かずに参照層として使いやすい。
- ただしNotebookLMに資料を入れるだけでは弱い。チャット用・Studio用のカスタムプロンプトで「役割」「判断基準」「話し方」「重視する観点」を与えることで、ノートブックごとに人格や専門性を持たせる。
- 用途ごとにノートブックを分けるのが実務向き。例: Codex運用、教材作成、Web制作、AI動画、業務自動化など。
- Codex側は、NotebookLMで整理された知識や出典を材料にして、Git管理されたMarkdown、スクリプト、運用ルールへ落とし込む役割に向く。

## このプロジェクトでの判断

ObsidianSecondBrainの位置づけは変えない。現時点では、Codexが確実に読めるGit管理Markdownとして `raw/`、`reports/`、`wiki/` を維持するのが中核。

NotebookLMは置き換えではなく、重い資料や大量の外部情報を扱う補助レイヤーとして使う。本文全文、PDF、長いTranscript、書籍、配布資料はGoogle DriveやNotebookLM側に置き、Gitには軽い索引、要約、判断メモだけを残す。

## 既存メモとの重複判断

- [[reports/source-summaries/2026-06-22-youtube-obsidian第二の脳|Obsidian第二の脳 要約]] とテーマは近い。
- 既存メモはObsidian運用の基礎が中心。
- 今回のメモは「NotebookLMを外部知識倉庫として組み合わせる判断」に焦点があるため、新規要約として残す。

## 今後の運用に反映すること

- Codexに毎回全文を読ませる必要があるかを確認する。全文が重い場合はDrive/NotebookLMへ寄せ、Gitには要約と判断だけ残す。
- NotebookLMを使う場合でも、最終的な運用ルールや反省は `reports/` と `wiki/` に残す。
- 重要資料は「どこに原本があり、Gitには何を残したか」を索引に明記する。

## 注意

この要約は動画の文字起こしDocsをもとにした整理であり、NotebookLMやCodexの公式仕様確認ではない。機能差分や制限は、実際に使う段階で公式情報または現環境で確認する。
