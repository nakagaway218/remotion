# Webarticle 起動ファイル復元メモ

## 何が起きたか

`Webarticle` は以前、`A_Webarticle_Start.cmd` をダブルクリックして起動するブラウザー型ツールでした。
しかし、後続の AI 社員化・ワークフロー整理の過程で、起動用ファイルとアプリ本体が作業ツリーから見えない状態になりました。

復元元:

- commit: `c73e2f7d37`
- message: `Adopt AI research as the standard knowledge step`

## 消してはいけないもの

以下は Webarticle の実用入口なので、別作業や整理のために削除しないでください。

- `A_Webarticle_Start.cmd`
- `A_Webarticle_Index.html`
- `server.mjs`
- `package.json`
- `public/index.html`
- `public/app.js`
- `public/styles.css`

## 今後の反省

- AI 社員化、サブエージェント化、設計メモ追加は、既存ツールの置き換えではありません。
- Markdown の設計ファイルだけを残して、ダブルクリック起動できる実体を消すと、ユーザーが再開できなくなります。
- 大きな整理をするときは、先に起動入口の有無を確認します。
- `git status` で削除や未追跡が出た場合、起動ファイル一式が消えていないか確認してから作業します。

## 起動方法

`A_Webarticle_Start.cmd` をダブルクリックします。

サーバーは `http://localhost:4173` で開きます。
