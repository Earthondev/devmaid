#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/dist/DevMaid.app"
APP_BIN="$APP_BUNDLE/Contents/MacOS/DevMaid"
OUTPUT_DIR="${1:-$HOME/Desktop}"
TMP_DIR="$(mktemp -d /tmp/devmaid-captures.XXXXXX)"
APP_PID=""

cleanup() {
  if [[ -n "$APP_PID" ]] && kill -0 "$APP_PID" 2>/dev/null; then
    kill "$APP_PID" 2>/dev/null || true
    sleep 1
  fi
  launchctl unsetenv ROOMSERVICE_HOME 2>/dev/null || true
  launchctl unsetenv ROOMSERVICE_SEARCH_ROOTS 2>/dev/null || true
  launchctl unsetenv ROOMSERVICE_LANGUAGE 2>/dev/null || true
  launchctl unsetenv ROOMSERVICE_VOLATILE_PREFERENCES 2>/dev/null || true
  launchctl unsetenv ROOMSERVICE_UPDATE_FEED_URL 2>/dev/null || true
  pkill -f "$APP_BIN" 2>/dev/null || true
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

if [[ ! -x "$APP_BIN" ]]; then
  "$ROOT_DIR/scripts/build_release.sh" >/dev/null
fi

mkdir -p "$OUTPUT_DIR"

WORKSPACE="$TMP_DIR/workspace"
APP_HOME="$TMP_DIR/.roomservice-home"
UPDATE_FEED="$TMP_DIR/appcast.json"
mkdir -p \
  "$WORKSPACE/ArchiveCandidate/node_modules/react" \
  "$WORKSPACE/MobileClient/.venv/bin" \
  "$WORKSPACE/FreshWorkspace/node_modules/lodash"

python3 - <<'PY' "$WORKSPACE/ArchiveCandidate/node_modules/react/index.js" "$WORKSPACE/MobileClient/.venv/bin/python" "$WORKSPACE/FreshWorkspace/node_modules/lodash/index.js"
from pathlib import Path
import sys

payloads = [
    ("console.log('react');\n" * 2000).encode(),
    ("#!/usr/bin/env python3\n" + "print('venv')\n" * 1200).encode(),
    ("module.exports = 'lodash';\n" * 1800).encode(),
]

for path, data in zip(sys.argv[1:], payloads):
    file_path = Path(path)
    file_path.parent.mkdir(parents=True, exist_ok=True)
    file_path.write_bytes(data)
PY

cat > "$UPDATE_FEED" <<'JSON'
{
  "version": "0.3.0",
  "build": "0.3.0",
  "minimumSystemVersion": "13.0",
  "summary": "A softer glassmorphism refresh, in-app update checks, and a cleaner macOS-native navigation shell.",
  "downloadURL": "https://github.com/Earthondev/devmaid/releases/download/v0.3.0/DevMaid-0.3.0.dmg",
  "releaseNotesURL": "https://github.com/Earthondev/devmaid/releases/tag/v0.3.0",
  "publishedAt": "2026-03-24T12:00:00Z"
}
JSON

env \
  ROOMSERVICE_HOME="$APP_HOME" \
  ROOMSERVICE_SEARCH_ROOTS="$WORKSPACE" \
  ROOMSERVICE_LANGUAGE="en" \
  ROOMSERVICE_VOLATILE_PREFERENCES="1" \
  ROOMSERVICE_UPDATE_FEED_URL="$UPDATE_FEED" \
  swift run devmaid delete --category node-modules --search-root "$WORKSPACE" --all --yes >/dev/null

mkdir -p "$WORKSPACE/RecreatedWorkspace/node_modules/next"
python3 - <<'PY' "$WORKSPACE/RecreatedWorkspace/node_modules/next/index.js"
from pathlib import Path
import sys

path = Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)
path.write_bytes(("module.exports = 'next';\n" * 2200).encode())
PY

launchctl setenv ROOMSERVICE_HOME "$APP_HOME"
launchctl setenv ROOMSERVICE_SEARCH_ROOTS "$WORKSPACE"
launchctl setenv ROOMSERVICE_LANGUAGE "en"
launchctl setenv ROOMSERVICE_VOLATILE_PREFERENCES "1"
launchctl setenv ROOMSERVICE_UPDATE_FEED_URL "$UPDATE_FEED"
open -na "$APP_BUNDLE"

run_osascript() {
  osascript "$@"
}

wait_for_devmaid() {
  for _ in $(seq 1 40); do
    if [[ "$(run_osascript <<'APPLESCRIPT' 2>/dev/null
tell application "System Events"
  return exists process "DevMaid"
end tell
APPLESCRIPT
)" == "true" ]]; then
      return 0
    fi
    sleep 1
  done

  echo "DevMaid did not launch in time." >&2
  return 1
}

wait_for_main_window() {
  for _ in $(seq 1 40); do
    if [[ "$(run_osascript <<'APPLESCRIPT' 2>/dev/null
tell application "System Events"
  tell process "DevMaid"
    return (count of windows) > 0
  end tell
end tell
APPLESCRIPT
)" == "true" ]]; then
      return 0
    fi
    sleep 1
  done

  echo "DevMaid main window did not appear in time." >&2
  return 1
}

activate_app() {
  run_osascript <<'APPLESCRIPT'
tell application "DevMaid" to activate
APPLESCRIPT
}

focus_main_window() {
  run_osascript <<'APPLESCRIPT'
tell application "DevMaid" to activate
delay 0.4
tell application "System Events"
  tell process "DevMaid"
    set frontmost to true
    set position of window 1 to {80, 60}
    set size of window 1 to {1440, 920}
  end tell
end tell
APPLESCRIPT
}

send_shortcut() {
  local key="$1"
  run_osascript - "$key" <<'APPLESCRIPT'
on run argv
  set targetKey to item 1 of argv
  tell application "DevMaid" to activate
  delay 0.2
  tell application "System Events"
    tell process "DevMaid"
      set frontmost to true
      keystroke targetKey using command down
    end tell
  end tell
end run
APPLESCRIPT
}

click_toolbar_button() {
  local label="$1"
  run_osascript - "$label" <<'APPLESCRIPT'
on run argv
  set targetLabel to item 1 of argv
  tell application "DevMaid" to activate
  delay 0.2
  tell application "System Events"
    tell process "DevMaid"
      set frontmost to true
      repeat with b in (every button of toolbar 1 of window 1)
        if description of b is targetLabel then
          click b
          return
        end if
      end repeat
      error "Toolbar button not found: " & targetLabel
    end tell
  end tell
end run
APPLESCRIPT
}

window_id_for_title() {
  local title="$1"
  swift -e '
import CoreGraphics
import Foundation

let targetTitle = CommandLine.arguments[1]
let infos = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []

for info in infos {
    let ownerName = info[kCGWindowOwnerName as String] as? String ?? ""
    let title = info[kCGWindowName as String] as? String ?? ""
    let layer = info[kCGWindowLayer as String] as? Int ?? 0

    guard ownerName == "DevMaid", layer == 0 else {
        continue
    }

    if title == targetTitle {
        if let number = info[kCGWindowNumber as String] {
            print(number)
            break
        }
    }
}
' "$title"
}

capture_window() {
  local title="$1"
  local output_path="$2"
  local window_id=""

  for _ in $(seq 1 20); do
    window_id="$(window_id_for_title "$title" | tr -d '\n')"
    if [[ -n "$window_id" ]]; then
      break
    fi
    sleep 1
  done

  if [[ -z "$window_id" ]]; then
    echo "Unable to find a DevMaid window titled '$title'." >&2
    return 1
  fi

  screencapture -x -l "$window_id" "$output_path"
}

wait_for_devmaid
APP_PID="$(pgrep -f "$APP_BIN" | tail -n 1)"
activate_app
wait_for_main_window
focus_main_window
sleep 1

capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-overview.png"

click_toolbar_button "Run Scan"
sleep 2
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-results.png"

send_shortcut "3"
sleep 1
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-history.png"

send_shortcut "4"
sleep 1
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-settings.png"

send_shortcut "5"
sleep 1
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-about.png"

echo "Saved screenshots:"
echo "$OUTPUT_DIR/DevMaid-overview.png"
echo "$OUTPUT_DIR/DevMaid-results.png"
echo "$OUTPUT_DIR/DevMaid-history.png"
echo "$OUTPUT_DIR/DevMaid-settings.png"
echo "$OUTPUT_DIR/DevMaid-about.png"
