# Security Policy

DevMaid touches developer machines and file deletion workflows, so security and safe behavior matter.

## Report a vulnerability

Please do not open a public issue first for vulnerabilities that could expose user data, unsafe deletion behavior, privilege abuse, or path traversal problems.

Instead, send a private report to the maintainer contact you publish for the repository.

Current security contact:

- `security@your-domain.example`
- `https://github.com/your-org/devmaid/security`

## What to include

- affected version
- macOS version
- reproduction steps
- proof of impact
- whether the issue requires Full Disk Access or elevated permissions

## Scope examples

Examples of security-relevant issues:

- deletion outside intended paths
- quarantine restore overwriting unexpected files
- symlink traversal problems
- unsafe package or installer behavior
- malicious formula or release artifact substitution risks

## Response goals

Recommended public policy:

- acknowledge receipt within 3 business days
- provide a status update within 7 business days
- coordinate disclosure after a fix is available
