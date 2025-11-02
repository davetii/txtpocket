import 'package:flutter_test/flutter_test.dart';
import 'package:txtpocket/models/snippet.dart';
import 'package:isar/isar.dart';

void main() {
  group('Snippet Model', () {
    test('should create snippet with factory constructor', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: 'Test Title',
        content: 'Test Content',
      );

      // Assert
      expect(snippet.title, 'Test Title');
      expect(snippet.content, 'Test Content');
      expect(snippet.usageCount, 0);
      expect(snippet.lastUsedAt, isNull);
      expect(snippet.addedDate, isNotNull);
      expect(snippet.updatedDate, isNotNull);
    });

    test('should create snippet with custom usage count', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: 'Title',
        content: 'Content',
        usageCount: 5,
      );

      // Assert
      expect(snippet.usageCount, 5);
    });

    test('should create snippet with lastUsedAt', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final snippet = Snippet.create(
        title: 'Title',
        content: 'Content',
        lastUsedAt: now,
      );

      // Assert
      expect(snippet.lastUsedAt, now);
    });

    test('should set addedDate and updatedDate to current time', () {
      // Arrange
      final before = DateTime.now();

      // Act
      final snippet = Snippet.create(
        title: 'Title',
        content: 'Content',
      );

      final after = DateTime.now();

      // Assert
      expect(snippet.addedDate.isAfter(before.subtract(Duration(seconds: 1))), true);
      expect(snippet.addedDate.isBefore(after.add(Duration(seconds: 1))), true);
      expect(snippet.updatedDate.isAfter(before.subtract(Duration(seconds: 1))), true);
      expect(snippet.updatedDate.isBefore(after.add(Duration(seconds: 1))), true);
    });

    test('should set addedDate and updatedDate to same value initially', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: 'Title',
        content: 'Content',
      );

      // Assert
      expect(snippet.addedDate.millisecondsSinceEpoch,
          snippet.updatedDate.millisecondsSinceEpoch);
    });

    test('should use Isar.autoIncrement for id', () {
      // Arrange & Act
      final snippet = Snippet();

      // Assert
      expect(snippet.id, Isar.autoIncrement);
    });

    test('should handle empty title and content', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: '',
        content: '',
      );

      // Assert
      expect(snippet.title, '');
      expect(snippet.content, '');
    });

    test('should handle very long title', () {
      // Arrange
      final longTitle = 'A' * 1000;

      // Act
      final snippet = Snippet.create(
        title: longTitle,
        content: 'Content',
      );

      // Assert
      expect(snippet.title.length, 1000);
    });

    test('should handle very long content', () {
      // Arrange
      final longContent = 'B' * 10000;

      // Act
      final snippet = Snippet.create(
        title: 'Title',
        content: longContent,
      );

      // Assert
      expect(snippet.content.length, 10000);
    });

    test('should handle multiline content', () {
      // Arrange
      final multilineContent = '''Line 1
Line 2
Line 3
Line 4''';

      // Act
      final snippet = Snippet.create(
        title: 'Title',
        content: multilineContent,
      );

      // Assert
      expect(snippet.content.split('\n').length, 4);
    });

    test('should handle special characters in title', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: '🔧 Git Commit Template @#\$%',
        content: 'Content',
      );

      // Assert
      expect(snippet.title, contains('🔧'));
      expect(snippet.title, contains('@'));
      expect(snippet.title, contains('#'));
    });

    test('should handle special characters in content', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: 'Title',
        content: 'SELECT * FROM users WHERE id = \$1 AND name = \'test\'',
      );

      // Assert
      expect(snippet.content, contains('\$'));
      expect(snippet.content, contains('\''));
    });

    test('should default usageCount to 0', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: 'Title',
        content: 'Content',
      );

      // Assert
      expect(snippet.usageCount, 0);
    });

    test('should default lastUsedAt to null', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: 'Title',
        content: 'Content',
      );

      // Assert
      expect(snippet.lastUsedAt, isNull);
    });
  });

  group('Snippet Model - Edge Cases', () {
    test('should handle null-like strings', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: 'null',
        content: 'undefined',
      );

      // Assert
      expect(snippet.title, 'null');
      expect(snippet.content, 'undefined');
    });

    test('should handle whitespace-only title', () {
      // Arrange & Act
      final snippet = Snippet.create(
        title: '   ',
        content: 'Content',
      );

      // Assert
      expect(snippet.title, '   ');
    });

    test('should handle code snippets with formatting', () {
      // Arrange
      final code = '''function test() {
  console.log("Hello, World!");
  return true;
}''';

      // Act
      final snippet = Snippet.create(
        title: 'JavaScript Function',
        content: code,
      );

      // Assert
      expect(snippet.content, contains('function test()'));
      expect(snippet.content, contains('  console.log'));
    });
  });
}
