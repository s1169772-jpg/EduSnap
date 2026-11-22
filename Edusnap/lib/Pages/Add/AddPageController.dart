// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Models/JournalEntry.dart';

class AddPageController extends ChangeNotifier {
  AddPageController({
    this.existingEntry,
    this.onBack,
    this.onSave,
    this.onTitleMissing,
    this.onPermissionDenied,
  }) : _imagePath = existingEntry?.imagePath;

  final JournalEntry? existingEntry;
  final VoidCallback? onBack;
  final ValueChanged<JournalEntry>? onSave;
  final VoidCallback? onTitleMissing;
  final VoidCallback? onPermissionDenied;

  bool get isEditMode => existingEntry != null;

  String get title => isEditMode ? 'Edit' : 'Add';
  final String titleLabel = 'Title';
  final String noteLabel = 'Note';
  String get saveLabel => isEditMode ? 'Update' : 'Save';
  final String backLabel = 'Back';
  final String pickPhotoLabel = 'Add photo';
  final String changePhotoLabel = 'Change photo';
  final String removePhotoLabel = 'Remove photo';
  final String cameraLabel = 'Camera';
  final String galleryLabel = 'Gallery';
  final String missingTitleDialogTitle = 'Title is missing';
  final String missingTitleDialogMessage =
      'Please enter a title before saving.';
  final String okLabel = 'OK';
  final String leaveDialogTitle = 'Discard changes?';
  final String leaveDialogMessage =
      'You have unsaved data. Are you sure you want to leave?';
  final String leaveConfirmLabel = 'Leave';
  final String leaveCancelLabel = 'Stay';
  final String permissionDeniedTitle = 'Permission needed';
  final String permissionDeniedMessage =
      'Photo access is required to add an image. Please enable it in Settings.';
  final String openSettingsLabel = 'Open Settings';
  final String cancelLabel = 'Cancel';

  String? _imagePath;
  String? get imagePath => _imagePath;

  final ImagePicker _picker = ImagePicker();

  bool hasTitle(String title) => title.trim().isNotEmpty;

  bool hasUnsavedData({required String title, required String note}) {
    final trimmedTitle = title.trim();
    final trimmedNote = note.trim();
    if (isEditMode) {
      return trimmedTitle != existingEntry!.title ||
          trimmedNote != existingEntry!.note ||
          _imagePath != existingEntry!.imagePath;
    }
    return trimmedTitle.isNotEmpty ||
        trimmedNote.isNotEmpty ||
        _imagePath != null;
  }

  JournalEntry createEntry({required String title, required String note}) {
    return JournalEntry(
      title: title.trim(),
      note: note.trim(),
      createdAt: existingEntry?.createdAt ?? DateTime.now(),
      imagePath: _imagePath,
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

  void clearImage() {
    _imagePath = null;
    notifyListeners();
  }

  Future<bool> _requestPermission(ImageSource source) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    var status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (source == ImageSource.gallery) {
      final storage = await Permission.storage.status;
      if (storage.isGranted) return true;
      final storageResult = await Permission.storage.request();
      if (storageResult.isGranted) return true;
    }

    onPermissionDenied?.call();
    return false;
  }

  Future<void> pickImage(ImageSource source) async {
    final granted = await _requestPermission(source);
    if (!granted) return;

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null) return;

    _imagePath = file.path;
    notifyListeners();
  }

  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }
}