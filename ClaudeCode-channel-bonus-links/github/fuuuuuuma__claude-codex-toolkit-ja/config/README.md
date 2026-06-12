# config/ — 全体設定サンプル

エージェント本体の設定ファイルのひな型です。MCPだけでなく、権限・モデル・フック・サンドボックスなどの全体像を含みます。

| ファイル | 対象 | 置き場所 |
|---|---|---|
| [claude-settings.json](claude-settings.json) | Claude Code | `~/.claude/settings.json`（個人）／ `.claude/settings.json`（プロジェクト） |
| [codex-config.toml](codex-config.toml) | OpenAI Codex | `~/.codex/config.toml`（個人）／ `.codex/config.toml`（信頼済みプロジェクト） |

## ポイント

- **機密は分離**：Claude Code は `.claude/settings.local.json`（gitignore）へ、または環境変数へ。Codex も実キーは環境変数で。
- **権限は絞る**：`permissions.deny` で `.env` や `credentials*` の読み取りをブロック。`ask` で push 等を都度確認に。
- **モデル名・既定値は変わる**：`model` の値などはバージョンで変動。各公式リファレンスで最新を確認（ファイル冒頭にURL）。

## 参照

- 各キーの意味：[docs/01-claude-code.md](../docs/01-claude-code.md)（settings.json）／ [docs/02-codex.md](../docs/02-codex.md)（config.toml）
- 安全な運用：[docs/06-セキュリティ.md](../docs/06-セキュリティ.md)
