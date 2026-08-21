#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:-macos}"

export_preset() {
  local preset_name="$1"
  local output_path="$2"
  mkdir -p "$(dirname "$project_root/$output_path")"
  "$project_root/tools/godot.sh" --headless --path "$project_root" --export-debug "$preset_name" "$project_root/$output_path"
}

case "$target" in
  macos)
    export_preset "macOS Development" "builds/macos/LOOT The Living Expanse.app"
    ;;
  windows)
    export_preset "Windows Development" "builds/windows/loot-living-expanse.exe"
    ;;
  linux)
    export_preset "Linux Development" "builds/linux/loot-living-expanse.x86_64"
    ;;
  all)
    export_preset "macOS Development" "builds/macos/LOOT The Living Expanse.app"
    export_preset "Windows Development" "builds/windows/loot-living-expanse.exe"
    export_preset "Linux Development" "builds/linux/loot-living-expanse.x86_64"
    ;;
  *)
    echo "Usage: tools/export.sh [macos|windows|linux|all]" >&2
    exit 2
    ;;
esac
