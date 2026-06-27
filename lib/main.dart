import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/data/app_database.dart';
import 'src/data/vault_repository.dart';
import 'src/services/favicon_service.dart';
import 'src/services/rewarded_ad_service.dart';
import 'src/state/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await AppDatabase.open();
  final repository = VaultRepository(database, FaviconService());
  await repository.ensureDefaultQuickLinks();
  final preferences = await SharedPreferences.getInstance();
  final rewardedAdService = RewardedAdService();

  runApp(
    ProviderScope(
      overrides: [
        vaultRepositoryProvider.overrideWithValue(repository),
        appPreferencesProvider.overrideWithValue(preferences),
        rewardedAdServiceProvider.overrideWithValue(rewardedAdService),
      ],
      child: const QuietVaultApp(),
    ),
  );
}
