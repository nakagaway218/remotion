# プリセット: コード開発の安全装置

開発者向け。全リポジトリに入れる「事故防止＋規律」のベースレイヤー。

## 入れるもの（推奨順）
1. **Git Guardrails**（mattpocock/skills）— 危険なgit（push/reset --hard/clean）を実行前ブロック
2. **Setup Pre-Commit**（mattpocock/skills）— lint-staged+Prettier+型+テストのpre-commit構築
3. **TDD**（mattpocock/skills）— テストファースト red-green-refactor を強制
4. **Systematic Debugging**（obra/superpowers）— 4段階デバッグ。3回失敗で設計見直し
5. **Triage Issue**（mattpocock/skills、実repoは `triage`）— 原因不明バグの根本原因特定

## ベースレイヤー
- **Superpowers**（obra/superpowers）を入れると、TDD・デバッグ・計画など複数が一括で入る。
  「エンジニアリング脳」のデフォルト層として最初に検討。

## セキュリティ注意
- これらは git やフックを操作する＝**取り消しにくい操作に触れる**。
  導入前に必ず [`AGENTS.md` 手順4](../AGENTS.md#手順4-セキュリティ確認必須スキップ禁止) の中身確認を通すこと。

## 最初の1個だけなら
- **Git Guardrails**。本番リポジトリでAIエージェントを使うなら最優先のセーフティネット。
