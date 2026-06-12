# app/ — ここに iOS アプリを作っていきます

このフォルダが、あなたのアプリの本体です。AI エージェントが `AGENTS.md` の手順に沿って、ここにコードを足していきます。

## 中身

- `SPEC.md` … 作るアプリの仕様メモ（インタビュー後に AI が記入）。
- `project.yml` … Xcode プロジェクトの設計図（XcodeGen 用テンプレート）。`{{APP_NAME}}` `{{BUNDLE_ID}}` は後で実際の値に置換します。
- `Sources/` … SwiftUI のコード。最初は最小の「ようこそ画面」だけ入っています。

## プレースホルダについて

雛形には `{{APP_NAME}}`（アプリ名）と `{{BUNDLE_ID}}`（アプリの識別子）が埋め込まれています。
インタビューでアプリ名が決まったら、AI がこれらを実際の値に置換します（例: `{{APP_NAME}}` → `Mainichi`、`{{BUNDLE_ID}}` → `com.example.mainichi`）。

## 自分で動かすときの流れ（参考）

1. Mac に Xcode と XcodeGen を入れる（`brew install xcodegen`）
2. リポジトリ直下で `bash scripts/bootstrap.sh`（プロジェクト生成）
3. `bash scripts/build.sh`（シミュレータ向けビルド）

> これらは出発点のテンプレートです。実際のビルドは、あなたの Mac 環境に合わせて AI と一緒に調整してください（`docs/03-build-ios-apps.md` の「前提・必要なもの」を参照）。
