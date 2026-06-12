# OpenAI 大型アップデートまとめ（2026年5月版）

> ChatGPT インスタントモデル / GPT-Realtime 2 / 音声系API / Codex for Chrome を**実用事例・APIコードサンプル・料金・移行ガイド**まで踏み込んで解説。
>
> 最終更新: 2026-05-10
> 対象読者: 開発者・プロダクトマネージャー・AI活用担当者・コンテンツクリエイター

---

## 目次

1. [サマリー（30秒で読む）](#1-サマリー30秒で読む)
2. [GPT-5.5 Instant — ChatGPTの新しいデフォルトモデル](#2-gpt-55-instant--chatgptの新しいデフォルトモデル)
3. [GPT-Realtime-2 — GPT-5級推論を持つ音声モデル](#3-gpt-realtime-2--gpt-5級推論を持つ音声モデル)
4. [GPT-Realtime-Translate — リアルタイム同時通訳API](#4-gpt-realtime-translate--リアルタイム同時通訳api)
5. [GPT-Realtime-Whisper — ストリーミング文字起こし](#5-gpt-realtime-whisper--ストリーミング文字起こし)
6. [Realtime API 周辺の新機能（MCP / 画像 / SIP）](#6-realtime-api-周辺の新機能mcp--画像--sip)
7. [Codex for Chrome — ブラウザで動くコーディングエージェント](#7-codex-for-chrome--ブラウザで動くコーディングエージェント)
8. [実用事例集（業種別ユースケース）](#8-実用事例集業種別ユースケース)
9. [料金・コスト試算チートシート](#9-料金コスト試算チートシート)
10. [移行ガイド（既存実装からのアップデート手順）](#10-移行ガイド既存実装からのアップデート手順)
11. [既知の制約・注意点](#11-既知の制約注意点)
12. [出典](#12-出典)

---

## 1. サマリー（30秒で読む）

2026年5月、OpenAI は「テキスト・音声・ブラウザ」の3軸で大規模アップデートを連続投入しました。

| 日付 | 製品 | 一言で |
|---|---|---|
| **2026-05-05** | **GPT-5.5 Instant** | ChatGPTのデフォルトを刷新。ハルシネーション 52.5% 減 |
| **2026-05-07** | **GPT-Realtime-2** | GPT-5級推論を持つ音声モデル。コンテキスト 128K |
| **2026-05-07** | **GPT-Realtime-Translate** | 70+ → 13言語のライブ翻訳。$0.034/分 |
| **2026-05-07** | **GPT-Realtime-Whisper** | ストリーミングSTT。$0.017/分 |
| **2026-05-07** | **Codex for Chrome** | DevTools・マルチタブ対応のブラウザ拡張 |

ポイントは「**Realtime API がエンタープライズ電話・通訳・教育・サポート用途で実用フェーズに入った**」「**Codex がIDE外（ブラウザ）に進出**」「**ChatGPT本体がより少ない言葉で正確に答える方向へ最適化**」の3点です。

---

## 2. GPT-5.5 Instant — ChatGPTの新しいデフォルトモデル

### 2-1. リリース概要

- **リリース日**: 2026年5月5日
- **置き換え対象**: GPT-5.3 Instant（旧デフォルト）
- **API名**: `chat-latest`（API経由でも利用可能）
- **GPT-5.3 Instant の延命**: 有料ユーザー向けにモデル設定から **3か月間** 利用可（その後リタイア）

### 2-2. 性能改善の数字

| ベンチマーク | GPT-5.3 Instant | GPT-5.5 Instant | 上昇幅 |
|---|---|---|---|
| **AIME 2025**（数学コンテスト） | 65.4% | **81.2%** | +15.8pt |
| **GPQA**（PhD級科学推論） | 78.5% | **85.6%** | +7.1pt |
| **MMMU-Pro**（マルチモーダル専門問題） | 69.2% | **76.0%** | +6.8pt |
| **High-stakes hallucination**（法・医・金融） | — | **-52.5%** | ハルシネーション半減 |

### 2-3. 体感面の変化

公式ブログによれば、応答は「**30.2% 短い単語数**、**29.2% 短い行数**」で同等以上の品質を維持。トーンも「**インフォーマルかつ実務的、職場でも安全**」に最適化されています。

具体的な変化:
- 過剰な前置き・免責文言の削減
- 箇条書きの過剰使用が減少（必要なときだけ箇条書き）
- STEM 質問・写真/画像分析が改善
- Web 検索を呼ぶか否かの判断精度が向上

### 2-4. パーソナライゼーション機能

GPT-5.5 Instant は次の3つを参照して回答を組み立てます。

1. **過去のチャット履歴**
2. **アップロード済みファイル**
3. **接続済み Gmail**（オプトイン）

さらに、新機能として **「メモリーソース透明性（memory source transparency）」** が全モデルに展開されました。回答に使われた文脈をユーザーが**確認・編集・削除**できます。古い情報を訂正したり、回答に紐づく Gmail スレッドを切り離したりが可能です。

### 2-5. 展開ロードマップ

| ティア | Web | モバイル |
|---|---|---|
| Plus / Pro | ✅ 先行展開 | ✅ 順次 |
| Free / Go | 数週間以内 | 数週間以内 |
| Business / Enterprise | 数週間以内 | 数週間以内 |

### 2-6. API での利用例（cURL）

```bash
curl https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "chat-latest",
    "messages": [
      {"role": "system", "content": "あなたは医療用語を分かりやすく解説するアシスタントです。"},
      {"role": "user", "content": "心筋梗塞の初期症状は？"}
    ]
  }'
```

`chat-latest` を指定するとデフォルトモデル（GPT-5.5 Instant）に常時追従します。本番系で固定したい場合は、リリース後に発表される具体的なモデル ID（例: `gpt-5.5-instant-2026-05-05` 形式）を指定してください。

---

## 3. GPT-Realtime-2 — GPT-5級推論を持つ音声モデル

### 3-1. 何が新しいか

| 項目 | gpt-realtime（旧） | **gpt-realtime-2（新）** |
|---|---|---|
| 推論レベル | GPT-4 級 | **GPT-5 級**（speech-to-speech） |
| コンテキスト | 32K | **128K** |
| 推論努力（reasoning effort） | なし | `minimal / low / medium / high / xhigh`（デフォルト `low`） |
| 関数呼び出し | 改善版 | **長時間関数呼び出し中も会話継続** |
| 画像入力 | ❌ | ✅（写真・スクショ併用） |
| MCP サーバ接続 | ❌ | ✅（リモート MCP をセッション設定で渡せる） |
| SIP 着信 | ❌ | ✅（電話網と直結） |

### 3-2. 料金

| 種別 | 料金 |
|---|---|
| 音声入力 | **$32 / 1M tokens** |
| キャッシュ済み入力 | $0.40 / 1M tokens |
| 音声出力 | **$64 / 1M tokens** |

### 3-3. WebSocket 接続コード（Node.js）

```javascript
import WebSocket from "ws";

const url = "wss://api.openai.com/v1/realtime?model=gpt-realtime-2";
const ws = new WebSocket(url, {
  headers: {
    Authorization: "Bearer " + process.env.OPENAI_API_KEY,
    "OpenAI-Safety-Identifier": "hashed-user-id",
  },
});

ws.on("open", () => {
  ws.send(JSON.stringify({
    type: "session.update",
    session: {
      modalities: ["audio", "text"],
      instructions: "あなたは丁寧な日本語のカスタマーサポート担当です。",
      voice: "alloy",
      input_audio_format: "pcm16",
      output_audio_format: "pcm16",
      turn_detection: { type: "server_vad" },
      // GPT-5級推論をどこまで使うか
      reasoning: { effort: "medium" },
    },
  }));
});

ws.on("message", (data) => {
  const event = JSON.parse(data);
  // event.type に応じて音声 chunk / 文字起こし / function_call を処理
});
```

### 3-4. Python で SIP 着信を受ける

```python
import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])

# Twilio などからの着信 webhook に call_id が届く想定
def accept_inbound_call(call_id: str):
    return client.realtime.calls.accept(
        call_id=call_id,
        model="gpt-realtime-2",
        voice="alloy",
        instructions=(
            "電話に出たら『お電話ありがとうございます、AI受付です』と挨拶し、"
            "用件を伺ってください。"
        ),
        tools=[
            {
                "type": "function",
                "name": "lookup_reservation",
                "description": "予約番号から予約情報を引く",
                "parameters": {
                    "type": "object",
                    "properties": {"reservation_id": {"type": "string"}},
                    "required": ["reservation_id"],
                },
            }
        ],
    )
```

### 3-5. 推論努力レベルの選び方

| 用途 | 推奨 effort | 根拠 |
|---|---|---|
| 受付・FAQ Bot | `minimal` / `low` | 応答速度優先、定型処理 |
| カスタマーサポート（一般） | `low` | デフォルト。低レイテンシと推論のバランス |
| 法務・医療・金融サポート | `medium` / `high` | ハルシネーション抑制とロジック整合 |
| 複雑な多段ツール呼び出し（例: 在庫照会→予約→決済） | `high` / `xhigh` | 計画立案とエラーリカバリ |

### 3-6. 関数呼び出しの3軸改善

OpenAI 自身が公式に挙げた改善は以下の通り。

1. **どの関数を呼ぶか**（relevance）
2. **いつ呼ぶか**（timing）
3. **どんな引数で呼ぶか**（arguments accuracy）

加えて、**長時間かかる関数呼び出し（DB照会・外部APIなど）の最中でも会話が止まらない**よう改善されています。これは音声エージェントで「ちょっと待ってください」を自然に挟みながらツールを実行できることを意味します。

---

## 4. GPT-Realtime-Translate — リアルタイム同時通訳API

### 4-1. 概要

- **入力**: 70+ 言語の音声（連続ストリーム）
- **出力**: 13 言語の音声
- **料金**: **$0.034 / 分**
- **遅延**: ストリーム処理のため、文単位の同時通訳が現実的

### 4-2. 想定ユースケース

| 業界 | 適用例 |
|---|---|
| カスタマーサポート | 多言語コールセンターの自動通訳介在 |
| クロスボーダー営業 | 商談中の同時通訳。CRMにテキストも保存 |
| 教育 | 海外講師のライブ授業を学習者の母語で受講 |
| イベント・メディア | カンファレンスの同時通訳配信 |
| クリエイター | YouTube ライブを多言語同時放送 |
| 医療・公共サービス | 外国人患者・住民との対面コミュニケーション |

### 4-3. 構成例（Node.js + WebSocket）

```javascript
const ws = new WebSocket(
  "wss://api.openai.com/v1/realtime?model=gpt-realtime-translate"
);

// 入力 PCM16 音声を継続送信し、13 言語のうち target を指定
ws.on("open", () => {
  ws.send(JSON.stringify({
    type: "session.update",
    session: {
      input_audio_format: "pcm16",
      output_audio_format: "pcm16",
      translation: { target_language: "en" },  // 出力言語
    },
  }));
});
```

### 4-4. 競合との比較ポイント

- 既存の DeepL Voice / Google Translate Live と比較して、**「同じセッション内で会話文脈を保持しながら通訳」** ができるのが最大の差別化点
- 名前・固有名詞・略語の保持精度が高い（前後文脈を見て判断するため）

---

## 5. GPT-Realtime-Whisper — ストリーミング文字起こし

### 5-1. Whisper との違い

| | Whisper（既存） | **GPT-Realtime-Whisper（新）** |
|---|---|---|
| 処理形態 | バッチ（録音後に転送） | **ストリーミング**（話している最中に文字化） |
| 遅延 | ファイル全長ぶん | リアルタイム |
| 主な用途 | 議事録・字幕の後処理 | ライブ字幕・リアルタイム検索・音声トリガー |
| 価格 | $0.006 / 分（既存） | **$0.017 / 分** |

価格はストリーミング版がやや高いものの、**「録音終了を待たずに次の処理（要約・翻訳・コマンド実行）を走らせられる」** メリットが大きく、ライブ配信や対話型アプリと相性が良いです。

### 5-2. ユースケース

- ライブ配信のリアルタイム字幕（YouTube Live, Twitch, Zoom）
- 通話モニタリング（コンプライアンスチェック）
- 音声操作 UI（話した瞬間に検索・コマンド実行）
- 教室・会議の同時記録

---

## 6. Realtime API 周辺の新機能（MCP / 画像 / SIP）

GPT-Realtime-2 と同時に Realtime API 全体にも以下の機能が追加されています。

### 6-1. MCP サーバ接続

セッション設定でリモート MCP サーバの URL を渡すと、**ツール呼び出しを自動で MCP 経由にルーティング**できます。

```json
{
  "type": "session.update",
  "session": {
    "tools": [
      {
        "type": "mcp",
        "server_url": "https://mcp.example.com/sse",
        "server_label": "internal-crm"
      }
    ]
  }
}
```

社内システムの MCP サーバ（CRM, 在庫DB, ERP）を **音声エージェントに直接接続** できるため、企業向けボイスエージェントの実装コストが大幅に下がります。

### 6-2. 画像入力

セッション中に画像（写真、スクリーンショット、図面）を音声・テキストと一緒に渡せるようになりました。

**実用例**:
- 「この症状（写真）について教えて」（医療相談）
- 「この画面のエラーを直す方法を音声で説明して」（テクニカルサポート）
- 「この間取り図、改善点ある？」（不動産・建築）

### 6-3. SIP（電話網）連携

**Twilio などを介さず**、SIP プロトコルで直接電話を受発信できます。

- インバウンドコール: `client.realtime.calls.accept(call_id=...)` で着信応答
- 通話中: 通常の Realtime セッションと同じ扱い
- アウトバウンドコール: 顧客への自動架電・予約確認・督促などに利用

これにより「**0からのカスタマーサポート電話システム**」が数百行のコードで構築可能になりました。

---

## 7. Codex for Chrome — ブラウザで動くコーディングエージェント

### 7-1. 概要

- **リリース日**: 2026年5月7日
- **対応OS**: macOS / Windows
- **配布**: Chrome Web Store（Codex アプリ経由）
- **対応外**: **EU および UK は当面利用不可**（「近日公開予定」）
- **ユーザー数**: Codex 全体で **週間 400万人**（2026年初頭比 8倍）

### 7-2. 何ができるか

Codex がブラウザを「乗っ取らずに共存」しながら以下を実行:

1. **マルチタブ横断の文脈取得** — 開いている複数タブの内容を踏まえて推論
2. **Web アプリの自動テスト** — フォーム入力・遷移・スクショ取得
3. **構造化ページのナビゲーション** — ダッシュボード・管理画面の操作
4. **データ入力フローの自動化** — 営業ツール、SaaS設定画面など
5. **Web DevTools の操作** — Console, Network, Performance を AI が読む
6. **サインイン済みセッションの利用** — LinkedIn / Salesforce / Gmail / 社内ツール

特に「**ユーザーがログイン済みの認証コンテキストを使って AI が代理操作**」できる点が大きく、社内 SaaS の操作を自然言語で代替できます。

### 7-3. インストール手順

1. Codex アプリを開く
2. **Plugins** タブで **Chrome plugin** を選択 → Add
3. セットアップフローに従い Chrome 拡張をインストール
4. Chrome で Codex 拡張が **Connected** になっていることを確認

### 7-4. 権限モデル（重要）

セキュリティ上の制御:

- **サイトごとに毎回確認**: Codex が新しいドメインへアクセスする際は **都度ユーザーに確認**
- **「常に許可」は無し**: 履歴アクセスは **リクエスト単位**でのみ許可可能
- **Allowlist / Blocklist**: 信頼するドメイン・拒否するドメインを設定可能
- **Chrome 標準の権限**: 履歴・ブックマーク・ページデータへのアクセスはインストール時に確認

### 7-5. Tab Group による作業分離

Codex のスレッドごとに Chrome の **Tab Group** が作られ、その中だけで動作します。手元の作業タブを汚さないので、人間の作業と並列に走らせられます。

### 7-6. Chrome DevTools MCP との関係

Codex Chrome 拡張は内部的に **Chrome DevTools MCP** とも連携可能で、以下を AI に開放できます。

- Console ログの解析
- Network リクエストの追跡
- Performance プロファイリング
- DOM スナップショット取得

これにより **「実機で動くアプリの不具合を、エージェントが DevTools を見ながらデバッグ」** が可能になりました。

### 7-7. 実用シナリオ

| シナリオ | Codex の動作 |
|---|---|
| 「この React アプリの遅さを調べて」 | DevTools の Performance を取得 → ボトルネック特定 → コード修正提案 |
| 「LinkedIn の最近の投稿から営業リストを作って」 | サインイン済みセッションでスクレイピング → CSV出力 |
| 「Salesforce の今期の案件を一覧化して、Slack に流して」 | Salesforce 操作 → 集計 → Slack送信 |
| 「Web フォームの本番投入前テストを20パターンで回して」 | フォーム自動入力 → エラー収集 → レポート生成 |

---

## 8. 実用事例集（業種別ユースケース）

### 8-1. カスタマーサポート（電話 + チャット）

**構成**:
- 電話: SIP 直結で **GPT-Realtime-2** が応対（`reasoning: medium`）
- チャット: **GPT-5.5 Instant** が応対
- 多言語: **GPT-Realtime-Translate** で外国語着信を社内日本語にリレー
- ナレッジ参照: 社内 MCP サーバ経由で FAQ DB / 注文 DB を引く

**期待効果**:
- ハルシネーション 52.5% 減により、回答の信頼性向上
- 外国語対応のオペレーター不要化
- 平均処理時間短縮（音声→ツール→音声がワンセッションで完結）

### 8-2. 海外向けライブ配信

**構成**:
- 配信音声を **GPT-Realtime-Whisper** で文字化（字幕用）
- 同時に **GPT-Realtime-Translate** で英語・スペイン語・中国語に翻訳
- 翻訳結果を OBS のテキスト入力にストリーム

**コスト試算**（90分配信、1音声で日→英のみ翻訳の場合）:
- Whisper: $0.017 × 90 = **$1.53**
- Translate: $0.034 × 90 = **$3.06**
- 合計: **約 $4.6 / 配信**（人手通訳の数十分の一）

### 8-3. 開発チームのコードレビュー支援

**構成**:
- ローカル開発: **Codex for Chrome** で開発中のアプリを実機テスト
- DevTools MCP 経由で Console エラー / Network 失敗を AI が読む
- バグ修正を ChatGPT（GPT-5.5 Instant）と対話しながら進める

### 8-4. 営業の事前リサーチ

**構成**:
- **Codex for Chrome** に「明日のアポ先10社を LinkedIn と公式サイトでリサーチして」と依頼
- サインイン済みセッションで効率的に情報収集
- 結果を **GPT-5.5 Instant** に渡して提案資料の下書きを生成

### 8-5. クリエイター（YouTuber, ストリーマー）

**構成**:
- Premiere Pro 書き出し済み音声を **Whisper（既存）** または **Realtime-Whisper** で文字化 → SRT 字幕
- SRT を **GPT-5.5 Instant** で多言語化 / トーン調整
- ライブ配信時は **Realtime-Translate** で英語同時配信

### 8-6. 医療現場・公共サービス

**構成**:
- 受付窓口に SIP 連携の **Realtime-2 + Translate**
- 多言語の問診を AI が一次対応 → 必要に応じて人間にエスカレ
- MCP 経由で診療予約 DB と接続

---

## 9. 料金・コスト試算チートシート

### 9-1. 音声系（1分あたり概算）

| モデル | 入力 | 出力 | 1分あたり目安（会話） |
|---|---|---|---|
| GPT-Realtime-2 | $32 / 1M tokens | $64 / 1M tokens | 約 $0.10〜0.30（会話密度による） |
| GPT-Realtime-Translate | — | — | **$0.034 固定** |
| GPT-Realtime-Whisper | — | — | **$0.017 固定** |

### 9-2. キャッシュ活用

GPT-Realtime-2 の **キャッシュ済み入力 $0.40 / 1M tokens** は通常入力の **約 80分の1**。同じシステムプロンプト・ツール定義を使い回すケースでは積極的に活用したい。

### 9-3. 月間利用シミュレーション（カスタマーサポート1席）

- 1日 6時間稼働 × 22営業日 = **132時間/月**
- うち実通話 30%（39.6時間）= **2,376分**
- GPT-Realtime-2 のみ運用で 1分あたり $0.20 と仮定
- **月額 約 $475 / 席** （≒ 7万円台）

→ 人件費（数十万円/席）と比較して 1/5〜1/10。多言語対応や24時間対応では更に効果大。

---

## 10. 移行ガイド（既存実装からのアップデート手順）

### 10-1. ChatGPT API を使っている場合

1. モデルを `chat-latest` に切り替え（または GPT-5.5 Instant の固定 ID）
2. プロンプトを再評価:
   - GPT-5.5 Instant は**短く返す傾向**。冗長な指示は不要
   - 法務・医療・金融のシステムプロンプトでハルシネーション対策を緩められる
3. 応答長の自動カットや UI 側の表示行数調整が必要な場合あり
4. パーソナライゼーション機能を使う場合、Gmail 接続のオプトイン UX を整備

### 10-2. 旧 Realtime API（`gpt-realtime` / `gpt-4o-realtime`）から移行

1. モデル ID を `gpt-realtime-2` に変更
2. `session.update` に `reasoning: { effort: ... }` を追加（推奨）
3. コンテキスト 32K → 128K への拡張に合わせて、長文文脈の使い方を再設計
4. MCP / 画像 / SIP を使うなら新たに対応コード追加
5. 関数呼び出しのプロンプトを見直し（精度が上がっているので冗長なヒントを減らせる）

### 10-3. Codex CLI ユーザー

- Codex アプリの Plugins から Chrome 拡張を追加するだけ
- CLI と Chrome の両方を 1スレッドで使えるため、ローカル開発 → 実機テストの往復が滑らかに

---

## 11. 既知の制約・注意点

- **Codex for Chrome は EU / UK 未対応**（2026年5月時点）。VPN 等での回避は OpenAI の利用規約に抵触するおそれがあるので推奨しません。
- **GPT-Realtime-2 の `xhigh` は高コスト**。レイテンシも増えるので、必要なステップでだけ部分的に上げる設計が望ましい（複数セッションを使い分ける、または途中で `session.update` する）。
- **Realtime-Translate の出力言語は 13 言語**。日本語 → 英語、英語 → 日本語など主要ペアはカバーされていますが、出力先がマイナー言語の場合は対応状況を確認すること。
- **メモリーソース透明性** はユーザーが過去履歴を編集できるため、ビジネス用途では「履歴に意図せず混ざった機密情報」のレビュー運用が必要。
- **Codex Chrome 拡張のサインイン済みセッション利用** は強力ですが、**監査ログとアクセス制御**を社内ポリシーで整備すべき。
- **API の chat-latest はデフォルトに追従する**ため、プロダクション系は具体的なバージョン ID 固定を推奨（互換性維持目的）。

---

## 12. 出典

### GPT-5.5 Instant
- [GPT-5.5 Instant: smarter, clearer, and more personalized — OpenAI](https://openai.com/index/gpt-5-5-instant/)
- [Introducing GPT-5.5 — OpenAI](https://openai.com/index/introducing-gpt-5-5/)
- [OpenAI releases GPT-5.5 Instant, a new default model for ChatGPT — TechCrunch](https://techcrunch.com/2026/05/05/openai-releases-gpt-5-5-instant-a-new-default-model-for-chatgpt/)
- [OpenAI updates ChatGPT Instant with GPT 5.5 — Axios](https://www.axios.com/2026/05/05/openai-chatgpt-update-default-model)
- [ChatGPT update rolls out GPT-5.5 Instant — The Decoder](https://the-decoder.com/chatgpt-update-rolls-out-gpt-5-5-instant-with-fewer-hallucinations-and-more-personalized-answers/)
- [GPT-5.5 Instant: 9 Powerful ChatGPT Upgrades Explained — ProgressiveRobot](https://www.progressiverobot.com/2026/05/07/gpt-5-5-instant/)

### GPT-Realtime-2 / 音声系API
- [Advancing voice intelligence with new models in the API — OpenAI](https://openai.com/index/advancing-voice-intelligence-with-new-models-in-the-api/)
- [Introducing gpt-realtime and Realtime API updates for production voice agents — OpenAI](https://openai.com/index/introducing-gpt-realtime/)
- [Realtime and audio — OpenAI API Docs](https://developers.openai.com/api/docs/guides/realtime)
- [Realtime API with WebSocket — OpenAI API Docs](https://developers.openai.com/api/docs/guides/realtime-websocket)
- [Realtime API with WebRTC — OpenAI API Docs](https://developers.openai.com/api/docs/guides/realtime-webrtc)
- [Realtime API with SIP — OpenAI Platform](https://platform.openai.com/docs/guides/realtime-sip)
- [Realtime translation — OpenAI API Docs](https://developers.openai.com/api/docs/guides/realtime-translation)
- [Build Live Translation Apps with gpt-realtime-translate — OpenAI Cookbook](https://developers.openai.com/cookbook/examples/voice_solutions/realtime_translation_guide)
- [MCP and Connectors — OpenAI API Docs](https://developers.openai.com/api/docs/guides/tools-connectors-mcp)
- [OpenAI launches GPT-Realtime-2 and two new voice API models — TheNextWeb](https://thenextweb.com/news/openai-gpt-realtime-2-voice-models)
- [OpenAI has new voice models that reason, translate, and transcribe — 9to5Mac](https://9to5mac.com/2026/05/07/openai-has-new-voice-models-that-reason-translate-and-transcribe-as-you-speak/)
- [What Is GPT-Realtime-2 and How to Use It — Apidog](https://apidog.com/blog/gpt-realtime-2-api/)

### Codex for Chrome
- [Codex Chrome extension — OpenAI Developers](https://developers.openai.com/codex/app/chrome-extension)
- [OpenAI's Codex Now Works in Chrome With New Extension — MacRumors](https://www.macrumors.com/2026/05/07/openai-codex-chrome-extension/)
- [OpenAI debuts a Codex plugin for Chrome — Engadget](https://www.engadget.com/2167480/openai-debuts-a-codex-plugin-for-chrome/)
- [OpenAI adds Chrome plugin and tests Remote control for Codex — Testing Catalog](https://www.testingcatalog.com/openai-adds-chrome-plugin-and-tests-remote-control-for-codex/)
- [OpenAI Adds Chrome Extension to Codex, Letting Its AI Agent Access LinkedIn, Salesforce, Gmail — MarkTechPost](https://www.marktechpost.com/2026/05/08/openai-adds-chrome-extension-to-codex-letting-its-ai-agent-access-linkedin-salesforce-gmail-and-internal-tools-via-signed-in-sessions/)
- [Codex for Chrome (2026): Capabilities, Architecture, and Use Case — Eigent](https://www.eigent.ai/blog/codex-for-chrome)
- [Chrome DevTools for agents — Chrome for Developers](https://developer.chrome.com/docs/devtools/agents)

---

> ※ 本資料は 2026年5月10日 時点の公開情報をもとに整理したものです。料金・仕様・展開地域は変更される可能性があります。実装前に必ず公式ドキュメントを確認してください。

