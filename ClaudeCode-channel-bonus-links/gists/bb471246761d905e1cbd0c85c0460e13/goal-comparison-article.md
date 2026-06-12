# `/goal` 完全ガイド ― Codex と Claude Code、自律ループ時代の標準語彙

> **対象読者**: AI コーディングエージェントを触り始めた人〜中級者
> **更新日**: 2026-05-15
> **キーワード**: `/goal`, Claude Code, Codex CLI, Ralph Loop, 自律エージェント, Stop hook, agent view, GoalBuddy, Goal4

---

## 目次

1. [はじめに：なぜ 2026 年は「自律ループ元年」なのか](#1-はじめに)
1.5. [`/goal` を 1 行で説明するなら ― 「お願い」ではなく「完了条件」](#15-goal-を-1-行で説明するなら--お願いではなく完了条件を置くコマンド)
2. [`/goal` とは何か ― Ralph Loop の OS 化](#2-goal-とは何か)
3. [内部メカニズム ― 二人三脚モデル](#3-内部メカニズム)
4. [Claude Code `/goal` 完全解剖](#4-claude-code-goal-完全解剖)
5. [Codex `/goal` 完全解剖](#5-codex-goal-完全解剖)
6. [機能比較表 ― 同じ名前、違う思想](#6-機能比較表)
7. [実機検証 ― Settlers of Catan クローンバトル](#7-実機検証)
8. [3 本の解説動画から拾った現場の知見](#8-3-本の解説動画から拾った現場の知見)
9. [使い分け戦略マトリクス](#9-使い分け戦略マトリクス)
10. [GoalBuddy / Goal4 ― ゴール書きをスキャフォールドする](#10-goalbuddy--goal4)
11. [ハマりどころと安全運用](#11-ハマりどころと安全運用)
12. [コピペで使えるプロンプト集](#12-コピペで使えるプロンプト集)
13. [動画解説の構成テンプレート](#13-動画解説の構成テンプレート)
14. [まとめ ― これから `/goal` をどう使うか](#14-まとめ)
15. [参考リンク](#15-参考リンク)

---

<a id="1-はじめに"></a>

## 1. はじめに：なぜ 2026 年は「自律ループ元年」なのか

2026 年春、AI コーディングの世界に **同じ名前の同じ機能** が前後して投入された。OpenAI の Codex CLI が `rust-v0.128.0`（4 月 30 日リリース）で `/goal` を実装し、その約 2 週間後に Anthropic の Claude Code もハーネスに `/goal` を組み込んだ。両者は、独立した実装でありながら、コマンド名・基本コンセプト・使い方まで驚くほど似通っている。

これは偶然ではない。X や GitHub で 2025 年から流行していた **「Ralph Loop」** ―― エージェントに完了条件を渡し、満たすまで自走させるパターン ―― が、ついに **公式機能として OS レベルに焼き付けられた瞬間** である。

ある事例では Codex `/goal` を使って **6 時間 44 分の自律的な開発セッション** を回したという報告がブログで共有された。海外の解説者 Robo Nuggets 氏は「14 時間オーバーナイトの活用例」「最長 5 日連続走行のセッション」を紹介している。45 時間ぶっ通しのセッションを X に投稿するユーザーすら現れた。

「AI エージェントに **夜寝てる間** に仕事させる」というかつては妄想だった運用が、`/goal` 一行で現実になりつつある。

この記事では、Claude Code と Codex の `/goal` を **公式ドキュメント・現場の解説動画・実機ベンチマーク** をベースに徹底比較する。最後に、自分のプロジェクトでどちらをどう使い分けるかの実用的なマトリクスと、コピペで動くプロンプト集を付ける。

---

## 1.5. `/goal` を 1 行で説明するなら ― 「お願い」ではなく「完了条件」を置くコマンド

X で `/goal` 解説を投稿した **AI 駆動塾（@L_go_mrk）** の言い回しが、初心者に刺さる定義として優れているので拝借する：

> **「`/goal` は『お願い』ではなく『完了条件』を置くコマンド」**

普通のプロンプトは「**この記事を書いてください**」「**このエラーを直してください**」と **動作を依頼** する。`/goal` は、その作業が「**終わったと判断できる条件**」を先に置く。

| 普通のプロンプト | `/goal` の条件文 |
|---|---|
| 「記事を書いて」 | 「指定ファイルに 5 章構成の下書きを書き終え、禁止語チェックが 0 件になったら完了」 |
| 「テストを直して」 | 「`npm test` が exit 0 になったら完了」 |
| 「リサーチして」 | 「research_*.md に出典 URL が 10 個以上あり、各 URL に 3 行以上の要約が付いたら完了」 |

この **視点の転換** が決定的に重要だ。長い作業を AI に頼むと、必ず途中で最初の目的が薄れる ―― 記事を書いていたのに調査だけが深くなったり、リファクタを頼んだのに別の改善まで広がったり。

これは AI が悪いのではなく、長い会話の性質である。直近のエラー、ファイル、会話に反応しているうちに、最初に決めた目的から少しずつズレる。これまでは **人間が手で引き戻していた** ―― `/compact` で会話を圧縮する、`/clear` で切り直す、「最初の目的に戻ってください」と再プロンプトする。どれも必要な操作だが、長い作業ほど監督コストが増えた。

`/goal` は、この **「引き戻し作業」を機械化** する専用コマンドだ。セッションに目標を留めておき、ターンごとに達成判定を走らせる。人間が毎回「まだ終わっていません」と言わなくても、AI 側が完了条件へ向けて続ける。

### 1.5.1 非エンジニアにとっても実務寄り

`/goal` はエンジニア専用ではない。明確なゴールはあるが工程が長い作業 ―― **記事執筆、リサーチ、画像セット作成、投稿バッチ作成** ―― すべてが対象になる。

良い条件文とは「**終わった雰囲気**」ではなく、「**何を見れば終わりと言えるか**」を書くことだ。

- ❌ 「いい感じの記事ができたら」
- ✅ 「`記事/2026-05-14_*.md` に 5 章構成の下書きが書き終わり、文字数が 4,000 字以上、指定した禁止語 2 語が 0 件になったら」

具体的なプロンプト例は [12 章](#12-コピペで使えるプロンプト集) にまとめてある。

---

<a id="2-goal-とは何か"></a>

## 2. `/goal` とは何か ― Ralph Loop の OS 化

### 2.1 一言定義

> **`/goal`**：完了条件（condition）を 1 行入力すると、その条件が満たされるまで AI が **自分でターンを繰り返し** 続ける、セッション内ループ起動コマンド。

普通のチャットでは、1 ターンの応答が終わるたびに **ユーザーが次のプロンプト** を打つ必要があった。`/goal` を使うと、その「次のプロンプト」を **AI 自身（あるいは別の評価モデル）** が自動で生成・投入するので、ユーザーは寝ていて構わない。

### 2.2 Ralph Loop との関係

「Ralph Loop」は、`The Simpsons` のキャラクター Ralph Wiggum をモジった愛称で、2025 年に X で広まったパターンである。素朴な要約は次の通り：

```
while not GOAL_MET:
    fresh_context()
    run_agent()
    check(GOAL_MET)
```

各イテレーションを **新しいコンテキストウィンドウ** で走らせ、外部ファイルに状態を退避させながら、暴走を防ぎつつ長時間走らせるパターンだ。Claude Code でも `claude-wiggum`（Ralph プラグイン）として実装が出回っていた。

`/goal` はその発想を **公式機能** に取り込んだものだが、設計上の違いがある：

| | Ralph Loop（外部ループ） | `/goal`（内部ループ） |
|---|---|---|
| コンテキスト | 毎回フレッシュ（汚染回避） | **同一セッション継続**（履歴蓄積） |
| 状態管理 | 外部ファイル（goal.md, state.yaml など） | セッション内の会話履歴 |
| カスタマイズ性 | 高（コードを自分で書ける） | 公式提供分のみ |
| 暴走耐性 | 高（毎回リセット） | 条件文の精度に依存 |

つまり **「Ralph Loop は外部の振り子」「`/goal` は内部の機関銃」** という棲み分けで、用途によって使い分けることになる。

### 2.3 何が「向く」作業か

公式・現場の声を総合すると、`/goal` が真価を発揮するのは：

- **完了条件が機械判定できる** タスク
  - 「テストが全部 green」「lint clean」「ビルド exit 0」
- **複数ターンに分散しないと終わらない** タスク
  - 大規模リファクタ、ライブラリ移行、コードベース横断的な変更
- **目的の達成度合いに段階がある** タスク
  - issue キューを潰す、設計ドキュメントの acceptance criteria を埋める
- **長時間走らせて構わない** タスク
  - ベンチマーク、評価ハーネスの実行、コンテンツの大量生成

逆に向かないのは：

- **1 ターンで終わる** 単純なタスク → 過剰
- **完了の判定が主観的** なタスク（「いい感じにして」） → 評価がブレる
- **副作用が大きい・取り返しがつかない** 操作（本番デプロイ、課金、メール送信） → 自走させると怖い

---

<a id="3-内部メカニズム"></a>

## 3. 内部メカニズム ― 二人三脚モデル

両ハーネスとも、内部構造は **「メインの作業 AI + 軽量の評価 AI」** の二人三脚で構成されている。これが Ralph Loop よりも公式機能としてシンプルな理由でもある。

### 3.1 Claude Code の場合

```
[Claude (Opus/Sonnet)]      [Stop hook]         [評価モデル (Haiku)]
       ↓                         ↓                       ↓
   1 ターン作業    →   ターン終了で発火   →   会話履歴を読んで判定
                                                         ↓
                                                  YES / NO + 理由
                                                         ↓
                                  NO → 理由を渡して次ターン開始
                                  YES → ゴール達成、ユーザーに返却
```

公式ドキュメントには明記されている：

> `/goal` is a wrapper around a session-scoped prompt-based Stop hook.

つまり Claude Code の `/goal` は **「セッション限定の Stop hook の薄いラッパー」** に過ぎない。だから自前で hook を書けば似たものは作れる。

評価モデルは **`smallFastModel`**（デフォルト Haiku）が使われる。これは「賢いがゆっくり」のメインモデルと違い、「軽くて速い」のが取り柄。判定は会話履歴に対する YES/NO 2 値分類なので、Haiku で十分なはずだが、ゆるい条件で誤判定が起きる場合は `smallFastModel` を Sonnet などに差し替える手もある。

> **プロバイダ対応**：評価モデルは **セッションで設定されているプロバイダで動く**。直接 Anthropic API はもちろん、**AWS Bedrock / Google Vertex AI / Azure Foundry** いずれの経路でも `/goal` は動作する。評価分のトークンも各プロバイダで課金されるが、Haiku クラスのため通常はメインターン消費に比べて無視できる規模になる。

### 3.2 Codex の場合

```
[Codex Main Agent (GPT-5.5)]    [app-server runtime]      [軽量 validator]
            ↓                            ↓                       ↓
        作業ターン       →  状態を server-side 永続化  →  goal 達成判定
                                         ↓
                              NO → runtime continuation で次ターン
                              YES → ゴール状態を completed に
```

Codex の特徴は **「app-server APIs」と「runtime continuation」** という 2 つのキーワード。これにより：

- ゴールの状態が **マシン側に永続化** される
- ネット切断・PC スリープ・Codex の再起動を挟んでも続行できる
- `/goal pause` で明示的に止めて、後日 `/goal resume` で再開できる

ただし重要なポイントとして、**Codex の評価はメインエージェントが自己判定する** 構造に近い（ドキュメントは「checkpoint discipline」と「compact status report」を強調しており、独立評価者は明示されていない）。これに対し **Claude Code は明確に別エージェントが採点** している。

> **思想の違い**：
> - Claude Code → 「**他人の目** で見てもらう」マルチエージェント協調
> - Codex → 「**本人が完了を宣言** する」モデル単体強化

### 3.3 評価モデルは「会話履歴」しか見えない

ここを誤解する人が多いポイント：

> 評価モデルは独立してファイルを読みに行ったりコマンドを実行したりは **しない**。あくまで「これまでの会話履歴に出てきたもの」だけを材料に YES/NO を出す。

つまり、テストが通ったかどうかを判定させたいなら、**メインエージェントに `npm test` を叩かせて、その結果を会話履歴に必ず残す** 必要がある。「裏でテストを実行してくれてるはず」ではダメ。

これは `/goal` を書くときの最重要原則になる。

---

<a id="4-claude-code-goal-完全解剖"></a>

## 4. Claude Code `/goal` 完全解剖

### 4.1 リリース状況と要件

- **ステータス**：GA（正式機能）
- **必要バージョン**：Claude Code v2.1.x 以降（アップデート時に自動で利用可能）
- **要件**：
  - Workspace の **trust 受諾済み**（hooks 機能の前提）
  - `disableAllHooks=true` が立っていないこと
  - `allowManagedHooksOnly=true` がマネージド設定に立っていないこと
- 上記が不可の環境では `/goal` が **理由付きで** 拒否される（黙って失敗しない）

### 4.2 コマンド体系

| コマンド | 効果 |
|---|---|
| `/goal <条件文>` | 新規ゴール設定、即座に 1 ターン目スタート |
| `/goal`（引数なし） | 現在のステータス確認（条件・経過時間・ターン数・トークン・直近理由） |
| `/goal clear` | ゴールを解除 |
| `/goal stop` / `/goal off` / `/goal reset` / `/goal none` / `/goal cancel` | 上記の alias |
| `/clear` | 通常のセッションクリア（ゴールも一緒に消える） |

条件文は **最大 4,000 文字**。1 セッションに 1 ゴールしかアクティブにできない（新しい `/goal` で上書き）。

> ### ⚠️ 勘違い注意 ― Claude Code の `/goal` には pause / resume は **ない**
>
> Codex `/goal` には `/goal pause` と `/goal resume` という一級コマンドがあるが、**Claude Code の `/goal` にはこれらは存在しない**。
>
> Claude Code 側の `/goal stop` / `/goal off` / `/goal reset` / `/goal none` / `/goal cancel` は **すべて `/goal clear` の同義語** であり、「一時停止して後で再開」ではなく **「完全にゴールを解除」** する動作になる。
>
> 「途中で止めて、明日続きから」みたいな運用をしたい場合は：
> - Claude Code → `/goal clear` ではなく **セッション自体を残して `--resume` / `--continue`** で復元（条件と進行は残るが、ターン数 / タイマー / トークンベースラインはリセット）
> - Codex → そのまま `/goal pause` → 後日 `/goal resume`
>
> ここを取り違えると「Claude で `/goal stop` したら全部消えた！」という事故になる。動画の解説でも明確に分けて伝えるのが親切。

### 4.3 ステータス表示

ゴール実行中は画面に `◎ /goal active` インジケータが表示され、ホバーで経過時間が見える。`/goal`（引数なし）で出る詳細：

- 条件文
- 経過時間
- 評価済みターン数
- 累計トークン消費
- 評価モデルの最新「理由」

ゴール達成後も、セッション中はステータスに「achieved」として残る。

### 4.4 セッション復元

- `claude --resume` または `claude --continue` で **未達成のゴールは復元される**
- ただし **ターン数・タイマー・トークンベースラインはリセット**
- 達成済み・clear 済みゴールは復元されない

### 4.5 ヘッドレス（非対話モード）

```bash
claude -p "/goal CHANGELOG.md has an entry for every PR merged this week"
```

`-p` モードで `/goal` を渡すと、**ゴール達成までその場でブロッキング実行** される。CI に組み込みやすい設計だ。`Ctrl+C` で中断可能。

### 4.6 agent view（`claude agents`）との連携

これが Claude Code 側の **隠れ強み**。

```bash
claude agents --permission-mode plan --model opus --effort high
```

を起動すると、agent view UI が立ち上がる。ここで：

- 入力欄に `/goal <条件文>` を直接打つと、**バックグラウンドセッション** として `/goal` 駆動の作業がスタート
- 複数の `/goal` セッションを **並列に走らせられる**
- 各セッションの状態（Working / Needs input / Ready for review / Completed）が一画面で見られる
- `Space` で peek、`Enter` で attach、`←` で detach

つまり **「`/goal` を 5 個並列に走らせて、寝る前に放置」** という運用が公式機能だけで可能。Robo Nuggets 氏が紹介した「週末にトークンを使い切る」テクニックも、この組み合わせで実現する。

### 4.7 効くコンディションの 3 部品（公式ガイドライン）

長期ゴールが破綻しない条件文の書き方として、公式ドキュメントは 3 つの要素を挙げる：

1. **One measurable end state（測定可能な単一の最終状態）**
   - テスト結果 / ビルド exit コード / ファイル数 / 空のキュー
2. **A stated check（証明方法の明示）**
   - 「`npm test` exits 0」「`git status` is clean」
3. **Constraints that matter（守るべき制約）**
   - 「他のテストファイルは変更しない」「依存関係を追加しない」

加えて、**ターン上限 / 時間上限** を条件文に書き込むのが推奨されている：

> `or stop after 20 turns` を末尾に付けると暴走を防げる。

### 4.8 Claude Code `/goal` の制約まとめ

| 制約 | 値・内容 |
|---|---|
| 条件文の長さ | 4,000 文字まで |
| 1 セッション内のゴール数 | 1 つだけ（上書き） |
| 永続性 | セッション内のみ、`--resume` で復元可 |
| 評価モデル | `smallFastModel`（デフォルト Haiku、変更可） |
| 評価対象 | **会話履歴のみ**（ファイル直接読まない） |
| 動作環境 | trust 受諾済み workspace、hooks 有効必須 |
| 課金 | 評価分は smallFastModel に微小、メインはターンごと通常通り |

---

<a id="5-codex-goal-完全解剖"></a>

## 5. Codex `/goal` 完全解剖

### 5.1 リリース状況と要件

- **ステータス**：実験的機能（feature flag の後ろ）
- **必要バージョン**：Codex CLI `rust-v0.128.0`（2026 年 4 月 30 日リリース）以降
- **重要**：デフォルトでは **コマンドが認識すらされない**。`config.toml` で明示的に有効化する必要がある

### 5.2 セットアップ（ここで詰まる人が多い）

`~/.codex/config.toml` を開き（無ければ作る）、以下を追記：

```toml
[features]
goals = true
```

または CLI 内で：

```text
/experimental
```

を実行して `goals` フィーチャをトグルする。

これをやらずに `/goal hello` と打つと、Codex は「unknown command」扱いで何も起きない。動画で解説するなら **このステップは必ず実演** したほうがよい。

### 5.3 コマンド体系

| コマンド | 効果 |
|---|---|
| `/goal <objective>` | 新規ゴール作成、開始 |
| `/goal` | ステータス確認 |
| `/goal pause` | 一時停止（ここが Claude Code との差別化ポイント） |
| `/goal resume` | 一時停止からの再開 |
| `/goal clear` | ゴール解除 |

### 5.4 persisted workflows と runtime continuation

リリースノートの一節：

> Added persisted `/goal` workflows with app-server APIs, model tools, runtime continuation, and TUI controls for create, pause, resume, and clear

これが Codex `/goal` の **最大の差別化機能**。`app-server` がマシン側でゴール状態を永続化するので：

- ノート PC を閉じる → 翌日開く → `/goal resume` で続行
- Codex CLI を完全にアップデート → バイナリ入れ替え後も状態は残る
- ネットワーク切断 → 復旧後に runtime continuation で復帰

> 海外の Tecton & Tide ブログには **「6 時間走らせて 5 時間停止、その後復帰して続行できた」** という事例レポートがある。

### 5.5 TUI コントロール

CLI 内でゴールが active になると：

- ターミナルタイトルに **「action required」** マーカー
- `/statusline` がゴール進行状況に切り替わる
- `/title` でゴール名を編集可能
- **plan-mode nudges**：途中でチェックポイントを提案してくる

つまり、**長時間走らせる前提で UI 設計されている**。

### 5.6 公式ベストプラクティス（developers.openai.com より）

OpenAI 自身が示すゴール作成の 4 原則：

1. **Be explicit about "done"**
   > "Codex should know what 'done' means before it starts."
2. **Checkpoint over iteration**
   > 検証可能なステージに分け、各段階で短い進捗ログを残す
3. **Trust through clarity**
   > 各ターンで「現在のチェックポイント / 検証済み項目 / 残作業 / ブロッカー」を簡潔に報告
4. **Tighten, don't patch**
   > 走らせて挙動がおかしいときは、ad-hoc な追加指示ではなく **ゴール定義そのものを締め直す**

### 5.7 公式が示すスターターテンプレート

```
/goal Complete [objective] without stopping until [verifiable end state].
```

具体例：

```
/goal Migrate this project from [legacy stack] to [target stack].
Verify visually using playwright interactive.
```

```
/goal Implement PLAN.md, creating tests for each milestone and
verifying output with playwright interactive.
```

```
/goal Optimize prompts in [file] until eval suite reaches [target score].
Run [eval command] after each change, inspect failures, keep edits minimal.
```

### 5.8 Codex `/goal` の制約まとめ

| 制約 | 値・内容 |
|---|---|
| 有効化 | `config.toml` で `goals = true` 必須 |
| 永続性 | **マシン側に永続化、再起動を跨ぐ** |
| pause/resume | **一級コマンド** |
| 評価 | メインエージェント主導の自己判定 + validator |
| 並列実行 | 複数ゴール並列はまだ未整備 |
| 上限 | 明記なし（実質はトークン予算とレート制限） |
| 動作環境 | full-auto モード推奨（`codex --approval-mode full-auto`） |

---

<a id="6-機能比較表"></a>

## 6. 機能比較表 ― 同じ名前、違う思想

両者の違いを一望できる詳細比較表：

| 観点 | Claude Code `/goal` | Codex `/goal` (v0.128.0) |
|---|---|---|
| **リリース状態** | GA（正式機能） | 実験フラグ（要オプトイン） |
| **必要バージョン** | Claude Code v2.1.x+ | Codex CLI rust-v0.128.0+ |
| **有効化手順** | アプデのみ | `~/.codex/config.toml` 編集 |
| **判定主体** | 別エージェント（Haiku） | メインエージェント自身 |
| **思想** | マルチエージェント協調 | 単体モデル強化 |
| **永続化** | セッション内のみ（`--resume` で復元） | **マシン側永続化** |
| **pause/resume** | 明示的 pause なし | **一級コマンド** |
| **並列実行** | `claude agents` で複数同時走行 | 単発（複数並列はまだ未整備） |
| **ヘッドレス** | `claude -p "/goal ..."` | `codex --approval-mode full-auto` |
| **ステータス UI** | `◎ /goal active` インジケータ + 詳細表示 | TUI コントロール + action-required title |
| **チェックポイント** | 評価モデルの「理由」をターンごと表示 | plan-mode nudges |
| **評価対象** | 会話履歴のみ | 同左（明示なしだが同様） |
| **条件文上限** | 4,000 文字 | 明記なし |
| **評価モデル変更** | `smallFastModel` で差し替え可 | 不可（内部 validator） |
| **暴走対策** | 条件文に「max N turns」を書く | plan checkpoint + pause |
| **課金** | 評価分は smallFastModel に微小 | validator は軽量 |
| **agent view 連携** | ◎（バックグラウンド並列） | TUI のみ |
| **公式ドキュメント** | code.claude.com/docs/en/goal | developers.openai.com/codex/use-cases/follow-goals |

### 6.1 設計思想の対比（深掘り）

Claude Code は **「複数の役割を持つエージェントが協調する」** 方向に拡張している。`/goal` でも別の評価モデルが採点、`claude agents` で複数セッション並列、`agent teams` で互いにメッセージしあう、というように **役割分担** が一貫した思想。

Codex は **「単体のモデルが粘り強く完了まで走り抜く」** 方向。`/goal` の永続化、pause/resume、長時間走行の事例が前面に出ているのもこの思想の表れ。app-server で状態を持つことで、モデル単体の能力を最大限引き出す土俵を整える、というアプローチ。

> どちらが優れているかではなく、**「他人の目を借りる Claude」「自分の意志で走り抜く Codex」** という性格の違いとして捉えるとよい。

---

<a id="7-実機検証"></a>

## 7. 実機検証 ― Settlers of Catan クローンバトル

海外の解説者 Robo Nuggets 氏が実施した head-to-head ベンチマークが秀逸なので紹介する。

### 7.1 お題

> **Build me a single-file Settlers of Catan clone.**
> - **テーマ**: Game of Thrones
> - **スタイル**: 32-bit pixel art
> - **4 派閥**: Anthropic / Google / OpenAI / xAI にリスキン
> - **モード**: 1 人プレイ vs 3 体の AI bot

### 7.2 共通プラン作成

両ハーネスとも、まず **plan-for-goal** スキルで仕様書（plan.md）を作成：

- Stack
- In scope / Out of scope
- Constraints
- Definition of done
- Acceptance criteria
- Verification 方法
- **Turn budget**（このタスクは unlimited で実施）
- Risks / Open questions

その上で `/goal Execute this plan in <plan file>` を実行。

### 7.3 結果

| 観点 | Claude Code (Opus 4.7) | Codex (GPT-5.5) |
|---|---|---|
| **完了時間** | **13 分 5 秒** | 33 分 |
| **ビジュアル** | シンプル（画像生成なし） | リッチ（GPT image 2 で生成） |
| **ゲーム機能** | 動作良好 | 動作するが UX に粗 |
| **特徴的な動き** | 各派閥に AI ラボの個性を描写（"Anthropic: honest, helpful, harmless" など） | アセット生成はしたが盤面に反映できず |

### 7.4 知見

- **速度面では Claude Code が有利**（画像生成しない分シンプル）
- **ビジュアル面では Codex が有利**（GPT image 2 統合）
- どちらも **acceptance criteria の精度が結果を左右** ＝ ゴール定義が最重要
- 「アセットを作っても盤面で使わない」のような **指示不足ポイント** は、plan の段階で潰す必要がある

> 教訓：`/goal` を走らせる前に **plan.md の definition of done と acceptance criteria を徹底的に詰める** のが結果を分ける。

---

<a id="8-3-本の解説動画から拾った現場の知見"></a>

## 8. 3 本の解説動画から拾った現場の知見

### 8.1 ポスまさ氏「Claude Code に新コマンド `/goal` が登場」

- Claude Code の `/goal` は **Stop hook の薄いラッパー**
- 判定モデルは **デフォルト Haiku** だが、`smallFastModel` で Sonnet に変えられる
- Haiku は **ハルシネーション少ないが賢さは控えめ** → 条件が緩いタスクで Sonnet 切り替えが有効
- **コンディション 3 要素**（end state / 証明手段 / 不変条件）を意識すると失敗しにくい
- ラルフループとの違い：
  - **ラルフループ = 外部ループ**（毎回フレッシュなコンテキスト、状態は外部ファイル、コンテキスト汚染回避）
  - **`/goal` = 内部ループ**（同一コンテキストで継続）
- **GoalBuddy（`npx goalbuddy`）** を組み合わせると目標ドリフト防止
- 「**目標ドリフト**」＝ 自分のやりたいことと実際のエージェント動作のズレ。これを防ぐ仕組みの有無が運用品質を分ける

### 8.2 ポスまさ氏「Codex の `/goal` を徹底解説」

- 「ラルフループとアイデアは似ているが、細部の仕様が違う」
- ある事例で **6 時間 44 分の自律開発** を達成、ブログで共有
- 単発タスクには過剰、**ハーネスが仕上がってからのロングラン** が最適
- **「夜寝てる間にリファクタやテスト追加」** が推奨用途
- Codex `/goal` は **同一コンテキストウィンドウで走り続ける**（ラルフはフレッシュ）
- **Goal4 スキル** 紹介：
  - Codex 用、git curl で導入
  - ユーザーのラフアイデアを spec.md / goal.md に変換
  - ハードゲート（hard gate）で品質を担保
- 「**プランにトークンをかける**」のが品質の鍵

### 8.3 Robo Nuggets 氏「The Future of AI Agents Just Arrived」

- 「Codex が先行し、Anthropic が 2 週間後に **コピー** した」（中立な評価）
- 「**ユーザーの選択肢が増えるから良いこと**」
- 事例：
  - 14 時間オーバーナイトセッション
  - 45 時間ぶっ通し走行
  - 最長 5 日連続のセッション
- 実用パターン：
  - **週次レート制限が切り替わる前にトークンを使い切る** 用途
  - **ニュースレター 4 本を 8 分で一括生成** など、確実に消化する作業に充てる
- Catan クローンの head-to-head（前章参照）
- 結論：「**definition of done と acceptance criteria の精度がすべて**」

---

<a id="9-使い分け戦略マトリクス"></a>

## 9. 使い分け戦略マトリクス

実務での選択肢を整理する：

| シチュエーション | 推奨ハーネス | 理由 |
|---|---|---|
| 短〜中時間で品質重視のリファクタ | **Claude Code `/goal`** | Opus の品質 + 別エージェント評価で精度高い |
| 数時間〜数日のロングラン、中断耐性必須 | **Codex `/goal`** | 永続化 + pause/resume で安全 |
| 並列に 5〜10 個のタスクを走らせたい | **Claude Code `/goal` + agent view** | 公式 UI で並列管理可能 |
| 寝てる間に大規模ベンチマーク | **Codex `/goal` + full-auto** | 復帰耐性 + 長時間特化 |
| issue キューを潰す | **Claude Code `/goal`** | 別エージェントが「キューが空か」を客観判定 |
| コード移行（巨大スタック切替） | **Codex `/goal`** | plan-mode nudges + checkpoint discipline |
| プロンプトの eval スコア最適化 | どちらでも OK | スコア比較を会話履歴に出せば判定可能 |
| 画像アセットを含むプロトタイプ | **Codex `/goal`** | GPT image 2 統合の利点 |
| CI に組み込みたい | **Claude Code `/goal` (-p mode)** | ヘッドレスが完成度高い |
| チームで承認チェックポイントを挟む | **Codex `/goal`** | plan-mode nudges + pause で停止できる |

### 9.1 「両方持つ」が現実解

著者の見立てでは、**両方を契約しているユーザーは両方使うべき**。タスクの性質によって決定的に強みが違うので、`/goal` のどちらか一方で済ませようとすると損をする。

> **目安**：「**短期高品質は Claude、長期粘着は Codex**」と覚えておく。

---

<a id="10-goalbuddy--goal4"></a>

## 10. GoalBuddy / Goal4 ― ゴール書きをスキャフォールドする

`/goal` の最大の罠は **「条件文を雑に書くと自走が破綻する」** こと。これを系統的に避けるためのスキャフォールド・ツールが既に複数登場している。

### 10.1 GoalBuddy（Claude Code 寄り）

GitHub: <https://github.com/tolibear/goalbuddy>

```bash
npx goalbuddy
# その後 Claude Code 内で
$goal-prep
```

を実行すると：

1. ヒアリングで **目的の解像度を上げる質問** を投げてくる
2. 看板ボード形式で **タスクが並ぶ**
3. 続けて Claude Code に渡す **正確な `/goal` コマンド** を生成

生成される構造：

```
docs/goals/<name>/
├── goal.md       # 目的の宣言
├── state.yaml    # 看板状態の追跡
├── notes/        # 詳細メモ（チャット汚染を避ける）
└── subgoals/     # 子ゴール
```

エージェントの役割分担：

- **Scout**：リポジトリと現状をマッピング
- **Judge**：最大の実行可能スライスを判定
- **Worker**：作業を完了して記録

サイクル：

```
rough idea → goal prep → /goal → scout → judge → worker → receipt → verify
```

設計思想は **「safe useful slices」** ＝ 最小スコープではなく「境界が明確・検証可能・取り消し可能」な単位で進む。

### 10.2 Goal4（Codex 寄り）

Codex 用のスキルパッケージ。`git` で curl してターミナルに貼り付けるだけでグローバル領域に導入される。

呼び出し：

```text
/goal4 美しいテトリスを作る
```

すると：

1. spec.md / goal.md でアプリ構成を一緒に詰める
2. **ハードゲート（hard gate）** が品質チェックを担保
3. 仕上がった goal.md をもとに `/goal` で実行

ポイントは **「プランにトークンをかけるべし」** という思想。プロンプトに時間をかけたほうが、自走の品質が劇的に上がる。

### 10.3 自前テンプレート（最小版）

GoalBuddy や Goal4 を使わなくても、`docs/goals/<name>.md` に下記テンプレートを置くだけでも効果が大きい：

```markdown
# Goal: <名前>

## End State（達成状態）
- [ ] xxx

## Proof（証明手段）
- 実行コマンド: `npm test`
- 期待出力: exit 0, all green

## Constraints（不変条件）
- 他のテストファイルは変更しない
- 依存パッケージは追加しない

## Stop Conditions（停止条件）
- 上記 End State を満たす
- または 20 ターン経過

## Out of Scope
- UI 変更
- マイグレーション

## Notes
- 参考: docs/spec.md
```

これを Claude Code に渡して：

```text
/goal docs/goals/auth-refactor.md に書かれている End State / Proof / Constraints / Stop Conditions に従って作業を進めること。
```

とすれば、4,000 文字制限を回避しつつ詳細な条件を投入できる。

---

<a id="11-ハマりどころと安全運用"></a>

## 11. ハマりどころと安全運用

### 11.1 暴走を防ぐ 5 ヶ条

1. **必ずターン上限を入れる**
   - 「最大 20 ターンで停止」
2. **トークン予算を意識**
   - レート制限ある場合は「累計 X トークン超えたら stop」を条件に書く
3. **副作用の大きい操作は除外**
   - `git push --force`, `rm -rf`, 本番デプロイ、外部送信、課金は条件で禁止
4. **証明コマンドを必ず指定**
   - 「テスト結果を会話履歴に必ず出す」を明示
5. **ゴールが満たされたら即停止する条件を書く**
   - 「END STATE を満たしたら追加の作業をしない」

### 11.2 評価モデルあるある

- **評価モデルが甘い**：条件をもう少しタイトに（測定可能にする）
- **評価モデルが厳しすぎる**：完了をデモする手段を会話履歴に明示する
- **同じ理由でループする**：条件文に「すでに試した失敗は繰り返さない」を追加 or 一旦 clear して条件を作り直す

### 11.3 Codex 特有の注意

- **feature flag を入れ忘れる** ＝ コマンドが認識すらされない → 動画でも実演ポイント
- **pause したまま忘れる** → 翌週見たら状態が残ってる、確認の習慣を
- マシン側に状態があるので、**マシン引越し時は状態が消える**
- `/goal pause` 中もリソースは多少使う

### 11.4 Claude Code 特有の注意

- **hooks 設定が無効** だと動かない（マネージド環境では特に確認）
- **trust 受諾していない workspace** では使えない
- セッションが消えるとゴールも消える → `--resume` の習慣を
- agent view で並列走行するときは **トークン消費が並列分かかる**

### 11.5 「予算上限がない」問題（両者共通）

`/goal` は **金額ベースの自動停止機能を持たない**。これが業界共通の懸念で：

- 1 ゴールで 1 万円使った事例も報告されている
- プラン制（Claude Max $200/月、Codex Pro $200/月）であれば青天井のリスクは小さいが、レート制限消化は早い
- API 課金モデルで使う場合は **必ずターン上限 or トークン上限を条件に書く**

---

<a id="12-コピペで使えるプロンプト集"></a>

## 12. コピペで使えるプロンプト集

実際に手を動かして試すための、コピペで動くプロンプト集。

### 12.1 入門：まずは触ってみる

**Claude Code：「Hello, Goal」**

```text
/goal hello.txt というファイルを作って、中身を "Hello, Goal!" にする。
作成後に `cat hello.txt` を実行して結果を表示すること。
これが達成できたら完了。
```

**Codex：同じく**

```text
/goal Create a file `hello.txt` containing "Hello, Goal!".
After creation, run `cat hello.txt` and show the output.
Stop when verified.
```

### 12.2 テスト通すまで自走

```text
/goal test/ 配下のすべてのテストが pass で、lint も clean な状態にする。
証明手段:
- `npm test` を実行して exit 0 を確認
- `npm run lint` を実行して exit 0 を確認
不変条件:
- テストファイル自体は変更しない（src/ のみ修正可）
- 依存関係は追加しない
停止条件:
- 上記が満たされる、または 30 ターン経過
```

### 12.3 大量リファクタ（夜寝てる間用）

```text
/goal src/ 配下の全 TypeScript ファイルから any 型を排除する。
段階的に作業し、各ファイル変更後に必ず:
1. `npm run typecheck` で型エラーゼロを確認
2. `npm test` でテスト全 green を確認
3. その時点でのファイル数進捗を会話履歴に出力
を実施すること。
不変条件:
- 公開 API の型定義は変更しない
- 1 ファイル単位でコミット相当の単位で進める
停止条件:
- `grep -r ": any" src/ | wc -l` の結果が 0
- または 100 ターン経過
- または累計トークンが 200,000 を超える
```

### 12.4 issue キュー消化

```text
/goal GitHub の bug ラベル付き open issue を 1 件ずつ着手し、
各 issue に対して:
1. `gh issue view <number>` で内容確認
2. 修正実装
3. テスト追加
4. `gh pr create` で PR 作成
5. PR 番号を会話履歴に出力
を実施する。
停止条件:
- `gh issue list --label bug --state open` の件数が 0
- または 10 件処理した（時間と予算保護）
- または 50 ターン経過
```

### 12.5 ドキュメント生成

```text
/goal docs/guide/ 配下に、src/ の各モジュールに対応する解説 Markdown を生成する。
要件:
- 各 .md は対応する .ts ファイルから関数シグネチャを抽出して反映
- 使用例を含める
- 完了後に `ls docs/guide/*.md | wc -l` と `ls src/*.ts | wc -l` が一致することを確認
停止条件:
- 上記ファイル数が一致
- または 25 ターン経過
```

### 12.6 評価ハーネスの自動チューニング

```text
/goal prompts/system.md を反復改良し、`npm run eval` のスコアを 85 点以上に到達させる。
プロセス:
1. 現在のスコアを `npm run eval` で計測
2. 失敗ケースを `eval-results/failures.json` から読み込み
3. system.md を最小編集で改善
4. 再度 eval を実行、スコアと差分を会話履歴に出力
不変条件:
- system.md の文字数を 8,000 文字以下に保つ
- 既存の通っているケースを壊さない（regression なし）
停止条件:
- スコアが 85 点以上
- または 15 反復経過
- または 5 反復連続でスコア改善なし
```

### 12.7 設計ドキュメント駆動の実装

```text
/goal docs/spec/feature-x.md に書かれた acceptance criteria をすべて満たす。
プロセス:
1. acceptance criteria を 1 項目ずつ取り出す
2. それぞれに対応するテストを書く
3. 実装を進める
4. 各項目達成ごとに `[x]` チェックを spec ファイルに反映
5. 全項目達成後に `git diff docs/spec/feature-x.md` で確認
停止条件:
- spec の全項目が [x] になり、`npm test` 全 green
- または 40 ターン経過
```

### 12.8 ニュースレター大量生成（Robo Nuggets 流）

```text
/goal 直近 4 本の YouTube 動画 (videos/*.json のメタデータ参照) を題材に、
それぞれを Substack 用のニュースレターに変換する。
要件:
- skills/master-newsletter.md のスキルとトーンに準拠
- 各記事を `out/newsletters/<slug>.html` に保存
- 件名候補を 3 つずつ提案
- 本文は 800-1200 語
停止条件:
- `ls out/newsletters/*.html | wc -l` が 4 以上
- または 20 ターン経過
```

### 12.9 【非エンジニア向け】記事執筆を 5 章単位で

```text
/goal 記事/2026-05-14_goal-explainer.md に5章構成の下書きを書き終え、
- 文字数が 4,000 字以上
- 指定した禁止語2語（「すごい」「神」）が 0 件
- 各章の冒頭に H2 見出しがある
を満たしたら完了。
途中で文字数と禁止語ヒット数を会話に出して進捗報告すること。
or stop after 15 turns.
```

### 12.10 【非エンジニア向け】リサーチ＋出典整理

```text
/goal リサーチ/research_<topic>.md に
- 出典 URL が10個以上記載
- 各 URL に3行以上の要約
- 公開日が明記されているものは年月日を併記
を満たすまで作業を続ける。
各 URL について、信頼度（公式 / 一次情報 / 二次情報 / SNS）を 1 語タグ付け。
or stop after 10 turns.
```

### 12.11 【非エンジニア向け】サムネ・画像セット作成

```text
/goal 記事/assets/article-15_*.png が5枚揃い、
- 各画像のファイルサイズが200KB以上
- ファイル名が article-15_01.png 〜 article-15_05.png の形式
- 各画像について、対応する本文内の引用箇所をテキストでリスト化
を満たしたら完了。
or stop after 12 turns.
```

### 12.12 【非エンジニア向け】SNS 投稿バッチ

```text
/goal posts/queue/ に
- 今週分の 5 投稿 (.md) が存在
- 各ファイルに title / body / hashtags / scheduled_at の4フィールド
- body は 140 字以内
- hashtags は最大 3 個
- scheduled_at は来週の月〜金 09:00 にスケジュール
を満たしたら完了。
生成後に `ls posts/queue/*.md | wc -l` を実行して 5 であることを会話に出す。
or stop after 8 turns.
```

> 💡 **コツ**：非エンジニアの作業でも、「ファイルを確認して」「件数を数えて」「禁止語を検索して」のように、**判定材料を会話に出す手順** を条件文に入れること。評価モデルは会話履歴しか見ないので、これを省くと判定がブレる。

### 12.13 NLA 実験（添付画像のお題）

添付画像で言及されている NLA uncertainty/hallucination experiment 用の `/goal`：

```text
/goal docs/nla_uncertainty_hallucination_experiment.md を source of truth として、
NLA uncertainty/hallucination experiment を end-to-end で完遂する。

実行環境:
- ローカル GB10 (gx10-b55e.local) で NVIDIA Sync 経由で重い計算
- MacBook はオーケストレーション役
- scripts/gb10-*.sh を使う

段階:
1. GB10 connectivity / GPU / Docker 確認
2. 実行環境セットアップ
3. natural_language_autoencoders リポジトリの clone
4. ターゲットモデル (Qwen/Qwen2.5-7B-Instruct) と NLA AV/AR checkpoint をキャッシュ
5. data/prompts.jsonl を 120-prompt で生成 (easy/obscure/unanswerable/underspecified/private/false_premise)
6. scripts/{collect_target_outputs_and_activations,run_nla_decode,score_outputs,analyze_results}.py 実装
7. 各段階で smoke run → full 120 prompts
8. 最終アーティファクト生成:
   - outputs/target_outputs.jsonl
   - outputs/activations_prompt_final.parquet
   - outputs/nla_decodes.jsonl
   - outputs/scored_results.jsonl
   - outputs/analysis.md
   - outputs/top_unverbalized_uncertainty_cases.md
   - outputs/figures/condition_scores.png
   - outputs/figures/risk_by_nla_uncertainty.png
9. ./scripts/gb10-pull.sh で Mac に成果物を回収

不変条件:
- AGENTS.md のワークフローに従う
- 各段階で smoke run → 本実行 の順を守る
- ハードコード（injection token / template / scale factor）禁止
- SGLang は --disable-radix-cache で input-embedding requests を使う

停止条件:
- outputs/analysis.md が生成され、4 つの問い
  (NLA uncertainty が condition で変わるか / hallucination 予測性 /
   unverbalized uncertainty cases の表出 / explanation の noisy/confabulated 度合い)
  に明確に答えている
- または 80 ターン経過
- または累計トークンが 1,000,000 を超える
```

このプロンプトを `docs/goals/nla-experiment.md` に置いて、Claude Code なら：

```text
/goal docs/goals/nla-experiment.md に書いた条件に従って実行
```

Codex なら：

```text
/goal Run the experiment defined in docs/goals/nla-experiment.md
```

と短く投入する運用が現実的。

---

<a id="13-動画解説の構成テンプレート"></a>

## 13. 動画解説の構成テンプレート

動画でこの記事の内容を解説するなら、次の構成が回しやすい：

### 13.1 オープニング（30 秒）

- 「Codex と Claude Code に **同じ名前** のコマンドが立て続けに来た事件」
- 「14 時間オーバーナイト、最長 5 日、っていう自走事例も出てる」
- 「今日はこれを完全に理解して帰ろう」

### 13.2 本編 1：そもそも `/goal`（2 分）

- ホワイトボード①の図を見せる
- 「終わりの条件を書くと、満たすまで AI が勝手にループする」
- Ralph Loop との関係（ざっくり）

### 13.3 本編 2：Claude Code で動かす（3 分）

- インジケータ `◎ /goal active` を見せる
- 簡単な条件文（12.1 や 12.2）で実演
- 評価モデル（Haiku）が「No」を出して継続するシーンを見せる

### 13.4 本編 3：Codex で動かす（3 分）

- **`config.toml` 編集を実演**（ここで詰まる人を救う）
- `/goal pause` → 「ノート PC 閉じる演出」 → `/goal resume`
- 永続化の威力を視覚的に見せる

### 13.5 本編 4：比較（2 分）

- 比較表をテロップで
- 「思想の違い」を一言で：「**他人の目の Claude、自分で完走の Codex**」
- Catan ベンチマークの結果を映像で

### 13.6 本編 5：使い分け（1 分）

- 9 章のマトリクスを見せる
- 「短期高品質は Claude、長期粘着は Codex」

### 13.7 本編 6：注意点（1 分）

- 「**予算上限がない**」問題
- 必ずターン上限を入れる話
- Codex feature flag 忘れ「あるある」

### 13.8 まとめ（30 秒）

- 「`/goal` は AI 自走の **最小単位**」
- 「これからは **終わりを書く** のがプロンプトの基本になる」
- 「目標ドリフトを防ぐために GoalBuddy / Goal4 のスキャフォールドも併用しよう」

---

<a id="14-まとめ"></a>

## 14. まとめ ― これから `/goal` をどう使うか

`/goal` は、コーディングエージェントの **インターフェースを「次の指示」から「終わりの条件」へとシフト** させる転換点になる機能だ。

これまで AI を使いこなすコツが「**良い指示を書くこと**」だったとすれば、これからは「**良い終わりを定義すること**」が主役になる。終わり方が機械判定できる作業は、人間が見守る必要がない。逆に終わりが言語化できない作業は、まだ人間の領域だ。

- **Claude Code は GA・並列・他人の目で粘る** ―― 短期〜中時間の高品質仕事に強い
- **Codex は永続化・pause/resume で長期粘着** ―― 数時間〜数日の連続走行に強い
- **どちらも `/goal` で同じ名前** ―― 業界の語彙が収束し始めている
- **失敗の根本原因はほぼ「ゴール定義の精度不足」** ―― ここに時間を投下する習慣を作る

今夜試すなら、12 章のいちばん簡単なプロンプトから始めて、徐々に条件の精度を上げていくのが王道。`docs/goals/<name>.md` テンプレートを使えば、4,000 文字制限も実質回避できる。

そして最後に、最重要のアドバイスを 1 行で：

> **「`/goal` を書いた後、走らせる前に、もう一度ゴール定義を見直すこと。それが結果の 80% を決める」**

---

<a id="15-参考リンク"></a>

## 15. 参考リンク

### 公式ドキュメント
- [Claude Code `/goal` 公式](https://code.claude.com/docs/en/goal)
- [Claude Code Agent View 公式](https://code.claude.com/docs/en/agent-view)
- [Codex `/goal` 公式（OpenAI Developers）](https://developers.openai.com/codex/use-cases/follow-goals)
- [Codex CLI rust-v0.128.0 リリースノート](https://github.com/openai/codex/releases/tag/rust-v0.128.0)

### スキャフォールド / プラグイン
- [GoalBuddy（GitHub）](https://github.com/tolibear/goalbuddy)

### 解説動画
- 【日本語】Claude Code の `/goal` 解説（ポスまさ氏）: <https://youtu.be/P3P97U5CWqs>
- 【日本語】Codex の `/goal` 徹底解説（ポスまさ氏）: <https://youtu.be/ZMZ5s2DQuKo>
- 【英語】"The Future of AI Agents Just Arrived" (Robo Nuggets): <https://youtu.be/aEDq1bBynOg>

### 関連記事・SNS
- 【日本語・非エンジニア向け解説】AI 駆動塾（@L_go_mrk）「公式が語る "神コマンド" /goal のベストプラクティス」: <https://x.com/L_go_mrk>（ClaudeCode 側の `/goal` を公式情報範囲で網羅、文字数や禁止語ベースの非エンジニア向け条件例を多数提示）
- [/goal: The Six-Hour Codex Run That Survived a Five-Hour Pause (Tecton & Tide)](https://www.tectontide.com/en/blog/codex-goal-six-hour-run/)
- [Codex /goal Command: OpenAI's Built-in Ralph Loop (Ralphable)](https://ralphable.com/blog/codex-goal-command-ralph-loop-openai-built-in-autonomous-coding-agent-2026)
- [The /goal Command: Codex and Claude Code as 24/7 Agents (Apidog)](https://apidog.com/blog/goal-command-codex-claude-code-autonomous-agents/)
- [Codex /goal vs Claude Code Agents (DevToolPicks)](https://devtoolpicks.com/blog/codex-goal-command-vs-claude-code-agents-2026)

---

*本記事は 2026-05-15 時点の情報。Codex `/goal` は experimental flag のため仕様変更の可能性あり、Claude Code `/goal` は v2.1.x で GA。最新情報は各公式ドキュメントを参照。*

