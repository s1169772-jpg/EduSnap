// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/JournalEntry.dart';

class HomePageController extends ChangeNotifier {
  HomePageController({
    this.onOpenDetail,
    this.onOpenAdd,
    this.onOpenSettings,
  });

  final ValueChanged<JournalEntry>? onOpenDetail;
  final VoidCallback? onOpenAdd;
  final VoidCallback? onOpenSettings;

  static const String _storageKey = 'journal_entries';

  final String title = 'List';
  final String pageName = 'List';
  final String addLabel = 'Add';
  final String settingsLabel = 'Settings';

  final List<JournalEntry> entries = [];
  bool isLoading = true;

  final List<JournalEntry> _defaultEntries = [
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

  Future<void> loadEntries() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      entries.clear();
      if (raw == null || raw.isEmpty) {
        entries.addAll(_defaultEntries);
        _sortByTitleDesc();
        await _saveEntries();
      } else {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          if (item is Map) {
            entries.add(
              JournalEntry.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
        _sortByTitleDesc();
      }
    } catch (_) {
      if (entries.isEmpty) {
        entries.addAll(_defaultEntries);
        _sortByTitleDesc();
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (_) {}
  }

  Future<void> addEntry(JournalEntry entry) async {
    entries.add(entry);
    _sortByTitleDesc();
    notifyListeners();
    await _saveEntries();
  }

  Future<void> updateEntry(JournalEntry oldEntry, JournalEntry newEntry) async {
    final index = entries.indexOf(oldEntry);
    if (index == -1) return;
    entries[index] = newEntry;
    _sortByTitleDesc();
    notifyListeners();
    await _saveEntries();
  }

  Future<void> remove(JournalEntry entry) async {
    entries.remove(entry);
    notifyListeners();
    await _saveEntries();
  }

  void openDetail(JournalEntry entry) => onOpenDetail?.call(entry);
  void openAdd() => onOpenAdd?.call();
  void openSettings() => onOpenSettings?.call();
}