# MyConversion

Google Documentの記事を、参考ページに寄せたHTML、Google Document提出用DOCX、WordPress入稿用HTMLへ変換するための再現ファイルです。

## 全体フロー

```text
Google Document元記事
  -> 参考ページ寄せHTML
  -> Google Document提出用DOCX
  -> WordPress本文HTML
```

## ファイル

- `頭皮アートメイク_痛み記事_リライト_再現手順.md`
  - 今回の変換プロセス全体の手順メモです。

- `html_to_google_docx_replay.py`
  - 参考ページ寄せHTMLを、Google Document提出用のDOCXへ変換するスクリプトです。

- `docx_to_wordpress_replay.py`
  - Google Document提出用DOCXを、WordPress本文欄に貼れるHTMLへ変換するスクリプトです。

## 目的

同じ型の記事変換を再実行できるように、変換の判断基準とスクリプトを保存しています。

参考ページの文章や画像をそのまま複製するのではなく、構成、見せ方、読者導線を参考にして、元記事を読みやすい記事形式へ整えます。
