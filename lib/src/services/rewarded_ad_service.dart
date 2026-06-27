import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAdService({AdMobRuntimeConfig? config})
    : _config = config ?? AdMobRuntimeConfig.current;

  final AdMobRuntimeConfig _config;
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isInitialized = false;
  int _eligibleSaveCount = 0;
  Completer<RewardedAd?>? _loadCompleter;
  Future<void>? _initializationFuture;

  Future<void> initialize() async {
    if (!_config.isEnabled) {
      return;
    }
    if (_isInitialized) {
      return;
    }
    if (_initializationFuture != null) {
      await _initializationFuture;
      return;
    }

    _initializationFuture = _initializeInternal();
    await _initializationFuture;
  }

  Future<void> warmup() async {
    if (!_config.isEnabled) {
      return;
    }
    unawaited(initialize());
  }

  Future<void> _initializeInternal() async {
    await MobileAds.instance.initialize();
    _isInitialized = true;
    _initializationFuture = null;
    unawaited(_loadRewardedAd());
  }

  Future<void> maybeShowOnSaveAction() async {
    if (!_config.isEnabled) {
      return;
    }

    _eligibleSaveCount += 1;

    final isEligible =
        _eligibleSaveCount == 1 || (_eligibleSaveCount > 1 && (_eligibleSaveCount - 1) % 3 == 0);

    if (!isEligible) {
      return;
    }

    final ad = _rewardedAd ?? await _waitForRewardedAd();
    if (ad == null) {
      return;
    }

    final completer = Completer<void>();
    _rewardedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete();
        }
        unawaited(_loadRewardedAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete();
        }
        unawaited(_loadRewardedAd());
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {},
    );

    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => null,
    );
  }

  Future<RewardedAd?> _waitForRewardedAd() async {
    if (!_config.isEnabled) {
      return null;
    }

    await initialize();

    if (_rewardedAd != null) {
      return _rewardedAd;
    }

    final completer = _loadCompleter;
    if (completer != null) {
      return completer.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
    }

    final loadFuture = _loadRewardedAd();
    return loadFuture.timeout(
      const Duration(seconds: 4),
      onTimeout: () => null,
    );
  }

  Future<RewardedAd?> _loadRewardedAd() async {
    if (!_config.isEnabled) {
      return null;
    }

    if (_rewardedAd != null) {
      return _rewardedAd;
    }

    if (_isLoading) {
      return _loadCompleter!.future;
    }

    _isLoading = true;
    final completer = Completer<RewardedAd?>();
    _loadCompleter = completer;
    await RewardedAd.load(
      adUnitId: _config.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          _loadCompleter?.complete(ad);
          _loadCompleter = null;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
          _loadCompleter?.complete(null);
          _loadCompleter = null;
        },
      ),
    );

    return completer.future;
  }
}

class AdMobRuntimeConfig {
  const AdMobRuntimeConfig({
    required this.isEnabled,
    required this.rewardedAdUnitId,
  });

  final bool isEnabled;
  final String rewardedAdUnitId;

  static const String _debugRewardedAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _releaseRewardedAdUnitId = String.fromEnvironment(
    'QUIET_ADMOB_REWARDED_ID',
    defaultValue: '',
  );

  static AdMobRuntimeConfig get current {
    if (!kReleaseMode) {
      return const AdMobRuntimeConfig(
        isEnabled: true,
        rewardedAdUnitId: _debugRewardedAdUnitId,
      );
    }

    if (_releaseRewardedAdUnitId.isEmpty) {
      return const AdMobRuntimeConfig(
        isEnabled: false,
        rewardedAdUnitId: '',
      );
    }

    return const AdMobRuntimeConfig(
      isEnabled: true,
      rewardedAdUnitId: _releaseRewardedAdUnitId,
    );
  }
}
