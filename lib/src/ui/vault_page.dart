import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entities.dart';
import '../state/app_providers.dart';
import 'browser_page.dart';
import 'ui_primitives.dart';

class VaultPage extends ConsumerWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vaultControllerProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: FilledButton(
          onPressed: () => ref.read(vaultControllerProvider.notifier).refresh(),
          child: const Text('Reload vault'),
        ),
      ),
      data: (value) {
        return AppBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vault',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  AppPill(
                    label: '${value.savedLinks.length} saved',
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Filter collections, revisit saved links, and edit favorites without leaving the device.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: value.selectedCollectionId == null,
                        onSelected: (_) => ref
                            .read(vaultControllerProvider.notifier)
                            .selectCollection(null),
                      ),
                    ),
                    ...value.collections.map((collection) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(collection.name),
                          selected: value.selectedCollectionId == collection.id,
                          onSelected: (_) => ref
                              .read(vaultControllerProvider.notifier)
                              .selectCollection(collection.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (value.filteredLinks.isEmpty)
                _VaultEmptyState(
                  onOpenBrowser: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BrowserPage(),
                      ),
                    );
                  },
                )
              else
                ...value.filteredLinks.map(
                  (link) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VaultLinkTile(link: link),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _VaultLinkTile extends ConsumerWidget {
  const _VaultLinkTile({required this.link});

  final SavedLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = link.tags.isNotEmpty ? link.tags.first : link.collectionName;

    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SiteAvatar(
                url: link.url,
                iconPath: link.iconPath,
                size: 44,
                backgroundColor: _collectionTint(link.collectionName),
                foregroundColor: _collectionAccent(link.collectionName),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link.url,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => ref
                    .read(vaultControllerProvider.notifier)
                    .toggleFavorite(link.id, !link.isFavorite),
                icon: Icon(
                  link.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              AppPill(label: tag, compact: true),
              const SizedBox(width: 8),
              Text(
                link.lastOpenedAt == null ? 'Saved locally' : 'Opened recently',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    await ref
                        .read(vaultControllerProvider.notifier)
                        .deleteLink(link.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          if (link.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              link.note,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BrowserPage(
                    initialInput: link.url,
                    linkIdToTouch: link.id,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open again'),
          ),
        ],
      ),
    );
  }
}

class _VaultEmptyState extends StatelessWidget {
  const _VaultEmptyState({required this.onOpenBrowser});

  final VoidCallback onOpenBrowser;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpenBrowser,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start saving private links',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2A2333),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Use the browser tab or the floating action button to open a page, then save it into your local vault.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF6B6376),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _collectionTint(String value) {
  const palette = [
    Color(0xFFEEF6FF),
    Color(0xFFF5F0FF),
    Color(0xFFFFF0E8),
    Color(0xFFEAF8F2),
  ];
  return palette[value.hashCode.abs() % palette.length];
}

Color _collectionAccent(String value) {
  const palette = [
    Color(0xFF4E90FF),
    Color(0xFF8C68F0),
    Color(0xFFFF8A5B),
    Color(0xFF46B57E),
  ];
  return palette[value.hashCode.abs() % palette.length];
}
