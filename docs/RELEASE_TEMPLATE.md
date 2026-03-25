# Release Template

Use this template for GitHub releases when publishing a new DevMaid version.

## Title

`DevMaid vX.Y.Z`

## Short summary

DevMaid is a free, preview-first cleanup tool for developer Macs. It helps reclaim space from Xcode, Docker, `node_modules`, `.venv`, editor caches, package caches, project artifacts, and other rebuildable dev junk without hiding what will be touched.

## Highlights

- native macOS desktop app plus `devmaid` CLI
- preview-first, quarantine-first, undo-capable cleanup
- Thai and English UI
- weekly reclaimable-storage trend and local smart alerts
- exclusions list for paths or projects you never want scanned
- startup-item visibility and launch-at-login control for DevMaid itself

## Downloads

- `DevMaid-<version>.dmg`
- `devmaid-<version>-macos-<arch>.tar.gz`
- `devmaid.rb`
- `devmaid-app.rb`
- `appcast.json`
- `checksums-<version>.txt`

## Recommended install paths

### Desktop app

1. Download `DevMaid-<version>.dmg`
2. Drag `DevMaid.app` into Applications
3. Open DevMaid and complete the welcome guide

### CLI

```bash
brew install --formula <public-devmaid.rb-url>
```

## Suggested sections for this release

### Added

- new cleanup categories
- new UI flows or settings
- new CLI commands or export support

### Improved

- macOS polish
- scanning performance
- safety messaging
- onboarding, alerts, or localization

### Fixed

- scan bugs
- restore bugs
- results filtering or selection bugs
- packaging or install issues

## Verification note

This release should be verified on:

- direct DMG install
- first launch on a clean Mac
- CLI install from the generated Homebrew formula
- one full scan and one cleanup/undo cycle
