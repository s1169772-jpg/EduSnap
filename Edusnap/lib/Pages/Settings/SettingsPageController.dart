// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

class SettingsPageController extends ChangeNotifier {
  SettingsPageController({this.onBack});

  final VoidCallback? onBack;

  final String title = 'Settings';
  final String pageName = 'Settings';
  final String backLabel = 'Back';

  void goBack() => onBack?.call();
}
