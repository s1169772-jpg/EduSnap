// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Models/JournalEntry.dart';
import '../../Services/LocaleController.dart';
import '../../l10n/app_localizations.dart';
import 'AddPageController.dart';

class AddPage extends StatefulWidget {
  const AddPage({
    super.key,
    this.entry,
    this.controller,
  });

  final JournalEntry? entry;
  final AddPageController? controller;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late final AddPageController _controller;
  late final bool _ownsController;
  final LocaleController _localeController = LocaleController.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  /// Always follow the language selected in Settings.
  AppLocalizations get _l10n =>
      lookupAppLocalizations(_localeController.locale);

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        AddPageController(
          existingEntry: widget.entry,
          onBack: _goBack,
          onSave: _popEntry,
          onTitleMissing: _showTitleMissingDialog,
          onPermissionDenied: _showPermissionDeniedDialog,
        );

    final existing = widget.entry ?? _controller.existingEntry;
    if (existing != null) {
      _titleController.text = existing.title;
      _noteController.text = existing.note;
    }

    _controller.addListener(_onChanged);
    _localeController.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool get _hasUnsavedData => _controller.hasUnsavedData(
        title: _titleController.text,
        note: _noteController.text,
      );

  Future<bool> _confirmLeave() async {
    if (!_hasUnsavedData) return true;
    if (!mounted) return false;

    final l10n = _l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.leaveDialogTitle),
          content: Text(l10n.leaveDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.leaveCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.leaveConfirm),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleBack() async {
    final shouldLeave = await _confirmLeave();
    if (!shouldLeave || !mounted) return;
    Navigator.of(context).pop();
  }

  void _goBack() {
    _handleBack();
  }

  void _popEntry(JournalEntry entry) {
    if (!mounted) return;
    Navigator.of(context).pop(entry);
  }

  Future<void> _showTitleMissingDialog() async {
    if (!mounted) return;
    final l10n = _l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.missingTitleDialogTitle),
          content: Text(l10n.missingTitleDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    if (!mounted) return;
    final l10n = _l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.permissionDeniedTitle),
          content: Text(l10n.permissionDeniedMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _controller.openAppSettingsPage();
              },
              child: Text(l10n.openSettings),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPickSourceSheet() async {
    if (!mounted) return;
    final l10n = _l10n;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(l10n.camera),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _controller.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.gallery),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _controller.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSavePressed() {
    _controller.save(
      title: _titleController.text,
      note: _noteController.text,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _localeController.removeListener(_onChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final imagePath = _controller.imagePath;
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    final pageTitle =
        _controller.isEditMode ? l10n.editTitle : l10n.addTitle;

    return PopScope(
      canPop: !_hasUnsavedData,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _confirmLeave();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            pageTitle,
            key: ValueKey(_localeController.locale.toString()),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.titleLabel,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  minLines: 4,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: l10n.noteLabel,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagePath),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 180,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showPickSourceSheet,
                          icon: const Icon(Icons.photo),
                          label: Text(l10n.changePhoto),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _controller.clearImage,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.removePhoto),
                        ),
                      ),
                    ],
                  ),
                ] else
                  OutlinedButton.icon(
                    onPressed: _showPickSourceSheet,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(l10n.pickPhoto),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _onSavePressed,
                  child: Text(
                    _controller.isEditMode ? l10n.update : l10n.save,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _handleBack,
                  child: Text(l10n.back),
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