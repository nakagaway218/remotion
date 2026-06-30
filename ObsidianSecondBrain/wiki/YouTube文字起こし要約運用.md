---
type: concept
status: active
date: 2026-06-18
topic: YouTube文字起こし要約運用
tags: [wiki, youtube, transcript, google-drive, automation, codex]
---

# YouTube文字起こし要約運用

YouTube動画の内容をObsidianSecondBrainに取り込むときは、動画そのものや文字起こし全文をGitに入れない。Google Driveに文字起こしDocsを置き、Git側には索引と要約だけを残す。

## 基本方針

- YouTube URLだけでは動画内容は読めない。
- 文字起こしDocsがGoogle Driveにあれば、Codexが本文を読み取って要約できる。
- 自動文字起こしの誤字脱字は、文脈から補正して要約する。
- 固有名詞、数値、料金、機能名は誤認しやすいので、必要なら要確認にする。
- 文字起こし全文はGitに保存しない。

## 標準フロー

```text
YouTube URLをSpreadsheetに追加
↓
文字起こしDocsをGoogle Driveに置く
↓
Spreadsheetの要約リンク列にDocs URLを入れる
↓
CodexがDocs本文を読む
↓
reports/source-summaries/ に要約を作る
↓
raw/webclip-index/ の索引から要約へリンクする
↓
必要に応じて wiki/ に昇格する
```

## Spreadsheetで使う列

最低限:

```text
追加日
動画名
ＵＲＬ
要約リンク
```

将来的な推奨:

```text
追加日
種別
タイトル
URL
Drive URL
文字起こし/本文Docs URL
要約状態
要約保存先
wiki反映
優先度
メモ
```

## 自動化できる範囲

- Driveフォルダ内のSpreadsheet検出
- 新規URLの索引作成
- Docs本文の読み取り
- 要約Markdown作成
- 索引から要約へのリンク追加
- 新規・警告・失敗時だけ通知
- コピー済みTranscriptからGoogle Docsを作成する
- 作成したDocs URLをSpreadsheetの `要約リンク` 列へ書き戻す

## まだ手動または半自動の範囲

- YouTube SummaryなどからTranscriptを取得してクリップボードへコピーする作業
- ブラウザで見ているURLを保存対象として判断する作業
- 要約からwikiへ昇格する判断

## 壊れにくい半自動フロー

YouTube Summary拡張機能のUI操作は変わりやすいため、そこは手作業に残す。コピー後はGoogle APIで処理する。

```text
new-youtube-transcript-doc-from-clipboard.cmd を実行
↓
URLと動画タイトルを入力する
↓
表示に従ってYouTube SummaryでTranscript本文をコピーし、PowerShellに戻ってEnter
↓
動画タイトルを使ったGoogle DocsがDriveフォルダに作成される
↓
Spreadsheetの追加日・動画名・URL・要約リンクが補完される
↓
通常のDrive/Sheets同期で読み取り・要約する
```

## クリップボード運用の注意

- クリップボードは1つだけなので、`.cmd`実行用コマンドをコピーするとTranscript本文は上書きされる。
- 安定運用では、`.cmd`を起動してURL・動画タイトルを入力した後、スクリプトの表示に従ってTranscriptをコピーする。
- 動画タイトルはDocsタイトルとSpreadsheetの `動画名` に使う。Docs本文には入れない。
- Transcript本文だけをDocs本文に入れる。
- 間違ってコマンド文や動画タイトルだけをコピーしている場合、スクリプトはコピーし直しを促す。

## 発展課題へ進むタイミング

- 要約が5〜10本たまったとき。
- 同じテーマの素材が複数たまったとき。
- 「どこに置くべきか」「何をルール化すべきか」で迷いが出たとき。
- Spreadsheetの管理が手間になり、状態管理やリンク補完を自動化したくなったとき。

## 関連

- [[reports/2026-06-18-youtube-transcript-automation-handoff|YouTube文字起こしとGoogle Drive同期自動化 引き継ぎ]]
- [[reports/2026-06-30-youtube-transcript-docs-workflow-fix|YouTube Transcript Docs作成フローの失敗と修正]]
- [[raw/google-drive-source|Google Drive raw保存先]]
- [[scripts/README|Google API Sync Scripts]]
