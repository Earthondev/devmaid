#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/devmaid-ui.XXXXXX)"
APP_BUNDLE="$ROOT_DIR/dist/DevMaid.app"
APP_BIN="$ROOT_DIR/dist/DevMaid.app/Contents/MacOS/DevMaid"
APP_PID=""

cleanup() {
  if [[ -n "$APP_PID" ]] && kill -0 "$APP_PID" 2>/dev/null; then
    kill "$APP_PID" 2>/dev/null || true
    sleep 1
  fi
  launchctl unsetenv DEVMAID_HOME 2>/dev/null || true
  launchctl unsetenv DEVMAID_SEARCH_ROOTS 2>/dev/null || true
  launchctl unsetenv DEVMAID_LANGUAGE 2>/dev/null || true
  launchctl unsetenv DEVMAID_VOLATILE_PREFERENCES 2>/dev/null || true
  launchctl unsetenv DEVMAID_TEST_SCAN_DELAY_MS 2>/dev/null || true
  pkill -f "$APP_BIN" 2>/dev/null || true
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

run_osascript() {
  osascript "$@"
}

toolbar_descriptions() {
  run_osascript <<'APPLESCRIPT'
tell application "DevMaid" to activate
delay 1
tell application "System Events"
  tell process "DevMaid"
    set frontmost to true
    delay 1
    set output to {}
    repeat with b in (every button of toolbar 1 of window 1)
      set end of output to description of b
    end repeat
    return output
  end tell
end tell
APPLESCRIPT
}

wait_for_toolbar_label() {
  local expected="$1"
  local attempts="${2:-20}"
  local output=""

  for _ in $(seq 1 "$attempts"); do
    output="$(toolbar_descriptions 2>/dev/null || true)"
    if [[ "$output" == *"$expected"* ]]; then
      echo "$output"
      return 0
    fi
    sleep 1
  done

  echo "Timed out waiting for toolbar label: $expected" >&2
  if [[ -n "$output" ]]; then
    echo "Last toolbar output: $output" >&2
  fi
  return 1
}

detect_toolbar_language() {
  local output=""
  for _ in $(seq 1 20); do
    output="$(toolbar_descriptions 2>/dev/null || true)"
    if [[ "$output" == *"Run Scan"* ]]; then
      echo "en"
      return 0
    fi
    if [[ "$output" == *"เริ่มสแกน"* ]]; then
      echo "th"
      return 0
    fi
    sleep 1
  done

  echo "Unable to detect toolbar language." >&2
  if [[ -n "$output" ]]; then
    echo "Last toolbar output: $output" >&2
  fi
  return 1
}

press_toolbar_button() {
  local label="$1"
  run_osascript - "$label" <<'APPLESCRIPT'
on run argv
  set targetLabel to item 1 of argv
  tell application "DevMaid" to activate
  delay 0.2
  tell application "System Events"
    tell process "DevMaid"
      set frontmost to true
      delay 0.2
      repeat with b in (every button of toolbar 1 of window 1)
        if description of b is targetLabel then
          try
            perform action "AXPress" of b
          on error
            click b
          end try
          return
        end if
      end repeat
      error "Toolbar button not found: " & targetLabel
    end tell
  end tell
end run
APPLESCRIPT
}

press_toolbar_button_until() {
  local label="$1"
  local expected_after="$2"
  local attempts="${3:-6}"
  local output=""

  for _ in $(seq 1 "$attempts"); do
    press_toolbar_button "$label" >/dev/null 2>&1 || true
    sleep 1
    output="$(toolbar_descriptions 2>/dev/null || true)"
    if [[ "$output" == *"$expected_after"* ]]; then
      echo "$output"
      return 0
    fi
  done

  echo "Toolbar button '$label' did not transition to '$expected_after'." >&2
  if [[ -n "$output" ]]; then
    echo "Last toolbar output: $output" >&2
  fi
  return 1
}

open_settings_page() {
  run_osascript <<'APPLESCRIPT'
tell application "DevMaid" to activate
delay 1
tell application "System Events"
  tell process "DevMaid"
    keystroke "4" using command down
    delay 1
    return true
  end tell
end tell
APPLESCRIPT
}

mkdir -p "$TMP_DIR/DemoApp/node_modules"
printf 'console.log("hello");\n' > "$TMP_DIR/DemoApp/node_modules/index.js"

pkill -f "$APP_BIN" 2>/dev/null || true

if [[ "${DEVMAID_SKIP_BUILD:-0}" != "1" ]]; then
  "$ROOT_DIR/scripts/build_release.sh" >/dev/null
fi

launchctl setenv DEVMAID_HOME "$TMP_DIR/.devmaid-home"
launchctl setenv DEVMAID_SEARCH_ROOTS "$TMP_DIR"
launchctl setenv DEVMAID_LANGUAGE "en"
launchctl setenv DEVMAID_VOLATILE_PREFERENCES "1"
launchctl setenv DEVMAID_TEST_SCAN_DELAY_MS "4000"
open -na "$APP_BUNDLE"
sleep 2
APP_PID="$(pgrep -f "$APP_BIN" | tail -n 1)"

run_osascript <<'APPLESCRIPT'
try
  tell application "DevMaid" to activate
  delay 1
  tell application "System Events"
    tell process "DevMaid"
      if exists (sheet 1 of window 1) then
        click button "Start using DevMaid" of sheet 1 of window 1
        delay 1
      end if
    end tell
  end tell
end try
APPLESCRIPT

toolbar_language="$(detect_toolbar_language)"
if [[ "$toolbar_language" == "th" ]]; then
  run_scan_label="เริ่มสแกน"
  cancel_scan_label="ยกเลิกสแกน"
else
  run_scan_label="Run Scan"
  cancel_scan_label="Cancel Scan"
fi

wait_for_toolbar_label "$run_scan_label" 20 >/dev/null
press_toolbar_button_until "$run_scan_label" "$cancel_scan_label" 8 >/dev/null
press_toolbar_button_until "$cancel_scan_label" "$run_scan_label" 8 >/dev/null

open_settings_page >/dev/null

echo "UI smoke test passed."
