# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Currently supported versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

The TxtPocket team takes security bugs seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report a Security Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **Preferred**: Open a [security advisory](https://github.com/yourusername/txtpocket/security/advisories/new) on GitHub
2. **Alternative**: Email security concerns to [your-email@example.com]

Please include the following information in your report:

- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

- **Acknowledgment**: You should receive an acknowledgment within 48 hours
- **Communication**: We'll keep you informed about the progress
- **Fix Timeline**: We aim to address critical issues within 7 days
- **Credit**: You'll be credited for the discovery (unless you prefer anonymity)

### Security Update Process

1. The security report is received and assigned to a primary handler
2. The problem is confirmed and affected versions are determined
3. Code is audited to find similar problems
4. Fixes are prepared for all supported versions
5. Security advisory is published with proper credits

## Security Best Practices for Users

### Data Storage

- TxtPocket stores all data locally in your Documents folder
- The Isar database is not encrypted by default
- **Do not store sensitive credentials** or private keys in snippets
- Consider encrypting sensitive snippets manually before saving

### Running the Application

- Only download TxtPocket from official sources
- Verify release signatures when available
- Keep your Flutter SDK and dependencies up to date
- Review permissions requested by the application

### Safe Usage

- **Clipboard Security**: Be aware that snippets are copied to your system clipboard
- **Clipboard History**: Some clipboard managers keep history
- **Screen Sharing**: Snippets may be visible during screen sharing
- **Backup Security**: Secure any backups containing snippet data

## Known Security Considerations

### Current Implementation

1. **Local Storage Only**: All data is stored locally without encryption
2. **No Authentication**: Single-user application without user authentication
3. **No Network Access**: Application does not transmit data over network (currently)
4. **Clipboard Access**: Application requires clipboard read/write permissions

### Planned Security Enhancements

See [TODO.md](TODO.md) for planned security features:
- Encryption for sensitive snippets
- Password protection option
- Secure backup/export options

## Third-Party Dependencies

TxtPocket relies on several third-party packages. We monitor these for security updates:

- `isar` - Database (actively maintained)
- `window_manager` - Window management (actively maintained)
- `clipboard` - Clipboard operations (actively maintained)
- `path_provider` - File system access (Flutter team)

We regularly update dependencies to incorporate security patches.

## Security Audit

This project has not undergone a formal security audit. We welcome security researchers to review the code and report findings responsibly.

## Disclosure Policy

- Security issues are disclosed after a fix is available
- We aim for coordinated disclosure with researchers
- Security advisories are published on GitHub
- Critical issues are announced via release notes

## Bug Bounty Program

We currently do not offer a bug bounty program.

## Contact

For security concerns, please use the reporting methods listed above.

For general questions, use GitHub Discussions or Issues.

---

**Last Updated**: 2025-11-02

Thank you for helping keep TxtPocket and its users safe!
