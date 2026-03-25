#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  publish_release.sh [version]

Environment:
  DEVMAID_REPOSITORY       GitHub repo slug. Defaults to Earthondev/devmaid.
  DEVMAID_RELEASE_SUMMARY  Short summary used for appcast.json.
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOSITORY="${DEVMAID_REPOSITORY:-Earthondev/devmaid}"
VERSION_FILE="$ROOT_DIR/VERSION"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ -f "$VERSION_FILE" ]]; then
  DEFAULT_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
else
  DEFAULT_VERSION="0.1.0"
fi

VERSION="${1:-$DEFAULT_VERSION}"
TAG_NAME="v${VERSION}"
RELEASE_SUMMARY="${DEVMAID_RELEASE_SUMMARY:-Free preview-first cleanup for developer Macs with native app + CLI, safe quarantine-first deletion, and local update checks.}"

cd "$ROOT_DIR"

gh auth status >/dev/null

./scripts/build_release.sh "$VERSION"

TARBALL_PATH="$(find dist -maxdepth 1 -name "devmaid-${VERSION}-macos-*.tar.gz" | head -n 1)"
DMG_PATH="dist/DevMaid-${VERSION}.dmg"
CHECKSUMS_PATH="dist/checksums-${VERSION}.txt"
FORMULA_PATH="dist/devmaid.rb"
CASK_PATH="dist/devmaid-app.rb"
APPCAST_PATH="dist/appcast.json"

if [[ ! -f "$TARBALL_PATH" || ! -f "$DMG_PATH" || ! -f "$CHECKSUMS_PATH" ]]; then
  echo "Expected release artifacts are missing from dist/." >&2
  exit 1
fi

TARBALL_NAME="$(basename "$TARBALL_PATH")"
DMG_NAME="$(basename "$DMG_PATH")"

./scripts/generate_homebrew_formula.sh \
  --version "$VERSION" \
  --url "https://github.com/${REPOSITORY}/releases/download/${TAG_NAME}/${TARBALL_NAME}" \
  --archive "$TARBALL_PATH" \
  --homepage "https://github.com/${REPOSITORY}" \
  --output "$FORMULA_PATH"

./scripts/generate_homebrew_cask.sh \
  --version "$VERSION" \
  --url "https://github.com/${REPOSITORY}/releases/download/${TAG_NAME}/${DMG_NAME}" \
  --dmg "$DMG_PATH" \
  --homepage "https://github.com/${REPOSITORY}" \
  --output "$CASK_PATH"

./scripts/generate_appcast.sh \
  --version "$VERSION" \
  --summary "$RELEASE_SUMMARY" \
  --download-url "https://github.com/${REPOSITORY}/releases/download/${TAG_NAME}/${DMG_NAME}" \
  --release-notes-url "https://github.com/${REPOSITORY}/releases/tag/${TAG_NAME}" \
  --output "$APPCAST_PATH"

if gh release view "$TAG_NAME" --repo "$REPOSITORY" >/dev/null 2>&1; then
  gh release upload "$TAG_NAME" \
    "$DMG_PATH" \
    "$TARBALL_PATH" \
    "$CHECKSUMS_PATH" \
    "$FORMULA_PATH" \
    "$CASK_PATH" \
    "$APPCAST_PATH" \
    --clobber \
    --repo "$REPOSITORY"
else
  gh release create "$TAG_NAME" \
    "$DMG_PATH" \
    "$TARBALL_PATH" \
    "$CHECKSUMS_PATH" \
    "$FORMULA_PATH" \
    "$CASK_PATH" \
    "$APPCAST_PATH" \
    --repo "$REPOSITORY" \
    --title "DevMaid ${TAG_NAME}" \
    --generate-notes \
    --latest
fi

echo "Published ${TAG_NAME} to https://github.com/${REPOSITORY}/releases/tag/${TAG_NAME}"
