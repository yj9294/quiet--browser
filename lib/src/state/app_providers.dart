import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/vault_repository.dart';
import '../models/entities.dart';
import '../services/rewarded_ad_service.dart';

final vaultRepositoryProvider = Provider<VaultRepository>(
  (ref) => throw UnimplementedError('vaultRepositoryProvider must be overridden in main().'),
);

final appPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('appPreferencesProvider must be overridden in main().'),
);

final rewardedAdServiceProvider = Provider<RewardedAdService>(
  (ref) => throw UnimplementedError('rewardedAdServiceProvider must be overridden in main().'),
);

final appShellIndexProvider = NotifierProvider<AppShellIndexNotifier, int>(
  AppShellIndexNotifier.new,
);

final vaultControllerProvider =
    AsyncNotifierProvider<VaultController, VaultState>(VaultController.new);

class VaultController extends AsyncNotifier<VaultState> {
  VaultRepository get _repository => ref.read(vaultRepositoryProvider);

  @override
  Future<VaultState> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> selectCollection(int? collectionId) async {
    final current = state.hasValue ? state.requireValue : null;
    if (current == null) {
      return;
    }
    state = AsyncData(current.withSelectedCollection(collectionId));
  }

  Future<void> saveLink(SaveLinkDraft draft) async {
    await _repository.saveLink(draft);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> deleteLink(int linkId) async {
    await _repository.deleteLink(linkId);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> toggleFavorite(int linkId, bool value) async {
    await _repository.toggleFavorite(linkId, value);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> touchLink(int linkId) async {
    await _repository.touchLink(linkId);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> saveQuickLink(QuickLinkDraft draft) async {
    await _repository.upsertQuickLink(draft);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> deleteQuickLink(int quickLinkId) async {
    await _repository.deleteQuickLink(quickLinkId);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> saveCollection(CollectionDraft draft) async {
    await _repository.upsertCollection(draft);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> trackSession({
    required String url,
    required String title,
  }) async {
    await _repository.trackSession(url: url, title: title);
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  Future<void> clearRecentSessions() async {
    await _repository.clearRecentSessions();
    state = AsyncData(await _load(_currentSelectedCollectionId));
  }

  int? get _currentSelectedCollectionId =>
      state.hasValue ? state.requireValue.selectedCollectionId : null;

  Future<VaultState> _load([int? selectedCollectionId]) async {
    final collections = await _repository.fetchCollections();
    final savedLinks = await _repository.fetchSavedLinks();
    final quickLinks = await _repository.fetchQuickLinks();
    final recentSessions = await _repository.fetchRecentSessions();

    return VaultState(
      collections: collections,
      savedLinks: savedLinks,
      quickLinks: quickLinks,
      recentSessions: recentSessions,
      selectedCollectionId: selectedCollectionId,
    );
  }
}

class AppShellIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int value) {
    state = value;
  }
}
