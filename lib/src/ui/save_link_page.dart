import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entities.dart';
import '../state/app_providers.dart';
import 'ui_primitives.dart';

class SaveLinkPage extends ConsumerStatefulWidget {
  const SaveLinkPage({
    super.key,
    required this.initialUrl,
    required this.initialTitle,
  });

  final String initialUrl;
  final String initialTitle;

  @override
  ConsumerState<SaveLinkPage> createState() => _SaveLinkPageState();
}

class _SaveLinkPageState extends ConsumerState<SaveLinkPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  late final TextEditingController _tagsController;
  late final TextEditingController _noteController;

  int? _selectedCollectionId;
  bool _isFavorite = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTitle.isEmpty ? 'Saved page' : widget.initialTitle,
    );
    _urlController = TextEditingController(text: widget.initialUrl);
    _tagsController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultControllerProvider);
    final collections = state.hasValue ? state.requireValue.collections : const <LinkCollection>[];
    _selectedCollectionId ??= collections.isEmpty ? null : collections.first.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Save privately')),
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            children: [
              Text(
                'Everything stays on-device and becomes instantly searchable in your vault.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              AppPanel(
                radius: 32,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(labelText: 'URL'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Enter a URL';
                        }
                        final uri = Uri.tryParse(text);
                        if (uri == null || !uri.hasScheme) {
                          return 'Use a valid URL starting with http or https';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCollectionId,
                      decoration: const InputDecoration(labelText: 'Collection'),
                      items: collections
                          .map(
                            (collection) => DropdownMenuItem<int>(
                              value: collection.id,
                              child: Text(collection.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCollectionId = value),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'Research, Inspiration, Private',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _noteController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Private note',
                        alignLabelWithHint: true,
                        hintText: 'Add why this page matters and what to revisit later.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      value: _isFavorite,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) => setState(() => _isFavorite = value),
                      title: const Text('Favorite this link'),
                      subtitle: const Text('Show it more prominently in your local vault.'),
                    ),
                    const SizedBox(height: 6),
                    const AppPill(
                      label: 'Stored only on this device. No sync account required.',
                      foregroundColor: Color(0xFFB56F67),
                      expand: true,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: Text(_isSaving ? 'Saving...' : 'Save Privately'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'If a rewarded ad is eligible and loaded for this cold-start session, it may appear before the save completes.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCollectionId == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(rewardedAdServiceProvider).maybeShowOnSaveAction();
      await ref.read(vaultControllerProvider.notifier).saveLink(
            SaveLinkDraft(
              title: _titleController.text,
              url: _urlController.text,
              collectionId: _selectedCollectionId!,
              note: _noteController.text,
              tagsCsv: _tagsController.text,
              isFavorite: _isFavorite,
            ),
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
