# scripts/ — ビルド補助スクリプト（テンプレート）

ここのスクリプトは **出発点のテンプレート**です。あなたの Mac 環境（Xcode のバージョンや使うツール）に合わせて、AI エージェントと一緒に調整して使ってください。
**まだ動作確認はされていません**（リポジトリ配布時点ではアプリ名が未確定のため）。AGENTS.md STEP 3 でプレースホルダを置換してから実行します。

## 前提

- Mac＋Xcode（iOS シミュレータを含む）
- XcodeGen（`brew install xcodegen`）
- `xcodebuild`（Xcode 同梱）

## 使う順番

1. `bash scripts/bootstrap.sh`
   - `app/project.yml` をもとに Xcode プロジェクト（`.xcodeproj`）を生成します。
2. `bash scripts/build.sh`
   - iOS シミュレータ向けにビルドします。
   - シミュレータ名は環境変数で変更可: `SIMULATOR="iPhone 15" bash scripts/build.sh`

## Codex / Build iOS Apps プラグインを使う場合

スクリプトを手で叩く代わりに、Codex に「`scripts/bootstrap.sh` と `scripts/build.sh` を実行して、エラーが出たら直して」と頼めます。
Build iOS Apps プラグイン（XcodeBuildMCP）が、ビルド・シミュレータ起動・スクショ・ログ取得・修正のループを担当します（`docs/03-build-ios-apps.md` 参照）。
