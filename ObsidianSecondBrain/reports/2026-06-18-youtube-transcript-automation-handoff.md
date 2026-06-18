---
type: handoff
status: active
date: 2026-06-18
topic: YouTube文字起こしとGoogle Drive同期自動化
tags: [handoff, google-drive, google-sheets, youtube, transcript, automation, source-index-sync]
---

# YouTube文字起こしとGoogle Drive同期自動化 引き継ぎ

このメモは、Google Drive / Google Sheets / ObsidianSecondBrain を使った素材管理と、YouTube文字起こし要約の自動化を今後進めるための記録です。

## 今日できたこと

- Google Driveフォルダ `ObsidianSecondBrain` を重い素材置き場として使う方針を確認した。
- Driveフォルダ内の4つのSpreadsheetを自動検出する運用にした。
- `AIエージェント参考YouTubeリスト` の `要約リンク` 列を確認した。
- `要約リンク` にあるGoogle DocsをCodexが読み取れることを確認した。
- YouTube文字起こしDocs 4件を読み取り、全文ではなく要約だけを `reports/source-summaries/` に保存した。
- 各YouTube索引に `transcript_url` と要約レポートへのリンクを追加した。
- `sync-youtube-sheet-index.ps1` が今後 `要約リンク` / `文字起こしURL` 系の列を認識できるようにした。
- Google Docs本文を読む補助スクリプト `scripts/get-drive-doc-text.ps1` を追加した。
- 自動確認 `youtube` の指示に、Google Docs本文取得と要約作成を含めた。

## 現在の運用

```text
Google Drive
  重い素材、Google Docs、文字起こし全文を置く

Google Sheets
  素材の管理表として使う

raw/webclip-index/
  URL、Driveリンク、要約リンクなどの軽い索引を置く

reports/source-summaries/
  Codexが読んだDocsや文字起こしの要約を置く

wiki/
  複数素材から抽象化した知識や運用ルールを置く
```

## 現在のSpreadsheet列

`AIエージェント参考YouTubeリスト`:

```text
追加日
動画名
ＵＲＬ
要約リンク
```

`要約リンク` には、YouTube文字起こしまたは要約元のGoogle Docs URLを入れる。

## 誤字脱字の扱い

YouTubeの自動文字起こしには誤字脱字が多い。要約では、逐語的に引用せず、文脈から自然に補正して扱う。

ただし、次は誤認が起きやすいため注意する。

- ツール名
- 人名
- 会社名
- 料金
- 数値
- 機能名
- サービス比較

これらは、必要に応じて「要確認」と残す。確定情報として使う前には、公式情報や元動画の該当箇所で確認する。

## できること

- Driveフォルダ内のSpreadsheetを自動検出する。
- SpreadsheetのURL行から軽い索引Markdownを作る。
- `要約リンク` にGoogle Docsがあれば本文を読む。
- Docs本文を要約し、Git側には要約だけ保存する。
- 同じURLや同じDriveファイルIDは重複作成しない。
- URL列未検出、読み取り範囲上限到達、Docs取得失敗などは警告する。

## まだ完全自動ではないこと

- YouTube動画から文字起こしDocsを作成すること。
- YouTube Summary拡張のTranscriptを安定して自動コピーすること。
- ブラウザで見ているYouTubeや記事URLを完全自動で判断してSpreadsheetに入れること。
- 要約から `wiki/` の概念ページへ昇格する判断。

## 今後の自動化候補

### 1. Spreadsheet整備の自動化

4つのSpreadsheetに標準列を追加・整形する。

推奨列:

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

`要約状態` の候補:

```text
未処理
要約済み
要確認
本文なし
wiki反映済み
```

### 2. URL・リンク貼り付けの自動化

Driveフォルダ内の新規Google Docs / PDF / 画像などを検出し、対応するSpreadsheetへ行追加する。

できること:

- Drive URLの自動記入
- Google Docsリンクの自動記入
- 種別、タイトル、更新日の自動記入
- 要約保存先の自動記入
- 要約状態の更新

### 3. YouTube Summary transcriptの半自動取得

Chrome操作でYouTubeページを開き、YouTube Summary拡張のTranscriptをコピーしてGoogle Docs化する案。

注意点:

- Chrome拡張のUIに依存するため壊れやすい。
- YouTube側や拡張側の画面変更に弱い。
- 字幕がない動画は失敗する。
- 失敗時は `文字起こし取得失敗` として記録する設計が必要。

### 4. wikiへの昇格

要約が5〜10本たまったら、横断整理して `wiki/` に昇格する。

候補:

- Codex活用ルール
- AIエージェント記憶設計
- ObsidianSecondBrain運用
- YouTube文字起こし要約フロー
- 外部AIツールの使い分け

## 次に再開するときの確認順

1. `raw/google-drive-source.md` でDriveフォルダと管理表を確認する。
2. `scripts/README.md` で同期スクリプトの使い方を確認する。
3. `scripts/sync-youtube-sheet-index.ps1 -DryRun` で新規・警告の有無を確認する。
4. `AIエージェント参考YouTubeリスト` の `要約リンク` 列に新しいDocs URLがあるか確認する。
5. Docs本文を読む必要がある場合は `scripts/get-drive-doc-text.ps1` を使う。
6. 要約は `reports/source-summaries/` に保存し、索引からリンクする。
7. まとまった知識は `wiki/` に昇格する。

## 関連ファイル

- [[raw/google-drive-source|Google Drive raw保存先]]
- [[raw/webclip-index/README|Webclip Index README]]
- [[scripts/README|Google API Sync Scripts]]
- [[wiki/YouTube文字起こし要約運用|YouTube文字起こし要約運用]]
- [[reports/source-summaries/2026-06-15-youtube-codexオートメーション機能|Codexオートメーション機能 要約]]
- [[reports/source-summaries/2026-06-15-youtube-codex入門|Codex入門 要約]]
- [[reports/source-summaries/2026-06-16-youtube-obsidianでcodexとclaudecodeを賢くする|ObsidianでCodexとClaude Codeを賢くする 要約]]
- [[reports/source-summaries/2026-06-17-youtube-lylisai|LylisAI 要約]]
