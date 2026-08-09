# PDF結合ツール

Windows向けのPDF結合ツールです。バッチファイルを実行すると、Pythonスクリプトが起動してファイル選択やドラッグアンドドロップでPDFを作成・結合できます。

## ツール一覧

### Codex GPT-OSS-20B 起動ツール

- 起動ファイル: `Codex GPT-OSS-20B 起動ツール.bat`
- 本体: `../AiLaunchers/Start-Codex-GPT-OSS-20B.cmd`
- LM Studioのローカルサーバーを確認し、`openai/gpt-oss-20b` をコンテキスト長32768で読み込んでから、Codexを `--oss` モードで起動します。
- CodexMemoryの引き継ぎメモも準備します。
- PowerShellを毎回開かず、このbatファイルをダブルクリックして使います。
- 参考資料がない場合は、Codexの入力欄へそのまま実際の作業依頼を入力してください。
- 参考資料がある場合、文章ならその文章をCtrl+Vで入力欄へ貼り付け、その下に作業依頼を書いてください。
- 参考資料がある場合、ファイルならファイル自体を貼り付けず、`まず C:\Users\nakag\Desktop\GitHub\Myownproject\AiLaunchers\参考資料.pdf を読み、その内容を前提に作業してください。` のように実際のフルパスを書いてください。`参考資料.pdf` は実際のファイル名に置き換えます。
- 資料だけ先に読ませたい場合は、依頼文の最後に `まだ作業は開始せず、次の指示を待ってください。` と書いてください。

### フォルダ同期バックアップツール

- 起動ファイル: `フォルダ同期バックアップツール.bat`
- 本体: `folder_backup_sync.py`
- 元フォルダとバックアップ先フォルダを選び、バックアップ先を元フォルダと同じ状態にします。
- 同期にはWindows標準の `robocopy` を使います。
- バックアップ先にだけあるファイルやフォルダは削除されます。
- Desktop全体を同期する場合に重くなりやすい `.git`、`node_modules`、`dist`、`build` などは、チェック項目で除外できます。
- 本体、起動ファイル、設定ファイルの3点セットで管理します: `folder_backup_sync.py`、`フォルダ同期バックアップツール.bat`、`folder_backup_sync_settings.json`

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

## ツール紛失防止メモ

フォルダ同期バックアップツールは、過去に別ブランチで作成されたため、現在のブランチでは本体が見えない状態になっていました。

再発防止として、次の3点を同じ `Mytools/` フォルダで管理します。

1. `folder_backup_sync.py`: 本体
2. `フォルダ同期バックアップツール.bat`: 起動ファイル
3. `folder_backup_sync_settings.json`: 最後に使った元フォルダとバックアップ先

GitHubに残す場合は、この3点とREADMEの説明を同じコミットに含めてください。

## exe化手順

`何でもPDF結合ツール.exe` は `何でもPDF結合ツール.bat` から作成した実行ファイルです。GitHubでは `.exe` 本体は管理せず、必要になった場合は以下の手順で作り直します。

1. Bat To Exe Converterなどのバッチファイル変換ツールを起動します。
2. 入力ファイルに `何でもPDF結合ツール.bat` を指定します。
3. 出力ファイル名を `何でもPDF結合ツール.exe` にします。
4. 出力先はこの `Mytools` フォルダにします。
5. 文字コードはUTF-8として扱える設定にします。
6. 変換を実行します。

作成した `.exe` は `Mytools/*.exe` のルールでGit管理から除外されます。
