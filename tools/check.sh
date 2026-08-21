#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
check_output_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$check_output_dir"
}
trap cleanup EXIT

run_checked() {
  local check_name="$1"
  shift
  local output_file="$check_output_dir/$check_name.log"
  set +e
  "$project_root/tools/godot.sh" "$@" 2>&1 | tee "$output_file"
  local godot_status="${PIPESTATUS[0]}"
  set -e
  if [[ "$godot_status" -ne 0 ]]; then
    echo "$check_name failed with exit code $godot_status." >&2
    exit "$godot_status"
  fi
  if grep -Eq 'SCRIPT ERROR:|(^|[[:space:]])ERROR:' "$output_file"; then
    echo "$check_name emitted an engine or script error." >&2
    exit 1
  fi
}

run_checked import --headless --editor --path "$project_root" --quit
run_checked content --headless --path "$project_root" --script res://tools/validate_content.gd
run_checked tests --headless --path "$project_root" --script res://tests/test_runner.gd
run_checked runtime --headless --path "$project_root" --quit-after 8

echo "Foundation check passed: import, content, tests, and runtime smoke."
