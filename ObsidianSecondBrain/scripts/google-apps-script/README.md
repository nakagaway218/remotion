---
type: guide
status: active
date: 2026-07-03
topic: Google Apps Script transcript Docs workflow
tags: [gas, google-sheets, google-docs, youtube, transcript]
---

# Google Apps Script: Transcript列からDocsを作る

`youtube-transcript-docs.gs` は、Google Sheets上で次の処理を行うApps Scriptです。

```text
Transcript列に文字起こし本文を貼る
↓
メニューから実行
↓
Google DocsをDrive素材フォルダに作成
↓
要約リンク列へDocs URLを書き戻す
```

YouTube Summary拡張機能の操作や、他人のYouTube動画のTranscript取得は行いません。手作業で残るのは、Transcript本文をコピーしてSpreadsheetの `Transcript` 列へ貼るところです。

## 設置方法

1. 対象Spreadsheetを開く。
2. メニューから `拡張機能` → `Apps Script` を開く。
3. `Code.gs` に `scripts/google-apps-script/youtube-transcript-docs.gs` の内容を貼り付ける。
4. 保存する。
5. Spreadsheetを再読み込みする。
6. `Transcript Docs` メニューが出ることを確認する。

初回実行時は、Google Sheets / Google Docs / Google Drive / 外部通信への権限確認が出ます。

## 対象列

既存列名を自動検出します。

| 用途 | 対応列名 |
| --- | --- |
| YouTube URL | `URL`, `ｕｒｌ`, `YouTube URL`, `YouTube`, `リンク` |
| 追加日 | `追加日`, `日付`, `登録日`, `作成日`, `date` |
| 動画タイトル | `動画名`, `動画タイトル`, `タイトル`, `title`, `name` |
| Transcript本文 | `Transcript`, `文字起こし本文`, `文字起こしテキスト`, `全文`, `本文` |
| Docsリンク | `要約リンク`, `文字起こしURL`, `文字起こしリンク`, `transcript_url`, `summary_url` |
| 状態 | `状態`, `視聴状況`, `status` |

`Transcript` 列と `要約リンク` 列がない場合は、`Transcript Docs` → `必要な列を作成` で追加できます。

## 使い方

### 選択行だけ処理

1. `Transcript` 列に文字起こし本文を貼る。
2. 処理したい行を選択する。
3. `Transcript Docs` → `選択行からDocsを作成` を実行する。

### 未処理行を一括処理

1. 複数行の `Transcript` 列に文字起こし本文を貼る。
2. `Transcript Docs` → `未処理行を一括処理` を実行する。

`要約リンク` に既にURLが入っている行はスキップします。

## 作成されるDocs

- Docs名は `動画タイトル 文字起こし` です。
- `動画名` が空欄で、YouTube URLがある場合はYouTube oEmbedからタイトル取得を試みます。
- 作成先はDriveフォルダ `ObsidianSecondBrain` です。
- Docs本文にはTranscript本文を入れます。
- Spreadsheetの `要約リンク` にDocs URLを書き戻します。
- `追加日` が空欄なら今日の日付を補完します。
- `状態` 列が空欄なら `Docs作成済み` を入れます。

## 設定

`youtube-transcript-docs.gs` の冒頭で変更できます。

```javascript
const TRANSCRIPT_DOCS_CONFIG = {
  driveFolderId: '1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz',
  minTranscriptChars: 80,
  clearTranscriptAfterDocCreate: false,
  docNameSuffix: ' 文字起こし',
  defaultDocTitle: 'YouTube transcript',
  transcriptHeader: 'Transcript',
  linkHeader: '要約リンク',
  dateFormat: 'yyyy-MM-dd',
};
```

`clearTranscriptAfterDocCreate` を `true` にすると、Docs作成後にSpreadsheet上のTranscript本文を消します。誤削除を避けるため、既定では `false` です。

## 注意

- Transcript全文はSpreadsheetとGoogle Docs側に残ります。Gitには保存しません。
- 80文字未満のTranscriptは、誤ってタイトルやコマンドだけを貼った可能性があるため停止します。
- YouTubeタイトル取得に失敗してもDocs作成は可能です。その場合は行のタイトル、または `YouTube transcript` を使います。
- Apps Script単体では、YouTube Summary拡張機能のUI操作はできません。

