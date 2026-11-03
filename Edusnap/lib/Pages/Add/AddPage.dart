// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../Models/JournalEntry.dart';
import 'AddPageController.dart';

class AddPage extends StatefulWidget {
  const AddPage({
    super.key,
    this.entry,
    this.controller,
  });

  /// Pass an existing entry to open in edit mode.
  final JournalEntry? entry;
  final AddPageController? controller;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late final AddPageController _controller;
  late final bool _ownsController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

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
        );

    // Pre-fill when editing
    final existing = widget.entry ?? _controller.existingEntry;
    if (existing != null) {
      _titleController.text = existing.title;
      _noteController.text = existing.note;
    }

    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  bool get _hasUnsavedData => _controller.hasUnsavedData(
        title: _titleController.text,
        note: _noteController.text,
      );

  Future<bool> _confirmLeave() async {
    if (!_hasUnsavedData) return true;
    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_controller.leaveDialogTitle),
          content: Text(_controller.leaveDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_controller.leaveCancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_controller.leaveConfirmLabel),
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_controller.missingTitleDialogTitle),
          content: Text(_controller.missingTitleDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_controller.okLabel),
            ),
          ],
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
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(_controller.title),
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
                    labelText: _controller.titleLabel,
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
                    labelText: _controller.noteLabel,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _onSavePressed,
                  child: Text(_controller.saveLabel),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _handleBack,
                  child: Text(_controller.backLabel),
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