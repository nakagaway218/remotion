# Pixel Agents セットアップ

以下をすべて自動で実行してください。各ステップでエラーが出たら止めて報告してください。

## やること

VS Code拡張「Pixel Agents」をセットアップする。
Claude Codeのエージェントがピクセルアートのキャラになって仮想オフィスで動く可視化ツール。

- GitHub: https://github.com/pablodelucca/pixel-agents
- Marketplace: https://marketplace.visualstudio.com/items?itemName=pablodelucca.pixel-agents

## Step 1: 前提チェック

```
which brew || echo "Homebrewが必要です: https://brew.sh"
which code || echo "VS Code未インストール"
which claude || echo "Claude Code CLI未インストール"
```

## Step 2: VS Codeインストール（未インストールの場合のみ）

```
brew install --cask visual-studio-code
```

インストール済みなら何もしない。

## Step 3: Pixel Agents拡張インストール

```
code --install-extension pablodelucca.pixel-agents
```

## Step 4: インストール確認

```
code --list-extensions --show-versions | grep pixel
```

`pablodelucca.pixel-agents@X.X.X` が表示されればOK。

## Step 5: VS Code起動

現在の作業ディレクトリで起動:

```
open -a "Visual Studio Code" .
```

## Step 6: ユーザーへの案内（これを出力して）

セットアップ完了後、以下をそのまま表示してください:

---

### ✅ Pixel Agents セットアップ完了

**パネルの開き方:**
1. VS Code上部メニュー → **View** → **Open View...**
2. リストから **「Pixel Agents」** を選択
3. 画面下部にピクセルアートのオフィスが表示される

**使い方:**
- **「+ Agent」ボタン** → Claude Codeターミナルが起動し、キャラが出現
- **「Layout」ボタン** → オフィスの家具・壁を配置
- **「Settings」ボタン** → サウンド通知などの設定

**注意:**
- パネルは左サイドバーではなく **下のパネル領域（ターミナルと同じ場所）** に出る
- 初回は Claude Code for VS Code（Anthropic公式・別の拡張）も自動インストールされることがある。競合はしないのでそのままでOK
- 複数の「+ Agent」で複数キャラを同時に動かせる（それぞれ独立したClaude Codeセッション）

---

