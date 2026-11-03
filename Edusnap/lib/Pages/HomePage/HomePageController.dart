// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

import '../../Models/JournalEntry.dart';

class HomePageController extends ChangeNotifier {
  HomePageController({
    this.onOpenDetail,
    this.onOpenAdd,
    this.onOpenSettings,
  }) {
    _sortByTitleDesc();
  }

  final ValueChanged<JournalEntry>? onOpenDetail;
  final VoidCallback? onOpenAdd;
  final VoidCallback? onOpenSettings;

  final String title = 'List';
  final String pageName = 'List';
  final String addLabel = 'Add';
  final String settingsLabel = 'Settings';

  final List<JournalEntry> entries = [
    JournalEntry(
      title: 'Morning lecture',
      note: 'Covered photosynthesis and the Calvin cycle.',
      createdAt: DateTime(2026, 11, 1, 9, 30),
    ),
    JournalEntry(
      title: 'Study group',
      note: 'Practiced quadratic equations with examples from class.',
      createdAt: DateTime(2026, 11, 2, 16, 0),
    ),
    JournalEntry(
      title: 'Lab recap',
      note: 'Recorded steps for the density experiment.',
      createdAt: DateTime(2026, 11, 3, 11, 15),
    ),
  ];

  void _sortByTitleDesc() {
    entries.sort(
      (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
    );
  }

  void addEntry(JournalEntry entry) {
    entries.add(entry);
    _sortByTitleDesc();
    notifyListeners();
  }

  void updateEntry(JournalEntry oldEntry, JournalEntry newEntry) {
    final index = entries.indexOf(oldEntry);
    if (index == -1) return;
    entries[index] = newEntry;
    _sortByTitleDesc();
    notifyListeners();
  }

  void remove(JournalEntry entry) {
    entries.remove(entry);
    notifyListeners();
  }

  void openDetail(JournalEntry entry) => onOpenDetail?.call(entry);
  void openAdd() => onOpenAdd?.call();
  void openSettings() => onOpenSettings?.call();
}