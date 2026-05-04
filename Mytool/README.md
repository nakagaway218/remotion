# PDF結合ツール

Windows向けのPDF結合ツールです。バッチファイルを実行すると、Pythonスクリプトが起動してファイル選択やドラッグアンドドロップでPDFを作成・結合できます。

## ツール一覧

### 何でもPDF結合ツール

- 起動ファイル: `何でもPDF結合ツール.bat`
- 本体: `multi_pdf_merger.py`
- PDF、画像、Excel、Word、PowerPointなどをPDF化して結合します。

### エクセルPDF結合ツール

- 起動ファイル: `エクセルPDF結合ツール.bat`
- 本体: `merge_excel_pdf.py`
- ExcelファイルをPDF化し、指定したPDFと結合します。

## 使い方

1. `何でもPDF結合ツール.bat` または `エクセルPDF結合ツール.bat` を実行します。
2. 表示される案内に従って、変換・結合したいファイルを選択します。
3. ドラッグアンドドロップにも対応しています。

## 必要な環境

- Windows
- Python
- Microsoft Office
- Pythonライブラリ: `pypdf`, `pywin32`, `Pillow`

必要なライブラリは以下でインストールできます。

```bash
pip install pypdf pywin32 Pillow
```

## GitHubで管理するもの

このフォルダでは、読み取れるソースとして `.bat` と `.py` を管理します。生成した `.exe` や出力PDFはGitHubに含めません。
