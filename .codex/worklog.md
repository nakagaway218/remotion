# Codex Work Log

## 2026-08-09: ローカルCodex起動案内の反省点を記録

- 度重なった修正の原因を、話者、資料の種類、表示タイミング、CMD/PowerShell境界、通し確認の観点で整理した。
- `tasks/done/2026-08-09-local-codex-launcher-lessons.md` に再発防止チェックリストを追加した。
- 自動生成される `CodexMemory/Codex-Reference-Pack.md` をGit管理対象から外した。

## 2026-08-09: Codex起動時の参考資料案内を簡素化

- クリップボードへ準備文をコピーする手順を廃止した。
- 「準備できました」と返答させる往復を廃止した。
- Codexの入力欄が表示されたら、最初から実際の作業依頼を入力する方式に統一した。
- 追加の参考資料は、実際の依頼文にファイルのフルパスを書く。

## 2026-08-08

**依頼内容**
CodexをLM Studio上のローカルモデルで運用し、作業記録を残す仕組みを追加する。

**実施内容**
- AGENTS.md に Work Log Policy を追加。
- Windows環境では apply_patch を使用せず、PowerShellで編集する運用を追加。
- .codex/worklog.md を作成。

**変更ファイル**
- AGENTS.md
- .codex/worklog.md

**未解決事項**
- CodexとLM Studio間のコンテキスト長設定を安定させる必要がある。

## 2026-08-08 12:32

**依頼内容**
指定時刻に新しいシフトPDFがあるか自動確認する。

**実施内容**
- `Check-New-Schedule-PDFs.ps1 -AutomationCheck` を実行。
- 未確認の新しいシフトPDFが0件であることを確認。
- Outlook予定表への書き込みは行っていない。

**変更ファイル**
- `.codex/worklog.md`（作業記録のみ）

**未解決事項**
- なし。

## 2026-08-08 AGENTS.md worklog policy cleanup

- 依頼内容: AGENTS.md の文字化け修正と作業記録先の統一。
- 実施内容: 文字化けしていたダッシュ表記を復元し、作業記録先を .codex/worklog.md に統一。
- 変更ファイル: AGENTS.md, .codex/worklog.md
- 未解決事項: なし。

## 2026-08-09 00:29 +09:00 LM Studio / Codex ローカル運用整理

**依頼内容**
LM Studioを使ってCodexの推論クレジットを節約する構成、Qwen系モデルの検証・整理、`openai/gpt-oss-20b` をダブルクリックで起動するツール作成までの流れを記録する。

**実施内容**
- 添付された過去会話を確認し、CodexからLM Studio/Ollamaのローカルモデルへ接続する試行内容を整理。
- LM Studio CLI、LM Studioサーバー、`codex.cmd` 経由の起動確認、PowerShell実行ポリシーによる `codex.ps1` ブロック回避を記録。
- Qwen2.5-Coder 14B は reasoning 設定を外すと起動できるものの、正式な `tool_calls` ではなくJSON風テキストを返すため、Codexの実作業用モデルには不向きと判断。
- Ollama側のQwen系モデル削除後、`ollama list` が空になったことを記録。LM Studio側のQwen Coder系はアプリの My Models から削除し、`openai/gpt-oss-20b` は残す方針を記録。
- 既存の `AiLaunchers/Start-Codex-GPT-OSS-20B.cmd` と準備スクリプトを確認し、`Mytools/` からダブルクリックで起動できる入口を追加。
- `Mytools/README.md` に起動ツールの説明を追加。
- PowerShell構文パーサーで `Prepare-LMStudio-GPT-OSS-20B.ps1` と `Prepare-CodexMemory-Hook.ps1` に構文エラーがないことを確認。

**変更ファイル**
- `Mytools/Codex GPT-OSS-20B 起動ツール.bat`
- `Mytools/README.md`
- `.codex/worklog.md`

**未解決事項**
- 実際のLM Studio/Codex起動テストは、ローカルモデルと対話セッションを起動する操作になるため未実行。
- LM Studio側に残っているQwen Coder系モデルの削除は、必要に応じてLM Studioアプリの My Models から実施する。

## 2026-08-09 CodexMemory 参照パック自動生成

**依頼内容**
作業場所判定ランチャーの3番などでPowerShellからローカルCodexを起動したとき、ChatGPTのように参考ファイルを添付できない問題を補う。

**実施内容**
- `Prepare-CodexMemory-Hook.ps1` に参照パック生成を追加。
- `Codex-Reference-Pack.md` に共通指示、docs、進行中/保留タスク、直近完了タスクをまとめるようにした。
- `Codex-Attachment-Prompt.txt` を生成し、起動時にクリップボードへコピーするようにした。
- `CodexMemory` の手順書と引き継ぎ文を参照パック方式へ更新。
- PowerShell構文チェックとフック実行で生成確認。

**変更ファイル**
- `AiLaunchers/Prepare-CodexMemory-Hook.ps1`
- `CodexMemory/README.md`
- `CodexMemory/Codex-Handoff.md`
- `CodexMemory/Codex-Reference-Pack.md`
- `CodexMemory/Codex-Attachment-Prompt.txt`
- `.codex/worklog.md`

**未解決事項**
- LM Studio/Codex本体の対話起動は未実行。

## 2026-08-11 LM Studio連携ランチャーの同時利用確認

**依頼内容**
`Start-Codex-GPT-OSS-20B` を起動しておけば、Codex DesktopのタスクとLM Studioで作業を分担できるか確認する。

**実施内容**
- `Start-Codex-GPT-OSS-20B.cmd` と `Prepare-LMStudio-GPT-OSS-20B.ps1` の動作を確認。
- ランチャーはLM Studioサーバーと `openai/gpt-oss-20b` を準備し、LM Studioをバックエンドにした別のCodex CLIセッションを起動する構成と確認。
- LM Studio API（`127.0.0.1:1234`）が稼働し、`openai/gpt-oss-20b` がコンテキスト長32768でロード済みであることを確認。
- 複数タスクからの同時利用は可能だが、自動的な作業分担にはならず、計算資源の競合と同一ファイルの同時編集に注意が必要と判断。

**変更ファイル**
- `.codex/worklog.md`

**未解決事項**
- Codex DesktopからLM Studioへ自動委任する仕組みは未構築。必要ならローカルAPI呼び出しによる連携処理を別途用意する。

## 2026-08-11 LM Studio API単発依頼の疎通確認

**依頼内容**
Codex Desktopの現在タスクから、LM Studio APIへ単発の質問・調査を依頼できる導線が確立しているか確認する。

**実施内容**
- `http://127.0.0.1:1234/v1/chat/completions` へ `openai/gpt-oss-20b` を指定した短い接続確認を送信。
- LM Studioから正常な応答（`OK`）を回収し、現在タスクからの単発API呼び出しが実用上通ることを確認。

**変更ファイル**
- `.codex/worklog.md`

**未解決事項**
- 「LM Studioに任せて」という依頼から、モデル選択・送信・結果回収までを自動化する共通ラッパーは未構築。

## 2026-08-11 LM Studio単発委譲の共通化

**依頼内容**
GitHub配下のCodexタスクからLM Studio APIへ単発依頼できる導線を共通化し、将来Claude Codeからも同じ運用を参照できるようにする。

**実施内容**
- `docs/LM_STUDIO_DELEGATION.md` に、モデル確認・明示選択・依頼・検証の共通手順を作成。
- `AiLaunchers/Invoke-LMStudioTask.ps1` に、既存モデルを入れ替えずLM StudioのOpenAI互換APIを呼ぶラッパーを追加。
- リポジトリ内の `AGENTS.md` と `CLAUDE.md` から共通手順を参照するよう更新。
- GitHub親フォルダの `AGENTS.md` と `CLAUDE.md` にも入口を設け、配下タスクへローカル運用を伝播。
- モデル一覧取得、PowerShell構文、`openai/gpt-oss-20b` への単発依頼を実地確認。

**変更ファイル**
- `AGENTS.md`
- `CLAUDE.md`
- `AiLaunchers/Invoke-LMStudioTask.ps1`
- `docs/LM_STUDIO_DELEGATION.md`
- `.codex/worklog.md`
- 親フォルダの `../AGENTS.md` と `../CLAUDE.md`（親フォルダはGit管理外）

**未解決事項**
- 親フォルダ自体はGitリポジトリではないため、親の入口ファイルはこのリポジトリのコミット対象外。
- リモート反映は、既存の未送信コミットを含むブランチのpush範囲を確認してから行う。

## 2026-08-12 PDF監査後のExcel手修正を見落としとして記録

**依頼内容**
PDFの写り込み確認後、ユーザーが元のExcelファイルを直接手作業で修正した事実を、今回の監査におけるミスとして残す。

**実施内容**
- PDF監査レポートに、Excelの手修正が必要だったことを「監査上の見落とし」として追記。
- 当初の「問題候補なし」は写り込みと見た目の破綻に限った結果であり、元Excelを含む無問題の保証ではないことを明記。
- 次回の確認項目として、元ExcelとPDFの対応、文字切れ、内容の不整合、修正後の再PDF化結果を追加。

**変更ファイル**
- `Studymaterials/output/pdf_visual_audit_report.md`
- `.codex/worklog.md`

**未解決事項**
- ユーザーが手修正した具体的なセル・内容と、PDFへの反映差分は未照合。
## 2026-08-21 8月21日Cコマ更新可否の調査

**依頼内容**

- 当日終了後に判明した担当人数変更について、開始前なら既存のOutlook予定を更新できたか確認する。

**実施内容**

- 最新PDFの解析結果で、8月21日Cコマ（18:30-20:00）が担当1人として読み取られていることを確認した。
- 実行時刻の22:19には開始時刻を過ぎていたため、「過去の予定は変更しない」保護によって更新対象外になったことを確認した。
- 開始前に実行した場合は、同じ開始時刻の既存予定を検出し、本文を担当1人分で置き換えて保存する処理になることを確認した。
- 個人名は作業記録に残さず、Outlookの過去予定も変更していない。

**変更ファイル**

- `.codex/worklog.md`

**未解決事項**

- 時刻を巻き戻した実動試験は行わず、PDF解析結果と更新処理のコード経路で確認した。
## 2026-08-23 9月初旬予定の読取・更新精度改善

**依頼内容**
- 9月1日C枠と9月3日の予定が正しく反映されない問題を修正し、再発防止策を追加する。

**実施内容**
- 新しいPDFの22列構成を解析し、曜日ごとの講師・生徒・教科列を明示的に割り当てる処理を追加。
- 匿名データによる22列形式の回帰テストを3件追加し、複数日、複数枠、連続行、任意番号を検証。
- 水口校の予定で生徒または教科が欠けた場合、Outlookへ書き込まず停止する検証を追加。
- 対象PDFを再解析し、対象5件の詳細が揃っていることを確認後、ローカルPSTの既存予定5件を更新。
- 個人名はログ・テスト・作業記録に保存せず、Web版予定表と過去予定は変更していない。

**変更ファイル**
- `Schedule/Extract-Schedule-Table.py`
- `Schedule/Test-Extract-Schedule-Table.py`
- `Schedule/Local-Schedule-To-Outlook.ps1`
- `.codex/worklog.md`

**確認結果**
- Python回帰テスト3件成功。
- 事前解析で対象5件すべてに生徒・教科情報があることを確認。
- Outlook反映ログ: 新規0件、更新5件。

**未解決事項**
- Outlook画面上で9月1日C枠と9月3日の表示を最終確認する。

## 2026-08-23 PDF帳票誤読取の振り返り文書化

**依頼内容**
- 9月初旬の予定誤読取について、原因と再発防止策をMarkdownに残し、今後の運用・実装で参照できるようにする。

**実施内容**
- 原因、見逃した兆候、必須確認手順、停止基準、チェックリストを個人情報を含めず文書化。
- ツール案内から新しい反省文へのリンクを追加。
- 未対応の列構成を推測処理せず停止させ、匿名の回帰テストを追加。

**変更ファイル**
- `Schedule/RETROSPECTIVE-2026-08-23-PDF-LAYOUT-VALIDATION.md`
- `Schedule/SCHEDULE-PDF-TOOL.md`
- `Schedule/Extract-Schedule-Table.py`
- `Schedule/Test-Extract-Schedule-Table.py`
- `.codex/worklog.md`

**確認結果**
- 予定表ツールと同じPython環境で回帰テスト4件が成功。
- 新しい反省文とテストにメールアドレスやPDF本文を含めていないことを確認。

**未解決事項**
- なし。

## 2026-08-30 9月3日D枠・9月4日守山北校のOutlook反映と重複修正

**依頼内容**

- Scheduleツールで対象2枠を確認し、デスクトップ版OutlookのローカルPSTへ反映。
- 同一生徒の三重登録と番号の丸数字変換を修正。個人情報は端末内のみで処理。

**実施内容**

- 狭い表形式からD枠まで抽出できるよう、時限位置と表構造の判定を修正。
- 番号の全角・半角を正規化し、予定本文では丸数字へ変換する処理を修正。
- 同一生徒を大文字・小文字を区別せず予定単位で重複排除する処理を追加。
- 対象2枠だけを選択してローカルPSTへ直接反映（新規2件）。
- 外部サービスへのデータ送信は実施せず、PDFと個人情報は端末内だけで処理。

**変更ファイル**

- `Schedule/Extract-Schedule-Table.py`
- `Schedule/Local-Schedule-To-Outlook.ps1`
- `Schedule/Test-Extract-Schedule-Table.py`
- `.codex/worklog.md`

**確認結果**

- Python単体テスト4件成功。
- PowerShell構文エラー0。匿名データによる重複排除と丸数字変換のテストに成功。
- ローカルPSTの読み取り検証で、9月3日20:10～21:40と9月4日18:30～20:00が各1件であることを確認。
- 予定本文の重複行は0件。9月3日の番号は丸数字であることを確認。
- 9月4日の元表は担当枠のみで生徒・科目欄がないため、予定本文は空欄。

**未解決事項**

- なし。

## 2026-08-30 Schedule修正のクレジット効率に関する再発防止記録

**依頼内容**

- Schedule修正でクレジットを使いすぎた点を反省し、今後は本作業の完了と修正速度を両立できる手順をMarkdownへ残す。

**実施内容**

- 調査範囲の固定、処理層の切り分け、匿名の最小回帰テスト、最小修正、対象テスト、ローカルPST再読取という標準順序を記録。
- 中断・再開時のチェックポイントと完了条件を明文化。
- Scheduleツール案内の関連記録から参照できるようにした。

**変更ファイル**

- `Schedule/RETROSPECTIVE-2026-08-30-CREDIT-EFFICIENCY.md`
- `Schedule/SCHEDULE-PDF-TOOL.md`
- `.codex/worklog.md`

**確認結果**

- 記録に個人名やPDF本文を含めていないことを確認。
- 外部サービスへの送信は実施していない。

**未解決事項**

- なし。
