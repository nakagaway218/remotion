# Mistakes

AIが実際に起こした失敗と再発防止策を残す場所です。

## 書き方

```markdown
## YYYY-MM-DD
- やらかし:
- 原因:
- 再発防止:
```

## 記録

## 2026-06-20

- やらかし: Google同期をPowerShell 7内から古い `powershell.exe` で二重起動し、OAuth通信が応答しない状態になった。
- 原因: 実行環境を固定せず、Windows PowerShell 5系とPowerShell 7を混在させた。API呼び出しにも明示的なタイムアウトがなかった。
- 再発防止: Google/GitHub APIスクリプトはPowerShell 7必須にし、`pwsh -File` で実行する。全API呼び出しに既定30秒のタイムアウトを設定する。

## 2026-06-30

- やらかし: YouTube Transcript Docs作成フローで、クリップボードに残っていたPowerShellコマンドや動画タイトルだけをGoogle Docs本文として保存してしまった。
- 原因: `new-youtube-transcript-doc-from-clipboard.cmd` はクリップボードを読む設計なのに、実行用コマンドのコピーや動画タイトル入力でTranscript本文が上書きされるリスクを十分に考慮していなかった。短い本文を警告だけで通す、`N`後にコピーし直す導線がない、タイトルを本文と混同しやすい案内だったことも原因。
- 再発防止: `.cmd`実行後にTranscriptをコピーしてEnterする運用へ寄せる。クリップボードがコマンド文・動画タイトルのみ・短すぎる本文の場合は、Docs作成前にコピーし直しを促す。動画タイトルはDocsタイトルとSpreadsheetのB列にだけ使い、Docs本文にはTranscriptだけを入れる。
