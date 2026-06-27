import '../models/entities.dart';
import '../services/favicon_service.dart';
import 'app_database.dart';

class VaultRepository {
  const VaultRepository(this.database, this.faviconService);

  final AppDatabase database;
  final FaviconService faviconService;

  static const List<QuickLinkDraft> _defaultQuickLinks = [
    QuickLinkDraft(label: 'YouTube', url: 'https://www.youtube.com/'),
    QuickLinkDraft(label: 'Wikipedia', url: 'https://www.wikipedia.org/'),
    QuickLinkDraft(label: 'GitHub', url: 'https://github.com/'),
    QuickLinkDraft(label: 'Reddit', url: 'https://www.reddit.com/'),
    QuickLinkDraft(label: 'Medium', url: 'https://medium.com/'),
    QuickLinkDraft(label: 'Hacker News', url: 'https://news.ycombinator.com/'),
  ];

  Future<List<LinkCollection>> fetchCollections() async {
    final rows = await database.db.query(
      'collections',
      orderBy: 'created_at ASC',
    );
    return rows.map(LinkCollection.fromMap).toList();
  }

  Future<List<SavedLink>> fetchSavedLinks() async {
    final rows = await database.db.rawQuery('''
      SELECT
        saved_links.*,
        collections.name AS collection_name
      FROM saved_links
      JOIN collections ON collections.id = saved_links.collection_id
      ORDER BY COALESCE(last_opened_at, updated_at) DESC
    ''');

    return rows.map(SavedLink.fromMap).toList();
  }

  Future<List<QuickLink>> fetchQuickLinks() async {
    final rows = await database.db.query(
      'quick_links',
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(QuickLink.fromMap).toList();
  }

  Future<List<RecentSession>> fetchRecentSessions() async {
    final rows = await database.db.query(
      'recent_sessions',
      orderBy: 'visited_at DESC',
      limit: 12,
    );
    return rows.map(RecentSession.fromMap).toList();
  }

  Future<void> saveLink(SaveLinkDraft draft) async {
    final now = DateTime.now().toIso8601String();
    final normalizedUrl = draft.url.trim();
    final resolvedIconPath = await _resolveIconPath(draft);
    final payload = <String, Object?>{
      'title': draft.title.trim(),
      'url': normalizedUrl,
      'icon_path': resolvedIconPath,
      'collection_id': draft.collectionId,
      'note': draft.note.trim(),
      'tags_csv': draft.tagsCsv.trim(),
      'is_favorite': draft.isFavorite ? 1 : 0,
      'updated_at': now,
      'last_opened_at': now,
    };

    if (draft.id == null) {
      await database.db.insert('saved_links', {...payload, 'created_at': now});
      return;
    }

    await database.db.update(
      'saved_links',
      payload,
      where: 'id = ?',
      whereArgs: [draft.id],
    );
  }

  Future<void> deleteLink(int linkId) async {
    await database.db.delete(
      'saved_links',
      where: 'id = ?',
      whereArgs: [linkId],
    );
  }

  Future<void> toggleFavorite(int linkId, bool value) async {
    await database.db.update(
      'saved_links',
      {
        'is_favorite': value ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [linkId],
    );
  }

  Future<void> touchLink(int linkId) async {
    await database.db.update(
      'saved_links',
      {'last_opened_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [linkId],
    );
  }

  Future<void> upsertQuickLink(QuickLinkDraft draft) async {
    final payload = {
      'label': draft.label.trim(),
      'url': draft.url.trim(),
      'sort_order': draft.id ?? DateTime.now().millisecondsSinceEpoch,
    };

    if (draft.id == null) {
      await database.db.insert('quick_links', payload);
      return;
    }

    await database.db.update(
      'quick_links',
      payload,
      where: 'id = ?',
      whereArgs: [draft.id],
    );
  }

  Future<void> ensureDefaultQuickLinks() async {
    final countResult = await database.db.rawQuery(
      'SELECT COUNT(*) AS total FROM quick_links',
    );
    final count = countResult.first['total'] as int? ?? 0;
    if (count > 0) {
      return;
    }

    final batch = database.db.batch();
    for (var i = 0; i < _defaultQuickLinks.length; i += 1) {
      final link = _defaultQuickLinks[i];
      batch.insert('quick_links', {
        'label': link.label,
        'url': link.url,
        'sort_order': i,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertCollection(CollectionDraft draft) async {
    final payload = {'name': draft.name.trim(), 'color_hex': draft.colorHex};

    if (draft.id == null) {
      await database.db.insert('collections', {
        ...payload,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }

    await database.db.update(
      'collections',
      payload,
      where: 'id = ?',
      whereArgs: [draft.id],
    );
  }

  Future<void> deleteQuickLink(int quickLinkId) async {
    await database.db.delete(
      'quick_links',
      where: 'id = ?',
      whereArgs: [quickLinkId],
    );
  }

  Future<void> trackSession({
    required String url,
    required String title,
  }) async {
    if (url.isEmpty) {
      return;
    }

    await database.db.insert('recent_sessions', {
      'url': url,
      'title': title,
      'visited_at': DateTime.now().toIso8601String(),
    });

    await database.db.execute('''
      DELETE FROM recent_sessions
      WHERE id NOT IN (
        SELECT id FROM recent_sessions
        ORDER BY visited_at DESC
        LIMIT 30
      )
    ''');
  }

  Future<void> clearRecentSessions() async {
    await database.db.delete('recent_sessions');
  }

  Future<String> _resolveIconPath(SaveLinkDraft draft) async {
    final existing = draft.iconPath?.trim() ?? '';
    if (existing.isNotEmpty) {
      return existing;
    }
    return faviconService.fetchAndStore(draft.url);
  }
}
