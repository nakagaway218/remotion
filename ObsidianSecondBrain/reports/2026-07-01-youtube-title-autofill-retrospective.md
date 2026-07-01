---
type: report
status: active
date: 2026-07-01
topic: YouTube Transcript Docs作成フローの動画タイトル自動入力ミス
tags: [youtube, transcript, google-docs, google-sheets, automation, mistake]
---

# YouTube Transcript Docs作成フローの動画タイトル自動入力ミス

## 背景

`AIエージェント参考YouTubeリスト` のYouTube行から、Transcript本文をGoogle Docsに保存し、DocsリンクをSpreadsheetへ書き戻す半自動フローを整備している。

ユーザーの期待は次の状態だった。

```text
YouTube URLを指定する
↓
動画タイトルは自動で取得される
↓
DocsタイトルとSpreadsheetの動画名に入る
↓
Transcript本文だけがDocs本文に入る
```

## 起きた問題

- `.cmd` ラッパーがまだ動画タイトルの手入力を求める設計だった。
- 空Enterで進めると、DocsタイトルやSpreadsheetの `動画名` が補完されない場合があった。
- `-ExistingDocUrl` で既存Docsを再利用する場合、リンク書き戻しはできても、既存Docsのタイトルを動画タイトルベースへそろえる処理がなかった。
- 「タイトルはDocsタイトルとB列に入る。本文にはTranscriptだけを入れる」という境界は決めていたが、実装がその体験に追いついていなかった。

## 原因

- 前回の修正では、クリップボード誤保存を防ぐことに集中し、タイトル入力の自動化を別課題として見落とした。
- `FillBlankMetadata` は空欄補完の仕組みだが、補完に使う `$Title` が空のままなら何も入らない、という前提を十分に確認していなかった。
- `RowNumber` 指定時でも、行のURLから動画タイトルを取りにいける設計にしていなかった。
- ユーザー視点では「URLがあるならタイトルも取れるはず」なのに、スクリプトは「タイトルは別入力」という開発者目線の設計のままだった。

## 修正

- `scripts/new-youtube-transcript-doc.ps1` に `Get-YouTubeOEmbedTitle` を追加した。
- `Title` と `DocTitle` が空で、対象行または入力値からYouTube URLが分かる場合、YouTube oEmbedから動画タイトルを自動取得する。
- 取得したタイトルをDocsタイトルの元にし、`FillBlankMetadata` が有効ならSpreadsheetの `動画名` / `動画タイトル` / `タイトル` 相当列にも補完する。
- `scripts/new-youtube-transcript-doc-from-clipboard.ps1` は、動画タイトルの手入力プロンプトをやめた。
- 自動取得できない場合や別名にしたい場合だけ、`-DocTitle "動画タイトル"` を使う方針にした。
- `-ExistingDocUrl` で既存Docsを再利用する場合も、可能なら既存Docsのファイル名を `動画タイトル 文字起こし` にそろえる処理を追加した。

## 現在の推奨手順

```text
1. PowerShellで .cmd を実行する
2. YouTube URLを入力する、または -RowNumber を指定する
3. スクリプトが動画タイトルをYouTube URLから自動取得する
4. YouTube SummaryでTranscript本文をコピーする
5. PowerShellに戻ってEnterを押す
6. Docs作成、Docsタイトル設定、Sheetsリンク書き戻し、空欄メタデータ補完が行われる
```

## 今後の再発防止

- 「自動」と説明した項目は、実際に手入力が残っていないか確認する。
- メタデータ補完は、補完先の列だけでなく、補完元の値がどこから来るかまで検証する。
- `RowNumber` 指定時も、行内URLから取得できる情報は自動取得対象にする。
- Google Docs本文、Docsタイトル、Spreadsheet列の役割を混同しない。
- DryRunでは、最低限 `doc name` が期待どおりになるか確認する。

## 検証

2026-07-01に次を確認した。

- PowerShell構文チェック: `new-youtube-transcript-doc.ps1` OK
- PowerShell構文チェック: `new-youtube-transcript-doc-from-clipboard.ps1` OK
- DryRunで行21のDocs名が動画タイトルベースになることを確認

```text
DryRun: doc name: 【超入門】話題の「Obsidian」で第二の脳を構築し、インプットした知識を永久資産に変える方法 文字起こし
```

