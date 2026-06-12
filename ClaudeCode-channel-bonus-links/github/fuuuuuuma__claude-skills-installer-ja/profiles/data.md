# プリセット: データ処理・書類整理

請求書・見積書・各種データの転記や集計が多い人向け。「手入力15時間」を消す束。

## 入れるもの（推奨順）
1. **XLSX**（anthropics/skills）— データ整理・集計・グラフ・数式の再計算検証
2. **PDF**（anthropics/skills）— PDFの読み取り・抽出・OCR
3. **DOCX**（anthropics/skills）— Word文書の読み取り・編集
4. （任意・同梱）**ドキュメント一括処理パック**（`skills/document-processor/`）— PDF/Word/Excel混在を自動判定

## 業務別の主役
- 形式バラバラの書類整理 → **document-processor**（同梱）でフォルダごと処理
- 請求書のデータ化・金額検証 → 同梱 **read-invoices**（`skills/read-invoices/`）。計算はプログラムで厳密検証
- 表計算が中心 → **XLSX**

## 最初の1個だけなら
- **XLSX**。数式の再計算検証で計算ミスまで拾える、万人向けの直球。
