import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/app_providers.dart';
import 'theme/app_theme.dart';
import 'ui/app_shell.dart';

class QuietVaultApp extends ConsumerStatefulWidget {
  const QuietVaultApp({super.key});

  @override
  ConsumerState<QuietVaultApp> createState() => _QuietVaultAppState();
}

class _QuietVaultAppState extends ConsumerState<QuietVaultApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rewardedAdServiceProvider).warmup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiet Vault Browser',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
