#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  generate_appcast.sh --version <version> --download-url <url> --release-notes-url <url> [options]

Options:
  --build <build>                     Build identifier. Defaults to version.
  --minimum-system-version <version>  Minimum macOS version. Defaults to 13.0.
  --summary <text>                    Short release summary.
  --published-at <timestamp>          ISO-8601 UTC timestamp. Defaults to current UTC time.
  --output <path>                     Output path. Defaults to dist/appcast.json.
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="$ROOT_DIR/dist/appcast.json"
VERSION=""
BUILD=""
MINIMUM_SYSTEM_VERSION="13.0"
SUMMARY="Latest DevMaid release."
PUBLISHED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
DOWNLOAD_URL=""
RELEASE_NOTES_URL=""

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --build)
      BUILD="$2"
      shift 2
      ;;
    --minimum-system-version)
      MINIMUM_SYSTEM_VERSION="$2"
      shift 2
      ;;
    --summary)
      SUMMARY="$2"
      shift 2
      ;;
    --published-at)
      PUBLISHED_AT="$2"
      shift 2
      ;;
    --download-url)
      DOWNLOAD_URL="$2"
      shift 2
      ;;
    --release-notes-url)
      RELEASE_NOTES_URL="$2"
      shift 2
      ;;
    --output)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$VERSION" || -z "$DOWNLOAD_URL" || -z "$RELEASE_NOTES_URL" ]]; then
  echo "--version, --download-url, and --release-notes-url are required" >&2
  exit 1
fi

if [[ -z "$BUILD" ]]; then
  BUILD="$VERSION"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

SUMMARY_JSON="$(printf '%s' "$SUMMARY" | json_escape)"
DOWNLOAD_URL_JSON="$(printf '%s' "$DOWNLOAD_URL" | json_escape)"
RELEASE_NOTES_URL_JSON="$(printf '%s' "$RELEASE_NOTES_URL" | json_escape)"
VERSION_JSON="$(printf '%s' "$VERSION" | json_escape)"
BUILD_JSON="$(printf '%s' "$BUILD" | json_escape)"
MINIMUM_JSON="$(printf '%s' "$MINIMUM_SYSTEM_VERSION" | json_escape)"
PUBLISHED_AT_JSON="$(printf '%s' "$PUBLISHED_AT" | json_escape)"

cat > "$OUTPUT_PATH" <<EOF
{
  "version": ${VERSION_JSON},
  "build": ${BUILD_JSON},
  "minimumSystemVersion": ${MINIMUM_JSON},
  "summary": ${SUMMARY_JSON},
  "downloadURL": ${DOWNLOAD_URL_JSON},
  "releaseNotesURL": ${RELEASE_NOTES_URL_JSON},
  "publishedAt": ${PUBLISHED_AT_JSON}
}
EOF

echo "Wrote appcast to $OUTPUT_PATH"
