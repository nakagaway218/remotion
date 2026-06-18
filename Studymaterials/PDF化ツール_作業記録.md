# PDF化ツール 作業記録

作成日: 2026-06-18

## 目的

Studymaterials の Excel 教材を、配布しやすいPDF形式に変換できるようにする。

特に、問題と解答、日曜始まりと月曜始まりなど、複数シートに分かれた教材を扱いやすくすることを目的にした。

## 背景

Excel教材を他人に提供する場合、Excelファイルのまま渡すと、相手の環境によって印刷範囲、改頁、余白、フォント、ページ数が崩れる可能性がある。

そのため、配布用にはPDFを基本にする方針とした。

ただし、問題と解答がシートで分かれている教材では、次のような配布・印刷需要がある。

- 全体を1つのPDFとして見たい
- シート単位でPDF内のしおりから移動したい
- 問題だけ、解答だけを別々に印刷したい

このため、1種類の固定変換ではなく、用途ごとに選択できるPDF化ツールが必要になった。

## 作成したツール

入口:

- `PDF化ツール.bat`

本体:

- `scripts/Convert-ExcelToPdf.ps1`
- `scripts/merge_pdfs_with_bookmarks.py`

説明:

- `scripts/README_PDF_TOOL.md`

## 選べるPDF化形式

### 1. そのまま全ページPDF化

Excelブック全体を1つのPDFにする。

出力例:

```text
output/pdf/教材名_all.pdf
```

PowerPoint資料のように、連続ページとして配布・印刷したい場合に向く。

### 2. シートをしおりにして全ページPDF化

各シートをPDF化し、1つのPDFに結合したうえで、シート名をPDFのしおりにする。

出力例:

```text
output/pdf/教材名_bookmarked.pdf
```

PDFビューアの左側ペインに、シート名のしおりが表示される。

問題と解答が同じPDF内にありつつ、場所を探しやすくしたい場合に向く。

注意点として、しおりは移動には便利だが、PDFビューアによっては「しおり単位で自動印刷」まではできない。その場合はページ範囲を指定して印刷する。

### 3. シートごとにPDF化

各シートを別々のPDFにする。

出力例:

```text
output/pdf/教材名_sheets/01_問題.pdf
output/pdf/教材名_sheets/02_解答.pdf
```

問題だけ、解答だけを確実に別印刷したい場合に向く。

## 使い方

PowerShellに慣れていない場合は、`PDF化ツール.bat` を使う。

### ダブルクリック

`PDF化ツール.bat` をダブルクリックすると、Excelファイル一覧とPDF化形式を選べる。

### ドラッグ

PDF化したい Excel ファイルを `PDF化ツール.bat` の上にドラッグすると、そのExcelファイルを対象にして起動できる。

表示されたメニューで、次の番号を入力する。

```text
1: そのまま全ページPDF化
2: シートをしおりにして全ページPDF化
3: シートごとにPDF化
```

出力先は次のフォルダ。

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Studymaterials\output\pdf
```

## 今回起きた問題と原因

### 問題1: PowerShellで直接実行できなかった

実行したコマンド:

```powershell
.\scripts\Convert-ExcelToPdf.ps1
```

表示された内容:

```text
このシステムではスクリプトの実行が無効になっているため...
```

原因:

PowerShellの実行ポリシーにより、`.ps1` ファイルの直接実行が制限されていた。

対応:

`PDF化ツール.bat` を追加し、内部で次の形で起動するようにした。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1"
```

これはPC全体の設定を変更せず、その1回の実行だけ制限を回避する。

### 問題2: bat経由で文字化けし、ParserErrorになった

表示例:

```text
PDF蛹悶☆繧...
ParserError
```

原因:

`.bat` から起動した Windows PowerShell が、`.ps1` 内の日本語メッセージを想定外の文字コードとして読み、文字化けした結果、構文エラーになった。

対応:

`scripts/Convert-ExcelToPdf.ps1` 内の固定メッセージを英語に変更し、ASCII文字だけで読めるようにした。

ファイル名やシート名は日本語のまま扱える。

### 問題3: 出力先が分かりにくかった

PDFは作成されていた可能性があるが、出力先を十分に案内できていなかった。

現在の出力先:

```text
output/pdf/
```

絶対パス:

```text
C:\Users\nakag\Desktop\GitHub\Myownproject\Studymaterials\output\pdf
```

今後の改善候補:

- PDF作成後に `output/pdf` フォルダを自動で開く
- 出力先を最後に大きく表示する
- `README_PDF_TOOL.md` の冒頭に出力先をより目立つ形で書く

## 検証結果

検証に使ったファイル:

```text
週間学習計画表生徒用_縦型.xlsx
```

確認済み:

- `.bat` 経由で起動できる
- 全ページPDF化ができる
- シートごとPDF化ができる
- しおり付きPDF化ができる
- しおり付きPDFには2ページ、2しおりが入った
- しおり名は `縦型日曜始まり` と `縦型月曜始まり`
- 一時フォルダ `_bookmark_tmp` は通常実行後に削除される

## 依存関係

ExcelのPDF出力には、Windows版Excelを使う。

しおり付きPDFの結合には Python の `pypdf` を使う。

未導入の場合:

```powershell
python -m pip install pypdf
```

## 現在の運用方針

教材配布では、用途に応じて次のように使い分ける。

- 見た目を固定して配布する: PDF
- 編集してもらう: Excel
- 問題と解答を分けて印刷したい: シートごとPDF化
- 1つのPDFで管理しつつ移動しやすくしたい: しおり付きPDF化
- 連続ページとして見せたい: そのまま全ページPDF化

## 次に改善するとよいこと

優先度が高い改善:

- 変換後に `output/pdf` フォルダを自動で開く
- 作成完了時に出力先をより分かりやすく表示する

必要になったら検討する改善:

- 既定モードを選べる設定ファイルを作る
- 問題シートと解答シートを自動判定して、問題PDF・解答PDFを個別に作る
- PDFファイル名に日付を付けるオプションを追加する
- しおり付きPDFの先頭に目次ページを追加する

## 注意

`output/pdf/` は生成物置き場なので、`.gitignore` でGit管理対象外にした。

ツール本体と説明書はGit管理対象として残す。
