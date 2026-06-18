# Excel PDF化ツール

`Convert-ExcelToPdf.ps1` は、Studymaterials の Excel 教材をPDF化するためのツールです。

Excel本体のPDF出力を使うため、各ブックに設定済みの印刷範囲、改頁、余白、A4縦横設定をできるだけそのまま使います。

## できること

- そのまま全ページPDF化
- シート名をしおりにして全ページPDF化
- シートごとに別々のPDF化

## 使い方

一番簡単な方法は、`PDF化ツール.bat` をダブルクリックすることです。

Excelファイルを `PDF化ツール.bat` の上にドラッグすると、そのファイルを対象にできます。

PowerShellから使う場合は、このフォルダで次を実行します。

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1"
```

メニューで Excel ファイルとPDF化形式を選べます。

コマンドで直接指定する場合:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1" -WorkbookPath ".\中学生英作文一般動詞現在形編.xlsx" -Mode all
powershell -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1" -WorkbookPath ".\中学生英作文一般動詞現在形編.xlsx" -Mode bookmarks
powershell -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1" -WorkbookPath ".\中学生英作文一般動詞現在形編.xlsx" -Mode sheets
```

## 出力先

指定しない場合、PDFは `output/pdf/` に作られます。

- `all`: `ファイル名_all.pdf`
- `bookmarks`: `ファイル名_bookmarked.pdf`
- `sheets`: `ファイル名_sheets/01_シート名.pdf`

同じ名前のPDFがすでにある場合は、上書きしてよいか確認します。

```text
Overwrite? Type y to overwrite, or press Enter to cancel
```

`y` を入力して Enter すると上書きします。Enter だけなら中止します。

出力先を変える場合:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1" -WorkbookPath ".\教材.xlsx" -Mode bookmarks -OutputDirectory ".\配布用PDF"
```

確認なしで上書きしたい場合は、`-Force` を付けます。

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1" -WorkbookPath ".\教材.xlsx" -Mode all -Force
```

## しおり付きPDFについて

しおり付きPDFでは、いったんシートごとの一時PDFを作り、Pythonの `pypdf` で結合してしおりを付けます。

`pypdf` が入っていない場合は、次を実行してください。

```powershell
python -m pip install pypdf
```

一時PDFを残して確認したい場合:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1" -WorkbookPath ".\教材.xlsx" -Mode bookmarks -KeepTemporary
```

## 注意

- ExcelがインストールされているWindows環境で使う想定です。
- PowerShellの実行ポリシーで `.ps1` が直接起動できない場合は、`PDF化ツール.bat` を使ってください。
- 対象ブックをExcelで開いたままだと、環境によってはPDF化や保存に失敗することがあります。
- `bookmarks` のしおりは、PDFビューアの左側ペインに表示される「アウトライン」です。
