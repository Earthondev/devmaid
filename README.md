# DevMaid

DevMaid is a free, developer-focused macOS cleaner built for the storage problems generic cleaners usually miss: Xcode build junk, `node_modules`, `.venv`, package caches, browser test binaries, Docker Desktop data, editor caches, project artifacts, and other dev-only disk hogs.

![DevMaid desktop app](docs/assets/devmaid-window.png)

This repository ships a safe-first CLI today:

- `scan` shows what can be cleaned before anything is moved
- `delete` always quarantines first so you can undo later
- `undo` restores a previous cleanup action
- `history` keeps an audit trail of what happened
- `export scan` and `export history` write JSON reports you can share or archive

## Project status

DevMaid is being prepared as a serious public project:

- installable via DMG or Homebrew
- native macOS app plus CLI
- safe-first cleanup with quarantine and undo
- weekly reclaimable-storage trend from local scan history
- smart low-space and reclaimable-spike alerts
- startup-item visibility plus launch-at-login control for DevMaid itself
- exclusion list for paths or projects you never want scanned
- first-launch onboarding for Full Disk Access, scan roots, and cleanup safety
- in-app update checks backed by a JSON update feed
- documented release flow for maintainers
- community docs for users, contributors, and security reports
- maintainer support links routed through your GitHub repo, Issues, and Sponsors

## Install

### Homebrew

The CLI remains available through Homebrew:

```bash
brew install --formula https://github.com/Earthondev/devmaid/releases/latest/download/devmaid.rb
```

If you maintain a tap:

```bash
brew tap Earthondev/devmaid
brew install devmaid
```

### DMG

The desktop app is the main end-user product:

1. Download `DevMaid-<version>.dmg`
2. Open the DMG
3. Drag `DevMaid.app` into Applications
4. Launch the app and run your first scan

### App and CLI

- `DevMaid.app` is the native macOS interface
- `devmaid` is the CLI for automation and shell workflows
- both products use `RoomServiceKit` as the cleanup engine

## Updates

DevMaid can check for updates directly inside the app:

- `About` and `Settings` both surface the current version and latest known version
- the app reads an update feed from `DevMaidUpdateFeedURL` in the app bundle
- local development and screenshot runs can override that feed with `DEVMAID_UPDATE_FEED_URL` or `ROOMSERVICE_UPDATE_FEED_URL`
- GitHub releases should publish `appcast.json` alongside the DMG so the in-app updater has a stable latest-release feed

The update feed is a JSON document shaped like:

```json
{
  "version": "0.3.0",
  "build": "0.3.0",
  "minimumSystemVersion": "13.0",
  "summary": "Release summary",
  "downloadURL": "https://github.com/Earthondev/devmaid/releases/download/v0.3.0/DevMaid-0.3.0.dmg",
  "releaseNotesURL": "https://github.com/Earthondev/devmaid/releases/tag/v0.3.0",
  "publishedAt": "2026-03-24T12:00:00Z"
}
```

## Community and support

The recommended support channels are:

- bugs and regressions: GitHub Issues
- usage questions: GitHub Discussions or [SUPPORT.md](/Users/earthondev/Desktop/RoomService/SUPPORT.md)
- security reports: [SECURITY.md](/Users/earthondev/Desktop/RoomService/SECURITY.md)
- contribution guide: [CONTRIBUTING.md](/Users/earthondev/Desktop/RoomService/CONTRIBUTING.md)
- community expectations: [CODE_OF_CONDUCT.md](/Users/earthondev/Desktop/RoomService/CODE_OF_CONDUCT.md)

## Support the maintainer

This repo now includes a funding plan in [FUNDING.md](/Users/earthondev/Desktop/RoomService/docs/FUNDING.md) so support channels stay consistent across the app, the CLI, and GitHub.

Recommended support options:

- GitHub Issues as the primary support entry point for bugs
- GitHub Discussions for usage questions and setup help
- GitHub Sponsors or another recurring-support service for maintenance
- company sponsorships for roadmap priorities, support, or custom cleanup rules

The live GitHub funding config is in [.github/FUNDING.yml](/Users/earthondev/Desktop/RoomService/.github/FUNDING.yml), and a reusable template remains in [.github/FUNDING.yml.example](/Users/earthondev/Desktop/RoomService/.github/FUNDING.yml.example).

## Why this exists

Generic Mac cleaners are optimized for broad consumer cleanup. Developer machines have different pain points:

- Xcode DerivedData, Archives, and simulator data
- `node_modules`, `.venv`, and large local dependency folders
- Homebrew, npm, Yarn, pnpm, Gradle, Playwright, and Cypress caches
- Docker Desktop storage that silently grows over time

DevMaid is meant to be transparent, automatable, and respectful of risk.

## Safety model

- Preview first: `scan` never deletes anything
- Quarantine first: `delete` moves items into `~/.roomservice/quarantine`
- Undo support: `undo` restores an earlier action
- Risk labels: each category is marked as `safe`, `review`, or `danger`
- Dangerous targets: `docker-data` requires `--allow-danger`

## Supported categories

- `xcode-derived-data`
- `xcode-archives`
- `core-simulator`
- `docker-data`
- `node-modules`
- `python-virtual-envs`
- `homebrew-cache`
- `npm-cache`
- `yarn-cache`
- `pnpm-store`
- `playwright-cache`
- `cypress-cache`
- `gradle-cache`
- `unity-cache`
- `code-editors`
- `project-artifacts`
- `pip-cache`
- `poetry-cache`
- `cargo-cache`
- `nuget-cache`
- `go-cache`
- `android-artifacts`

Run `devmaid categories` for descriptions and risk labels.

## Build

```bash
cd /Users/earthondev/Desktop/RoomService
swift build
```

The built binary will be available at:

```bash
.build/debug/devmaid
```

## Usage

Scan everything using the default search roots:

```bash
swift run devmaid scan
```

Scan only `node_modules` inside a specific workspace:

```bash
swift run devmaid scan --category node-modules --search-root ~/Projects
```

Scan a workspace but exclude a path completely:

```bash
swift run devmaid scan --category node-modules --search-root ~/Projects --exclude ~/Projects/client-a/build
```

Quarantine all Playwright and Cypress caches:

```bash
swift run devmaid delete --category playwright-cache --category cypress-cache --all --yes
```

Quarantine all DerivedData without a prompt:

```bash
swift run devmaid delete --category xcode-derived-data --yes
```

Restore a cleanup action:

```bash
swift run devmaid undo <action-id>
```

View cleanup history:

```bash
swift run devmaid history
```

Export the latest scan as JSON:

```bash
swift run devmaid export scan --format json --output devmaid-scan.json
```

## Full Disk Access

Some directories on macOS are protected. For broad scans to work reliably, Terminal or the eventual app wrapper may need Full Disk Access:

- System Settings
- Privacy & Security
- Full Disk Access

Grant access only to tools you trust.

The desktop app now includes a first-launch onboarding flow that links straight to Privacy & Security and explains scan roots, exclusions, quarantine-first cleanup, and undo before your first real scan.

## State location

DevMaid stores quarantine data and action history in `~/.roomservice` by default.

For testing, CI, or isolated runs, set:

```bash
export DEVMAID_HOME=/path/to/sandbox
```

## Verification

Build the binary first:

```bash
swift build
```

Then run the included smoke test for the CLI:

```bash
./scripts/smoke_test.sh
```

It creates a temporary workspace, scans a fake `node_modules`, quarantines it, then restores it.

For a local macOS desktop-app smoke test with Accessibility enabled:

```bash
./scripts/ui_smoke_test.sh
```

That script builds `DevMaid.app`, launches it in an isolated temp environment, verifies `Run Scan -> Cancel Scan -> Run Scan`, and confirms the app can navigate into the Settings page without hanging.

For screenshot captures you can review with design:

```bash
./scripts/capture_app_screens.sh ~/Desktop
```

That script creates demo cleanup data, injects a local update feed, opens the app, and saves overview/results/history/settings/about screenshots to your Desktop.

## Packaging

Release packaging scripts are included:

```bash
./scripts/build_release.sh
```

That produces:

- a Homebrew-friendly tarball
- `DevMaid.app`
- a downloadable dmg
- release checksums

Homebrew formulas can be generated with:

```bash
./scripts/generate_homebrew_formula.sh --help
```

The release workflow and knobs are documented in [DISTRIBUTION.md](/Users/earthondev/Desktop/RoomService/docs/DISTRIBUTION.md).
Signing and notarization setup is documented in [SIGNING_AND_NOTARIZATION.md](/Users/earthondev/Desktop/RoomService/docs/SIGNING_AND_NOTARIZATION.md).
Landing-page and launch copy live in [LANDING_PAGE_COPY.md](/Users/earthondev/Desktop/RoomService/docs/LANDING_PAGE_COPY.md), [LAUNCH_POSTS.md](/Users/earthondev/Desktop/RoomService/docs/LAUNCH_POSTS.md), and [MEDIA_KIT.md](/Users/earthondev/Desktop/RoomService/docs/MEDIA_KIT.md).
The public launch checklist is in [LAUNCH_CHECKLIST.md](/Users/earthondev/Desktop/RoomService/docs/LAUNCH_CHECKLIST.md).

This repo also ships GitHub Actions for:

- CI builds and smoke tests
- release asset generation
- optional DMG signing and notarization when release secrets are configured

## Packaging roadmap

This repo is intentionally split so the core engine can later power:

- a menu bar app
- scheduled cleanup workflows
- richer category rules and ignore lists
- Homebrew cask distribution for the desktop app

## Known limitations

- Recursive scans focus on common developer roots by default, not the entire home directory
- Docker cleanup is treated as dangerous and currently works at the storage-directory level
- Some categories are path-based and may vary across custom tool installations
- The app is currently ad-hoc signed by default unless you provide a signing identity during release packaging
- Homebrew tap publication is still a manual step after formula generation

## License

MIT
