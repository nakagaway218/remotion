#!/usr/bin/env bash
# bootstrap.sh — Xcode プロジェクトを生成するテンプレート
# 前提: Mac + Xcode + XcodeGen（brew install xcodegen）
# 注意: 出発点のテンプレートです。環境に合わせて AI と一緒に調整してください。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/../app"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "[エラー] XcodeGen が見つかりません。'brew install xcodegen' で導入してください。" >&2
  exit 1
fi

if grep -q '{{APP_NAME}}' "${APP_DIR}/project.yml" 2>/dev/null; then
  echo "[エラー] app/project.yml にプレースホルダ {{APP_NAME}} が残っています。" >&2
  echo "        AGENTS.md STEP 3 で実際のアプリ名／Bundle ID に置換してから実行してください。" >&2
  exit 1
fi

echo "[1/1] Xcode プロジェクトを生成します..."
( cd "${APP_DIR}" && xcodegen generate )
echo "完了。次に: bash scripts/build.sh"
