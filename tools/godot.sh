#!/usr/bin/env bash
set -euo pipefail

engine_bin="${GODOT_BIN:-}"

if [[ -z "$engine_bin" ]] && command -v godot >/dev/null 2>&1; then
  engine_bin="$(command -v godot)"
fi

if [[ -z "$engine_bin" ]] && command -v godot4 >/dev/null 2>&1; then
  engine_bin="$(command -v godot4)"
fi

steam_engine="/Users/$(id -un)/Library/Application Support/Steam/steamapps/common/Godot Engine/Godot.app/Contents/MacOS/Godot"
if [[ -z "$engine_bin" ]] && [[ -x "$steam_engine" ]]; then
  engine_bin="$steam_engine"
fi

if [[ -z "$engine_bin" ]] || [[ ! -x "$engine_bin" ]]; then
  echo "Godot was not found." >&2
  echo "Install Godot 4.7.2, or run with GODOT_BIN=/absolute/path/to/Godot." >&2
  exit 1
fi

exec "$engine_bin" "$@"
