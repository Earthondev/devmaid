#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  generate_homebrew_cask.sh --version <version> --url <url> [--dmg <path> | --sha256 <hash>] [--output <path>] [--homepage <url>] [--token <token>]

Examples:
  ./scripts/generate_homebrew_cask.sh \
    --version 0.2.2 \
    --url https://github.com/Earthondev/devmaid/releases/download/v0.2.2/DevMaid-0.2.2.dmg \
    --dmg dist/DevMaid-0.2.2.dmg \
    --output dist/devmaid-app.rb
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="$ROOT_DIR/dist/devmaid-app.rb"
HOMEPAGE="https://github.com/Earthondev/devmaid"
TOKEN="devmaid-app"
VERSION=""
URL=""
DMG_PATH=""
SHA256=""

sha_for() {
  shasum -a 256 "$1" | awk '{print $1}'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --url)
      URL="$2"
      shift 2
      ;;
    --dmg)
      DMG_PATH="$2"
      shift 2
      ;;
    --sha256)
      SHA256="$2"
      shift 2
      ;;
    --homepage)
      HOMEPAGE="$2"
      shift 2
      ;;
    --token)
      TOKEN="$2"
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

if [[ -z "$VERSION" || -z "$URL" ]]; then
  echo "--version and --url are required" >&2
  exit 1
fi

if [[ -n "$DMG_PATH" && -z "$SHA256" ]]; then
  SHA256="$(sha_for "$DMG_PATH")"
fi

if [[ -z "$SHA256" ]]; then
  echo "--dmg or --sha256 is required" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

cat > "$OUTPUT_PATH" <<EOF
cask "$TOKEN" do
  version "$VERSION"
  sha256 "$SHA256"

  url "$URL"
  name "DevMaid"
  desc "Developer-focused macOS cleaner for build artifacts, caches, and dependencies"
  homepage "$HOMEPAGE"

  auto_updates true
  app "DevMaid.app"

  zap trash: [
    "~/.devmaid",
    "~/Library/Application Support/DevMaid",
    "~/Library/Preferences/app.devmaid.desktop.plist",
  ]
end
EOF

echo "Wrote Homebrew cask to $OUTPUT_PATH"
