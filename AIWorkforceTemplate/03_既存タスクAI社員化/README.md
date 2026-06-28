# 既存タスクの AI 社員化

既存のサブエージェント、スキル、コマンド化された作業は、AI 社員として再整理できます。

## 考え方

サブエージェント化されたタスクは、主に「実行手順」です。

AI 社員化では、それに次の情報を足します。

- その担当が何を判断するか
- 何を入力として読むか
- 何を成果物として出すか
- どこまで自動で進めてよいか
- どこで人間に確認するか
- 次の担当へ何を引き継ぐか

つまり、サブエージェントは「作業マニュアル」、AI 社員は「役割と責任を持った担当者」です。

## 変換テンプレート

```markdown
# [AI社員名]

## 元になったタスク

- 元ファイル:
- 元スキル名:
- 元の目的:

## 役割

-

## 入力

-

## 出力

-

## 判断基準

-

## 人間に確認すること

-

## 次の担当への引き継ぎ

-

## 禁止事項

-
```

## Myownproject 既存スキルの AI 社員化例

現在の `Myownproject` には、`.agents/skills/` と `.claude/skills/` に既存スキルがあります。

| 既存スキル | AI 社員化した名前 | 役割 |
| --- | --- | --- |
| `writing-docs` | ドキュメント編集者 | Remotion やツールの説明文、MDX、README を整える |
| `docs-demo` | デモ実装担当 | ドキュメント用の実演コンポーネントを作る |
| `web-renderer-test` | レンダラーテスト担当 | Web renderer のテストケースを追加・確認する |
| `add-cli-option` | CLI仕様担当 | CLI オプション追加時の仕様、実装、説明を揃える |
| `add-new-package` | パッケージ立ち上げ担当 | 新規パッケージ追加の構成と手順を担当する |
| `add-sfx` | SFX素材担当 | 効果音追加のファイル配置、命名、確認を担当する |
| `add-expert` | Experts掲載担当 | 専門家ページへの掲載情報を整える |
| `fix-dependabot` | 依存関係更新担当 | Dependabot PR の更新範囲と検証を担当する |
| `make-pr` | PR作成担当 | 差分確認、PR本文、公開前チェックを担当する |
| `pr-name` | PR命名担当 | PRタイトルや命名規則を整える |
| `video-report` | 動画分析担当 | 動画の内容確認とレポート化を担当する |

## 汎用 AI 社員との対応

既存スキルをそのまま独立社員にするだけでなく、汎用 AI 社員の下に置くこともできます。

| 汎用 AI 社員 | 取り込める既存スキル |
| --- | --- |
| `@requirements-architect` | `add-cli-option`, `add-new-package`, `fix-dependabot` |
| `@researcher` | `video-report`, `docs-demo` の事前確認 |
| `@planner` | `add-new-package`, `docs-demo`, `web-renderer-test` |
| `@creator` | `writing-docs`, `docs-demo`, `add-sfx`, `add-expert` |
| `@reviewer` | `web-renderer-test`, `pr-name`, `fix-dependabot` |
| `@formatter` | `writing-docs`, `pr-name`, `make-pr` |
| `@archivist` | `make-pr`, `video-report` |

## 使い分け

### 独立した AI 社員にする場合

次のようなタスクは、独立した AI 社員に向いています。

- 繰り返し頻度が高い
- 手順が長い
- 成果物の形式が決まっている
- 専門的な判断基準がある

例:

- `ドキュメント編集者`
- `依存関係更新担当`
- `PR作成担当`

### 汎用 AI 社員の中に取り込む場合

次のようなタスクは、汎用 AI 社員の「専門メニュー」として持たせるだけで十分です。

- たまにしか使わない
- 単独では完結しない
- 他の工程の一部として使う

例:

- `pr-name`
- `video-report`
- `add-expert`

## おすすめの次の形

Myownproject では、まず次の 5人を追加の専門 AI 社員として切り出すのが実用的です。

| AI 社員 | 元スキル | 理由 |
| --- | --- | --- |
| ドキュメント編集者 | `writing-docs` | README、手順書、記事系にも応用しやすい |
| PR作成担当 | `make-pr`, `pr-name` | GitHub 反映時のミスを減らせる |
| 依存関係更新担当 | `fix-dependabot` | 自動化と検証の境界が明確 |
| テスト設計担当 | `web-renderer-test` | レビュー担当と連携しやすい |
| パッケージ立ち上げ担当 | `add-new-package` | 新規ツール作成にも考え方を応用できる |

この 5人を `00_AI社員/` に人物カードとして追加し、必要に応じて `.claude/agents/` に技術定義を置くと、既存スキルを壊さずに AI 社員化できます。

## キャリア・教育AI仮説検証の AI 社員化

`CareerAIProject/` は、教育、AI活用、キャリア仮説を中立的に検証する専用領域です。

この領域では、汎用AI社員を次のように読み替えます。

| 汎用 AI 社員 | CareerAIProject での名前 | 主な担当 |
| --- | --- | --- |
| `@requirements-architect` | 前提確認担当 | 目的、事実、仮説、未確認事項の整理 |
| `@reviewer` | バイアス点検担当 | 商業的誘導、過度な断定、肩書き誘導の確認 |
| `@researcher` | 教育AI調査担当 | 教育AI、EdTech、AIツール、現場課題の調査 |
| `@planner` | 仮説設計担当 | キャリア案、サービス案、検証手順の設計 |
| `@creator` | 試作品作成担当 | 教材、研修案、提案書、プロンプト、記事案の作成 |
| `@reviewer` | 成果検証担当 | 教育成果、費用対効果、実現可能性、リスクの確認 |
| `@formatter` | 中立表現整形担当 | 宣伝調や断定を避けたMarkdown、資料、表への整形 |
| `@archivist` | 検証記録担当 | 実験結果、未解決事項、次回行動の蓄積 |
| `@repository-guardian` | GitHub反映保全担当 | 公開可否、Git状態、個人情報混入の確認 |

作業前には `CareerAIProject/CONTEXT.md` と `CareerAIProject/BIAS_REVIEW.md` を読み、情報商材的な誘導や未検証の断定を取り除いてから使います。
