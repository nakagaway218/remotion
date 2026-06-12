# Pika × Claude で作れる動画 30 選 🎬

> Claude Code に Pika MCP を接続すると、チャットから動画・音声・リップシンクを直接生成できます。  
> このドキュメントでは **使えるコマンド・プロンプト例 30 パターン** を用途別にまとめています。

---

## 関連リンク

### 🔌 [pika.me/mcp](https://pika.me/mcp) — Pika MCP セットアップページ

Pika の MCP（Model Context Protocol）プラグインを Claude Code に接続するための公式ページ。  
接続すると `/pika:explainer` `/pika:ugc-ads` `/pika:podcast` などのスラッシュコマンドが使えるようになります。

**セットアップ手順（2 ステップ）**

1. **MCP 接続** — Claude の設定 → カスタムコネクターを追加
   ```
   URL: mcp.pika.me/api/mcp
   ```
2. **プラグイン有効化** — Pika スキルプラグインをインストールしてスラッシュコマンドを解放

料金はトークン方式（800 トークン $7.99〜）。Sora・Kling・Veo 3 など複数モデルに対応。

---

### 🐾 [clawd-on-desk](https://github.com/rullerzhou-afk/clawd-on-desk) — AIコーディングエージェントのデスクトップペット

Claude Code・Codex・Cursor・Copilot などの **AIエージェントの作業状態をリアルタイムで可視化** するデスクトップアプリ。

| 機能 | 詳細 |
|------|------|
| マルチエージェント対応 | Claude Code / Codex CLI / Copilot CLI / Gemini CLI など |
| アニメーション状態 | 思考・タイピング・ビルド・エラーなど 12 種類 |
| パーミッション管理 | ツール実行の許可/拒否をポップアップで操作 |
| 対応 OS | Windows 11 / macOS / Linux |

```bash
# インストール
# GitHubリリースページからインストーラーをDL → 実行するだけ
# Claude Code フックが自動登録され、起動後すぐに動作する
```

---

## Pika で作れる動画 30 選

### カテゴリ一覧

| # | カテゴリ | コマンド |
|---|---------|---------|
| 1〜5 | [URL解説動画](#-url解説動画-1-5) | `/pika:explainer` |
| 6〜11 | [UGC広告動画](#-ugc広告動画-6-11) | `/pika:ugc-ads` |
| 12〜16 | [ポッドキャスト動画](#-ポッドキャスト動画-12-16) | `/pika:podcast` |
| 17〜23 | [応用・組み合わせ](#-応用組み合わせ-17-23) | `/pika:explainer` + オプション |
| 24〜30 | [クリエイティブ活用](#-クリエイティブ活用-24-30) | 各種 |

---

### 🎥 URL解説動画（1〜5）

ブラウザを実際に操作しながら、アバターがナレーションする 60〜80 秒の解説動画を生成します。

---

#### 1. GitHubリポジトリ解説動画

README を自動スキャンし、コードブロック・アーキテクチャ・デモURLまで拾って解説します。

```
/pika:explainer https://github.com/anthropics/claude-code
```

**生成されるもの**
- リポジトリ構成のウォークスルー
- 主要ファイルへのナビゲーション
- ライブデモURLがあれば自動検出して紹介

---

#### 2. SaaSランディングページ紹介

製品の価値提案・機能一覧・CTAを順番に見せながら解説する営業ツールとして使えます。

```
/pika:explainer https://linear.app --focus "サイクルプランニング機能"
```

---

#### 3. ドキュメントサイト解説

APIドキュメントや公式ガイドを動画で説明。チームへの共有や社内研修に最適です。

```
/pika:explainer https://docs.anthropic.com/en/docs/claude-code/plugins
```

---

#### 4. ブログ記事・ニュース解説

テキスト記事を動画ナレーション付きでウォークスルー。SNS 二次利用に使えます。

```
/pika:explainer https://blog.example.com/ai-trends-2026 --focus "2026年のAIトレンド予測"
```

---

#### 5. 自社サービスの紹介動画（日本語）

日本語サイトにも対応。ナレーションが自動で日本語になります。

```
/pika:explainer https://n1-inc.co.jp/
```

**ポイント** — ページが日本語であれば TTS も日本語音声で生成されます。

---

### 📱 UGC広告動画（6〜11）

TikTok / Instagram Reels スタイルの 15 秒 UGC 広告を自動生成します。  
カテゴリを自動判定し、そのジャンルの「売れるトーク構成」で台本を生成します。

---

#### 6. アプリ・SaaS紹介広告（APP_REVEAL）

「何これ？」と思わせるフックで始まり、UIデモ → 機能 → CTAの流れで構成。

```
/pika:ugc-ads https://pika.me
```

**構成**
1. 困惑フック：「これ、なんて説明すればいいの…」
2. 製品名と概要紹介
3. 実際のUI操作画面
4. ワークフローへの変化（インサイト）
5. 「試してみて」CTA

---

#### 7. ファッション・ハウル動画（HAUL_UNBOX）

ブランドの開封シーンから素材感・ハードウェア詳細まで見せるハウル系コンテンツ。

```
/pika:ugc-ads https://maisonbrune.com avatar_url=https://example.com/face.jpg aspect_ratio=3:4
```

---

#### 8. フード・グルメ ASMR動画（FOOD_ASMR）

調理音・湯気・盛り付けの瞬間を見せながらナレーションする食欲促進型コンテンツ。

```
/pika:ugc-ads https://your-food-brand.com category=FOOD
```

**例の台本構成**
1. 「これ、ただ見てるだけで腹減る」（デモフック）
2. 食材名 + 第一印象
3. 調理の決定的シーン（蒸気・音）
4. 「これがデフォルトになった」（満足インサイト）
5. レシピ・購入リンク誘導

---

#### 9. 美容・スキンケア動画（BEAUTY_APPLY）

「○週間後」という時間軸で変化を見せる、ビフォーアフター構成の美容コンテンツ。

```
/pika:ugc-ads https://skincare-brand.com category=BEAUTY avatar_url=https://example.com/face.jpg
```

---

#### 10. フィットネス変容動画（FITNESS_TRANSFORM）

「やりたくなかったけど…」という共感フックから始まる、継続実績見せ系コンテンツ。

```
/pika:ugc-ads https://fitness-supplement.com category=FITNESS
```

---

#### 11. テック製品アンボックス（TECH_UNBOX）

開封の儀式から初起動・初使用シーンまでを見せるガジェット系コンテンツ。

```
/pika:ugc-ads https://framework.computer category=TECH
```

---

### 🎙️ ポッドキャスト動画（12〜16）

2人のホストが 1 分間（4 幕 × 15 秒）議論するポッドキャスト動画を生成します。  
URLを渡すと内容をレビュー、フリーテキストならトピックとして処理します。

---

#### 12. サービスのポッドキャストレビュー

URL を渡すと、ホスト A（熱狂派）と B（懐疑派）が製品を議論します。

```
/pika:podcast https://pika.art
```

---

#### 13. GitHubリポジトリ対談レビュー

OSS ツールを 2 人が掘り下げる開発者向けコンテンツ。

```
/pika:podcast https://github.com/anthropics/claude-code
```

---

#### 14. AI研究者の論争スタイル対談

架空の専門家 2 人がテーマを激論するコンテンツ。

```
/pika:podcast 2人のAI研究者がAGIは2030年前に実現するかを議論する
```

---

#### 15. 私 × 著名人スタイル対談

「私と〇〇が△△について話す」という形式で架空対談を生成します。

```
/pika:podcast 私とイーロン・マスクが火星移住のタイムラインについて話す
```

**注意** — 著名人の顔写真は自動生成されません（アーキタイプ肖像を使用）。

---

#### 16. 自分の声でホストAを担当

`use_avatar` オプションで登録した自分の声をホスト A に使用できます。

```
/pika:podcast https://cursor.com use_avatar
```

---

### ⚙️ 応用・組み合わせ（17〜23）

---

#### 17. 自分のアバターで解説動画

`--avatar` に自分の顔写真URLを渡すと、本人キャラで喋る解説動画になります。

```
/pika:explainer https://your-product.com --avatar https://cdn.example.com/your-face.jpg
```

---

#### 18. 特定機能にフォーカスした解説

`--focus` でナレーションの切り口を絞れます。

```
/pika:explainer https://notion.so --focus "AIによるタスク自動化機能"
```

---

#### 19. Kling リップシンクで高品質プレゼンター

`--lipsync-provider kling` で頭の動きが最小限の、プロプレゼンター風に。

```
/pika:explainer https://company.com --lipsync-provider kling
```

---

#### 20. 字幕なし版（BGMや別途字幕に対応）

`--no-captions` で字幕焼き込みをスキップ。

```
/pika:explainer https://product.com --no-captions
```

---

#### 21. プレビュー確認してから本番レンダリング

`--preview` で 3 秒のリップシンク確認後にフルレンダリングへ進めます。

```
/pika:explainer https://github.com/openai/whisper --preview
```

---

#### 22. ライブデモURLを手動指定

GitHubリポジトリでデモURLが自動検出されない場合に手動指定します。

```
/pika:explainer https://github.com/user/repo --live-url https://demo.example.com
```

---

#### 23. UGC広告に自分の声を使う

`avatar_url` と声クローン登録を組み合わせると、完全に自分キャラの広告になります。

```
/pika:ugc-ads https://your-product.com avatar_url=https://cdn.example.com/face.jpg
```

---

### 🎨 クリエイティブ活用（24〜30）

---

#### 24. 縦型（3:4）UGC広告

Instagram フィード向けの 3:4 アスペクト比（seedance プロバイダー限定）。

```
/pika:ugc-ads https://product.com aspect_ratio=3:4
```

---

#### 25. kling プロバイダーで高品質UGC広告

Kling v3 Omni を使用した高品質版。レンダリングに 5〜10 分かかりますが品質が向上します。

```
/pika:ugc-ads https://product.com provider=kling
```

---

#### 26. 字幕スタイルを変えたUGC広告

TikTok スタイル（紫ハイライト）で単語ごとに強調。

```
/pika:ugc-ads https://product.com captions=tiktok
```

---

#### 27. フード系アプリの縦型広告

食品デリバリーアプリを FOOD カテゴリ + 縦型で生成。

```
/pika:ugc-ads https://uber.com/jp/ja/order/ category=FOOD aspect_ratio=3:4
```

---

#### 28. 比較動画スタイルのポッドキャスト

2 つの製品を比較・議論するポッドキャスト形式コンテンツ。

```
/pika:podcast Claude Code と Cursor の違いを2人のエンジニアが議論する
```

---

#### 29. 採用・求人訴求動画

会社の採用サイトをポッドキャストレビュー形式で紹介。

```
/pika:podcast https://jobs.example.com
```

---

#### 30. 連続コンテンツ：複数URLを順番に解説

同じアバター・声で複数のページを解説する連続動画シリーズ。

```
/pika:explainer https://page1.com --avatar https://cdn.example.com/face.jpg --no-captions
/pika:explainer https://page2.com --avatar https://cdn.example.com/face.jpg --no-captions
/pika:explainer https://page3.com --avatar https://cdn.example.com/face.jpg --no-captions
```

> 同じ `--avatar` URL を使い回すことで、シリーズとして統一感が出ます。

---

## クイックリファレンス

### コマンド一覧

| コマンド | 用途 | 生成時間 |
|---------|------|---------|
| `/pika:explainer <url>` | URL解説動画（60〜80秒） | 5〜15分 |
| `/pika:ugc-ads <url>` | UGC広告（15秒） | 6〜12分 |
| `/pika:podcast <url or トピック>` | ポッドキャスト動画（60秒） | 10〜20分 |

### 主なオプション

| オプション | 対象 | 説明 |
|-----------|------|------|
| `--avatar <url>` | explainer | 自分の顔写真を使用 |
| `--focus "..."` | explainer | ナレーションの切り口を指定 |
| `--lipsync-provider kling` | explainer | 高品質リップシンク（遅め） |
| `--preview` | explainer | 3秒プレビュー確認 |
| `--no-captions` | explainer | 字幕なし |
| `avatar_url=<url>` | ugc-ads | アバター指定 |
| `aspect_ratio=3:4` | ugc-ads | 縦型（seedance限定） |
| `provider=kling` | ugc-ads | Kling プロバイダー |
| `use_avatar` | podcast | 自分の声でホストA担当 |

---

## セットアップ

```bash
# 1. Claude Code の設定ファイルを開く
# Settings > MCP Servers > Add Custom

# 2. 以下を追加
URL: mcp.pika.me/api/mcp

# 3. Pika プラグインをインストール（Claude Code のプラグインマーケットから）

# 4. 動作確認
/pika:explainer https://pika.art
```

詳細は [pika.me/mcp](https://pika.me/mcp) を参照。

---

## ライセンス

MIT — 自由に改変・再配布可能です。

---

> このリストは [河村風真 / AI収益化ラボ](https://n1-inc.co.jp/) がまとめました。
