import 'package:flutter_test/flutter_test.dart';
import 'package:txtpocket/services/clipboard_service.dart';

void main() {
  // Note: These are integration tests that interact with the system clipboard
  // They may fail in CI/CD environments without a display

  group('ClipboardService', () {
    testWidgets('should copy text to clipboard', (WidgetTester tester) async {
      // Arrange
      const testText = 'Hello, World!';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy empty string to clipboard', (WidgetTester tester) async {
      // Arrange
      const testText = '';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy multiline text to clipboard', (WidgetTester tester) async {
      // Arrange
      const testText = '''Line 1
Line 2
Line 3''';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy text with special characters', (WidgetTester tester) async {
      // Arrange
      const testText = 'Special chars: @#\$%^&*()_+-={}[]|:";\'<>?,./';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy text with emojis', (WidgetTester tester) async {
      // Arrange
      const testText = 'Hello 👋 World 🌍';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy very long text to clipboard', (WidgetTester tester) async {
      // Arrange
      final testText = 'A' * 10000;

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy code snippet to clipboard', (WidgetTester tester) async {
      // Arrange
      const testText = '''function test() {
  console.log("Hello, World!");
  return true;
}''';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy SQL query to clipboard', (WidgetTester tester) async {
      // Arrange
      const testText = '''SELECT
    u.id,
    u.username,
    u.email
FROM users u
WHERE u.is_active = true
ORDER BY u.created_at DESC;''';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy text with tabs and spaces', (WidgetTester tester) async {
      // Arrange
      const testText = '\t\tIndented with tabs\n    Indented with spaces';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should overwrite previous clipboard content', (WidgetTester tester) async {
      // Arrange
      const firstText = 'First text';
      const secondText = 'Second text';

      // Act
      await ClipboardService.copyToClipboard(firstText);
      await ClipboardService.copyToClipboard(secondText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, secondText);
      expect(result, isNot(firstText));
    });

    testWidgets('should copy unicode characters', (WidgetTester tester) async {
      // Arrange
      const testText = '日本語 中文 한글 Русский العربية';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy URL to clipboard', (WidgetTester tester) async {
      // Arrange
      const testText = 'https://api.example.com/v2/users?id=123&active=true';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should copy email template to clipboard', (WidgetTester tester) async {
      // Arrange
      const testText = '''Best regards,
John Doe
Senior Developer
john.doe@example.com
+1 (555) 123-4567''';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });
  });

  group('ClipboardService - Edge Cases', () {
    testWidgets('should handle whitespace-only text', (WidgetTester tester) async {
      // Arrange
      const testText = '     ';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should handle newlines only', (WidgetTester tester) async {
      // Arrange
      const testText = '\n\n\n';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, testText);
    });

    testWidgets('should handle mixed line endings', (WidgetTester tester) async {
      // Arrange
      const testText = 'Line1\nLine2\r\nLine3\rLine4';

      // Act
      await ClipboardService.copyToClipboard(testText);
      final result = await ClipboardService.getFromClipboard();

      // Assert
      expect(result, isNotEmpty);
      expect(result, contains('Line1'));
      expect(result, contains('Line2'));
    });
  });
}
