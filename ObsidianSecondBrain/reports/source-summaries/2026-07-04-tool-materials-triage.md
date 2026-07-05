---
type: source_summary
status: triaged
date: 2026-07-04
source_type: tool_batch
tags: [tool, github, zip, drive, duplicate-triage]
---

# 2026-07-04 ツール参考リスト追加分 / 導入判断メモ

## 対象

- [[raw/webclip-index/2026-07-04-tool-ai-design-build-kit]]
- [[raw/webclip-index/2026-07-04-tool-claude-opus-4-8-完全ガイド]]
- [[raw/webclip-index/2026-07-04-tool-crowdworks-pipeline-スキル]]
- [[raw/webclip-index/2026-07-04-tool-codex初期設定-特典プロンプト2点セット]]
- [[raw/webclip-index/2026-07-04-tool-codex秘書-ヒアリング型セットアッププロンプト]]
- [[raw/webclip-index/2026-07-04-tool-codex完全ガイド]]
- [[raw/webclip-index/2026-07-04-tool-higgsfield連携プロンプト]]
- [[raw/webclip-index/2026-07-04-tool-n1-ai-employee]]
- [[raw/webclip-index/2026-07-04-tool-n1-slide-deck-maker]]
- [[raw/webclip-index/2026-07-04-tool-seo-media-autopilot-skill1]]

## 読めたもの

### GitHub

- [[reports/github-repo-reviews/2026-07-05-github-fuuuuuuma-ai-design-build-kit]]
  - Web/アプリ/LP制作のための設計キット。
  - `AGENTS.md`、`DESIGN.md`、`SKILL.md` のようなルールファイルを先に置く考え方は、すでに `Myownproject` で採用済み。
  - 判定: `manual-review-required`。既存運用と重なるため、一部だけ採用候補。
- [[reports/github-repo-reviews/2026-07-05-github-fuuuuuuma-claude-opus-4-8-guide]]
  - Claude Opus 4.8の非公式まとめ。
  - モデル情報は変化しやすく、現時点では資料として読むだけ。公式確認なしに恒久ルール化しない。
  - 判定: `manual-review-required`。
- [[reports/github-repo-reviews/2026-07-05-github-smotodays-ai-blog-post01]]
  - CrowdWorksのライティング案件を、探す、応募、執筆、納品まで支援するClaude Codeスキル。
  - 送信、ログイン、納品は人間が行う安全設計がある。
  - 判定: `candidate-with-conditions`。ただし案件応募自動化はアカウント・規約・実名情報リスクがあるため、導入は慎重にする。

### Zip

- [[reports/zip-inspections/2026-07-04-zip-seo-media-autopilot-skill]]
  - `seo-media-autopilot.skill1` と同一Driveファイル。新規レポートは作らず既存レポートで代替。
- [[reports/zip-inspections/2026-07-04-zip-ai秘書-20260704t044530z-3-001-zip]]
  - `n1-ai-employee` と同一Driveファイル。既存の入れ子Zip確認 [[reports/zip-inspections/2026-07-04-zip-ai秘書-n1-ai-employee-nested]] で代替。

## 今回APIから読めなかったもの

以下のDriveリンクは、URLは索引化できたが、現在のOAuthトークンではDrive APIのメタデータ取得が404になった。

- `Codex初期設定 特典プロンプト2点セット`
- `Codex秘書 ヒアリング型セットアッププロンプト`
- `Codex完全ガイド`
- `Higgsfield連携プロンプト`
- `n1-slide-deck-maker`

可能性:

- リンク先がGoogle Docs/Slidesではなく、Office変換前ファイルや共有制限付きファイル。
- OAuthでログインしているGoogleアカウントが閲覧権限を持っていない。
- URLから抽出したIDが、APIで直接読めるファイルIDではない形式。

次に必要なこと:

- ブラウザでそのGoogleアカウントから開けるか確認する。
- 必要ならDrive内の該当ファイルを同じ素材置き場フォルダにコピーする。
- それでも読めない場合は、Docs化またはテキスト化してから再同期する。

## 統合方針

- `ai-design-build-kit`: 既存の `AGENTS.md` / `DESIGN.md` / `AI_CONTEXT.md` 運用と重複。新規導入ではなく、必要な設計観点だけ取り込む。
- `claude-opus-4-8-guide`: モデル情報は鮮度が重要。公式確認なしにルール化しない。
- `crowdworks-pipeline`: 営業・案件応募系の参考にはなるが、送信や応募の自動化はしない。読むなら安全設計部分だけ採用。
- `seo-media-autopilot.skill1`: 既存Zip検査で代替可。
- `n1-ai-employee`: 既存Zip検査で代替可。
- `n1-slide-deck-maker`: Drive本体未読。スライド生成の既存動画要約と合わせて、後日読める状態になってから判断。

## 注意点

- 外部スキルはインストールしない。
- GitHub repoやZip内のコードは実行しない。
- Google Driveで読めない素材は、読めたことにしない。
- 重複素材は新規ノートを増やさず、既存レポートへの参照に寄せる。
