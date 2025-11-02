import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:txtpocket/widgets/launcher_widget.dart';
import 'package:txtpocket/services/database_service.dart';
import 'package:txtpocket/models/snippet.dart';

void main() {
  late DatabaseService dbService;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dbService = DatabaseService();

    // Clear database before each test
    final isar = await dbService.isar;
    await isar.writeTxn(() async {
      await isar.snippets.clear();
    });
  });

  tearDown(() async {
    // Clean up after each test
    final isar = await dbService.isar;
    await isar.writeTxn(() async {
      await isar.snippets.clear();
    });
  });

  Widget createTestWidget(VoidCallback onClose) {
    return MaterialApp(
      home: Scaffold(
        body: LauncherWidget(onClose: onClose),
      ),
    );
  }

  group('LauncherWidget - UI Elements', () {
    testWidgets('should display search icon in search mode', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('🔍'), findsOneWidget);
    });

    testWidgets('should display search input field', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Search snippets...'), findsOneWidget);
    });

    testWidgets('should display footer with keyboard hints', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ctrl+E or Double-click to edit  |  Ctrl+N to add  |  ESC to close'), findsOneWidget);
    });

    testWidgets('should start in search mode by default', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('🔍'), findsOneWidget);
      expect(find.text('➕'), findsNothing);
    });
  });

  group('LauncherWidget - Search Mode', () {
    testWidgets('should display snippets in search mode', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Test Snippet 1', content: 'Content 1'),
        Snippet.create(title: 'Test Snippet 2', content: 'Content 2'),
      ]);

      // Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Snippet 1'), findsOneWidget);
      expect(find.text('Test Snippet 2'), findsOneWidget);
    });

    testWidgets('should filter snippets based on search input', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Email Template', content: 'Content'),
        Snippet.create(title: 'Code Snippet', content: 'Content'),
      ]);

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField), 'email');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email Template'), findsOneWidget);
      expect(find.text('Code Snippet'), findsNothing);
    });

    testWidgets('should show "No snippets found" when search has no results', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Test', content: 'Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No snippets found'), findsOneWidget);
    });

    testWidgets('should show message when no snippets exist', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No snippets yet'), findsOneWidget);
      expect(find.text('Press Ctrl+N to add your first snippet'), findsOneWidget);
    });

    testWidgets('should display usage count badge for used snippets', (WidgetTester tester) async {
      // Arrange
      final snippet = Snippet.create(title: 'Used Snippet', content: 'Content');
      await dbService.addSnippet(snippet);

      final snippets = await dbService.getAllSnippets();
      await dbService.incrementUsage(snippets.first.id);

      // Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('LauncherWidget - Add Mode', () {
    testWidgets('should switch to add mode when Ctrl+N is pressed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('➕'), findsOneWidget);
      expect(find.text('Add New Snippet'), findsOneWidget);
    });

    testWidgets('should display title and content input fields in add mode', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Switch to add mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Title:'), findsOneWidget);
      expect(find.text('Content:'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Enter snippet title...'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Enter snippet content...'), findsOneWidget);
    });

    testWidgets('should display Save and Cancel buttons in add mode', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Switch to add mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('should show correct footer text in add mode', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Switch to add mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ctrl+S or Ctrl+Enter to save  |  ESC to cancel'), findsOneWidget);
    });
  });

  group('LauncherWidget - Keyboard Navigation', () {
    testWidgets('should navigate down with arrow key', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Snippet 1', content: 'Content 1'),
        Snippet.create(title: 'Snippet 2', content: 'Content 2'),
        Snippet.create(title: 'Snippet 3', content: 'Content 3'),
      ]);

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Press arrow down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Assert - Second item should be highlighted
      final selectedContainer = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == const Color(0xFF2D2D30);
        }
        return false;
      });
      expect(selectedContainer, findsWidgets);
    });

    testWidgets('should navigate up with arrow key', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Snippet 1', content: 'Content 1'),
        Snippet.create(title: 'Snippet 2', content: 'Content 2'),
      ]);

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Go down then up
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      // Assert - Should be back to first item
      expect(find.text('Snippet 1'), findsOneWidget);
    });

    testWidgets('should switch back to search mode when ESC is pressed in add mode', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to add mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Act - Press ESC
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Assert - Should be back in search mode
      expect(find.text('🔍'), findsOneWidget);
      expect(find.text('➕'), findsNothing);
    });

    testWidgets('should call onClose when ESC is pressed in search mode', (WidgetTester tester) async {
      // Arrange
      bool closeCalled = false;
      await tester.pumpWidget(createTestWidget(() {
        closeCalled = true;
      }));
      await tester.pumpAndSettle();

      // Act
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Assert
      expect(closeCalled, true);
    });
  });

  group('LauncherWidget - Add Snippet Functionality', () {
    testWidgets('should save snippet when Save button is clicked', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to add mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Enter data
      final titleField = find.widgetWithText(TextField, 'Enter snippet title...');
      final contentField = find.widgetWithText(TextField, 'Enter snippet content...');

      await tester.enterText(titleField, 'New Snippet');
      await tester.enterText(contentField, 'New Content');
      await tester.pumpAndSettle();

      // Act - Click Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Assert - Should switch back to search mode
      expect(find.text('🔍'), findsOneWidget);

      // Verify snippet was saved
      final snippets = await dbService.getAllSnippets();
      expect(snippets.length, 1);
      expect(snippets.first.title, 'New Snippet');
      expect(snippets.first.content, 'New Content');
    });

    testWidgets('should cancel add mode when Cancel button is clicked', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to add mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Act - Click Cancel
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Assert - Should switch back to search mode
      expect(find.text('🔍'), findsOneWidget);
      expect(find.text('➕'), findsNothing);
    });

    testWidgets('should not save snippet with empty title and content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to add mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Act - Click Save without entering data
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Assert - Should stay in add mode
      expect(find.text('➕'), findsOneWidget);

      // Verify no snippet was saved
      final snippets = await dbService.getAllSnippets();
      expect(snippets.length, 0);
    });
  });

  group('LauncherWidget - Selection and Display', () {
    testWidgets('should display snippet content preview', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(
          title: 'Test',
          content: 'This is the first line\nThis is the second line',
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Assert - Should show first line only
      expect(find.text('This is the first line'), findsOneWidget);
      expect(find.text('This is the second line'), findsNothing);
    });

    testWidgets('should handle tap on snippet item', (WidgetTester tester) async {
      // Arrange
      bool closeCalled = false;
      await dbService.addSnippet(
        Snippet.create(title: 'Test Snippet', content: 'Content'),
      );

      await tester.pumpWidget(createTestWidget(() {
        closeCalled = true;
      }));
      await tester.pumpAndSettle();

      // Act - Tap on snippet
      await tester.tap(find.text('Test Snippet'));
      await tester.pumpAndSettle();

      // Assert - onClose should be called
      expect(closeCalled, true);
    });
  });

  group('LauncherWidget - Edit Mode', () {
    testWidgets('should switch to edit mode when Ctrl+E is pressed', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Test Snippet', content: 'Test Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Press Ctrl+E
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('✏️'), findsOneWidget);
      expect(find.text('Edit Snippet'), findsOneWidget);
      expect(find.text('Test Snippet'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should switch to edit mode on double tap', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Test Snippet', content: 'Test Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Double tap on snippet
      await tester.tap(find.text('Test Snippet'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Test Snippet'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('✏️'), findsOneWidget);
      expect(find.text('Edit Snippet'), findsOneWidget);
    });

    testWidgets('should display correct footer text in edit mode', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Test Snippet', content: 'Test Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Switch to edit mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ctrl+S or Ctrl+Enter to save  |  ESC to cancel'), findsOneWidget);
    });

    testWidgets('should populate form fields with snippet data in edit mode', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Original Title', content: 'Original Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Act - Switch to edit mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert - Check that fields are populated
      final titleFields = find.widgetWithText(TextField, 'Original Title');
      final contentFields = find.widgetWithText(TextField, 'Original Content');

      expect(titleFields, findsOneWidget);
      expect(contentFields, findsOneWidget);
    });

    testWidgets('should update snippet when Save button is clicked in edit mode', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Original Title', content: 'Original Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to edit mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Act - Modify the content
      final titleField = find.widgetWithText(TextField, 'Original Title');
      await tester.enterText(titleField, 'Updated Title');
      await tester.pumpAndSettle();

      // Click Save
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      // Assert - Should switch back to search mode
      expect(find.text('🔍'), findsOneWidget);

      // Verify snippet was updated
      final snippets = await dbService.getAllSnippets();
      expect(snippets.length, 1);
      expect(snippets.first.title, 'Updated Title');
    });

    testWidgets('should save snippet with Ctrl+S in edit mode', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Original Title', content: 'Original Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to edit mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Act - Modify and save with Ctrl+S
      final titleField = find.widgetWithText(TextField, 'Original Title');
      await tester.enterText(titleField, 'Ctrl+S Updated');
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert - Should switch back to search mode
      expect(find.text('🔍'), findsOneWidget);

      // Verify snippet was updated
      final snippets = await dbService.getAllSnippets();
      expect(snippets.length, 1);
      expect(snippets.first.title, 'Ctrl+S Updated');
    });

    testWidgets('should save snippet with Ctrl+Enter in edit mode', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Original Title', content: 'Original Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to edit mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Act - Modify and save with Ctrl+Enter
      final titleField = find.widgetWithText(TextField, 'Original Title');
      await tester.enterText(titleField, 'Ctrl+Enter Updated');
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Assert - Should switch back to search mode
      expect(find.text('🔍'), findsOneWidget);

      // Verify snippet was updated
      final snippets = await dbService.getAllSnippets();
      expect(snippets.length, 1);
      expect(snippets.first.title, 'Ctrl+Enter Updated');
    });

    testWidgets('should cancel edit mode when ESC is pressed', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Original Title', content: 'Original Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to edit mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Act - Press ESC
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Assert - Should be back in search mode
      expect(find.text('🔍'), findsOneWidget);
      expect(find.text('✏️'), findsNothing);
    });

    testWidgets('should not update snippet when cancelled', (WidgetTester tester) async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Original Title', content: 'Original Content'),
      );

      await tester.pumpWidget(createTestWidget(() {}));
      await tester.pumpAndSettle();

      // Switch to edit mode
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Modify the content
      final titleField = find.widgetWithText(TextField, 'Original Title');
      await tester.enterText(titleField, 'Changed Title');
      await tester.pumpAndSettle();

      // Act - Cancel
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Assert - Should not have updated the snippet
      final snippets = await dbService.getAllSnippets();
      expect(snippets.length, 1);
      expect(snippets.first.title, 'Original Title');
    });
  });
}
