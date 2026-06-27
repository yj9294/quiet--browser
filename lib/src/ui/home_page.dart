import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entities.dart';
import '../state/app_providers.dart';
import 'browser_page.dart';
import 'ui_primitives.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(vaultControllerProvider.notifier).refresh(),
      child: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
          children: [
            _SearchBar(
              controller: _searchController,
              onSubmit: (input) => _openBrowser(context, initialInput: input),
            ),
            const SizedBox(height: 16),
            const _HeroCard(),
            const SizedBox(height: 22),
            state.when(
              data: (value) => _HomeSections(state: value),
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _ErrorState(
                onRetry: () =>
                    ref.read(vaultControllerProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBrowser(BuildContext context, {required String initialInput}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowserPage(initialInput: initialInput),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.go,
      decoration: InputDecoration(
        hintText: 'Search or enter address',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () => onSubmit(controller.text),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      onSubmitted: onSubmit,
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      radius: 30,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppPill(label: 'Private Mode', compact: true),
                SizedBox(height: 12),
                Text(
                  'Your quiet\nbrowsing vault',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2A2333),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Save pages, keep notes, and reopen sessions locally with no cloud account required.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF746C78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 90,
            height: 104,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4F1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF3E4E0)),
            ),
            child: const Center(child: _VaultMark()),
          ),
        ],
      ),
    );
  }
}

class _HomeSections extends StatelessWidget {
  const _HomeSections({required this.state});

  final VaultState state;

  @override
  Widget build(BuildContext context) {
    final recentLinks = state.savedLinks.take(2).toList();
    final container = ProviderScope.containerOf(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Quick links'),
        const SizedBox(height: 12),
        state.quickLinks.isEmpty
            ? const _EmptyPanel(
                title: 'No quick links yet',
                body:
                    'Add your favorite destinations in Settings to pin them here.',
              )
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final link in state.quickLinks.take(6))
                    _QuickLinkCard(link: link),
                ],
              ),
        const SizedBox(height: 24),
        const AppSectionHeader(title: 'Recent collections'),
        const SizedBox(height: 12),
        if (state.collections.isEmpty)
          const _EmptyPanel(
            title: 'No collections yet',
            body:
                'Create your first collection in Settings to organize links locally.',
          )
        else
          Column(
            children: [
              for (final collection in state.collections.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CollectionCard(
                    collection: collection,
                    count: state.savedLinks
                        .where((link) => link.collectionId == collection.id)
                        .length,
                    onTap: () async {
                      await container
                          .read(vaultControllerProvider.notifier)
                          .selectCollection(collection.id);
                      container
                          .read(appShellIndexProvider.notifier)
                          .setIndex(1);
                    },
                  ),
                ),
            ],
          ),
        const SizedBox(height: 24),
        const AppSectionHeader(title: 'Saved recently'),
        const SizedBox(height: 12),
        if (recentLinks.isEmpty)
          const _EmptyPanel(
            title: 'Nothing saved yet',
            body:
                'Open a page in the browser and save it to start building your vault.',
          )
        else
          Column(
            children: [
              for (final link in recentLinks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SavedLinkCard(link: link),
                ),
            ],
          ),
      ],
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.link});

  final QuickLink link;

  @override
  Widget build(BuildContext context) {
    final config = _quickLinkVisual(link);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BrowserPage(initialInput: link.url),
          ),
        );
      },
      child: Ink(
        width: 102,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: config.tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: config.tint,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(config.icon, size: 16, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(
              link.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2A2333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.count,
    required this.onTap,
  });

  final LinkCollection collection;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _parseHexColor(collection.colorHex);
    final icon = _collectionIcon(collection.name);
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AppPanel(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count saved link${count == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Open vault',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF826E78),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedLinkCard extends StatelessWidget {
  const _SavedLinkCard({required this.link});

  final SavedLink link;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  BrowserPage(initialInput: link.url, linkIdToTouch: link.id),
            ),
          );
        },
        child: Row(
          children: [
            SiteAvatar(url: link.url, iconPath: link.iconPath, size: 42),
            const SizedBox(width: 16),
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
                    '${link.tags.isEmpty ? link.collectionName : link.tags.first} · ${link.url}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  link.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to open',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      backgroundColor: const Color(0xFFFFFCFB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _VaultMark extends StatelessWidget {
  const _VaultMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD9D2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const Icon(Icons.shield_rounded, color: Color(0xFFFF6B6B), size: 34),
        Positioned(
          right: 10,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF3E3149),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load your vault',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or retry loading your local data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
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

class _QuickLinkVisual {
  const _QuickLinkVisual(this.icon, this.tint);

  final IconData icon;
  final Color tint;
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

Color _parseHexColor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  final value = int.parse('FF$normalized', radix: 16);
  return Color(value);
}
