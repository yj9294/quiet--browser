class LinkCollection {
  const LinkCollection({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String colorHex;
  final DateTime createdAt;

  factory LinkCollection.fromMap(Map<String, Object?> map) {
    return LinkCollection(
      id: map['id'] as int,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class SavedLink {
  const SavedLink({
    required this.id,
    required this.title,
    required this.url,
    required this.iconPath,
    required this.collectionId,
    required this.collectionName,
    required this.note,
    required this.tagsCsv,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    required this.lastOpenedAt,
  });

  final int id;
  final String title;
  final String url;
  final String iconPath;
  final int collectionId;
  final String collectionName;
  final String note;
  final String tagsCsv;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;

  List<String> get tags => tagsCsv
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList();

  factory SavedLink.fromMap(Map<String, Object?> map) {
    return SavedLink(
      id: map['id'] as int,
      title: map['title'] as String,
      url: map['url'] as String,
      iconPath: map['icon_path'] as String? ?? '',
      collectionId: map['collection_id'] as int,
      collectionName: map['collection_name'] as String? ?? 'Inbox',
      note: map['note'] as String? ?? '',
      tagsCsv: map['tags_csv'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastOpenedAt: map['last_opened_at'] == null
          ? null
          : DateTime.parse(map['last_opened_at'] as String),
    );
  }
}

class QuickLink {
  const QuickLink({
    required this.id,
    required this.label,
    required this.url,
    required this.sortOrder,
  });

  final int id;
  final String label;
  final String url;
  final int sortOrder;

  factory QuickLink.fromMap(Map<String, Object?> map) {
    return QuickLink(
      id: map['id'] as int,
      label: map['label'] as String,
      url: map['url'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}

class RecentSession {
  const RecentSession({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
  });

  final int id;
  final String url;
  final String title;
  final DateTime visitedAt;

  factory RecentSession.fromMap(Map<String, Object?> map) {
    return RecentSession(
      id: map['id'] as int,
      url: map['url'] as String,
      title: map['title'] as String? ?? '',
      visitedAt: DateTime.parse(map['visited_at'] as String),
    );
  }
}

class SaveLinkDraft {
  const SaveLinkDraft({
    this.id,
    required this.title,
    required this.url,
    this.iconPath,
    required this.collectionId,
    required this.note,
    required this.tagsCsv,
    required this.isFavorite,
  });

  final int? id;
  final String title;
  final String url;
  final String? iconPath;
  final int collectionId;
  final String note;
  final String tagsCsv;
  final bool isFavorite;
}

class QuickLinkDraft {
  const QuickLinkDraft({this.id, required this.label, required this.url});

  final int? id;
  final String label;
  final String url;
}

class CollectionDraft {
  const CollectionDraft({this.id, required this.name, required this.colorHex});

  final int? id;
  final String name;
  final String colorHex;
}

class VaultState {
  const VaultState({
    required this.collections,
    required this.savedLinks,
    required this.quickLinks,
    required this.recentSessions,
    required this.selectedCollectionId,
  });

  final List<LinkCollection> collections;
  final List<SavedLink> savedLinks;
  final List<QuickLink> quickLinks;
  final List<RecentSession> recentSessions;
  final int? selectedCollectionId;

  VaultState withSelectedCollection(int? collectionId) {
    return VaultState(
      collections: collections,
      savedLinks: savedLinks,
      quickLinks: quickLinks,
      recentSessions: recentSessions,
      selectedCollectionId: collectionId,
    );
  }

  List<SavedLink> get filteredLinks {
    if (selectedCollectionId == null) {
      return savedLinks;
    }
    return savedLinks
        .where((link) => link.collectionId == selectedCollectionId)
        .toList();
  }
}
