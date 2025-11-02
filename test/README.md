# TxtPocket Tests

This directory contains comprehensive tests for the TxtPocket application.

## Test Structure

```
test/
├── models/
│   └── snippet_test.dart          # Snippet model tests
├── services/
│   ├── database_service_test.dart # Database CRUD and search tests
│   └── clipboard_service_test.dart# Clipboard integration tests
├── widgets/
│   └── launcher_widget_test.dart  # UI and interaction tests
└── README.md                       # This file
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Files
```bash
# Model tests (no dependencies, fast)
flutter test test/models/snippet_test.dart

# Service tests
flutter test test/services/database_service_test.dart
flutter test test/services/clipboard_service_test.dart

# Widget tests
flutter test test/widgets/launcher_widget_test.dart
```

### Run Tests by Category
```bash
# All model tests
flutter test test/models/

# All service tests
flutter test test/services/

# All widget tests
flutter test test/widgets/
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

## Test Categories

### 1. Model Tests (`test/models/snippet_test.dart`)
**What they test:**
- Snippet creation with factory constructor
- Default values and field initialization
- Edge cases (empty strings, special characters, long content)
- Date/time handling

**Dependencies:** None
**Speed:** Very fast
**Coverage:** 18 tests

---

### 2. Database Service Tests (`test/services/database_service_test.dart`)
**What they test:**
- CRUD operations (Create, Read, Update, Delete)
- Usage tracking and incrementing
- Search functionality (by title, content, case-insensitive)
- Sorting by usage count
- Sample data loading on initialization

**Dependencies:** Isar database, path_provider
**Speed:** Medium
**Coverage:** 15 tests

**Known Issues:**
- May fail in CI/CD without proper Isar setup
- Requires `path_provider` mocking for headless environments

---

### 3. Clipboard Service Tests (`test/services/clipboard_service_test.dart`)
**What they test:**
- Copy text to clipboard
- Retrieve text from clipboard
- Special characters and emojis
- Multiline text
- Very long text
- Code snippets and SQL queries
- Unicode characters

**Dependencies:** System clipboard
**Speed:** Fast (integration tests)
**Coverage:** 15 tests

**Known Issues:**
- Requires display/windowing system
- May fail in headless CI/CD environments
- May fail if clipboard is locked by another app

---

### 4. Widget Tests (`test/widgets/launcher_widget_test.dart`)
**What they test:**
- UI rendering (search icon, input fields, buttons)
- Search mode functionality
- Add mode functionality
- Keyboard navigation (arrow keys, ESC, Ctrl+N, Ctrl+Enter)
- Snippet selection and display
- Mode switching
- Event handling

**Dependencies:** Isar database, path_provider, Flutter test framework
**Speed:** Slow (widget tests)
**Coverage:** 17 tests

**Known Issues:**
- Same path_provider issues as database tests
- Keyboard simulation may behave differently on different platforms

---

## Known Test Issues

### 1. Path Provider in Tests
The `path_provider` package doesn't work in Flutter tests without mocking.

**Solution:** Tests that require database access need to mock or use a temporary directory.

**Affected Tests:**
- `database_service_test.dart`
- `launcher_widget_test.dart`

### 2. Clipboard Tests
Clipboard tests are integration tests that interact with the system clipboard.

**Limitations:**
- May fail in CI/CD without display
- Clipboard must not be locked
- Results depend on system clipboard implementation

### 3. Isar Database
Isar requires platform-specific binaries for testing.

**Solution:** Ensure `isar_flutter_libs` is properly installed.

## Test Best Practices

### Writing New Tests

1. **Follow the AAA pattern:**
   - **Arrange**: Set up test data
   - **Act**: Perform the action
   - **Assert**: Verify the result

2. **Use descriptive test names:**
   ```dart
   test('should increment usage count when snippet is selected', () {
     // Test code
   });
   ```

3. **Group related tests:**
   ```dart
   group('DatabaseService - CRUD Operations', () {
     test('should add a single snippet', () { });
     test('should delete a snippet', () { });
   });
   ```

4. **Clean up after tests:**
   ```dart
   tearDown(() async {
     await isar.writeTxn(() async {
       await isar.snippets.clear();
     });
   });
   ```

### Test Coverage Goals

- **Models**: 100% coverage (simple, no dependencies)
- **Services**: 80%+ coverage
- **Widgets**: 70%+ coverage (harder to test all UI states)

## CI/CD Considerations

For continuous integration, you may need to:

1. **Mock platform channels:**
   ```dart
   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
       .setMockMethodCallHandler(channel, handler);
   ```

2. **Skip clipboard tests in headless environments:**
   ```dart
   test('clipboard test', () {
     // Skip in CI
   }, skip: Platform.environment.containsKey('CI'));
   ```

3. **Use in-memory database:**
   - Configure Isar to use temporary directory
   - Clear database between tests

## Debugging Tests

### Run tests in verbose mode:
```bash
flutter test --verbose
```

### Run a single test:
```bash
flutter test test/models/snippet_test.dart --name "should create snippet"
```

### Debug in VS Code:
1. Set breakpoint in test
2. Click "Debug" above the test function
3. Step through execution

## Test Metrics

Current test counts:
- **Model tests**: 18
- **Database service tests**: 15
- **Clipboard service tests**: 15
- **Widget tests**: 17
- **Total**: 65 tests

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all existing tests pass
3. Add tests to appropriate category
4. Update this README if adding new test files

---

**Last Updated:** 2025-11-02
