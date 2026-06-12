#!/usr/bin/env bash
# build.sh — iOS シミュレータ向けにビルドするテンプレート
# 前提: bootstrap.sh 実行後（.xcodeproj が生成済み）
# 注意: 出発点のテンプレートです。動作はあなたの Xcode 環境に依存します。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/../app"

# AGENTS.md STEP 3 で {{APP_NAME}} を実際のアプリ名に置換してください。
APP_NAME="{{APP_NAME}}"
SIMULATOR="${SIMULATOR:-iPhone 16}"

if [ "${APP_NAME}" = "{{APP_NAME}}" ]; then
  echo "[エラー] APP_NAME が未設定（プレースホルダのまま）です。" >&2
  echo "        このスクリプト内の APP_NAME を実際のアプリ名に置換してください。" >&2
  exit 1
fi

echo "[ビルド] ${APP_NAME} を ${SIMULATOR} 向けにビルドします..."
xcodebuild \
  -project "${APP_DIR}/${APP_NAME}.xcodeproj" \
  -scheme "${APP_NAME}" \
  -destination "platform=iOS Simulator,name=${SIMULATOR}" \
  build
