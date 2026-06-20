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
