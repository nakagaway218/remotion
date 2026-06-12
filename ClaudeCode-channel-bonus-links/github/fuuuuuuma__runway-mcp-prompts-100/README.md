# runway-mcp-prompts-100

Runway MCP の **導入手順** と、Runway Gen-4 系の動画生成向け **オリジナル・プロンプト100選**（英語プロンプト＋日本語解説）をまとめた公開リポジトリです。

- **導入手順** … Claude（Desktop / Code）・Cursor・ChatGPT・Codex から Runway を MCP で叩く方法
- **プロンプト100選** … 動画中心。すべて新規作成（既存記事の転載なし）
- **機械可読** … [`prompts.json`](prompts.json) で自動化・MCP 連携にそのまま流し込める

> 出典の正確性について: 導入手順は [runwayml.com/mcp](https://runwayml.com/mcp) と公式ヘルプを 2026-05-29 時点で確認して記載しています。仕様は変わる場合があるため、最終的には公式ページをご確認ください。本リポジトリは Runway 公式とは無関係の非公式まとめです。

---

## 1. Runway MCP とは

MCP（Model Context Protocol）対応の AI ツール（Claude、ChatGPT、Cursor など）から、**コンテキストを切り替えずに** Runway で画像・動画を生成できる公式コネクタです。

- 利用可能モデル（公式記載）: **Seedance 2.0 / GPT image 2 / Kling / Nano Banana Pro / Gen-4.5**
- できること: 画像・動画生成、URL からのマーケ動画、セリフ付き広告、マルチショットのストーリー生成 など
- 課金: Runway アプリと同じく **アカウントのクレジット** を消費（モデル・解像度・設定でコストが変動）。生成物は Runway ライブラリに保存されます。

---

## 2. 導入手順（リモートMCP・推奨）

APIキー不要。**Runwayアカウントでサインイン**するだけの OAuth 方式です。

- **MCP サーバー URL**: `https://mcp.runwayml.com/mcp`
- 公式ヘルプ: <https://help.runwayml.com/hc/en-us/articles/51931843164691-Connecting-to-Runway-MCP>

### Claude（Desktop / claude.ai）※公式記載の手順
1. Claude の **Customize → Connectors** を開く
2. 新規コネクタを作成し、名前を `Runway` にする
3. 上記 URL を貼り付ける
4. **Add → Connect** をクリック
5. Runway アカウントでサインインして認証

### Claude Code（CLI）
リモート HTTP として追加し、`/mcp` で OAuth 認証します。
```bash
claude mcp add --transport http runway https://mcp.runwayml.com/mcp
# 追加後、Claude Code 内で /mcp を実行してブラウザ認証
```

### Cursor ※標準的な設定方法（公式ページに個別記載なし）
`~/.cursor/mcp.json`（プロジェクト単位なら `.cursor/mcp.json`）に追記:
```json
{
  "mcpServers": {
    "runway": {
      "url": "https://mcp.runwayml.com/mcp"
    }
  }
}
```
保存後、Cursor の MCP 設定画面で `runway` を有効化し、サインインします。

### ChatGPT
ChatGPT の **Settings → Connectors**（カスタムコネクタ／開発者モード。対応プランが必要）から上記 MCP URL を追加し、Runway アカウントで認証します。詳細は上記の公式ヘルプ記事を参照してください。

### Codex（OpenAI CLI）※ブリッジ方式（公式ページに個別記載なし）
Codex はローカル（stdio）MCP 前提のため、リモート OAuth サーバーには `mcp-remote` ブリッジを噛ませるのが一般的です。`~/.codex/config.toml` に追記:
```toml
[mcp_servers.runway]
command = "npx"
args = ["-y", "mcp-remote", "https://mcp.runwayml.com/mcp"]
```
初回起動時にブラウザで Runway 認証が走ります。

### Replit
公式が対応を明記。Replit のコネクタ設定から同じ MCP URL を追加します。

---

## 3. 導入手順（自前ホスト版・APIキー使用）

開発者として API を直接叩きたい場合は、Runway 公式の OSS MCP サーバーを自分で動かせます。

- 公式リポジトリ: <https://github.com/runwayml/runway-api-mcp-server>
- 前提: [Runway API](https://dev.runwayml.com/) の開発者アカウント＋課金設定＋APIキー、Node.js

```bash
git clone https://github.com/runwayml/runway-api-mcp-server
cd runway-api-mcp-server
npm install
npm run build   # build/index.js が生成される
```

Claude Code（stdio）に追加する例:
```bash
claude mcp add runway-api -- node /絶対パス/runway-api-mcp-server/build/index.js
# 環境変数に APIキーを設定: RUNWAYML_API_SECRET
```

Claude Desktop の `claude_desktop_config.json` 例（公式 README より）:
```json
{
  "mcpServers": {
    "runway-api-mcp-server": {
      "command": "node",
      "args": ["<クローンした絶対パス>/build/index.js"],
      "env": {
        "RUNWAYML_API_SECRET": "<YOUR_RUNWAY_API_KEY>",
        "MCP_TOOL_TIMEOUT": "1000000"
      }
    }
  }
}
```
利用可能ツール: `runway_generateVideo` / `runway_generateImage` / `runway_upscaleVideo` / `runway_editVideo` / `runway_getTask` / `runway_cancelTask` / `runway_getOrg`

> 公式注意: Runway API で生成した画像のリンクは **24時間で失効** します。期限内にダウンロードしてください。

---

## 4. プロンプトの使い方

接続後は、AI に英語プロンプトを渡して生成を依頼するだけです。

```text
Use Runway to generate a video. Prompt:
"A lone traveler stands at the edge of a cliff at dawn, the camera slowly pushing in
from behind as warm golden light spreads across a sea of clouds below, anamorphic lens
with soft flares, epic cinematic mood." ratio 16:9, duration 10s
```

### 書き方の3原則（Runway Gen-4）
1. **キーワード羅列ではなく完成した文で書く**（Runway は自然文の解釈に強い）
2. **構成テンプレ**: `被写体＋外見` ＋ `動き／アクション` ＋ `場所・状況` ＋ `カメラワーク` ＋ `光` ＋ `スタイル・ムード`
3. **カメラ語彙を明示**: push-in / dolly / tracking / crane up / orbit / handheld / aerial(drone) / tilt / whip pan / slow motion など

---

## 5. 収録カテゴリ（全100件）

| カテゴリ | 件数 | カテゴリ | 件数 |
|---|---|---|---|
| シネマティック / 映画的ショット | 12 | ファンタジー・SF | 10 |
| カメラワーク / ダイナミックムーブ | 12 | アクション・スポーツ | 8 |
| 自然・風景の動き | 10 | アニメ・イラスト調モーション | 6 |
| 人物・ポートレートの動き | 10 | 抽象・モーショングラフィックス | 6 |
| プロダクト・コマーシャル | 12 | 料理・フード | 3 |
| 都市・建築・空撮 | 8 | 天候・時間帯・ムード転換 | 3 |

全文は **[PROMPTS.md](PROMPTS.md)**（人間用）/ **[prompts.json](prompts.json)**（機械用）

---

## 6. ファイル構成・再生成

| ファイル | 役割 |
|---|---|
| [`build.py`](build.py) | 単一ソース。プロンプトの正典データ＋生成ロジック |
| [`PROMPTS.md`](PROMPTS.md) | 人間が読む用（カテゴリ別・英語＋日本語解説） |
| [`prompts.json`](prompts.json) | 機械可読（id / category / ratio / duration / prompt / note） |

プロンプトを追加・修正したら `build.py` だけを編集し、再生成します（2出力が同期）:
```bash
python3 build.py
```

---

## 7. ライセンス・免責

- 本リポジトリのプロンプト・文章はすべて **オリジナルの新規作成** です。
- ライセンス: [MIT](LICENSE)（自由に利用・改変可）。
- 本リポジトリは **Runway 公式とは無関係** の非公式まとめです。Runway の名称・モデル名は各権利者に帰属します。
- 導入手順は 2026-05-29 時点の情報です。最新は [runwayml.com/mcp](https://runwayml.com/mcp) を確認してください。
