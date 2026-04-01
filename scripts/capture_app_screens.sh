#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/dist/DevMaid.app"
APP_BIN="$APP_BUNDLE/Contents/MacOS/DevMaid"
OUTPUT_DIR="${1:-$HOME/Desktop}"
TMP_DIR="$(mktemp -d /tmp/devmaid-captures.XXXXXX)"
MOCK_UPDATE_VERSION="0.3.0"
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
  launchctl unsetenv DEVMAID_UPDATE_FEED_URL 2>/dev/null || true
  launchctl unsetenv DEVMAID_LAUNCH_DESTINATION 2>/dev/null || true
  launchctl unsetenv DEVMAID_AUTO_RUN_SCAN_ON_LAUNCH 2>/dev/null || true
  pkill -f "$APP_BIN" 2>/dev/null || true
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

"$ROOT_DIR/scripts/build_release.sh" >/dev/null

mkdir -p "$OUTPUT_DIR"

pkill -f "$APP_BIN" 2>/dev/null || true
sleep 1

WORKSPACE="$TMP_DIR/workspace"
APP_HOME="$TMP_DIR/.devmaid-home"
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
  "version": "__MOCK_UPDATE_VERSION__",
  "build": "__MOCK_UPDATE_VERSION__",
  "minimumSystemVersion": "13.0",
  "summary": "A softer glassmorphism refresh, in-app update checks, and a cleaner macOS-native navigation shell.",
  "downloadURL": "https://github.com/Earthondev/devmaid/releases/download/v__MOCK_UPDATE_VERSION__/DevMaid-__MOCK_UPDATE_VERSION__.dmg",
  "releaseNotesURL": "https://github.com/Earthondev/devmaid/releases/tag/v__MOCK_UPDATE_VERSION__",
  "publishedAt": "2026-03-24T12:00:00Z"
}
JSON

perl -0pi -e 's/__MOCK_UPDATE_VERSION__/'"$MOCK_UPDATE_VERSION"'/g' "$UPDATE_FEED"

env \
  DEVMAID_HOME="$APP_HOME" \
  DEVMAID_SEARCH_ROOTS="$WORKSPACE" \
  DEVMAID_LANGUAGE="en" \
  DEVMAID_VOLATILE_PREFERENCES="1" \
  DEVMAID_UPDATE_FEED_URL="$UPDATE_FEED" \
  swift run devmaid delete --category node-modules --search-root "$WORKSPACE" --all --yes >/dev/null

mkdir -p "$WORKSPACE/RecreatedWorkspace/node_modules/next"
python3 - <<'PY' "$WORKSPACE/RecreatedWorkspace/node_modules/next/index.js"
from pathlib import Path
import sys

path = Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)
path.write_bytes(("module.exports = 'next';\n" * 2200).encode())
PY

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

toolbar_descriptions() {
  run_osascript <<'APPLESCRIPT'
tell application "DevMaid" to activate
delay 0.4
tell application "System Events"
  tell process "DevMaid"
    set frontmost to true
    delay 0.4
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
  local attempts="${2:-25}"
  local output=""

  for _ in $(seq 1 "$attempts"); do
    output="$(toolbar_descriptions 2>/dev/null || true)"
    if [[ "$output" == *"$expected"* ]]; then
      return 0
    fi
    sleep 1
  done

  echo "Timed out waiting for toolbar label: $expected" >&2
  [[ -n "$output" ]] && echo "Last toolbar output: $output" >&2
  return 1
}

wait_for_toolbar_without_label() {
  local blocked="$1"
  local attempts="${2:-25}"
  local output=""

  for _ in $(seq 1 "$attempts"); do
    output="$(toolbar_descriptions 2>/dev/null || true)"
    if [[ "$output" != *"$blocked"* ]]; then
      return 0
    fi
    sleep 1
  done

  echo "Timed out waiting for toolbar to remove label: $blocked" >&2
  [[ -n "$output" ]] && echo "Last toolbar output: $output" >&2
  return 1
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

select_navigation_menu_item() {
  local label="$1"
  run_osascript - "$label" <<'APPLESCRIPT'
on run argv
  set targetLabel to item 1 of argv
  tell application "DevMaid" to activate
  delay 0.2
  tell application "System Events"
    tell process "DevMaid"
      set frontmost to true
      click menu item targetLabel of menu 1 of menu bar item "Navigate" of menu bar 1
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
  local attempts="${3:-8}"
  local output=""

  for _ in $(seq 1 "$attempts"); do
    click_toolbar_button "$label" >/dev/null 2>&1 || true
    sleep 1
    output="$(toolbar_descriptions 2>/dev/null || true)"
    if [[ "$output" == *"$expected_after"* ]]; then
      return 0
    fi
  done

  echo "Toolbar button '$label' did not transition to '$expected_after'." >&2
  [[ -n "$output" ]] && echo "Last toolbar output: $output" >&2
  return 1
}

window_id_for_title() {
  local title="$1"
  swift -e '
import CoreGraphics
import Foundation

let targetTitle = CommandLine.arguments[1]
let infos = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
var fallbackWindowNumber: Any?

for info in infos {
    let ownerName = info[kCGWindowOwnerName as String] as? String ?? ""
    let title = info[kCGWindowName as String] as? String ?? ""
    let layer = info[kCGWindowLayer as String] as? Int ?? 0

    guard ownerName == "DevMaid", layer == 0 else {
        continue
    }

    if fallbackWindowNumber == nil {
        fallbackWindowNumber = info[kCGWindowNumber as String]
    }

    if title == targetTitle {
        if let number = info[kCGWindowNumber as String] {
            print(number)
            break
        }
    }
}

if let fallbackWindowNumber {
    print(fallbackWindowNumber)
}
' "$title"
}

capture_window() {
  local title="$1"
  local output_path="$2"
  local window_id=""

  activate_app >/dev/null 2>&1 || true
  focus_main_window >/dev/null 2>&1 || true
  sleep 1

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

  for _ in $(seq 1 8); do
    window_id="$(window_id_for_title "$title" | tr -d '\n')"
    if [[ -n "$window_id" ]] && swift -e '
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let windowID = CGWindowID(UInt32(CommandLine.arguments[1]) ?? 0)
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2]) as CFURL

guard let image = CGWindowListCreateImage(.null, .optionIncludingWindow, windowID, [.boundsIgnoreFraming, .bestResolution]) else {
    fputs("could not create image from window\n", stderr)
    exit(1)
}

guard let destination = CGImageDestinationCreateWithURL(outputURL, UTType.png.identifier as CFString, 1, nil) else {
    fputs("could not create image destination\n", stderr)
    exit(1)
}

CGImageDestinationAddImage(destination, image, nil)

guard CGImageDestinationFinalize(destination) else {
    fputs("could not finalize image destination\n", stderr)
    exit(1)
}
' "$window_id" "$output_path" >/dev/null 2>&1; then
      return 0
    fi
    activate_app >/dev/null 2>&1 || true
    focus_main_window >/dev/null 2>&1 || true
    sleep 1
  done

  echo "Unable to capture a DevMaid window titled '$title'." >&2
  return 1
}

launch_for_capture() {
  local destination="$1"
  local auto_scan="${2:-0}"

  pkill -f "$APP_BIN" 2>/dev/null || true
  sleep 1

  launchctl setenv DEVMAID_HOME "$APP_HOME"
  launchctl setenv DEVMAID_SEARCH_ROOTS "$WORKSPACE"
  launchctl setenv DEVMAID_LANGUAGE "en"
  launchctl setenv DEVMAID_VOLATILE_PREFERENCES "1"
  launchctl setenv DEVMAID_UPDATE_FEED_URL "$UPDATE_FEED"
  launchctl setenv DEVMAID_LAUNCH_DESTINATION "$destination"
  launchctl setenv DEVMAID_AUTO_RUN_SCAN_ON_LAUNCH "$auto_scan"

  open -na "$APP_BUNDLE"

  wait_for_devmaid
  APP_PID="$(pgrep -f "$APP_BIN" | tail -n 1)"
  activate_app
  wait_for_main_window
  focus_main_window
  sleep 1
}

close_capture_app() {
  if [[ -n "$APP_PID" ]] && kill -0 "$APP_PID" 2>/dev/null; then
    kill "$APP_PID" 2>/dev/null || true
    sleep 1
  fi
  APP_PID=""
}

launch_for_capture "overview" "0"
wait_for_toolbar_without_label "Quarantine Selected" 10
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-overview.png"
close_capture_app

launch_for_capture "results" "1"
wait_for_toolbar_label "Quarantine Selected" 40
wait_for_toolbar_label "Run Scan" 40
sleep 1
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-results.png"
close_capture_app

launch_for_capture "history" "0"
wait_for_toolbar_without_label "Quarantine Selected" 10
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-history.png"
close_capture_app

launch_for_capture "settings" "0"
wait_for_toolbar_without_label "Quarantine Selected" 10
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-settings.png"
close_capture_app

launch_for_capture "about" "0"
wait_for_toolbar_without_label "Quarantine Selected" 10
capture_window "DevMaid" "$OUTPUT_DIR/DevMaid-about.png"
close_capture_app

echo "Saved screenshots:"
echo "$OUTPUT_DIR/DevMaid-overview.png"
echo "$OUTPUT_DIR/DevMaid-results.png"
echo "$OUTPUT_DIR/DevMaid-history.png"
echo "$OUTPUT_DIR/DevMaid-settings.png"
echo "$OUTPUT_DIR/DevMaid-about.png"
