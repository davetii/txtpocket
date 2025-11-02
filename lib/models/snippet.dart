import 'package:isar/isar.dart';

part 'snippet.g.dart';

@collection
class Snippet {
  Id id = Isar.autoIncrement;

  @Index()
  late String title;

  @Index()
  late String content;

  late DateTime addedDate;
  late DateTime updatedDate;

  DateTime? lastUsedAt;

  @Index()
  int usageCount = 0;

  Snippet();

  // Factory constructor for creating new snippets
  factory Snippet.create({
    required String title,
    required String content,
    DateTime? lastUsedAt,
    int usageCount = 0,
  }) {
    final now = DateTime.now();
    return Snippet()
      ..title = title
      ..content = content
      ..addedDate = now
      ..updatedDate = now
      ..lastUsedAt = lastUsedAt
      ..usageCount = usageCount;
  }
}
