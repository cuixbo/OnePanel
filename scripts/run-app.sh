#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="$ROOT_DIR/dist/OnePanel.app"

"$ROOT_DIR/scripts/build-app.sh" >/dev/null
open "$APP_PATH"

echo "Launched $APP_PATH"
