# youtube-html-slides

YouTube解説動画用の **16:9 HTMLスライド** を自動生成する Claude Code スキルです。

テーマとブランドカラーを伝えるだけで、ナビゲーション付きの本格的なHTMLスライドを作成します。

## できること

- 16:9固定のHTMLスライド生成（キーボード・ボタン・ドット操作対応）
- YouTube視聴者向けに最適化された構成設計（フック→説明→実演→まとめ）
- ブランドカラーを CSS変数で管理（差し替え簡単）
- Google Fonts（明朝体 × ゴシック体）で見やすいデザイン
- 生成後に構成品質をエージェントが自動チェック

## インストール

```bash
cp -r youtube-html-slides .claude/skills/
```

## 使い方

Claude Code に話しかけるだけです：

```
スライド作って
HTML資料作って
YouTube用の資料を作りたい
```

Claude がヒアリング→構成設計→HTML生成→レビューの順で進めます。

## ヒアリング項目

1. 動画のテーマ
2. 想定視聴者
3. 動画でやってもらいたい1アクション
4. ブランドカラー（省略可）
5. 保存先パス（省略可）

## サンプル

[examples/html-effectiveness-slides.html](./examples/html-effectiveness-slides.html)

「Claude Code でスライドをHTMLで作る方法」をテーマにしたサンプルスライドです。

## ファイル構成

```
youtube-html-slides/
├── SKILL.md                        # スキル本体（Claude が読む）
├── references/
│   ├── slide-structure.md          # 構成パターン集
│   └── html-template.md            # CSSデザインパターン集
└── examples/
    └── html-effectiveness-slides.html  # サンプル
```
