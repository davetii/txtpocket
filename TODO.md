# TODO

This file tracks planned features, improvements, and bug fixes for TxtPocket.

## Legend
- [ ] Not started
- [x] Completed
- [~] In progress
- [!] Blocked/On hold

---

## High Priority

### Core Features
- [ ] Snippet categories/tags
  - [ ] Add tags field to Snippet model
  - [ ] Update database schema and regenerate
  - [ ] Add tag filtering in search mode
  - [ ] Tag management UI

### User Experience
- [ ] Window position memory (remember last position on close)
- [ ] Adjustable window size
- [ ] Custom keyboard shortcut configuration
- [ ] Search result highlighting (show matching text)

---

## Medium Priority

### Data Management
- [ ] Export snippets
  - [ ] JSON format
  - [ ] CSV format
  - [ ] Plain text format
- [ ] Import snippets
  - [ ] JSON import
  - [ ] CSV import
  - [ ] Detect and handle duplicates
- [ ] Backup/restore functionality
  - [ ] Auto-backup on interval
  - [ ] Manual backup option
  - [ ] Restore from backup file

### Settings & Customization
- [ ] Settings UI/page
  - [ ] Theme selection (dark/light/custom)
  - [ ] Font size adjustment
  - [ ] Window opacity control
  - [ ] Behavior preferences
- [ ] Custom color schemes
- [ ] Multiple snippet collections/workspaces
- [ ] Clear usage statistics option

---

## Low Priority

### Polish & Enhancement
- [ ] Snippet preview pane (show full content on selection)
- [ ] Markdown rendering for snippet content
- [ ] Syntax highlighting for code snippets
- [ ] Snippet templates
- [ ] Snippet variables/placeholders (e.g., ${date}, ${clipboard})
- [ ] Pin frequently used snippets to top
- [ ] Recently used snippets section
- [ ] Search history

### Advanced Features
- [ ] Cloud sync support
  - [ ] Google Drive integration
  - [ ] Dropbox integration
  - [ ] Custom backend sync
- [ ] Snippet sharing via URL/QR code
- [ ] Multi-language support (i18n)
- [ ] Voice input for search
- [ ] OCR integration (paste from screenshot)

### Platform Expansion
- [x] macOS support (completed in v1.1.0)
  - [x] Frameless window implementation
  - [x] Menu bar integration
  - [x] Background app support
- [ ] Linux support
- [ ] Mobile support (iOS/Android)
  - [ ] Mobile-optimized UI
  - [ ] Share extension integration

---

## Bug Fixes & Technical Debt

### Known Issues
- [ ] Improve search algorithm (better fuzzy matching)
- [ ] Optimize database queries for large snippet collections
- [ ] Add loading indicators for slow operations
- [ ] Handle edge cases in snippet content (very long content)

### Code Quality
- [ ] Increase test coverage
  - [ ] Unit tests for services
  - [ ] Widget tests for LauncherWidget
  - [ ] Integration tests
- [ ] Add comprehensive error handling
- [ ] Improve documentation
  - [ ] Add inline code comments
  - [ ] Create API documentation
- [ ] Refactor database service (separate concerns)
- [ ] Add logging system

---

## Ideas & Considerations

### Future Exploration
- System tray integration (minimize to tray)
- Browser extension for saving web snippets
- CLI interface for power users
- Plugin system for extensibility
- AI-powered snippet suggestions
- Snippet version history
- Collaborative snippet sharing
- Encryption for sensitive snippets

### Performance Optimization
- Lazy loading for large snippet lists
- Virtual scrolling for performance
- Database indexing optimization
- Startup time optimization

---

## Recently Completed

### Version 1.1.0
- [x] macOS platform support
- [x] Menu bar integration for macOS
- [x] Background app capability (LSUIElement support)
- [x] Cross-platform window management
- [x] CocoaPods integration for macOS dependencies

---

**Last Updated:** 2025-11-03

**Note:** Priorities may change based on user feedback and development progress.
