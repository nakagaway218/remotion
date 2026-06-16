---
type: 運用メモ
status: 参照用
date: 2026-06-16
topic: Google API OAuth再認証の反省
tags: [google-api, oauth, drive, sheets, automation, source-index-sync]
---

# Google API OAuth再認証の反省

Google Drive / Google Sheets API連携を作り直したときの反省メモです。今後、同じ設定を別Workspaceや別Spreadsheetで行うときの確認順として使います。

## 結論

OAuthのアプリ名を変えたい場合、OAuthクライアントだけを削除・再作成しても直らないことがある。表示名はGoogle CloudのOAuth同意画面 / Google Auth PlatformのBranding側に依存する。

表示名を確実に変えたい場合は、新しいGoogle Cloudプロジェクトを作り、最初からアプリ名を `ObsidianSecondBrain Sync` のように設定する方が早い。

## 今回起きたこと

1. 最初のOAuth同意画面では、アプリ名が `OPENAI Codex` と表示された。
2. OAuthクライアントを削除・再作成しても、表示名が変わらなかった。
3. 新しいGoogle Cloudプロジェクトを作り、新しいOAuth JSONを `secrets/` に配置した。
4. しかし、テストユーザー未登録のため `access_denied` になった。
5. `dynakagawa@gmail.com` をテストユーザーに追加して再認証した。
6. 新しい `refresh_token` の取得に成功した。
7. Google Sheets / Drive APIのDry Runに成功した。

## 次回の確認順

### 1. JSONのプロジェクトを確認する

`client_secret_*.json` の中の `project_id` が、Google Cloud Consoleで見ているプロジェクトと一致しているか確認する。

今回の新プロジェクト:

```text
my-project-ai-agent-499605
```

### 2. APIを有効化する

同じプロジェクトで次を有効化する。

- Google Sheets API
- Google Drive API

別プロジェクトで有効化しても、OAuth JSONのプロジェクトが違えばAPI呼び出しは失敗する。

### 3. OAuth同意画面のテストユーザーに自分を入れる

アプリがテスト中の場合、使うGoogleアカウントをテストユーザーに追加する。

```text
dynakagawa@gmail.com
```

これを忘れると、次のようなエラーになる。

```text
アクセスをブロック: <アプリ名> は Google の審査プロセスを完了していません
エラー 403: access_denied
```

### 4. refresh_tokenを取り直す

新しいOAuth JSONを使う場合、既存の `refresh_token` は古いクライアント向けなので取り直す。

```powershell
.\scripts\get-google-refresh-token.ps1
```

成功すると次に保存される。

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\secrets\google-oauth-token.json
```

### 5. Dry RunでAPI接続を確認する

```powershell
$token = Get-Content ..\secrets\google-oauth-token.json -Raw | ConvertFrom-Json
$env:GOOGLE_CLIENT_ID = $token.client_id
$env:GOOGLE_CLIENT_SECRET = $token.client_secret
$env:GOOGLE_REFRESH_TOKEN = $token.refresh_token
.\scripts\sync-youtube-sheet-index.ps1 -DryRun
```

成功例:

```text
Reading spreadsheet: 記事参考リスト (...)
No data rows found in '記事参考リスト' range A1:K200.
Reading spreadsheet: AIエージェント参考YouTubeリスト (...)
Done. Spreadsheets: 2, created: 0, skipped: 3.
```

## 今回改善したこと

- `sync-youtube-sheet-index.ps1` を、固定SpreadsheetだけでなくDriveフォルダ内のSpreadsheet自動検出に対応させた。
- 同じURLのMarkdown索引が既にある場合は、日付が変わっても重複作成しないようにした。
- `get-google-refresh-token.ps1` のローカル受け取り方式を、`HttpListener` から `TcpListener` に変えて安定化した。
- 認証JSONとトークンは `secrets/` に置き、GitHubに入れない。

## 今後のルール

- Google API連携で詰まったら、まず「JSONのプロジェクト」「API有効化プロジェクト」「テストユーザー」「refresh_tokenのクライアントID」を順に確認する。
- アプリ名だけを変えたい場合でも、古いOAuth設定にこだわりすぎず、新プロジェクトで作り直す選択肢を早めに出す。
- 認証情報の中身はチャットに貼らない。存在確認と接続確認だけ行う。
- 自動確認は、必要がなければ通知しない。頻度は原則1日1回でよい。

