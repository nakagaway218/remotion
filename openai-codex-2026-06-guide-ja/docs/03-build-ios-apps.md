# ③ Codex のビルドアップ ＝ Build iOS Apps プラグイン

> iPhone / iPad アプリ（SwiftUI）の開発を、Codex の中で「作って → 動かして → 直す」まで回せるプラグインです。**このキットの中心**になる機能です。

確度マーク: ✅公式確認済み ／ 🔶一次情報はあるが流動的 ／ ⚠️未確認

---

## ひとことで言うと

これまで iOS アプリ開発は Xcode を手で操作する必要がありました。Build iOS Apps プラグインは、**コードを書く・ビルドする・シミュレータで動かす・スクショを撮る・不具合を直す**という一連の流れを、Codex に任せながら回せるようにします。✅

@OpenAIDevs は「**アプリ内ブラウザで iOS アプリを表示・テストし、SwiftUI プレビューを開き、Codex を離れずに編集をホットリロードできる**」と説明しています。🔶

## 含まれるスキル（公式 use-case ドキュメント）✅

- **SwiftUI expert**（基本のベストプラクティス）
- **SwiftUI Pro**（最新 API・アクセシビリティ）
- **Liquid Glass expert**（iOS 26 のデザインパターン）
- **SwiftUI performance**（実行時の最適化監査）
- **Swift concurrency expert**（async/await のデバッグ）
- **SwiftUI view refactor**（コード整理）
- **SwiftUI patterns**（Observable アーキテクチャ）

## 「作って試す」ループの中身 ✅

ワークフローは **CLI ファースト**で、Apple の `xcodebuild` や Tuist を使います。Xcode の GUI に頼らず、ターミナルから「スキーム一覧の取得・ビルド・テスト・アーカイブ」を実行できます。✅

プロジェクト全体の自動化が必要になると **XcodeBuildMCP** が、スキーム／ターゲット／シミュレータ制御／スクリーンショット／ログ／UI 操作を担当します。Codex は「**コードを書く → ビルド → 出力を受け取る → エラー特定 → 修正**」を連続して回せます。✅

## 初心者がやること（公式の手順）✅

1. **Scaffold（土台作り）**: 「SwiftUI のスターターアプリとビルドスクリプトを作って」と頼む
2. **Script locally**: ビルドスクリプトをローカル環境の Build アクションに結びつける
3. **Add skills**: 必要な SwiftUI スキルを追加インストール
4. **Iterate**: 変更のたびに小さく検証ループを回す
5. **Leverage XcodeBuildMCP**: プロジェクト全体の自動化やスクショが必要になったら使う

## このキットとの関係

この後の `AGENTS.md` と `app/` フォルダは、上の手順1〜2を**先回りして用意したもの**です。
あなたは「どんなアプリを作りたいか」を AI と対話で決めるだけで、AI が `app/` の中にコードを足してビルドしていけます。

## 前提・必要なもの（重要）

- **Mac ＋ Xcode**（iOS シミュレータを動かすため）。クラウドだけでは実機ビルドは完結しません。⚠️
- **Codex（CLI / IDE / アプリ）**＋ **Build iOS Apps プラグイン**のインストール。✅
- ビルド自動化に **XcodeGen** または **Tuist**、`xcodebuild`（Xcode 同梱）。🔶（このキットは XcodeGen を既定の例として用意）

## 出典

- 公式 use-case「Build for iOS」: https://developers.openai.com/codex/use-cases/native-ios-apps
- 公式 Codex 総合: https://developers.openai.com/codex
- 一次情報（X）: [@OpenAIDevs](https://x.com/OpenAIDevs/status/2062599291479478275)

## 未確認・注意

- 🔶 「アプリ内ブラウザで表示・ホットリロード」は @OpenAIDevs 投稿が一次情報で、2026-06-04 時点の changelog 個別エントリには未掲載。
- ⚠️ ビルドの成否は環境（Xcode バージョン・証明書・依存）に依存します。このキットのスクリプトは**動作確認前のテンプレート**で、実際のビルド検証は AI エージェント＋あなたの Mac 上で行ってください。
