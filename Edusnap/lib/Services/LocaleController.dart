// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const String _storageKey = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isChinese => _locale.languageCode == 'zh';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_storageKey);
      if (code == 'zh' || code == 'zh_TW' || code == 'zh_HK') {
        _locale = const Locale('zh', 'TW');
      } else {
        _locale = const Locale('en');
      }
    } catch (_) {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  Future<void> setChinese(bool value) async {
    _locale = value ? const Locale('zh', 'TW') : const Locale('en');
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, value ? 'zh_TW' : 'en');
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    await setChinese(locale.languageCode == 'zh');
  }
}