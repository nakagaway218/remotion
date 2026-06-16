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

`sync-youtube-sheet-index.ps1` は、Google Sheetsの `AIエージェント参考YouTubeリスト` を読み、`raw/webclip-index/` にYouTubeごとの索引Markdownを作る。

```powershell
.\scripts\sync-youtube-sheet-index.ps1
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

- Spreadsheet ID: `1SJAAR1_qG7UWQtumyUIGMi7V1e3h0PNRP6LK836LDD8`
- Drive Folder ID: `1f3WY-zSl1D7AAPdOUz8Spyz-y19gzvTz`
- 出力先: `raw/webclip-index/`

## 想定する列名

英語列名でも日本語列名でも読めるようにしている。

| 推奨列 | 日本語例 |
| --- | --- |
| title | タイトル / 動画タイトル |
| url | リンク |
| channel | チャンネル / チャンネル名 |
| theme | テーマ / 主題 |
| priority | 優先度 |
| status | 状態 / 視聴状況 |
| key_points | 要点 |
| action | 反映 / 自分のプロジェクトに反映すること |
| drive_url | drive / google_drive |
| drive_name | 保存ファイル名 |
| wiki_link | wiki / 整理後ノート |

## 確認だけする

ファイルを作らず動作確認する場合は `-DryRun` を付ける。

```powershell
.\scripts\sync-youtube-sheet-index.ps1 -DryRun
```
