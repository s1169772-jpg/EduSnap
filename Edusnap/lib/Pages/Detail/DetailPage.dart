// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../Models/JournalEntry.dart';
import '../Add/AddPage.dart';
import 'DetailPageController.dart';

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
    // Pop the current (possibly updated) entry so List can refresh
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
          title: Text(_controller.title),
          actions: [
            TextButton(
              onPressed: _controller.edit,
              child: Text(_controller.editLabel),
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
                  _controller.entryDate,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
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