// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

import '../../Models/JournalEntry.dart';

class DetailPageController extends ChangeNotifier {
  DetailPageController({
    required JournalEntry entry,
    this.onBack,
    this.onEdit,
  }) : _entry = entry;

  JournalEntry _entry;
  final VoidCallback? onBack;
  final VoidCallback? onEdit;

  final String title = 'Detail';
  final String backLabel = 'Back';
  final String editLabel = 'Edit';

  JournalEntry get entry => _entry;

  String get entryTitle => _entry.title;
  String get entryNote => _entry.note;

  String get entryDate {
    final date = _entry.createdAt;
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void updateEntry(JournalEntry entry) {
    _entry = entry;
    notifyListeners();
  }

  void goBack() => onBack?.call();
  void edit() => onEdit?.call();
}