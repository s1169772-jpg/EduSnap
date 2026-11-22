// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';

import '../../Models/JournalEntry.dart';
import '../Add/AddPage.dart';
import 'DetailPageController.dart';
import '../../l10n/app_localizations.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.entry,
    this.controller,
  });

  final JournalEntry entry;
  final DetailPageController? controller;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final DetailPageController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        DetailPageController(
          entry: widget.entry,
          onBack: _goBack,
          onEdit: _openEdit,
        );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _goBack() {
    if (!mounted) return;
    Navigator.of(context).pop(_controller.entry);
  }

  Future<void> _openEdit() async {
    if (!mounted) return;
    final updated = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => AddPage(entry: _controller.entry),
      ),
    );
    if (!mounted || updated == null) return;
    _controller.updateEntry(updated);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _buildPhoto(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = _controller.entryImagePath;
    final hasImage = path != null && path.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: hasImage
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) => _photoPlaceholder(colorScheme),
              )
            : _photoPlaceholder(colorScheme),
      ),
    );
  }

  Widget _photoPlaceholder(ColorScheme colorScheme) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).detailTitle),
          actions: [
            TextButton(
              onPressed: _controller.edit,
              child: Text(AppLocalizations.of(context).edit),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _controller.entryTitle,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).createdOn(_controller.entryDate),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPhoto(context),
                const SizedBox(height: 16),
                Text(
                  _controller.entryNote,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _controller.goBack,
                  child: Text(AppLocalizations.of(context).back),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}