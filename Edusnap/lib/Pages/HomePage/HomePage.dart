// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../Component/JournalCard/JournalCard.dart';
import '../../Models/JournalEntry.dart';
import '../Add/AddPage.dart';
import '../Detail/DetailPage.dart';
import '../Settings/SettingsPage.dart';
import 'HomePageController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller});

  final HomePageController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomePageController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        HomePageController(
          onOpenDetail: _openDetail,
          onOpenAdd: _openAdd,
          onOpenSettings: _openSettings,
        );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openDetail(JournalEntry entry) async {
    if (!mounted) return;
    final updated = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => DetailPage(entry: entry),
      ),
    );
    if (!mounted || updated == null) return;
    // If the entry was edited, replace it in the list
    if (!identical(updated, entry)) {
      _controller.updateEntry(entry, updated);
    }
  }

  Future<void> _openAdd() async {
    if (!mounted) return;
    final entry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(builder: (_) => const AddPage()),
    );
    if (!mounted || entry == null) return;
    _controller.addEntry(entry);
  }

  void _openSettings() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.title),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _controller.openSettings,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _controller.openAdd,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ListView.separated(
            itemCount: _controller.entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final entry = _controller.entries[index];
              return Dismissible(
                key: ValueKey('${entry.title}_${entry.createdAt.toIso8601String()}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _controller.remove(entry),
                child: JournalCard(
                  entry: entry,
                  onTap: () => _controller.openDetail(entry),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}