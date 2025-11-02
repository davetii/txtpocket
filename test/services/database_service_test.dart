import 'package:flutter_test/flutter_test.dart';
import 'package:txtpocket/models/snippet.dart';
import 'package:txtpocket/services/database_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  late DatabaseService dbService;
  late Isar isar;

  setUpAll(() async {
    // Initialize Isar for testing
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    dbService = DatabaseService();
    isar = await dbService.isar;

    // Clear database before each test
    await isar.writeTxn(() async {
      await isar.snippets.clear();
    });
  });

  tearDown(() async {
    // Clean up after each test
    await isar.writeTxn(() async {
      await isar.snippets.clear();
    });
  });

  group('DatabaseService - CRUD Operations', () {
    test('should add a single snippet', () async {
      // Arrange
      final snippet = Snippet.create(
        title: 'Test Snippet',
        content: 'Test content',
      );

      // Act
      await dbService.addSnippet(snippet);
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.length, 1);
      expect(result.first.title, 'Test Snippet');
      expect(result.first.content, 'Test content');
    });

    test('should add multiple snippets', () async {
      // Arrange
      final snippets = [
        Snippet.create(title: 'Snippet 1', content: 'Content 1'),
        Snippet.create(title: 'Snippet 2', content: 'Content 2'),
        Snippet.create(title: 'Snippet 3', content: 'Content 3'),
      ];

      // Act
      await dbService.addSnippets(snippets);
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.length, 3);
    });

    test('should retrieve all snippets', () async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'A', content: 'Content A'),
        Snippet.create(title: 'B', content: 'Content B'),
      ]);

      // Act
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.length, 2);
      expect(result.any((s) => s.title == 'A'), true);
      expect(result.any((s) => s.title == 'B'), true);
    });

    test('should update a snippet', () async {
      // Arrange
      final snippet = Snippet.create(
        title: 'Original Title',
        content: 'Original Content',
      );
      await dbService.addSnippet(snippet);

      final snippets = await dbService.getAllSnippets();
      final savedSnippet = snippets.first;

      // Act
      savedSnippet.title = 'Updated Title';
      savedSnippet.content = 'Updated Content';
      await dbService.updateSnippet(savedSnippet);

      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.first.title, 'Updated Title');
      expect(result.first.content, 'Updated Content');
      expect(result.first.updatedDate.isAfter(result.first.addedDate), true);
    });

    test('should delete a snippet', () async {
      // Arrange
      final snippet = Snippet.create(
        title: 'To Delete',
        content: 'Content',
      );
      await dbService.addSnippet(snippet);

      final snippets = await dbService.getAllSnippets();
      final snippetId = snippets.first.id;

      // Act
      await dbService.deleteSnippet(snippetId);
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.length, 0);
    });
  });

  group('DatabaseService - Usage Tracking', () {
    test('should increment usage count', () async {
      // Arrange
      final snippet = Snippet.create(
        title: 'Test',
        content: 'Content',
      );
      await dbService.addSnippet(snippet);

      final snippets = await dbService.getAllSnippets();
      final snippetId = snippets.first.id;

      // Act
      await dbService.incrementUsage(snippetId);
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.first.usageCount, 1);
      expect(result.first.lastUsedAt, isNotNull);
    });

    test('should sort snippets by usage count descending', () async {
      // Arrange
      final snippet1 = Snippet.create(title: 'Low Usage', content: 'Content');
      final snippet2 = Snippet.create(title: 'High Usage', content: 'Content');
      final snippet3 = Snippet.create(title: 'Medium Usage', content: 'Content');

      await dbService.addSnippets([snippet1, snippet2, snippet3]);

      // Increment usage counts
      final snippets = await dbService.getAllSnippets();
      await dbService.incrementUsage(snippets[0].id); // 1 time
      await dbService.incrementUsage(snippets[1].id); // 3 times
      await dbService.incrementUsage(snippets[1].id);
      await dbService.incrementUsage(snippets[1].id);
      await dbService.incrementUsage(snippets[2].id); // 2 times
      await dbService.incrementUsage(snippets[2].id);

      // Act
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result[0].usageCount, 3); // High Usage should be first
      expect(result[1].usageCount, 2); // Medium Usage should be second
      expect(result[2].usageCount, 1); // Low Usage should be last
    });
  });

  group('DatabaseService - Search Functionality', () {
    test('should return all snippets when query is empty', () async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Snippet 1', content: 'Content 1'),
        Snippet.create(title: 'Snippet 2', content: 'Content 2'),
      ]);

      // Act
      final stream = dbService.searchSnippets('');
      final result = await stream.first;

      // Assert
      expect(result.length, 2);
    });

    test('should search snippets by title', () async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Email Template', content: 'Content'),
        Snippet.create(title: 'Code Snippet', content: 'Content'),
        Snippet.create(title: 'Meeting Notes', content: 'Content'),
      ]);

      // Act
      final stream = dbService.searchSnippets('email');
      final result = await stream.first;

      // Assert
      expect(result.length, 1);
      expect(result.first.title, 'Email Template');
    });

    test('should search snippets by content', () async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Title 1', content: 'Contains JavaScript code'),
        Snippet.create(title: 'Title 2', content: 'Contains Python code'),
        Snippet.create(title: 'Title 3', content: 'Other content'),
      ]);

      // Act
      final stream = dbService.searchSnippets('javascript');
      final result = await stream.first;

      // Assert
      expect(result.length, 1);
      expect(result.first.content, contains('JavaScript'));
    });

    test('should be case-insensitive', () async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'UPPERCASE', content: 'Content'),
        Snippet.create(title: 'lowercase', content: 'Content'),
        Snippet.create(title: 'MixedCase', content: 'Content'),
      ]);

      // Act
      final stream1 = dbService.searchSnippets('uppercase');
      final stream2 = dbService.searchSnippets('LOWERCASE');
      final stream3 = dbService.searchSnippets('mixedcase');

      final result1 = await stream1.first;
      final result2 = await stream2.first;
      final result3 = await stream3.first;

      // Assert
      expect(result1.length, 1);
      expect(result2.length, 1);
      expect(result3.length, 1);
    });

    test('should return multiple matches', () async {
      // Arrange
      await dbService.addSnippets([
        Snippet.create(title: 'Git Commit', content: 'Template'),
        Snippet.create(title: 'Git Branch', content: 'Commands'),
        Snippet.create(title: 'Docker', content: 'Git commands'),
      ]);

      // Act
      final stream = dbService.searchSnippets('git');
      final result = await stream.first;

      // Assert
      expect(result.length, 3);
    });
  });

  group('DatabaseService - Initialization', () {
    test('should load sample data on first run', () async {
      // Arrange - ensure database is empty
      await isar.writeTxn(() async {
        await isar.snippets.clear();
      });

      // Act
      await dbService.initialize();
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.length, 7); // 7 sample snippets
      expect(result.any((s) => s.title.contains('Email')), true);
      expect(result.any((s) => s.title.contains('Meeting')), true);
    });

    test('should not load sample data if snippets exist', () async {
      // Arrange
      await dbService.addSnippet(
        Snippet.create(title: 'Existing', content: 'Content'),
      );

      // Act
      await dbService.initialize();
      final result = await dbService.getAllSnippets();

      // Assert
      expect(result.length, 1); // Only the one we added, not 7 sample snippets
    });
  });
}
