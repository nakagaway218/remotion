# Antigravity 引き継ぎメモ

このフォルダーは、Excel `Web記事作成.xlsx` の手順をもとにしたローカル記事作成ツールです。
Antigravity では、このフォルダーをそのまま開いて作業してください。

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Webarticle
```

## 起動方法

PowerShell または Antigravity のターミナルで実行します。

```powershell
node server.mjs
```

ブラウザーで開きます。

```text
http://localhost:4173
```

ポートが使用中の場合:

```powershell
$env:PORT="4183"
node server.mjs
```

## 標準運用

標準は **ChatGPT Plus 手動連携モード** です。

OpenAI API は標準では不要です。画面上のプロンプト作成ボタンを押して、生成されたプロンプトを ChatGPT Plus や NotebookLM に貼り付けます。回答を各ステップの保存欄へ貼り戻して次へ進みます。

工程は次の順番です。

1. 基礎知識
2. 検索意図
3. 構成
4. あらすじ
5. タイトル
6. リード文
7. 本文
8. まとめ

基礎知識工程では、専門性が高い記事のときに `情報ソース候補プロンプト` でNotebookLMに読み込ませる重要ソース候補を先に整理します。その後、`NotebookLM用プロンプト` を作成します。NotebookLMで関連記事や資料をもとにメモを作り、`NotebookLMで作成した基礎知識メモ` 欄へ貼り戻します。手元の文献・資料は `資料読込` で txt / md / csv を読み込むか、`インポートした文献・資料` 欄へ抜粋や出典メモを貼り付けます。重要情報ソースリスト、メモ、文献・資料は後続の検索意図、構成、あらすじ、本文などのプロンプトに自動で含まれます。通常の記事では空欄のまま進められます。
ラッコCSV/JSONを読み込んだ後は、`リサーチセット作成` でNotebookLMへ貼る調査依頼文と参考URL一覧を作れます。

あらすじ工程では、下書きを確認し、必要なら `修正プロンプト` で修正します。最終的に `このあらすじを採用` を押したものだけが、タイトル以降の工程に使われます。

## ラッコ連携

構成ステップでは、次のいずれかを使えます。

- `CSV/JSON読込`: ラッコキーワードで手動ダウンロードした見出し CSV または JSON を読み込む
- `ラッコGPTs用プロンプト`: ChatGPTのラッコキーワード連携GPTsへ貼るプロンプトを作る
- `GPTs結果を反映`: GPTsから返ってきたJSONまたはh2/h3テキストを構成用テキストへ変換する
- `ラッコから取得`: `RAKKO_API_KEY` を使って見出し抽出 API から取得する

通常は、APIキーをこのツールへ保存しない `CSV/JSON読込` または `ラッコGPTs用プロンプト` が扱いやすいです。
`simple` 形式のように、rank/title/url/headline が行になっているタブ区切りCSVや、UTF-16LE 形式で保存されたCSVにも対応しています。
読み込み時に、関連記事、人気記事、カテゴリー、タグ、商品一覧、SNSフォローなど、明らかなサイト共通導線は構成用テキストから除外します。

ラッコ API を使う場合:

```powershell
$env:RAKKO_API_KEY="your-rakko-api-key"
node server.mjs
```

## API生成

`API生成の詳細設定` を開いたときだけ、OpenAI API で自動生成するボタンが表示されます。

通常運用では使わなくてかまいません。使う場合は費用上限を必ず設定してください。

```powershell
$env:OPENAI_API_KEY="your-openai-api-key"
$env:OPENAI_COST_CAP_USD="1.00"
$env:OPENAI_MAX_OUTPUT_TOKENS="1200"
node server.mjs
```

使用量は `data/usage.json` に保存されます。このファイルは `.gitignore` 対象です。

## 主要ファイル

- `server.mjs`: ローカルサーバー、プロンプト作成、情報ソース候補プロンプト、API生成、ラッコ API 連携、ラッコGPTs用プロンプト
- `public/index.html`: 画面構成
- `public/app.js`: 画面操作、ローカル保存、CSV読込、ラッコGPTs結果変換、プロンプト作成
- `public/styles.css`: 画面スタイル
- `README.md`: 利用者向けの基本説明
- `ANTIGRAVITY.md`: Antigravity 作業用の引き継ぎメモ

## 変更時の注意

- 標準導線は ChatGPT Plus 手動連携です。API生成を前面に出さないでください。
- 重要情報ソースリスト、NotebookLM の基礎知識メモ、インポートした文献・資料は後続プロンプトに入ります。専門記事向けの補助工程として扱い、必須入力にはしないでください。
- 後工程は `採用するあらすじ` を参照します。あらすじ下書きだけを直接後工程に流さないでください。
- ラッコ CSV と GPTsの返答形式は揺れが出やすいため、読み込めないデータが出たら `public/app.js` の CSV判定処理またはGPTs結果変換処理を調整してください。
- API生成を変更する場合は、費用上限と `max_output_tokens` の制御を外さないでください。
- UIを増やす場合は、右側の記事下書きプレビューと重なったり、ボタン文字がはみ出したりしないように確認してください。

## 確認コマンド

```powershell
npm run check
node --check public/app.js
```

## 今後の改善候補

- ラッコ CSV の実ファイル形式に合わせた列判定の精度向上
- NotebookLMメモを読みやすく整理する補助機能
- 生成後の記事全文の文字数カウント
- 目標文字数との差分に応じた追記・圧縮プロンプト
- ChatGPT から貼り戻した本文を h2 ごとに整理する補助機能
- Markdown 以外の出力形式、たとえば Word や Google Docs 用の整形
