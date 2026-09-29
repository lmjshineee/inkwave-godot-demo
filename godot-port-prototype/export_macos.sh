#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUTPUT_APP="$PROJECT_DIR/build/INKWAVE Demo.app"

if [ -x /Applications/Godot.app/Contents/MacOS/Godot ]; then
  GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot
elif command -v godot >/dev/null 2>&1; then
  GODOT_BIN=$(command -v godot)
else
  printf '%s\n' 'Godot 4.8 未找到；请安装 Godot.app 到 /Applications。' >&2
  exit 1
fi

mkdir -p "$PROJECT_DIR/build" "$PROJECT_DIR/.godot"
TEMPLATE_VERSION=$("$GODOT_BIN" --version | cut -d. -f1-3)
TEMPLATE_SOURCE=${GODOT_MACOS_TEMPLATE:-"$HOME/Library/Application Support/Godot/export_templates/$TEMPLATE_VERSION/macos.zip"}
ARM64_TEMPLATE="$PROJECT_DIR/.godot/macos-arm64-template.zip"
if [ ! -f "$TEMPLATE_SOURCE" ]; then
  printf '找不到 Godot 官方 macOS 导出模板：%s\n' "$TEMPLATE_SOURCE" >&2
  exit 1
fi
if [ ! -f "$ARM64_TEMPLATE" ] || [ "$TEMPLATE_SOURCE" -nt "$ARM64_TEMPLATE" ]; then
  TEMPLATE_WORK=$(mktemp -d "$PROJECT_DIR/.godot/arm64-template.XXXXXX")
  trap 'rm -rf "$TEMPLATE_WORK"' EXIT
  unzip -q "$TEMPLATE_SOURCE" -d "$TEMPLATE_WORK"
  for KIND in release debug; do
    TEMPLATE_BIN="$TEMPLATE_WORK/macos_template.app/Contents/MacOS/godot_macos_$KIND"
    lipo -thin arm64 "$TEMPLATE_BIN.universal" -output "$TEMPLATE_BIN.arm64"
    rm "$TEMPLATE_BIN.universal"
  done
  (cd "$TEMPLATE_WORK" && zip -q -r "$ARM64_TEMPLATE" macos_template.app)
fi
"$GODOT_BIN" --headless --log-file "$PROJECT_DIR/.godot/import.log" --path "$PROJECT_DIR" --import
"$GODOT_BIN" --headless --log-file "$PROJECT_DIR/.godot/export.log" --path "$PROJECT_DIR" \
  --export-release macOS "$OUTPUT_APP"

APP_EXEC=$(find "$OUTPUT_APP/Contents/MacOS" -type f -perm -111 -print -quit 2>/dev/null || true)
if [ ! -d "$OUTPUT_APP/Contents/MacOS" ] || [ -z "$APP_EXEC" ]; then
  printf '%s\n' '导出命令结束，但没有找到可执行的 macOS .app。请检查 .godot/export.log。' >&2
  exit 1
fi
if [ "$(lipo -archs "$APP_EXEC")" != 'arm64' ]; then
  printf '%s\n' '导出程序必须仅包含 arm64 架构。' >&2
  exit 1
fi

check_log() {
  if grep -E '^(SCRIPT ERROR:|ERROR:|WARNING:)' "$1" | \
    grep -v '^ERROR: Condition "ret != noErr" is true. Returning: ""$'; then
    printf 'Godot 日志有脚本或场景错误：%s\n' "$1" >&2
    exit 1
  fi
}

check_log "$PROJECT_DIR/.godot/import.log"
check_log "$PROJECT_DIR/.godot/export.log"
codesign --verify --deep --strict "$OUTPUT_APP"
"$APP_EXEC" --headless --quit-after 2 --log-file "$PROJECT_DIR/.godot/export-smoke.log"
check_log "$PROJECT_DIR/.godot/export-smoke.log"

printf '已导出：%s\n' "$OUTPUT_APP"
