# AGENTS.md — Skills オンボーディング・インストーラ（エージェント向け指示書）

> **これを読んでいるAIエージェントへ。**
> ユーザーがこのリポジトリのリンクを渡して「自分の業務に必要な Skills を入れて」と言ったら、
> **このファイルの手順0〜7をそのまま実行**してください。勝手に全部入れず、必ずヒアリングして必要なものだけを、
> ユーザーの環境に合った**正しいファイル構造**へ配置します。

---

## このリポジトリは何か

- **カタログ＋インストーラ**です。skill 本体の多くは [`catalog/skills.json`](catalog/skills.json) の `source`（外部GitHub）にあります。
- `skills/` 配下の5件だけは**実体を同梱**（このリポジトリが配布元）。
- あなたの仕事は「ユーザーに質問 → 必要 skill を選定 → 安全確認 → 正しい場所へ配置 → 報告」。

---

## 手順0. まずカタログを読む

1. [`catalog/skills.json`](catalog/skills.json) を読み込む（全 skill のメタデータ）。
2. `disclaimer` と `known_renames` を必ず確認する。
   **出典記事の skill 名と実リポジトリのフォルダ名がズレている**ものがある（例: `write-a-prd`→`to-prd`、`prd-to-issues`→`to-issues`、`triage-issue`→`triage`、`request-refactor-plan`→廃止/`diagnose`・`zoom-out`）。
3. 困ったら [`catalog/catalog.md`](catalog/catalog.md)（人間可読版）も参照。

---

## 手順1. 環境判定（どこに置くか決める）

ユーザーの作業ディレクトリを調べ、どのエージェント環境かを判定する。判定材料：

| 見つかったもの | 環境 | skill の置き場所 |
|---|---|---|
| `~/.claude/` または `<project>/.claude/` | **Claude Code** | ユーザー全体: `~/.claude/skills/<id>/`<br>プロジェクト: `<project>/.claude/skills/<id>/` |
| `AGENTS.md` 階層 / `.codex/` | **Codex (OpenAI)** | [`install/install.md`](install/install.md) 参照 |
| `.cursor/` | **Cursor** | [`install/install.md`](install/install.md) 参照 |
| 上記なし | 不明 | **ユーザーに1問だけ聞く**（下記） |

- `ls -la`・glob で `.claude/` `.codex/` `AGENTS.md` `CLAUDE.md` `.cursor/` の有無を確認する。
- 判定できないときだけ聞く：「お使いのエージェントは Claude Code / Codex / Cursor のどれですか？ skill をあなた全体（~/.claude）に入れますか、このプロジェクトだけに入れますか？」
- 詳細な配置先ルールは [`install/install.md`](install/install.md) が正典。

---

## 手順2. 業務ヒアリング（必要なものだけ選ぶ）

**いきなり全部入れない。** 次を質問して候補を絞る（一度に全部聞かず、会話で1〜2問ずつ）：

1. 主な業務は？（企画・設計／資料作成／文書・記事／データ処理／コード開発／マーケ・営業／動画 など）
2. **毎日いちばん繰り返している作業**は何ですか？（最初の1個はそこに当てる）
3. 開発者ですか、非開発者ですか？（`audience: "dev"` の skill を出すか判断）
4. （手順1で未確定なら）環境と配置スコープ

ヒアリングが固まったら、業務に対応する **プリセット束**（[`profiles/`](profiles/)）を提案してよい：

| 業務 | プリセット | 中身 |
|---|---|---|
| 企画・壁打ちが多い | [`profiles/planning.md`](profiles/planning.md) | brainstorming / grill-me / write-a-prd（＋同梱 planning-sprint） |
| 資料作成が多い | [`profiles/docs-creation.md`](profiles/docs-creation.md) | pptx / theme-factory / xlsx / pdf |
| 文書・記事が多い | [`profiles/writing.md`](profiles/writing.md) | doc-coauthoring / edit-article（＋同梱 research-to-writing） |
| データ処理が多い | [`profiles/data.md`](profiles/data.md) | xlsx / pdf / docx（＋同梱 document-processor） |
| コード開発 | [`profiles/dev-baseline.md`](profiles/dev-baseline.md) | git-guardrails / setup-pre-commit / tdd / systematic-debugging / triage |

---

## 手順3. カタログ照合・候補提示

1. ヒアリング結果に合う skill を `catalog/skills.json` から抽出する。
2. `audience: "dev"` は非開発者には出さない（本人が望む場合を除く）。
3. **3〜5個に絞って**提示する。各候補について必ず示す：
   - 名前 / 何ができるか（1行）/ 出典（`source`）/ **公式か非公式か（`official`）**
4. 「全部入れる」を勧めない。出典記事の原則どおり「**各カテゴリから1つずつ、まず1個**」を基本にする。
5. 本人の YES/NO を取ってから次へ。

---

## 手順4. セキュリティ確認（**必須**・スキップ禁止）

skill は SKILL.md の指示でエージェントを動かす＝**信頼の境界**を越える。導入前に必ず：

- [ ] `source` URL が**実在**し、リポジトリがメンテされているか（最終更新・Issue の生死）を確認する。
- [ ] 取得した SKILL.md／同梱スクリプトを**目視**し、危険な挙動が無いか確認する：
  - `rm -rf`・破壊的 git（`push`/`reset --hard`/`clean`）・`sudo`
  - 認証情報や環境変数の**外部送信**（curl/fetch で外部URLへ POST 等）
  - 難読化された文字列・base64 でのコード実行
- [ ] `official: false`（非公式）は特に慎重に。怪しければ**入れずに**本人へ警告する。
- [ ] `official: true`（anthropics/skills 等）も信頼度は高いが、**中身は一度本人に提示**してから入れる。

> 出典記事も警告している：「あまり広まっていない skill を不用意に入れまくるのは危険」。
> 迷ったら入れない。これは取り消しにくい操作の一歩手前の安全ゲート。

---

## 手順5. インストール（コマンドの選び方）

`catalog/skills.json` の `install_methods` の優先順：

1. **bundled**（`bundled: true`）→ 本repoの `skills/<id>/` を `<target>/<id>/` へコピーするだけ。
2. **npx**（`install_hint` が `npx skills@latest add ...`）→ ハンドラ対応時の最短。
   ただし **`known_renames` を先に当てる**（記事の path が古い場合がある）。実行前に `source` で実フォルダ名を確認。
3. **manual_git** → `source` の SKILL.md（と同梱ファイル）を取得し、`<target>/<id>/SKILL.md` として保存。

```bash
# 例: Claude Code・ユーザー全体に grill-me を手動配置する場合
mkdir -p ~/.claude/skills/grill-me
# source の SKILL.md（とバンドル）を取得して ~/.claude/skills/grill-me/ に保存
```

- `npx` 実行は外部コードのダウンロード＋実行を伴う。**手順4の確認を通したものだけ**実行する。
- 失敗したら manual_git にフォールバックし、`source` から SKILL.md を取得して配置する。

---

## 手順6. 配置の検証

- 配置後に `<target>` を `ls -la`（または tree）で表示し、**実際のディレクトリ構造**を本人に見せる。
- 各 skill フォルダに `SKILL.md` が存在し、先頭の `---` frontmatter（`name` / `description`）が壊れていないか確認する。
- Claude Code なら、新しいセッションで skill が認識されるか（`/` で一覧に出るか）を案内する。

---

## 手順7. 報告

最後に必ず次を伝える：

- **入れた skill 一覧**（名前 / 置いた場所のフルパス）
- **入れなかったもの**と理由（dev限定だった／セキュリティ未確認／本人が見送り）
- **次の一手**：SKILL.md は自由に編集して育てるもの。本人の業務に合わせてルール/テンプレを足す。
- 出典の URL は記事時点のもの。動かない場合は `source` を再確認する旨。

---

## やってはいけないこと

- ヒアリングせず「全部入れ」する。
- 手順4のセキュリティ確認を飛ばして非公式 skill を入れる。
- `known_renames` を当てずに古い path のまま `npx` を叩いて「無い」と諦める。
- 配置先を勝手に決めて本人の既存ファイル構造を壊す。**置く前に構造を読む**。
- 出典記事のビュー数・スター数を「事実」として本人に伝える（未確認の宣伝値）。

---

## 付録: クイックスタート文（ユーザーが最初に言う想定）

> 「このリポジトリ（URL）の AGENTS.md に従って、私の業務に必要な Claude Skills を入れて。
> まず私の作業環境とよくやる業務を質問して、必要なものだけ正しい場所に配置してください。」
