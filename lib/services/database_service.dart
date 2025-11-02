import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/snippet.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    _isar = await _initIsar();
    return _isar!;
  }

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [SnippetSchema],
      directory: dir.path,
    );
  }

  // Initialize database and load sample data if first run
  Future<void> initialize() async {
    final db = await isar;
    final count = await db.snippets.count();

    if (count == 0) {
      await _loadSampleData();
    }
  }

  // Load sample data on first run
  Future<void> _loadSampleData() async {
    final sampleSnippets = [
      Snippet.create(
        title: '📧 Email Signature',
        content: '''Best regards,
John Doe
Senior Developer
john.doe@example.com
+1 (555) 123-4567''',
      ),
      Snippet.create(
        title: '💼 Meeting Template',
        content: '''Meeting Notes - [Date]

Attendees:
-

Agenda:
1.
2.
3.

Action Items:
- [ ]
- [ ]

Next Steps:
''',
      ),
      Snippet.create(
        title: '💻 Code Review Comment',
        content: '''Great work on this PR! A few suggestions:

1. Consider adding error handling for edge cases
2. The logic in this section could be simplified
3. Please add unit tests for the new functionality

Overall looks good, let\'s discuss these points.''',
      ),
      Snippet.create(
        title: '🔧 Git Commit Template',
        content: '''feat: Add new feature

- Implemented X functionality
- Updated Y component
- Added tests for Z

Closes #123''',
      ),
      Snippet.create(
        title: '🔗 API Documentation Link',
        content: 'https://api.example.com/docs/v2/reference',
      ),
      Snippet.create(
        title: '🐛 Bug Report Template',
        content: '''**Bug Description:**


**Steps to Reproduce:**
1.
2.
3.

**Expected Behavior:**


**Actual Behavior:**


**Environment:**
- OS:
- Browser:
- Version: ''',
      ),
      Snippet.create(
        title: '🗄️ SQL Query - Users',
        content: '''SELECT
    u.id,
    u.username,
    u.email,
    u.created_at,
    COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.is_active = true
GROUP BY u.id
ORDER BY u.created_at DESC
LIMIT 100;''',
      ),
    ];

    await addSnippets(sampleSnippets);
  }

  // Create - Add a single snippet
  Future<void> addSnippet(Snippet snippet) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.snippets.put(snippet);
    });
  }

  // Create - Add multiple snippets
  Future<void> addSnippets(List<Snippet> snippets) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.snippets.putAll(snippets);
    });
  }

  // Read - Get all snippets sorted by usage (most used first)
  Future<List<Snippet>> getAllSnippets() async {
    final db = await isar;
    return await db.snippets
        .where()
        .sortByUsageCountDesc()
        .thenByLastUsedAt()
        .findAll();
  }

  // Read - Search snippets with fuzzy matching
  Stream<List<Snippet>> searchSnippets(String query) async* {
    final db = await isar;

    if (query.isEmpty) {
      yield* db.snippets
          .where()
          .sortByUsageCountDesc()
          .thenByLastUsedAt()
          .watch(fireImmediately: true);
    } else {
      final lowerQuery = query.toLowerCase();
      yield* db.snippets.where().watch(fireImmediately: true).map(
        (snippets) => snippets.where((snippet) {
          return snippet.title.toLowerCase().contains(lowerQuery) ||
                 snippet.content.toLowerCase().contains(lowerQuery);
        }).toList()..sort((a, b) {
          // Sort by usage count (descending), then by last used date
          final usageCompare = b.usageCount.compareTo(a.usageCount);
          if (usageCompare != 0) return usageCompare;

          if (b.lastUsedAt != null && a.lastUsedAt != null) {
            return b.lastUsedAt!.compareTo(a.lastUsedAt!);
          } else if (b.lastUsedAt != null) {
            return 1;
          } else if (a.lastUsedAt != null) {
            return -1;
          }
          return 0;
        }),
      );
    }
  }

  // Update - Increment usage count and update lastUsedAt
  Future<void> incrementUsage(int snippetId) async {
    final db = await isar;
    await db.writeTxn(() async {
      final snippet = await db.snippets.get(snippetId);
      if (snippet != null) {
        snippet.usageCount++;
        snippet.lastUsedAt = DateTime.now();
        await db.snippets.put(snippet);
      }
    });
  }

  // Update - Update a snippet
  Future<void> updateSnippet(Snippet snippet) async {
    final db = await isar;
    await db.writeTxn(() async {
      snippet.updatedDate = DateTime.now();
      await db.snippets.put(snippet);
    });
  }

  // Delete - Delete a snippet
  Future<void> deleteSnippet(int snippetId) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.snippets.delete(snippetId);
    });
  }

  // Close database
  Future<void> close() async {
    await _isar?.close();
  }
}
