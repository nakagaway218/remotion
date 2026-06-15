# Teaching Materials

教材制作、問題作成、解答作成、授業用資料整理のための作業フォルダです。

もともと空フォルダでしたが、AI 社員化の対象として使えるように、教材制作の標準フローをここに置きます。個別テーマは下位フォルダに分けます。

## 想定する下位フォルダ

```text
teaching materials/
  Rikei_Kokkouritu_Juken/
  [subject-or-project-name]/
```

## 置き場所の判断ルール

新しい学習ツールや教材を作るときは、まず `teaching materials/` の下にテーマ別フォルダを作るか確認します。

- 理系・国公立大学受験向け: `Rikei_Kokkouritu_Juken/`
- 小論文対策向け: `Shoronbun_Taisaku/` などの別フォルダ
- 英検対策向け: `Eiken_Taisaku/` などの別フォルダ
- 中学英語、定期テスト、私立大学対策、汎用学習支援ツール: それぞれ別フォルダ

依頼内容と現在のフォルダが合わない場合は、作業を始める前にユーザーへ確認します。明らかに新規テーマの場合は、`teaching materials/[project-name]/` を保存先候補として提案します。既存ファイルを移動する場合は、ユーザー確認を優先します。

## 元資料の置き場所

画像、PDF、スクリーンショット、スキャン資料などの元資料は、対象プロジェクト内の `source-materials/` に置きます。

```text
teaching materials/
  [project-name]/
    source-materials/
      images/
      documents/
    work/
    outputs/
```

公開範囲が不明な資料、生徒情報、有料教材、転載不可資料は GitHub に入れません。その場合はローカル保管にして、GitHub には出典メモ、要約、自作した教材だけを残します。

## GitHub に含めるもの

- 教材の作成手順
- 公開してよい問題文や解答例
- AI 社員フロー、README、テンプレート

## GitHub に含めないもの

- 生徒の個人情報
- 有料教材や転載できない本文
- 未整理の画像、PDF、提出物
- 公開範囲が不明な学校資料
