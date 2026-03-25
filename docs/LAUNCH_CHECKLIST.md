# Public Launch Checklist

Before publishing DevMaid for real users, finish these items:

## Repository

- replace GitHub placeholders with your live repo/support/security URLs
- confirm the maintainer contact in [SECURITY.md](/Users/earthondev/Desktop/Devmaid/SECURITY.md)
- update `.github/FUNDING.yml` if the support URL changes
- enable GitHub Discussions if you want a support forum

## Releases

- build release artifacts with `./scripts/build_release.sh <version>`
- upload the tarball, dmg, checksums, and formula to your release page, or use `.github/workflows/release.yml`
- publish your Homebrew formula or tap
- verify install on a clean Mac through both DMG and Homebrew

## Trust and safety

- add Developer ID signing
- configure `DEVMAID_NOTARY_KEYCHAIN_PROFILE` so DMG notarization runs in CI
- publish a short privacy statement if you later add telemetry

## Project operations

- decide response expectations for issues and security reports
- publish support and sponsorship links
- create a roadmap or milestones for upcoming work
