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
- [ ] Global hotkey support (e.g., Ctrl+Shift+Space to launch from anywhere)
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
- [ ] macOS support
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

## Completed ✓

- [x] Basic snippet storage and retrieval
- [x] Fuzzy search functionality
- [x] Usage tracking
- [x] Keyboard navigation
- [x] Add new snippet mode
- [x] Edit snippet mode
- [x] Clipboard integration
- [x] Frameless window implementation
- [x] Sample data loading on first run
- [x] Basic keyboard shortcuts
- [x] Delete snippet functionality
  - [x] Delete key in search mode with confirmation dialog
  - [x] Delete button in edit mode
  - [x] Undo functionality with snackbar
  - [x] Ctrl+D hotkey in edit mode

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

**Last Updated:** 2025-11-02

**Note:** Priorities may change based on user feedback and development progress.
