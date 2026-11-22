// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Edusnap';

  @override
  String get listTitle => 'List';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get detailTitle => 'Detail';

  @override
  String get addTitle => 'Add';

  @override
  String get editTitle => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get settings => 'Settings';

  @override
  String get titleLabel => 'Title';

  @override
  String get noteLabel => 'Note';

  @override
  String get pickPhoto => 'Add photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get missingTitleDialogTitle => 'Title is missing';

  @override
  String get missingTitleDialogMessage => 'Please enter a title before saving.';

  @override
  String get ok => 'OK';

  @override
  String get leaveDialogTitle => 'Discard changes?';

  @override
  String get leaveDialogMessage =>
      'You have unsaved data. Are you sure you want to leave?';

  @override
  String get leaveConfirm => 'Leave';

  @override
  String get leaveCancel => 'Stay';

  @override
  String get permissionDeniedTitle => 'Permission needed';

  @override
  String get permissionDeniedMessage =>
      'Photo access is required to add an image. Please enable it in Settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get landingAppName => 'Edusnap';

  @override
  String get landingHeadline => 'Welcome to Edusnap';

  @override
  String get landingSubtitle =>
      'Capture lessons, stay organized, and learn in focused snaps.';

  @override
  String get getStarted => 'Get started';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String createdOn(String date) {
    return 'Created on $date';
  }
}
