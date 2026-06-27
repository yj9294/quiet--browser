import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entities.dart';
import '../state/app_providers.dart';
import 'privacy_policy_page.dart';
import 'support_page.dart';
import 'terms_of_use_page.dart';
import 'ui_primitives.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaultControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('Unable to load settings')),
      data: (value) {
        return AppBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage local-only data, quick links, and collections.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              AppPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local-only storage',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Quiet Vault keeps your saved pages, tags, and private notes entirely on this device.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SettingsRow(
                title: 'Manage quick links',
                subtitle: 'Edit your pinned destinations',
                onTap: () => _showQuickLinkDialog(context, ref),
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: 'Privacy Policy',
                subtitle: 'Read how Quiet Vault Browser handles your data',
                onTap: () => _showPrivacyPolicy(context),
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: 'Terms of Use',
                subtitle: 'Review the rules for using Quiet Vault Browser',
                onTap: () => _showTermsOfUse(context),
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: 'Support',
                subtitle: 'Contact support and view help information',
                onTap: () => _showSupport(context),
              ),
              const SizedBox(height: 12),
              _SettingsRow(
                title: 'Clear recent sessions',
                subtitle: value.recentSessions.isEmpty
                    ? 'No recent sessions stored on this device'
                    : 'Remove ${value.recentSessions.length} browsing trace${value.recentSessions.length == 1 ? '' : 's'} from this device',
                onTap: () => _clearRecentSessions(
                  context,
                  ref,
                  value.recentSessions.length,
                ),
              ),
              const SizedBox(height: 12),
              const AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewarded privacy boost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2A2333),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'A single rewarded ad slot is used near the save flow. On each cold start, the first eligible save waits for a loaded ad, then it may reappear every third eligible save.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Color(0xFF6B6376),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(title: 'Collections'),
                    const SizedBox(height: 12),
                    for (final collection in value.collections)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _parseHexColor(collection.colorHex),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _collectionIcon(collection.name),
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(collection.name)),
                          ],
                        ),
                      ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showCollectionDialog(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add collection'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(title: 'Quick links'),
                    const SizedBox(height: 12),
                    if (value.quickLinks.isEmpty)
                      Text(
                        'No quick links yet. Add one to mirror the home screen shortcuts.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      ...value.quickLinks.map((quickLink) {
                        final visual = _quickLinkVisual(quickLink);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: visual.tint.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              visual.icon,
                              size: 18,
                              color: visual.tint,
                            ),
                          ),
                          title: Text(quickLink.label),
                          subtitle: Text(quickLink.url),
                          trailing: IconButton(
                            onPressed: () => ref
                                .read(vaultControllerProvider.notifier)
                                .deleteQuickLink(quickLink.id),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppPill(
                label: 'On-device mode enabled',
                foregroundColor: Color(0xFFD46A61),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showQuickLinkDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _AddQuickLinkDialog(),
    );
  }

  Future<void> _showCollectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _AddCollectionDialog(),
    );
  }

  Future<void> _showPrivacyPolicy(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()));
  }

  Future<void> _showTermsOfUse(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TermsOfUsePage()));
  }

  Future<void> _showSupport(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SupportPage()));
  }

  Future<void> _clearRecentSessions(
    BuildContext context,
    WidgetRef ref,
    int recentCount,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    if (recentCount == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Recent sessions are already cleared.')),
      );
      return;
    }

    await ref.read(vaultControllerProvider.notifier).clearRecentSessions();
    if (!context.mounted) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$recentCount recent session${recentCount == 1 ? '' : 's'} cleared.',
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

Color _parseHexColor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

_QuickLinkVisual _quickLinkVisual(QuickLink link) {
  final label = link.label.toLowerCase();
  final url = link.url.toLowerCase();

  if (label.contains('youtube') || url.contains('youtube')) {
    return const _QuickLinkVisual(Icons.play_arrow_rounded, Color(0xFFFF6B6B));
  }
  if (label.contains('wikipedia') || url.contains('wikipedia')) {
    return const _QuickLinkVisual(Icons.menu_book_rounded, Color(0xFF4D90FF));
  }
  if (label.contains('github') || url.contains('github')) {
    return const _QuickLinkVisual(Icons.code_rounded, Color(0xFF3E3149));
  }
  if (label.contains('reddit') || url.contains('reddit')) {
    return const _QuickLinkVisual(Icons.forum_rounded, Color(0xFFFF8A5B));
  }
  if (label.contains('medium') || url.contains('medium')) {
    return const _QuickLinkVisual(Icons.article_rounded, Color(0xFF46B57E));
  }
  if (label.contains('hacker') || url.contains('ycombinator')) {
    return const _QuickLinkVisual(Icons.bolt_rounded, Color(0xFF7C63ED));
  }

  return const _QuickLinkVisual(Icons.public_rounded, Color(0xFF7C63ED));
}

IconData _collectionIcon(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('inbox')) {
    return Icons.inbox_rounded;
  }
  if (normalized.contains('work')) {
    return Icons.work_rounded;
  }
  if (normalized.contains('read')) {
    return Icons.auto_stories_rounded;
  }
  if (normalized.contains('travel')) {
    return Icons.flight_takeoff_rounded;
  }
  if (normalized.contains('design')) {
    return Icons.palette_rounded;
  }
  return Icons.folder_rounded;
}

class _QuickLinkVisual {
  const _QuickLinkVisual(this.icon, this.tint);

  final IconData icon;
  final Color tint;
}

class _AddQuickLinkDialog extends ConsumerStatefulWidget {
  const _AddQuickLinkDialog();

  @override
  ConsumerState<_AddQuickLinkDialog> createState() =>
      _AddQuickLinkDialogState();
}

class _AddQuickLinkDialogState extends ConsumerState<_AddQuickLinkDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add quick link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(labelText: 'Label'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(labelText: 'URL'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final label = _labelController.text.trim();
            final url = _urlController.text.trim();
            if (label.isEmpty || url.isEmpty) {
              return;
            }
            await ref
                .read(vaultControllerProvider.notifier)
                .saveQuickLink(QuickLinkDraft(label: label, url: url));
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddCollectionDialog extends ConsumerStatefulWidget {
  const _AddCollectionDialog();

  @override
  ConsumerState<_AddCollectionDialog> createState() =>
      _AddCollectionDialogState();
}

class _AddCollectionDialogState extends ConsumerState<_AddCollectionDialog> {
  static const _palette = [
    '#FF6B6B',
    '#7C63ED',
    '#4D90FF',
    '#46B57E',
    '#FF8A5B',
  ];

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add collection'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Collection name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final name = _controller.text.trim();
            if (name.isEmpty) {
              return;
            }
            final color = _palette[name.hashCode.abs() % _palette.length];
            await ref
                .read(vaultControllerProvider.notifier)
                .saveCollection(CollectionDraft(name: name, colorHex: color));
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
