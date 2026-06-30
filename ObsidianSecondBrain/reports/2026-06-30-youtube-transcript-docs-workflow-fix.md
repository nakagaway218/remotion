---
type: report
status: active
date: 2026-06-30
topic: YouTube Transcript Docs作成フローの失敗と修正
tags: [youtube, transcript, google-docs, google-sheets, automation, mistake]
---

# YouTube Transcript Docs作成フローの失敗と修正

## 背景

`AIエージェント参考YouTubeリスト` の行に対して、YouTube SummaryのTranscriptをGoogle Docsへ保存し、DocsリンクをSpreadsheetの `要約リンク` 列へ書き戻す半自動フローを作った。

目的は、手作業を次だけに絞ること。

```text
YouTube SummaryでTranscript本文をコピー
↓
.cmd 実行中にURLと動画タイトルを入力
↓
Google Docs作成、Sheets書き戻し、追加日・動画名・URL補完は自動
```

## 起きた失敗

1. `new-youtube-transcript-doc-from-clipboard.cmd` 実行用コマンドをコピーしたことで、クリップボード内のTranscriptがコマンド文に上書きされた。
2. その結果、Google Docs本文にTranscriptではなくPowerShellコマンドが入った。
3. 次に、動画タイトルだけがクリップボードに入っていた状態で実行され、Google Docs本文が動画タイトルだけになった。
4. `追加日`、`動画名`、`URL` の補完も当初は未実装または分かりにくく、行20のような整った状態にならなかった。

## 原因

- クリップボードは1つだけで、コマンドコピーやタイトルコピーで簡単に上書きされる。
- スクリプト名に `from-clipboard` とあるが、いつ・何をコピーすべきかの導線が弱かった。
- 短い本文を警告で通していたため、タイトルだけでもDocs本文として保存できてしまった。
- `N` を押した後に同じスクリプト内でコピーし直す導線がなく、ユーザーが同じ状態を繰り返しやすかった。
- 動画タイトルはDocsタイトルとB列用なのに、本文に入る可能性があるように見える案内だった。

## 修正方針

- `.cmd`実行後に、必要に応じてTranscriptをコピーし直してEnterできるループを入れる。
- クリップボードが次に該当する場合はDocs作成前に止める、またはコピーし直しを促す。
  - PowerShellコマンド文
  - 動画タイトルと同じ文字列
  - 既定200文字未満の短い本文
- 短いTranscriptは完全禁止にせず、確認して `y` なら進められるようにする。
- `N` の場合はスクリプトを終了せず、Transcriptをコピーし直してEnterで再確認する。
- 動画タイトルはDocs本文には入れず、DocsタイトルとSpreadsheetの `動画名` 列にだけ使う。
- 空欄の `追加日`、`動画名`、`URL` を自動補完する。

## 現在の推奨手順

```text
1. PowerShellで .cmd を実行する
2. YouTube URLを入力する
3. 動画タイトルを入力する
4. 「Transcript本文をコピーしてEnter」と出たらYouTube Summaryに戻る
5. Transcript本文をコピーする
6. PowerShellに戻ってEnterを押す
```

この順番なら、`.cmd` 実行用コマンドをコピーしたせいでTranscriptが上書きされる問題を避けやすい。

## 重要な区別

- 動画タイトル:
  - Google Docsのファイル名に使う
  - SpreadsheetのB列 `動画名` に入れる
  - Google Docs本文には入れない
- Transcript本文:
  - Google Docs本文に入れる
  - Gitには全文保存しない
- Docsリンク:
  - Spreadsheetの `要約リンク` 列に入れる

## 今後の注意

- `new-youtube-transcript-doc-from-clipboard.cmd` はYouTube Summary拡張機能を操作しない。Transcriptコピー自体は手作業。
- Chrome拡張UIの自動操作は壊れやすいため、今は「コピーだけ手作業、Docs作成とSheets更新はAPI」の方針を維持する。
- もし将来Chrome操作でTranscriptコピーを自動化するなら、UI変更で壊れる前提で別スクリプト・別運用として扱う。
