// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

class LandingPageController extends ChangeNotifier {
  LandingPageController({this.onGetStarted});

  final VoidCallback? onGetStarted;

  final String appName = 'Edusnap';
  final String headline = 'Welcome to Edusnap';
  final String subtitle =
      'Capture lessons, stay organized, and learn in focused snaps.';
  final String ctaLabel = 'Get started';

  bool _isStarting = false;
  bool get isStarting => _isStarting;

  Future<void> getStarted() async {
    if (_isStarting) return;

    _isStarting = true;
    notifyListeners();

    try {
      onGetStarted?.call();
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }
}
