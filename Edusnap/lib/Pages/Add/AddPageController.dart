// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

import '../../Models/JournalEntry.dart';

class AddPageController extends ChangeNotifier {
  AddPageController({
    this.existingEntry,
    this.onBack,
    this.onSave,
    this.onTitleMissing,
  });

  final JournalEntry? existingEntry;
  final VoidCallback? onBack;
  final ValueChanged<JournalEntry>? onSave;
  final VoidCallback? onTitleMissing;

  bool get isEditMode => existingEntry != null;

  String get title => isEditMode ? 'Edit' : 'Add';
  final String titleLabel = 'Title';
  final String noteLabel = 'Note';
  String get saveLabel => isEditMode ? 'Update' : 'Save';
  final String backLabel = 'Back';
  final String missingTitleDialogTitle = 'Title is missing';
  final String missingTitleDialogMessage =
      'Please enter a title before saving.';
  final String okLabel = 'OK';
  final String leaveDialogTitle = 'Discard changes?';
  final String leaveDialogMessage =
      'You have unsaved data. Are you sure you want to leave?';
  final String leaveConfirmLabel = 'Leave';
  final String leaveCancelLabel = 'Stay';

  bool hasTitle(String title) => title.trim().isNotEmpty;

  bool hasUnsavedData({required String title, required String note}) {
    final trimmedTitle = title.trim();
    final trimmedNote = note.trim();
    if (isEditMode) {
      return trimmedTitle != existingEntry!.title ||
          trimmedNote != existingEntry!.note;
    }
    return trimmedTitle.isNotEmpty || trimmedNote.isNotEmpty;
  }

  JournalEntry createEntry({required String title, required String note}) {
    return JournalEntry(
      title: title.trim(),
      note: note.trim(),
      createdAt: existingEntry?.createdAt ?? DateTime.now(),
    );
  }

  void goBack() => onBack?.call();

  void save({required String title, required String note}) {
    if (!hasTitle(title)) {
      onTitleMissing?.call();
      return;
    }
    onSave?.call(createEntry(title: title, note: note));
  }
}