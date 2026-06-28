# AIWorkforceTemplate

Myownproject 内のいろいろな作業に応用できる、汎用 AI 社員テンプレートです。

Instagram 専用ではなく、記事作成、YouTube 台本、教材作成、資料整理、ツール改善、調査メモ作成などを、役割分担された AI チームとして進めるための型です。

## 目的

- 1人の AI に全部頼む状態を避ける
- 調査、構成、作成、レビュー、整形、記録を分ける
- 大きな構成変更でも、既存フォルダや成果物を取りこぼさない
- 中間成果物を残して、後から再開しやすくする
- Myownproject の `REQUIREMENTS_DEFINITION.md` に沿って、作業前に目的と保存設計を確認する

## まず使うファイル

| ファイル | 用途 |
| --- | --- |
| `WORKFORCE_SPEC.md` | AI 社員を使う前の小さな要件定義 |
| `00_AI社員/README.md` | 8人の役割一覧 |
| `01_会社情報/作業方針.md` | このテンプレを使うプロジェクトの目的、対象、NG |
| `01_会社情報/品質基準.md` | 成果物のレビュー基準 |
| `.claude/agents/*.md` | Claude Code が読むサブエージェント定義 |
| `.claude/commands/*.md` | Claude Code で使うコマンド雛形 |
| `03_既存タスクAI社員化/README.md` | 既存スキルやサブエージェントを AI 社員化する対応表 |
| `04_判断ガイド/README.md` | サブエージェント化、AI社員化、マルチエージェント、スキル化の使い分け |
| `05_チャット文脈保存/README.md` | コミット相当のやり取りを次回用コンテキストとして残すルール |

## 8人の汎用 AI 社員

| # | 役割 | 呼び出し名 | 得意なこと |
| --- | --- | --- | --- |
| 1 | 要件定義担当 | `@requirements-architect` | 目的、入力、出力、確認点、保存設計を固める |
| 2 | 調査担当 | `@researcher` | 既存ファイル、資料、リンク、メモから材料を集める |
| 3 | 構成担当 | `@planner` | 記事、台本、教材、ツール改善の骨組みを作る |
| 4 | 作成担当 | `@creator` | 本文、台本、問題文、README、手順書などを作る |
| 5 | レビュー担当 | `@reviewer` | 抜け、矛盾、品質、リスクを確認する |
| 6 | 整形担当 | `@formatter` | Markdown、表、ファイル構成、納品形式に整える |
| 7 | 記録担当 | `@archivist` | 成果物、未解決事項、次回引き継ぎを残す |
| 8 | 構造保全担当 | `@repository-guardian` | ブランチ、必須フォルダ、移動・削除リスクを確認する |

## 標準フロー

```text
@requirements-architect
  -> @repository-guardian
  -> @researcher
  -> @planner
  -> @creator
  -> @reviewer
  -> @repository-guardian
  -> @formatter
  -> @archivist
```

すべてを毎回使う必要はありません。小さい作業なら `@requirements-architect` と `@creator` だけでも十分です。

## Claude Code での使い方

このフォルダを目的の作業フォルダにコピーし、必要に応じて名前を変えます。

```powershell
Copy-Item -Recurse .\AIWorkforceTemplate .\YourProjectWorkforce
```

その後、Claude Code でそのフォルダを開きます。

```powershell
cd .\YourProjectWorkforce
claude
```

最初は次の順番がおすすめです。

```text
/ai要件定義 作りたいものや進めたい作業
/ai構造保全チェック
/aiタスク分解
/ai成果物レビュー
/ai構造保全チェック
/ai引き継ぎ
```

## Myownproject でのおすすめ用途

- `Webarticle`: 調査、構成、本文、SEOチェック、出典整理
- `Scenariowriting`: リサーチ、あらすじ、台本、対話化、チェック
- `Learner`: 教材要件、問題作成、解答、難易度レビュー、印刷形式
- `Mytool`: ツール要件、実装手順、README、テスト観点
- `MyConversion`: 変換手順、再現手順、成果物チェック
- `.agents/skills` や `.claude/skills`: 既存のスキル型タスクを AI 社員カードに変換
- `CareerAIProject`: 教育・AI活用・キャリア仮説の中立的な検証、バイアス点検、プロンプト蓄積

## 大きな変更の保全ルール

サブエージェント化、テンプレート反映、フォルダ再編、ブランチ切り替えを含む作業では、作業前後に `@repository-guardian` を使います。

確認すること:

- 現在のブランチ名と `git status`
- 作業前に存在していた主要フォルダ
- 別ブランチにだけ存在するフォルダ
- 削除、移動、リネームされたファイル
- 未追跡ファイルを誤って置き去りにしていないか

特に `Studymaterials`、`Learner`、`Rikei_Kokkoritsu_Juken_Learner`、`Webarticle`、`Scenariowriting`、`Mytool`、`teaching materials` のようなユーザー所有フォルダは、構成変更の前後で所在を確認します。

## 注意

- API キー、個人情報、案件固有の秘密情報は保存しないでください。
- 生成物を GitHub に入れるかどうかは、作業ごとに判断してください。
- 調査結果や外部出力は、事実と推測を分けて記録してください。
- 大きな作業では、いきなり作成せず `WORKFORCE_SPEC.md` を先に埋めてください。
