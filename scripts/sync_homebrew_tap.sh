#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  sync_homebrew_tap.sh --version <version> --repository <owner/repo> --token <github-token> [options]

Options:
  --tap-repository <owner/repo>  Tap repo slug. Defaults to Earthondev/homebrew-devmaid.
  --homepage <url>               Homepage for formula and cask. Defaults to main repo.
  --work-dir <path>              Temporary checkout location.
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION=""
REPOSITORY=""
TOKEN=""
TAP_REPOSITORY="${DEVMAID_TAP_REPOSITORY:-Earthondev/homebrew-devmaid}"
HOMEPAGE=""
WORK_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --repository)
      REPOSITORY="$2"
      shift 2
      ;;
    --token)
      TOKEN="$2"
      shift 2
      ;;
    --tap-repository)
      TAP_REPOSITORY="$2"
      shift 2
      ;;
    --homepage)
      HOMEPAGE="$2"
      shift 2
      ;;
    --work-dir)
      WORK_DIR="$2"
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

if [[ -z "$VERSION" || -z "$REPOSITORY" || -z "$TOKEN" ]]; then
  echo "--version, --repository, and --token are required" >&2
  exit 1
fi

if [[ -z "$HOMEPAGE" ]]; then
  HOMEPAGE="https://github.com/${REPOSITORY}"
fi

if [[ -z "$WORK_DIR" ]]; then
  WORK_DIR="$(mktemp -d /tmp/devmaid-tap.XXXXXX)"
  CLEAN_WORK_DIR="true"
else
  mkdir -p "$WORK_DIR"
  CLEAN_WORK_DIR="false"
fi

cleanup() {
  if [[ "$CLEAN_WORK_DIR" == "true" ]]; then
    rm -rf "$WORK_DIR"
  fi
}

trap cleanup EXIT

DMG_PATH="$ROOT_DIR/dist/DevMaid-${VERSION}.dmg"
TARBALL_PATH="$(find "$ROOT_DIR/dist" -maxdepth 1 -name "devmaid-${VERSION}-macos-*.tar.gz" | head -n 1)"

if [[ ! -f "$DMG_PATH" || -z "$TARBALL_PATH" ]]; then
  echo "Expected release artifacts for version ${VERSION} are missing from dist/." >&2
  exit 1
fi

git clone "https://x-access-token:${TOKEN}@github.com/${TAP_REPOSITORY}.git" "$WORK_DIR/repo" >/dev/null 2>&1

mkdir -p "$WORK_DIR/repo/Formula" "$WORK_DIR/repo/Casks"

./scripts/generate_homebrew_formula.sh \
  --version "$VERSION" \
  --url "https://github.com/${REPOSITORY}/releases/download/v${VERSION}/$(basename "$TARBALL_PATH")" \
  --archive "$TARBALL_PATH" \
  --homepage "$HOMEPAGE" \
  --output "$WORK_DIR/repo/Formula/devmaid.rb"

./scripts/generate_homebrew_cask.sh \
  --version "$VERSION" \
  --url "https://github.com/${REPOSITORY}/releases/download/v${VERSION}/$(basename "$DMG_PATH")" \
  --dmg "$DMG_PATH" \
  --homepage "$HOMEPAGE" \
  --output "$WORK_DIR/repo/Casks/devmaid-app.rb"

cat > "$WORK_DIR/repo/README.md" <<EOF
# homebrew-devmaid

Homebrew tap for [DevMaid](${HOMEPAGE}).

## Install

\`\`\`bash
brew tap Earthondev/devmaid
\`\`\`

\`\`\`bash
brew install devmaid
\`\`\`

\`\`\`bash
brew install --cask devmaid-app
\`\`\`
EOF

git -C "$WORK_DIR/repo" config user.name "github-actions[bot]"
git -C "$WORK_DIR/repo" config user.email "41898282+github-actions[bot]@users.noreply.github.com"

if [[ -z "$(git -C "$WORK_DIR/repo" status --porcelain)" ]]; then
  echo "Tap repo already up to date."
  exit 0
fi

git -C "$WORK_DIR/repo" add README.md Formula/devmaid.rb Casks/devmaid-app.rb
git -C "$WORK_DIR/repo" commit -m "Update DevMaid formulas for v${VERSION}" >/dev/null
git -C "$WORK_DIR/repo" push origin main >/dev/null

echo "Synced ${TAP_REPOSITORY} for v${VERSION}"
