// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

class HomePageController extends ChangeNotifier {
  HomePageController({this.onOpenSnap});

  final VoidCallback? onOpenSnap;

  final String title = 'Edusnap';
  final String greeting = 'Home';
  final String subtitle = 'Your lessons and snaps will show up here.';
  final String ctaLabel = 'New snap';

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  Future<void> createSnap() async {
    if (_isCreating) return;

    _isCreating = true;
    notifyListeners();

    try {
      onOpenSnap?.call();
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }
}
