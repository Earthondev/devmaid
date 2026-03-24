# Signing And Notarization

Use this guide when you are ready to ship DevMaid to real users outside your local machine.

## What you need

- an Apple Developer account with Developer ID enabled
- a Developer ID Application certificate installed in Keychain Access
- Xcode command line tools
- `xcrun notarytool` configured with an App Store Connect keychain profile

## Local signing and notarization

Build signed and notarized release artifacts:

```bash
DEVMAID_SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
DEVMAID_NOTARY_KEYCHAIN_PROFILE="devmaid-notary" \
./scripts/build_release.sh 0.2.0
```

That produces:

- `dist/devmaid-<version>-macos-<arch>.tar.gz`
- `dist/DevMaid.app`
- `dist/DevMaid-<version>.dmg`
- `dist/appcast.json` when paired with the release publish flow
- `dist/checksums-<version>.txt`

## Configure notarytool

Create a reusable keychain profile once:

```bash
xcrun notarytool store-credentials "devmaid-notary" \
  --apple-id "YOUR_APPLE_ID" \
  --team-id "YOUR_TEAM_ID" \
  --password "YOUR_APP_SPECIFIC_PASSWORD"
```

You can also use App Store Connect API key credentials if that is how your team operates.

## Verify the signed artifacts

Check the app signature:

```bash
codesign --verify --deep --strict dist/DevMaid.app
codesign -dv --verbose=4 dist/DevMaid.app
```

Check Gatekeeper assessment:

```bash
spctl -a -vv dist/DevMaid.app
spctl -a -vv dist/DevMaid-0.2.0.dmg
```

## GitHub Actions secrets

Add these secrets if you want release automation to sign and notarize in CI:

- `DEVMAID_SIGNING_IDENTITY`
- `DEVMAID_NOTARY_KEYCHAIN_PROFILE`

The current release workflow will pass those through to `./scripts/build_release.sh`.

## Recommended release checklist

1. Build the signed release locally once and verify it opens on a clean Mac.
2. Confirm the DMG, CLI tarball, and formula all reference the same version.
3. Upload the notarized DMG, tarball, `devmaid.rb`, and `appcast.json` to a GitHub release.
4. Verify `brew install --formula <public devmaid.rb url>` works from that release.
5. Verify the app can fetch the released `appcast.json` from inside `About` or `Settings`.
6. Test direct DMG download and first launch on a machine that never ran DevMaid before.
