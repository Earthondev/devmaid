#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  generate_homebrew_formula.sh --version <version> [--url <url> --archive <tarball>] [--arm-url <url> --arm-archive <tarball>] [--intel-url <url> --intel-archive <tarball>] [--output <path>] [--homepage <url>]

Examples:
  ./scripts/generate_homebrew_formula.sh \
    --version 0.1.0 \
    --url https://github.com/owner/repo/releases/download/v0.1.0/devmaid-0.1.0-macos-arm64.tar.gz \
    --archive dist/devmaid-0.1.0-macos-arm64.tar.gz \
    --output dist/devmaid.rb
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="$ROOT_DIR/dist/devmaid.rb"
HOMEPAGE="https://github.com/Earthondev/devmaid"
LICENSE_NAME="MIT"
VERSION=""
GENERIC_URL=""
GENERIC_ARCHIVE=""
GENERIC_SHA=""
ARM_URL=""
ARM_ARCHIVE=""
ARM_SHA=""
INTEL_URL=""
INTEL_ARCHIVE=""
INTEL_SHA=""

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
      GENERIC_URL="$2"
      shift 2
      ;;
    --archive)
      GENERIC_ARCHIVE="$2"
      shift 2
      ;;
    --sha256)
      GENERIC_SHA="$2"
      shift 2
      ;;
    --arm-url)
      ARM_URL="$2"
      shift 2
      ;;
    --arm-archive)
      ARM_ARCHIVE="$2"
      shift 2
      ;;
    --arm-sha256)
      ARM_SHA="$2"
      shift 2
      ;;
    --intel-url)
      INTEL_URL="$2"
      shift 2
      ;;
    --intel-archive)
      INTEL_ARCHIVE="$2"
      shift 2
      ;;
    --intel-sha256)
      INTEL_SHA="$2"
      shift 2
      ;;
    --homepage)
      HOMEPAGE="$2"
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

if [[ -z "$VERSION" ]]; then
  echo "--version is required" >&2
  exit 1
fi

if [[ -n "$GENERIC_ARCHIVE" && -z "$GENERIC_SHA" ]]; then
  GENERIC_SHA="$(sha_for "$GENERIC_ARCHIVE")"
fi
if [[ -n "$ARM_ARCHIVE" && -z "$ARM_SHA" ]]; then
  ARM_SHA="$(sha_for "$ARM_ARCHIVE")"
fi
if [[ -n "$INTEL_ARCHIVE" && -z "$INTEL_SHA" ]]; then
  INTEL_SHA="$(sha_for "$INTEL_ARCHIVE")"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

if [[ -n "$ARM_URL" || -n "$INTEL_URL" ]]; then
  if [[ -z "$ARM_URL" || -z "$ARM_SHA" || -z "$INTEL_URL" || -z "$INTEL_SHA" ]]; then
    echo "arm and intel formula generation requires both URL and SHA256 for each architecture" >&2
    exit 1
  fi

  cat > "$OUTPUT_PATH" <<EOF
class Devmaid < Formula
  desc "Developer-focused macOS cleaner for build artifacts, caches, and dependencies"
  homepage "$HOMEPAGE"
  version "$VERSION"
  license "$LICENSE_NAME"

  on_arm do
    url "$ARM_URL"
    sha256 "$ARM_SHA"
  end

  on_intel do
    url "$INTEL_URL"
    sha256 "$INTEL_SHA"
  end

  def install
    bin.install "devmaid"
    prefix.install_metafiles "README.md", "LICENSE"
  end

  test do
    assert_match "DevMaid scan", shell_output("#{bin}/devmaid scan --category playwright-cache --search-root #{testpath} --limit 1")
  end
end
EOF
else
  if [[ -z "$GENERIC_URL" || -z "$GENERIC_SHA" ]]; then
    echo "generic formula generation requires --url plus --archive or --sha256" >&2
    exit 1
  fi

  cat > "$OUTPUT_PATH" <<EOF
class Devmaid < Formula
  desc "Developer-focused macOS cleaner for build artifacts, caches, and dependencies"
  homepage "$HOMEPAGE"
  url "$GENERIC_URL"
  sha256 "$GENERIC_SHA"
  version "$VERSION"
  license "$LICENSE_NAME"

  def install
    bin.install "devmaid"
    prefix.install_metafiles "README.md", "LICENSE"
  end

  test do
    assert_match "DevMaid scan", shell_output("#{bin}/devmaid scan --category playwright-cache --search-root #{testpath} --limit 1")
  end
end
EOF
fi

echo "Wrote Homebrew formula to $OUTPUT_PATH"
