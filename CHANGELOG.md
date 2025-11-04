# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Global hotkey support (Cmd+Shift+Space for macOS, Ctrl+Shift+Space for Windows)
- Edit/delete snippet functionality
- Settings UI
- Export/import snippets
- Tags and categories
- System tray icon for Windows
- Linux platform support

---

## [1.1.0] - 2025-11-03

### Added
- **macOS platform support** - Full native macOS application
- Menu bar integration for macOS with "Show TxtPocket" and "Quit" options
- Background app capability (LSUIElement configuration in Info.plist)
- macOS-specific window management with proper frameless window support
- CocoaPods integration for macOS dependencies
- Cross-platform compatibility improvements

### Changed
- Updated project to support both Windows and macOS platforms
- Enhanced window_manager configuration for macOS compatibility
- Updated dependencies to support multi-platform builds

### Technical
- macos_ui 2.0.2 for native macOS components
- Updated AppDelegate.swift with menu bar support
- macOS 10.14+ minimum version support
- Xcode 13+ required for macOS builds

---

## [1.0.0] - 2025-11-02

### Added
- Frameless window implementation using `window_manager` package
- Direct launch into search interface (no button required)
- Basic snippet storage and retrieval with Isar database
- Fuzzy search through snippet titles and content
- Usage tracking system (counts and last used timestamps)
- Automatic sorting by usage count
- Keyboard-first navigation (arrow keys, Enter, ESC)
- Add new snippet mode (Ctrl+N)
- Quick copy to clipboard functionality
- Sample data pre-loaded on first run (7 example snippets)
- Search mode with real-time filtering
- Add mode with title and content fields
- Post-frame callback for proper focus management
- Subtle border styling for frameless window
- Application closes on ESC key or snippet selection

### Changed
- Removed overlay/backdrop pattern from original design
- Updated window to fixed 600x500 size
- Centered window on launch
- Made scaffold background transparent for frameless effect
- Deferred focus requests to prevent layout errors

### Fixed
- "RenderBox was not laid out" error by deferring focus with `addPostFrameCallback`
- Focus timing issues in search text field

### Technical
- Flutter SDK 3.0+
- Isar 3.1.0 for local NoSQL database
- window_manager 0.3.9 for frameless window support
- clipboard 0.1.3 for clipboard operations
- path_provider 2.1.1 for file system access

---

## [0.1.0] - Initial Development

### Added
- Basic project structure
- Flutter Windows app scaffold
- Isar database integration
- Sample snippet model with code generation
- Basic UI components

---

## Types of Changes

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes

---

[Unreleased]: https://github.com/yourusername/txtpocket/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/yourusername/txtpocket/releases/tag/v1.1.0
[1.0.0]: https://github.com/yourusername/txtpocket/releases/tag/v1.0.0
[0.1.0]: https://github.com/yourusername/txtpocket/releases/tag/v0.1.0
