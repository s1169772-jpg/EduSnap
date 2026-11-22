// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/LocaleController.dart';
import '../../l10n/app_localizations.dart';
import 'SettingsPageController.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.controller});

  final SettingsPageController? controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsPageController _controller;
  late final bool _ownsController;
  final LocaleController _localeController = LocaleController.instance;

  String _version = '—';
  String _buildNumber = '—';
  String _storageLabel = '0.0 KB';
  bool _loadingMeta = true;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? SettingsPageController(onBack: _goBack);
    _controller.addListener(_onChanged);
    _localeController.addListener(_onChanged);
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final storage = await _computeStorageUsage();
      if (!mounted) return;
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
        _storageLabel = storage;
        _loadingMeta = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _version = '—';
        _buildNumber = '—';
        _storageLabel = '0.0 KB';
        _loadingMeta = false;
      });
    }
  }

  Future<String> _computeStorageUsage() async {
    int totalBytes = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('journal_entries');
      if (raw != null) {
        totalBytes += utf8.encode(raw).length;
        try {
          final list = jsonDecode(raw) as List<dynamic>;
          for (final item in list) {
            if (item is! Map) continue;
            final path = item['imagePath'] as String?;
            if (path == null || path.isEmpty) continue;
            final file = File(path);
            if (await file.exists()) {
              totalBytes += await file.length();
            }
          }
        } catch (_) {}
      }
    } catch (_) {}

    if (totalBytes < 1024) {
      return '${totalBytes.toStringAsFixed(1)} B';
    }
    final kb = totalBytes / 1024.0;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024.0;
    return '${mb.toStringAsFixed(1)} MB';
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _goBack() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _openLanguagePicker() async {
    final l10n = AppLocalizations.of(context);
    var pending = _localeController.isChinese;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.language),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: Text(l10n.languageEnglish),
                    value: false,
                    groupValue: pending,
                    onChanged: (v) {
                      if (v != null) setDialogState(() => pending = v);
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text(l10n.languageChinese),
                    value: true,
                    groupValue: pending,
                    onChanged: (v) {
                      if (v != null) setDialogState(() => pending = v);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.ok),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && pending != _localeController.isChinese) {
      await _localeController.setChinese(pending);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _localeController.removeListener(_onChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _row({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final valueStyle = textTheme.bodyLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(value, style: valueStyle),
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isChinese = _localeController.isChinese;
    final languageLabel =
        isChinese ? l10n.languageChinese : l10n.languageEnglish;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.settingsTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _loadingMeta
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          _row(
                            label: l10n.language,
                            value: languageLabel,
                            showChevron: true,
                            onTap: _openLanguagePicker,
                          ),
                          _row(
                            label: 'Storage usage',
                            value: _storageLabel,
                          ),
                          _row(
                            label: 'Version',
                            value: _version,
                          ),
                          _row(
                            label: 'Build number',
                            value: _buildNumber,
                          ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: TextButton(
                  onPressed: _goBack,
                  child: Text(l10n.back),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}