# Distribution

DevMaid can now be shipped in two installer-friendly forms:

- direct download as `.dmg`
- terminal install through Homebrew using a generated formula
- native `.app` bundle inside the DMG for end users

## Release artifacts

Run the release builder:

```bash
cd /Users/earthondev/Desktop/Devmaid
./scripts/build_release.sh
```

By default this creates:

- `dist/devmaid-<version>-macos-<arch>.tar.gz`
- `dist/DevMaid.app`
- `dist/DevMaid-<version>.dmg`
- `dist/checksums-<version>.txt`

The tarball is for Homebrew. The `.app` and `.dmg` are for website/download users.

## Release version

The default version comes from [VERSION](/Users/earthondev/Desktop/Devmaid/VERSION).

Override it per release if needed:

```bash
./scripts/build_release.sh 0.2.0
```

## Optional knobs

Environment variables supported by `build_release.sh`:

- `DEVMAID_ARCHS="arm64 x86_64"` builds two binaries and merges them with `lipo`
- `DEVMAID_HOMEBREW_URL="<public tarball url>"` also generates `dist/devmaid.rb`
- `DEVMAID_SIGNING_IDENTITY="Developer ID Application: ..."` signs the `.app`
- `DEVMAID_NOTARY_KEYCHAIN_PROFILE="<notarytool profile>"` notarizes and staples the generated DMG when signing is enabled
- `DEVMAID_APP_IDENTIFIER="app.devmaid.desktop"` changes the app bundle identifier
- the legacy `ROOMSERVICE_*` names still work for compatibility, but new automation should use `DEVMAID_*`

## Generate a Homebrew formula

Single-archive formula:

```bash
./scripts/generate_homebrew_formula.sh \
  --version 0.2.0 \
  --url https://github.com/OWNER/REPO/releases/download/v0.2.0/devmaid-0.2.0-macos-arm64.tar.gz \
  --archive dist/devmaid-0.2.0-macos-arm64.tar.gz \
  --output dist/devmaid.rb
```

Multi-architecture formula:

```bash
./scripts/generate_homebrew_formula.sh \
  --version 0.2.0 \
  --arm-url https://github.com/OWNER/REPO/releases/download/v0.2.0/devmaid-0.2.0-macos-arm64.tar.gz \
  --arm-archive dist/devmaid-0.2.0-macos-arm64.tar.gz \
  --intel-url https://github.com/OWNER/REPO/releases/download/v0.2.0/devmaid-0.2.0-macos-x86_64.tar.gz \
  --intel-archive dist/devmaid-0.2.0-macos-x86_64.tar.gz \
  --output dist/devmaid.rb
```

Publish that formula in either:

- a tap repository at `Formula/devmaid.rb`
- a raw public URL, then users can run `brew install --formula <url>`

## Signing and notarization

The current packaging flow supports app signing when you provide `DEVMAID_SIGNING_IDENTITY`.

If you also provide `DEVMAID_NOTARY_KEYCHAIN_PROFILE`, the generated DMG is submitted with `xcrun notarytool`, then stapled automatically.

What is not automated yet:

- Homebrew cask packaging for the app
- a tap repository update for `devmaid.rb`

Those are the remaining steps if you want a more turnkey public distribution story.

## GitHub Actions release automation

The repo now includes:

- `.github/workflows/ci.yml` for CLI/app builds plus smoke tests
- `.github/workflows/release.yml` for release artifact creation and GitHub release uploads

The release workflow:

1. resolves the version from a tag like `v0.2.0` or a manual dispatch input
2. runs `./scripts/build_release.sh`
3. generates `dist/devmaid.rb` pointing at the GitHub release tarball
4. generates `dist/devmaid-app.rb` pointing at the GitHub release DMG
5. generates `dist/appcast.json` for in-app update checks
6. uploads the DMG, tarball, checksums, formula, cask, and appcast as release assets

If you add these GitHub secrets, the release workflow will also sign and notarize the DMG:

- `DEVMAID_SIGNING_IDENTITY`
- `DEVMAID_NOTARY_KEYCHAIN_PROFILE`

## Recommended release flow

1. Push a tag such as `v0.2.0`, or run the `Release` GitHub Actions workflow manually
2. Verify the generated tarball, dmg, checksums, `devmaid.rb`, `devmaid-app.rb`, and `appcast.json`
3. Publish the formula and cask in your tap repo if you want `brew tap Earthondev/devmaid && brew install devmaid` plus `brew install --cask Earthondev/devmaid/devmaid-app`
4. Verify both install paths on a clean machine:
   `brew install`
   `brew install --cask`
   direct dmg download + app launch
