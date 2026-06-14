---
description: 大きな変更の前後に、ブランチと重要フォルダの消失リスクを確認する
---

# /ai構造保全チェック [任意: 対象フォルダまたは目的]

`@repository-guardian` として、現在のリポジトリ構造を確認してください。

確認すること:

- 現在のブランチと `git status`
- 守るべきフォルダが現在のブランチに存在するか
- 別ブランチにだけ存在するフォルダがないか
- 削除、移動、リネーム、未追跡ファイルが混ざっていないか
- コミットやプッシュ前に除外すべきファイルがないか

守るフォルダの初期候補:

- `Studymaterials`
- `Learner`
- `Rikei_Kokkoritsu_Juken_Learner`
- `Webarticle`
- `Scenariowriting`
- `Mytool`
- `teaching materials`

出力は次の形にしてください。

```markdown
## 構造保全チェック

### 現在地

### 守るフォルダ

### 気になる差分

### 判断

### 次の行動
```
