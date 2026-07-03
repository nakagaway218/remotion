---
type: guide
status: active
date: 2026-06-15
topic: Google API sync scripts
tags: [scripts, google-api, raw]
---

# Google API Sync Scripts

このフォルダには、Google SheetsやGoogle Driveを読み取り、このVault側に軽い索引Markdownを作るスクリプトを置く。

## YouTubeリスト同期

`sync-youtube-sheet-index.ps1` は、Google Driveの `ObsidianSecondBrain` フォルダ内にあるGoogle Sheetsを自動検出し、`raw/webclip-index/` に軽い索引Markdownを作る。YouTubeリストだけでなく、記事リストやDrive上のGoogle Docs/PDFなども対象にする。

```powershell
pwsh -File .\scripts\sync-youtube-sheet-index.ps1
```

特定のSpreadsheetだけを読む古い動きに戻したい場合は、`-DisableSpreadsheetDiscovery` を付ける。

```powershell
pwsh -File .\scripts\sync-youtube-sheet-index.ps1 -DisableSpreadsheetDiscovery
```

実行前に、次のどちらかの認証情報を環境変数に入れる。

```powershell
$env:GOOGLE_ACCESS_TOKEN = "一時アクセストークン"
```

または、長期運用では次の3つを使う。

```powershell
$env:GOOGLE_CLIENT_ID = "OAuthクライアントID"
$env:GOOGLE_CLIENT_SECRET = "OAuthクライアントシークレット"
$env:GOOGLE_REFRESH_TOKEN = "リフレッシュトークン"
```

Google CloudからダウンロードしたOAuthクライアントJSONは、Gitルート側の `secrets/` または `secret/` に置く。例:

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\secrets\client_secret_....json
```

このJSONは `client_id` と `client_secret` を含むが、長期運用には別途 `refresh_token` が必要。

## refresh tokenを取得する

Google Cloudからダウンロードした `client_secret_*.json` を `C:\Users\nakag\Desktop\GitHub\Myownproject\secrets\` に置いた後、次を実行する。

```powershell
.\scripts\get-google-refresh-token.ps1
```

ブラウザが開いたらGoogleアカウントで許可する。成功すると次のファイルが作られる。

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\secrets\google-oauth-token.json
```

このファイルには `client_id`、`client_secret`、`refresh_token` が入る。チャットやGitHubには貼らない。

取得後、現在のPowerShellだけで使う場合は次のように環境変数へ入れる。

```powershell
$token = Get-Content ..\secrets\google-oauth-token.json -Raw | ConvertFrom-Json
$env:GOOGLE_CLIENT_ID = $token.client_id
$env:GOOGLE_CLIENT_SECRET = $token.client_secret
$env:GOOGLE_REFRESH_TOKEN = $token.refresh_token
```

認証情報は `.env`、`credentials.json`、`token.json` などに保存してもよいが、GitHubには入れない。`.gitignore` で除外済み。

## 対象

- Driveフォルダ内のGoogle Sheetsを自動検出する
- 既定Spreadsheet ID: `1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8`
- Drive Folder ID: `1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz`
- 既定読み取り範囲: `A1:Z1000`
- 出力先: `raw/webclip-index/`

同じURLの索引Markdownがすでに `raw/webclip-index/` にある場合は、別の日に再実行しても重複作成しない。

## 見落とし防止

- 実行時にDriveフォルダ内のファイル数とSpreadsheet数を表示する。
- 各Spreadsheetについて、ヘッダー数・データ行数・読み取り範囲を表示する。
- URL列が見つからないSpreadsheetは警告する。
- 読み取り範囲の最終行までデータがある場合は、範囲外に行がある可能性として警告する。
- Google Sheets以外のDriveファイルは、Google Docs、PDF、画像、動画、音声などを軽いDriveファイル索引の対象にする。
- Driveフォルダは素材ファイルではないため索引化しない。

## 想定する列名

英語列名でも日本語列名でも読めるようにしている。

| 推奨列 | 日本語例 |
| --- | --- |
| date | 追加日 / 日付 / 登録日 |
| title | タイトル / 動画タイトル / 動画名 / 記事名 |
| url | URL / ＵＲＬ / URL or Link / リンク |
| channel | チャンネル / チャンネル名 |
| theme | テーマ / 主題 |
| priority | 優先度 |
| status | 状態 / 視聴状況 |
| key_points | 要点 |
| action | 反映 / 自分のプロジェクトに反映すること |
| drive_url | drive / google_drive |
| drive_name | 保存ファイル名 |
| transcript_url | 文字起こしURL / 文字起こし / 要約リンク |
| wiki_link | wiki / 整理後ノート |

## 確認だけする

ファイルを作らず動作確認する場合は `-DryRun` を付ける。

```powershell
pwsh -File .\scripts\sync-youtube-sheet-index.ps1 -DryRun
```

## Google Docs本文を読む

`get-drive-doc-text.ps1` は、Google Docsをプレーンテキストとして取得する補助スクリプト。本文全文はGitに保存せず、Codexが要約を作るときだけ読み取る。

```powershell
pwsh -File .\scripts\get-drive-doc-text.ps1 -DocumentUrl "https://docs.google.com/document/d/.../edit"
```

文字数を制限して確認する場合:

```powershell
pwsh -File .\scripts\get-drive-doc-text.ps1 -DocumentUrl "https://docs.google.com/document/d/.../edit" -MaxChars 4000
```

運用方針:

- Google Docs本文はDrive側に置く。
- Git側には `raw/webclip-index/` の索引と、`reports/` の要約だけを置く。
- 自動確認では、記事索引のURLがGoogle Docsの場合、必要に応じてこのスクリプトで本文を読み、要約レポートを作る。

## YouTube TranscriptからDocsを作りSheetsへリンクする

`new-youtube-transcript-doc.ps1` は、手元でコピー済みのYouTube Transcript、またはテキストファイルからGoogle Docsを作り、対象行の `要約リンク` 列へDocs URLを書き戻す補助スクリプト。

YouTube Summary拡張機能のボタン操作は自動化しない。壊れにくくするため、このスクリプトはGoogle APIでできる範囲だけを担当する。
Google Docsのタイトルは、対象行の動画タイトル、またはYouTube URLから自動取得したタイトルを使い、末尾に `文字起こし` を付ける。別名にしたい場合は `-DocTitle` で指定できる。
既定では `..\secrets\google-oauth-token.json` を自動で読み込む。
既定のSpreadsheet IDが読めない場合は、Driveフォルダ内の `AIエージェント参考YouTubeリスト` を名前で探して再試行する。

```powershell
pwsh -File .\scripts\new-youtube-transcript-doc.ps1 -FromClipboard -VideoUrl "https://www.youtube.com/watch?v=..."
```

PowerShellコマンドを毎回打たない場合は、次の `.cmd` を使う。

```text
scripts\new-youtube-transcript-doc-from-clipboard.cmd
```

実行するとYouTube URLの入力を求められる。先にYouTube SummaryなどでTranscript本文をコピーしておけば、Google Docs作成とSheetsへのリンク書き戻しまで行う。
動画タイトルは、対象行の `動画名` が空欄ならYouTube URLから自動取得を試みる。取得できたタイトルはDocsタイトルに使われ、Spreadsheetの `動画名` が空欄なら補完される。`追加日` が空欄なら今日の日付で補完される。`URL` が空欄で、実行時にYouTube URLを入力している場合はURLも補完される。
自動取得できない場合や別名にしたい場合だけ、`-DocTitle "動画タイトル"` を付けて手動指定する。
もし対象タブを明示したい場合は、次のように `-SheetName` を付ける。

```powershell
.\scripts\new-youtube-transcript-doc-from-clipboard.cmd -SheetName "シート1"
```

テキストファイルから作る場合:

```powershell
pwsh -File .\scripts\new-youtube-transcript-doc.ps1 -TranscriptTextPath ".\transcript.txt" -VideoUrl "https://www.youtube.com/watch?v=..."
```

行番号を直接指定する場合:

```powershell
pwsh -File .\scripts\new-youtube-transcript-doc.ps1 -FromClipboard -RowNumber 12
```

`.cmd` から行番号を指定する場合:

```powershell
.\scripts\new-youtube-transcript-doc-from-clipboard.cmd -RowNumber 12
```

URLで対象行が見つからない場合は、SpreadsheetにそのYouTube URLが入っているか確認する。URLが入っていない、または列名が特殊な場合は、`-RowNumber` で対象行を直接指定する。

Docs作成は成功したがSheets書き戻しで止まった場合は、作成済みDocs URLを再利用してリンクだけ書き戻せる。
この場合も、アクセス権があれば既存Docsのタイトルを動画タイトルベースの `... 文字起こし` にそろえる。

```powershell
.\scripts\new-youtube-transcript-doc-from-clipboard.cmd -RowNumber 12 -ExistingDocUrl "https://docs.google.com/document/d/.../edit?usp=drivesdk"
```

Docsタイトルを明示する場合:

```powershell
pwsh -File .\scripts\new-youtube-transcript-doc.ps1 -FromClipboard -VideoUrl "https://www.youtube.com/watch?v=..." -DocTitle "動画タイトル"
```

確認だけする場合:

```powershell
pwsh -File .\scripts\new-youtube-transcript-doc.ps1 -FromClipboard -VideoUrl "https://www.youtube.com/watch?v=..." -DryRun
```

注意:

- 実行前に、YouTube SummaryなどからTranscript本文をクリップボードへコピーする。
- クリップボードにPowerShellコマンドが残っている場合は停止する。Docs本文がコマンド文になるのを防ぐため。
- クリップボードの本文が短い場合は確認してから進む。`N` を選ぶと、スクリプトを終了せず、Transcriptをコピーし直してEnterで再確認できる。動画タイトルだけの場合もコピーし直しを促す。既定では200文字未満を短いTranscriptとして確認対象にする。
- `.cmd` では空欄の `追加日`、`動画名`、`URL` を補完する。補完したくない場合は `-NoFillBlankMetadata` を付ける。
- `要約リンク` 列が見つからない場合は、列を作ってよいときだけ `-CreateMissingLinkColumn` を付ける。
- Google Docs作成とSheets書き戻しを行うため、OAuthスコープは `drive.readonly`、`drive.file`、`spreadsheets` が必要。以前の読み取り専用トークンでは動かないため、`get-google-refresh-token.ps1` で再認証する。
- 現在のトークンに必要なスコープがない場合、スクリプトはAPI実行前に停止して再認証を促す。
- 文字起こし全文はGitに保存しない。作成されたDocsはGoogle Drive側に置く。

## Google Apps ScriptでSpreadsheet上からDocsを作る

PowerShellではなくSpreadsheet上で処理したい場合は、`google-apps-script/youtube-transcript-docs.gs` を使う。

```text
Transcript列に文字起こし本文を貼る
↓
Spreadsheetのメニューから実行
↓
Google Docs作成
↓
要約リンク列へDocs URLを書き戻し
```

詳細は `scripts/google-apps-script/README.md` を参照する。

### Googleアクセス診断

再認証後もSpreadsheetやDriveフォルダが404になる場合は、保存済みOAuthトークンで見えているGoogleアカウントと対象ファイルを確認する。

```powershell
pwsh -File .\scripts\diagnose-google-source-access.ps1
```

確認する項目:

- OAuthトークンの作成日時とスコープ
- Drive API上のユーザー
- DriveフォルダIDが見えるか
- フォルダ内のSpreadsheet一覧
- 対象Spreadsheet IDがSheets APIで開けるか

## 公開GitHubリポジトリを導入判断する

`review-github-repo-source.ps1` は、`raw/webclip-index/` にある `github.com/owner/repo` 形式の公開GitHub URLを読み取り、README、AGENTS.md、package.json、ルートファイル、GitHubメタ情報を確認して、`reports/github-repo-reviews/` に導入判断レポートを作る。

```powershell
pwsh -File .\scripts\review-github-repo-source.ps1
```

確認だけする場合:

```powershell
pwsh -File .\scripts\review-github-repo-source.ps1 -DryRun
```

GitHub APIの未認証アクセスは回数制限がある。必要な場合は、読み取り専用の `GITHUB_TOKEN` を環境変数に入れる。

```powershell
$env:GITHUB_TOKEN = "GitHubの読み取り用トークン"
```

このスクリプトで行うこと:

- 公開GitHub URLから `owner/repo` を抽出する。
- GitHub APIでrepo情報、README、AGENTS.md、package.json、ルートファイルを取得する。
- `curl | sh`、`Invoke-Expression`、`rm -rf`、`git reset --hard` などの注意サインを機械的に検出する。
- 導入候補、要手動確認、参考情報として保留、の一次判断を残す。

注意:

- private repo、ログイン必須ページ、GitHub以外の配布ページは対象外。
- 自動判断は一次判断。実際に導入する前には、Codexがレポートと主要ファイルを読み、既存スキルやプラグインと重複しないかを確認する。
- 外部コードを実行したり、パッケージをインストールしたりはしない。

## PowerShellと通信停止の防止

Google APIとGitHub APIを使うスクリプトはPowerShell 7（`pwsh`）必須。Windows PowerShell 5の `powershell.exe` では実行しない。

- 各API通信は既定30秒でタイムアウトする。
- 必要なら `-HttpTimeoutSec 60` のように変更できる。
- PowerShell 7の中から `powershell -File ...` を二重起動しない。
- 通信停止時は認証情報を作り直す前に、`pwsh` の使用と443番接続を確認する。
