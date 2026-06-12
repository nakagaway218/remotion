# OpenAI 2026年6月の3大アップデート ＋ AIと作る iOSアプリ・スターターキット

> 2026年6月4日前後に OpenAI が出した **3つの新機能**を初心者向けに解説し、そのうえで「**受け取った人が AI エージェントに渡すと、対話しながら iOS アプリを作っていける**」キットにまとめたリポジトリです。
> 解説を読むだけでもOK。実際に手を動かしてアプリを作るのもOK。撮影・配布用に作成した非公式まとめです。

---

## ⚠️ この資料の読み方（確度について）

- **作成日**: 2026-06-05 時点の情報です。仕様は頻繁に変わるため、最終確認は必ず公式で。
- **確度マーク**: ✅ 公式確認済み ／ 🔶 一次情報はあるが流動的 ／ ⚠️ 未確認・推測
- 本資料は **非公式まとめ**で、OpenAI 公式とは無関係です。

## TL;DR（3行）

- 取り上げる3つ: ① **ChatGPT の新メモリ「Dreaming」**（会話をまたいで記憶を自動更新・無料ユーザーにも）／② **Codex プロフィールの刷新**（使用状況を可視化＆共有カード）／③ **Codex の iOS ビルド強化（Build iOS Apps）**。✅
- この3つは **2026年6月4日前後**の発表です（ChatGPT 側と Codex 側の別々のアップデート）。✅
- このリポジトリは解説に加えて、**AI に渡すだけで iOS アプリ作りを対話で始められる**雛形（`AGENTS.md`／`prompts/`／`app/`）を同梱しています。

## 目次

1. [このリポジトリの2つの顔](#1-このリポジトリの2つの顔)
2. [3つの最新アップデート（要約）](#2-3つの最新アップデート要約)
3. [キットの使い方（AIと作る）](#3-キットの使い方aiと作る)
4. [フォルダ構造](#4-フォルダ構造)
5. [使い方（初心者基準）](#5-使い方初心者基準)
6. [必要なもの・前提](#6-必要なもの前提)
7. [出典](#7-出典)
8. [未確認・注意事項](#8-未確認注意事項)

---

## 1. このリポジトリの2つの顔

このリポジトリは、2つの使い方ができます。

- **(A) 読む資料として**: OpenAI が2026年6月に出した3機能を、初心者向けに解説しています（`docs/`）。動画の撮影資料や、配布物としてそのまま使えます。
- **(B) 作るキットとして**: AI エージェント（Codex など）にこのリポジトリを渡すと、`AGENTS.md` の手順に沿って **あなたに質問しながら iOS アプリを一緒に作って**くれます。

> まず手を動かしたい人は [START_HERE.md](START_HERE.md) へ。読み物として知りたい人はこのまま下へ。

---

## 2. 3つの最新アップデート（要約）

### ① ChatGPT の新メモリ「Dreaming（ドリーミング）」 ✅

会話をまたいで「あなたのこと」を覚え、**時間の経過に合わせて記憶を自動更新**する新しいメモリの仕組みです。
たとえば「7月にシンガポールへ行く」という記憶を、旅行後に「2026年7月に行った」へ自動で書き換えます。✅
明示的に「覚えて」と言わなくても、会話の中の文脈を拾います。計算コストを抑えたことで、**無料ユーザーにも初めて開放**（米国の Plus/Pro から2026-06-04開始、数週間で Free/Go・他国へ拡大）。✅🔶

→ 詳細: [docs/01-chatgpt-memory-dreaming.md](docs/01-chatgpt-memory-dreaming.md)

### ② Codex プロフィールの刷新（Codex Profiles） ✅

Codex（OpenAI のコーディングエージェント）に「自分のホーム」ができました。**累計トークン・連続利用日数（ストリーク）・最長タスク・よく使う機能**などをグラフで振り返れます。
**デフォルト非公開**で、見せたいときだけ「カード」で共有できます（2026-06-04 の changelog で追加）。✅

→ 詳細: [docs/02-codex-profiles.md](docs/02-codex-profiles.md)

### ③ Codex の iOS ビルド強化（Build iOS Apps） ✅

iPhone / iPad アプリ（SwiftUI）の開発を、**コードを書く → ビルド → シミュレータで動かす → スクショ → 直す**まで Codex 内で回せるプラグイン。
SwiftUI 専門スキル（SwiftUI expert / Liquid Glass expert など）と **XcodeBuildMCP** による自動化が中心です。✅
**このキットの `app/` フォルダは、この機能を実際に使うための土台**です。

→ 詳細: [docs/03-build-ios-apps.md](docs/03-build-ios-apps.md)

> 補足: ①は ChatGPT 側、②③は Codex 側の発表で、系統は別です。この3つに絞ってまとめています。同時期には役割特化プラグインや Sites なども出ていますが、本資料の対象外です（公式 changelog 参照）。

---

## 3. キットの使い方（AIと作る）

受け取ったあなたが、AI エージェントと一緒に iOS アプリを作る流れです。詳しい入口は [START_HERE.md](START_HERE.md)。

1. **AI を用意**: Codex（iOS なら Build iOS Apps プラグインも）を開く。Claude などでも可。
2. **このリポジトリを渡す**: フォルダを開く、または `git clone`。
3. **キックオフ文を貼る**（[prompts/kickoff.md](prompts/kickoff.md)）:
   > このリポジトリの AGENTS.md を読んで、その手順どおりに進めてください。わたしはコードが分かりません。日常語で、ひとつずつ確認しながら、まず STEP 1（インタビュー）から始めてください。
4. **質問に答える**: 「どんなアプリ？」「誰のため？」に答えると、AI が仕様（`app/SPEC.md`）にまとめます。
5. **一緒にビルド**: AI が `app/` にコードを足し、シミュレータで動かして直していきます。

AI 側の動き方は [AGENTS.md](AGENTS.md) に、質問の中身は [prompts/interview.md](prompts/interview.md) に定義されています。

---

## 4. フォルダ構造

```
openai-codex-2026-06-guide-ja/
├── README.md                       # このファイル（全体の入口）
├── START_HERE.md                   # 受け取った人がまず読む3ステップ
├── AGENTS.md                       # AIエージェントへの指示（インタビュー→iOSスキャフォールド）
├── .gitignore                      # Xcode / Swift / 秘密情報よけ
├── docs/                           # 3トピックの詳しい解説（出典つき）
│   ├── 01-chatgpt-memory-dreaming.md
│   ├── 02-codex-profiles.md
│   └── 03-build-ios-apps.md
├── prompts/                        # AIに渡すプロンプト
│   ├── kickoff.md                  #   最初に貼るキックオフ文
│   └── interview.md                #   アプリ要件のヒアリング質問集
├── app/                            # ここに iOS アプリを作っていく
│   ├── README.md
│   ├── SPEC.md                     #   インタビュー後にAIが記入する仕様メモ
│   ├── project.yml                 #   XcodeGen テンプレ（{{APP_NAME}}等を置換）
│   └── Sources/
│       ├── App.swift               #   SwiftUI の入口（テンプレ）
│       └── ContentView.swift       #   最初の画面（テンプレ）
└── scripts/                        # ビルド補助（テンプレート）
    ├── README.md
    ├── bootstrap.sh                #   xcodegen でプロジェクト生成
    └── build.sh                    #   xcodebuild でシミュレータ向けビルド
```

> `app/` と `scripts/` の雛形には `{{APP_NAME}}` `{{BUNDLE_ID}}` というプレースホルダが入っています。インタビューでアプリ名が決まったら、AI が実際の値に置換します。

---

## 5. 使い方（初心者基準）

「コードもコマンドも分からない」前提で、頼み方の例を挙げます。**完璧な指示文を書こうとしないこと**が大事です。まず雑に頼んで、返ってきたものを見て会話で詰めていきます。

### こんな悩み → AI にこう言うだけ

| こんな悩み | AI にこう言う |
|---|---|
| 何から決めればいいか分からない | 「AGENTS.md の手順で、最初の質問から始めて」 |
| アプリのアイデアはあるが整理できない | 「思いつくまま話すので、質問で整理して仕様にまとめて」 |
| 専門用語が出てきて止まった | 「今の説明、やさしい言葉で言い直して」 |
| 今どこまで決まったか分からない | 「今の仕様（SPEC）を見せて」 |
| 画面が表示されない／エラーが出た | 「何が起きているか一言で説明してから直して」 |
| 欲張りすぎて進まない | 「いちばん大事な1機能だけ先に動かそう」 |

### コピペで使える最初の一言

```
このリポジトリの AGENTS.md を読んで、その手順で進めてください。
コードは分かりません。日常語で、1〜3問ずつ確認しながら進めてください。
```

> 比喩で言うと: あなたは「監督」、AI は「実働スタッフ」です。あなたは「何を作りたいか」を伝えるだけ。手順やコマンドは AI が引き受けます。

---

## 6. 必要なもの・前提

- **AI エージェント**: OpenAI Codex（推奨）。iOS を作るなら **Build iOS Apps プラグイン**も。Claude などでも設計は可能。✅
- **iOS の実ビルド**: **Mac ＋ Xcode** が必要（シミュレータを動かすため）。⚠️ クラウドだけでは完結しません。
- **ビルド自動化**: **XcodeGen**（`brew install xcodegen`）＋ `xcodebuild`。🔶（このキットの既定例。Tuist でも可）
- 準備が未完でも、**アプリの設計・相談は先に進められます**。

---

## 7. 出典

**公式（OpenAI / Apple 関連）**

- ChatGPT メモリ Dreaming: https://openai.com/index/chatgpt-memory-dreaming/
- Codex 総合: https://developers.openai.com/codex
- Codex 変更履歴（changelog）: https://developers.openai.com/codex/changelog
- Codex アプリ設定（プロフィール）: https://developers.openai.com/codex/app/settings
- Build for iOS（use-case）: https://developers.openai.com/codex/use-cases/native-ios-apps
- XcodeGen: https://github.com/yonaskolb/XcodeGen

**X（一次情報・公式アカウント）**

- @OpenAI「ChatGPT メモリ」: https://x.com/OpenAI/status/2062567556524003631
- @OpenAIDevs「Codex profiles」: https://x.com/OpenAIDevs/status/2062674774644687268
- @OpenAIDevs「Build iOS Apps plugin」: https://x.com/OpenAIDevs/status/2062599291479478275

**報道（補足・裏取り）**

- 9to5Mac（メモリの無料開放・日付）: https://9to5mac.com/2026/06/04/openai-says-chatgpts-memory-feature-is-getting-smarter-and-coming-to-free-users/
- Android Headlines（dreaming の挙動）: https://www.androidheadlines.com/2026/06/openai-chatgpt-dreaming-memory-upgrade-free-users.html

---

## 8. 未確認・注意事項

- 🔶 ChatGPT メモリの「Dreaming V3」「約5倍の省コンピュート」「容量倍増」は、公式ページ本文を直接取得できず（403）、二次情報の要約に基づきます。最終確認は公式で。
- 🔶 Build iOS Apps の「アプリ内ブラウザ表示・ホットリロード」は @OpenAIDevs 投稿が一次情報で、2026-06-04 時点の changelog 個別エントリには未掲載（公式 use-case ドキュメントで内容は確認）。
- ⚠️ `scripts/` のビルドスクリプトと `app/` の雛形は **動作確認前のテンプレート**です。アプリ名が未確定のため、そのままでは実行できません（プレースホルダ置換後に、あなたの Mac 環境で AI と検証してください）。
- ⚠️ iOS の実ビルドの成否は Xcode のバージョン・証明書・依存に左右されます。本キットは「動きます」を保証するものではなく、**作り始めるための土台**です。
- すべての仕様・提供範囲は流動的です。最終判断の前に必ず公式ドキュメントで再確認してください。

---

> 撮影・配布用の非公式まとめ。事実は出典 URL とセットで確認できるよう構成しています。誤りや古い情報に気づいたら、公式ドキュメントを正としてください。
