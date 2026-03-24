# Contributing

Thanks for helping improve DevMaid.

## Development workflow

```bash
cd /Users/earthondev/Desktop/RoomService
swift build
./scripts/smoke_test.sh
```

## What contributions are most useful

- new cleanup categories for developer tools
- safer detection rules and risk labeling
- packaging and release automation
- SwiftUI GUI work built on top of `RoomServiceKit`
- docs improvements, especially install and recovery guidance

## Contribution expectations

- keep behavior safe-first
- avoid destructive cleanup flows without preview or clear guardrails
- document any new category with risk notes
- update README or docs when CLI behavior changes
- preserve portability for macOS users who only have Command Line Tools installed

## Pull requests

- keep changes scoped and explain the user-facing impact
- include the commands you used to verify the change
- mention any tradeoffs or follow-up work
- avoid unrelated formatting churn

## Need an idea to start?

Good early contributions:

- add more developer cache categories
- improve scan performance for very large workspaces
- add exclude rules
- add exportable scan reports
- add signed and notarized release automation
