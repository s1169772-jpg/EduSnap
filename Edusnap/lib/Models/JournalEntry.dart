// ignore_for_file: file_names

class JournalEntry {
  JournalEntry({
    required this.title,
    required this.note,
    required this.createdAt,
    this.imagePath,
  });

  final String title;
  final String note;
  final DateTime createdAt;
  final String? imagePath;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      imagePath: json['imagePath'] as String?,
    );
  }
}