// ignore_for_file: file_names

class JournalEntry {
  JournalEntry({
    required this.title,
    required this.note,
    required this.createdAt,
  });

  final String title;
  final String note;
  final DateTime createdAt;
}
