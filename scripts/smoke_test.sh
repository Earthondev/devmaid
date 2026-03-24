#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
export ROOMSERVICE_HOME="$TMP_DIR/.roomservice-home"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/DemoApp/node_modules"
printf 'console.log("hello");\n' > "$TMP_DIR/DemoApp/node_modules/index.js"

SCAN_JSON="$TMP_DIR/scan.json"
"$ROOT_DIR/.build/debug/devmaid" scan --category node-modules --search-root "$TMP_DIR" --json > "$SCAN_JSON"
grep -q '"node-modules"' "$SCAN_JSON"

DELETE_JSON="$TMP_DIR/delete.json"
"$ROOT_DIR/.build/debug/devmaid" delete --category node-modules --search-root "$TMP_DIR" --all --yes --json > "$DELETE_JSON"

ACTION_ID="$(python3 - <<'PY' "$DELETE_JSON"
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as fh:
    print(json.load(fh)["actionID"])
PY
)"

test ! -d "$TMP_DIR/DemoApp/node_modules"
"$ROOT_DIR/.build/debug/devmaid" undo "$ACTION_ID" > /dev/null
test -d "$TMP_DIR/DemoApp/node_modules"

echo "Smoke test passed."
