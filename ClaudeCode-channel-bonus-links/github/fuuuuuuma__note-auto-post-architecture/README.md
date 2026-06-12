# note 自動投稿ボットの内部構造

YouTube 動画の文字起こしを情報源に、note.com へ長文記事を毎日自動投稿する Node 製ボットの設計メモ。
Claude Code のサブエージェント（Task tool）は使わず、**単一プロセスがモジュール分業で完結**する構造。Claude API は本文生成とファクトチェックの 2 回だけ叩く。

## 公開資料

- [【保存版】Codexをスマホで使うための設定方法と実践ガイド](docs/codex-mobile-complete-guide-2026.md)

---

## 全体像

```
ユーザー / cron
   ↓
node index.js [--draft|--dry-run|--date|--videoId]
   ↓
lib/*.js を直列に呼び出すオーケストレーション
```

毎日決まった時刻に scheduled task で自動実行することを想定。

---

## ディレクトリ構成

```
.
├── index.js                  # オーケストレーション本体
├── config.json               # スプレッドシート ID / チャンネル URL / 既知の固有名詞
├── setup-auth.js             # note.com 初回ログイン用
├── lib/
│   ├── spreadsheet.js        # 投稿対象行の取得
│   ├── youtube.js            # 動画特定 / 字幕 / サムネ / スクショ
│   ├── article-generator.js  # 本文生成（Claude Sonnet）
│   ├── proper-noun-checker.js# 固有名詞ファクトチェック（Claude + Web Search）
│   ├── note-poster.js        # Playwright で note.com を操作
│   └── posted-log.js         # 重複投稿防止
└── data/
    └── YYYY-MM-DD/           # 1 日 1 ディレクトリ
        ├── transcript.txt
        ├── thumbnail.jpg
        ├── screenshots/
        ├── article.txt
        └── meta.json
```

---

## 処理フロー（index.js の `main()`）

| STEP | 処理 | 担当モジュール | 主要関数 |
|------|------|----------------|----------|
| 0 | `.env` 読み込み（NOTE_EMAIL/PASSWORD） | index.js | — |
| 1 | スプレッドシートから対象日の行を取得 | spreadsheet.js | `fetchSpreadsheetData` → `findYesterdayVideo` |
| 2 | YouTube 動画を特定（videoId 解決＋Shorts 排除） | youtube.js | `getVideoInfo` → `findVideoByDateViaYtdlp` / RSS フォールバック → `verifyLongForm` |
| 2.5 | 重複投稿チェック | posted-log.js | `isAlreadyPostedToday` |
| 3 | 文字起こし取得（yt-dlp 自動字幕 → VTT パース） | youtube.js | `getTranscript` → `parseVTT` → `transcriptToText` |
| 4 | サムネ画像 DL（JPEG マジックバイト＋8KB 検証） | youtube.js | `downloadThumbnail` |
| 5 | スクショ取得（ffmpeg） | youtube.js | `pickScreenshotTimestamps` → `captureScreenshots` |
| 6 | タイトル生成 | article-generator.js | `generateTitle` |
| 6 | 本文生成（Claude Sonnet 4.6 / max_tokens 16000） | article-generator.js | `generateArticle` → `generateBodyWithAI` |
| 6b | 固有名詞ファクトチェック（独立工程） | proper-noun-checker.js | `checkAndFixProperNouns` |
| 7 | note.com に Playwright で投稿 | note-poster.js | `postToNote` |
| 8 | `posted-log.json` に記録 | posted-log.js | `markAsPosted` |

---

## 各モジュールの担当

### ① spreadsheet.js — 起点
gid 指定で CSV 取得し、「基準日の前日」に該当する 1 行を `findYesterdayVideo` で抽出。タイトルヒント取得用であり、動画特定の一次情報源ではない。

### ② youtube.js — 動画ソース担当（最重要ゲート）
- `getVideoInfo`: yt-dlp の `/videos` タブ + `--flat-playlist` で直近横動画を一次情報源に。失敗時は RSS、それも失敗時は手動 `--videoId`。
- **`verifyLongForm`** がすべての経路の最終ゲート。
  - `aspect_ratio < 1.0` → Shorts 判定で不採用
  - `height > width` → Shorts 判定で不採用
  - 取得失敗時も安全側で不採用
  - **duration 単独では判別不可**（YouTube は最大 180 秒の Shorts を許容するため）
- `parseVTT`: YouTube 自動字幕は 2 行ローリング表示で重複が出るので、cue 内の **最終行のみ** 採用。
- `transcriptToText`: 隣接エントリの prefix を最大 30 字まで除去。

### ③ article-generator.js — 文章生成エンジン
2 段階構成:

1. **`generateBodyWithAI`** — Claude `claude-sonnet-4-6` / `max_tokens: 16000` / 文字起こし 15000 字を渡し、JSON で `{hook, sections[]}` を返させる。プロンプトには以下を明示:
   - 6〜9 セクション・各 1000〜1500 字・合計 8000〜11000 字
   - 禁止表現リスト（断定保証・詐欺連想・過度な煽り）
   - 登場人物・組織の表記固定
   - Markdown 記法禁止（noteには別途エディタ API で見出し/区切り線/太字を入れるため）
2. **`normalizeTranscriptForLLM`** で **LLM に渡す前** に表記揺れ補正、**`sanitizeBodyText`** で **生成後** にも再補正（2 段防御）。
3. `buildSectionsFromText` で `[{type:'text'|'image', ...}]` 配列に変換（note-poster が食いやすい形）。

失敗時は `buildFallbackBody`（テンプレ）に落とす。

### ④ proper-noun-checker.js — ファクトチェック工程（独立）
構造上もっとも“サブエージェント的”に動くモジュール。

- 入力: 生成済みの hook + sections
- **正典 6 本** を集める:
  1. YouTube タイトル
  2. yt-dlp 取得の概要欄（先頭 4000 字）
  3. 文字起こし（先頭 15000 字）
  4. チャンネル直近 30 動画タイトル（24h キャッシュ）
  5. `config.json` の `knownPeople`（既知の人物リスト・aliases 含む）
  6. `config.json` の `knownOrganizations`（既知の組織名リスト・aliases 含む）
- Claude `claude-sonnet-4-6` + **`web_search` ツール（最大 3 回）** を有効にし、`{fixes, warnings}` JSON を返させる。
- ポリシーは **保守的**:
  - 修正は固有名詞前後の短い文字列単位の置換のみ
  - 確証が持てないものは `warnings` に降格
  - 文章書き換え・削除・大幅な書き換えは禁止
- パッチ適用は記事中に `before` が **実在する場合のみ** split-join 置換し、適用済みのみ返す。

### ⑤ note-poster.js — Playwright 自動操作
`chromium.launchPersistentContext`（永続プロファイル）で `headless: false` 起動。

1. `ensureLoggedIn` — クッキー切れていたら `NOTE_EMAIL` / `NOTE_PASSWORD` でログイン
2. 新規記事ページへ遷移
3. **`setThumbnail`** — 起動時のチュートリアル / ダイアログを Escape で潰してから画像追加
4. タイトル入力（`getByRole('textbox', { name: '記事タイトル' })`）
5. 本文 `contenteditable="true"` をクリック → セクション配列を回す
   - 区切り線 `━━━` → `insertViaMenu('区切り線')`
   - `■ 見出し` → 見出しメニュー
   - `**太字**` → `typeLineWithBoldMarkers` が **Cmd+B トグル** で実機の太字に変換
   - 画像セクション → `insertImage`
6. `--draft` なら下書き保存ボタン、本番なら「公開に進む」→ ハッシュタグ入力 → 「公開」
7. 失敗時は `error-<timestamp>.png` に全画面スクショを残す

### ⑥ posted-log.js — 重複防止
`data/posted-log.json` に `{ videoId, date }` を書く。**投稿前後の二重チェック**。これを飛ばすと多重起動で重複投稿事故になる。

---

## データフロー図

```
スプレッドシート ──┐
                   ▼
           findYesterdayVideo (タイトルヒント+postDate)
                   ▼
   yt-dlp /videos → RSS → --videoId      ← Shortsゲート(verifyLongForm)
                   ▼ videoId
   ┌───────────────┼────────────────┐
   ▼               ▼                ▼
yt-dlp 字幕   yt-dlp サムネ    ffmpeg スクショ
   │               │                │
   ▼               │                │
parseVTT           │                │
transcriptToText   │                │
   ▼               │                │
normalizeForLLM    │                │
   ▼               │                │
Claude Sonnet 4.6 (本文生成 16k tok)
   ▼
sanitizeBodyText
   ▼
proper-noun-checker (Claude + web_search × ≤3)
   ▼
buildSectionsFromText  ←──── screenshots[] を image セクションとして織り込み
   ▼
data/YYYY-MM-DD/{transcript.txt, article.txt, meta.json, thumbnail.jpg, screenshots/}
   ▼
note-poster.js (Playwright)
   ├─ ensureLoggedIn
   ├─ setThumbnail
   ├─ inputFormattedText (見出し/区切り線/太字/画像をエディタAPIで)
   └─ 公開 + ハッシュタグ
   ▼
posted-log.json に記録
```

---

## 安全装置まとめ

| 事故 | 防御 |
|------|------|
| Shorts / 縦動画を本投稿 | `verifyLongForm` で aspect_ratio 判定（全経路通る） |
| 空記事公開 | videoId 未解決 / 文字起こし < 200 字で `[ABORT]` `exit 1` |
| 重複投稿 | `posted-log.json` 両端チェック |
| 偽サムネ（プレースホルダ） | JPEG マジックバイト＋8KB＋リトライ |
| 字幕の 3 重重複表示 | parseVTT で最終行のみ採用＋prefix 30 字除去 |
| 表記揺れ・誤認識 | normalize（LLM 前）+ sanitize（生成後）+ proper-noun-checker（独立工程） |
| プロンプトでの禁止表現 | プロンプトで明示禁止＋sanitizeBodyText で除去 |
| ログイン切れ | `setup-auth.js` で再ログイン |

---

## 設計上のポイント

1. **エージェントオーケストレーションではなく、Node 単一プロセスでモジュール分業**。Claude Code 側でサブエージェントを束ねるのではなく、責務を `lib/*.js` に分割している。これによりローカル cron / GitHub Actions / 任意のスケジューラから直接叩ける。
2. **Claude API を呼ぶのは 2 箇所だけ**: 本文生成と固有名詞ファクトチェック。コスト管理しやすい。
3. **proper-noun-checker は独立工程**。本文生成 LLM に固有名詞検証まで負わせず、別 LLM コールに切り出すことで「本文を書きすぎる」副作用を抑え、保守的な置換だけに専念させている。`web_search` ツールを与えることで、訓練データに無い実在チェックも可能。
4. **2 段階のサニタイズ**（LLM 入力前 + LLM 出力後）で、自動字幕の表記揺れと LLM の Markdown 暴走の両方をカバー。
5. **note エディタは Markdown を解釈しない**ため、太字・見出し・区切り線・画像はすべて Playwright がエディタ UI 経由で挿入する（`Cmd+B` トグル等）。生成側で Markdown 記法を出させない設計と、投稿側でエディタ API を叩く設計が対になっている。

---

## ライセンス

設計メモとして公開。コード本体は含まれていません。
