import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobBanner extends StatefulWidget {
  const AdMobBanner({super.key});

  @override
  State<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<AdMobBanner>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoadingAd = false;

  // CONTROLE DE RETRY (RECARGA AUTOMÁTICA)
  Timer? _retryTimer;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 4; // Tenta no máximo 4 vezes seguidas

  Orientation? _currentOrientation;
  bool? _isLargeScreen;

  final String _adUnitId = kDebugMode
      ? (Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-3940256099942544/2934735716')
      : (Platform.isAndroid
            ? 'ca-app-pub-4241608895500197/7309130446'
            : 'ca-app-pub-4241608895500197/7562768546');

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final isLarge = mediaQuery.size.shortestSide >= 600;

    if (_currentOrientation != orientation || _isLargeScreen != isLarge) {
      _currentOrientation = orientation;
      _isLargeScreen = isLarge;
      _retryAttempts = 0;
      _retryTimer?.cancel();
      _loadAd(orientation, isLarge);
    }
  }

  void _loadAd(Orientation orientation, bool isLargeScreen) {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    if (_isLoaded || _isLoadingAd) return;

    _isLoadingAd = true;

    final AdSize adSize;
    if (isLargeScreen) {
      adSize = orientation == Orientation.portrait
          ? AdSize.largeBanner
          : AdSize.fullBanner;
    } else {
      adSize = AdSize.banner; // 320x50 padrão
    }

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdMob: Anúncio carregado com sucesso!');
          _retryAttempts = 0; // Zera as tentativas ao obter sucesso
          _retryTimer?.cancel();
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isLoadingAd = false;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdMob: No Fill/Falha ($err). Agendando recarga...');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _isLoadingAd = false;
            });
            _scheduleRetry(orientation, isLargeScreen);
          }
        },
      ),
    )..load();
  }

  // AGENDA UMA NOVA TENTATIVA APÓS ALGUNS SEGUNDOS
  void _scheduleRetry(Orientation orientation, bool isLargeScreen) {
    if (_retryAttempts >= _maxRetryAttempts) {
      debugPrint('AdMob: Limite de retentativas atingido.');
      return;
    }

    _retryTimer?.cancel();
    // Aumenta o tempo a cada tentativa (5s, 10s, 15s, 20s) para não ser bloqueado por spam
    final int delaySeconds = 5 * (_retryAttempts + 1);
    _retryAttempts++;

    debugPrint(
      'AdMob: Tentando novamente em $delaySeconds segundos... (Tentativa $_retryAttempts)',
    );

    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (mounted && !_isLoaded && !_isLoadingAd) {
        _loadAd(orientation, isLargeScreen);
      }
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const SizedBox.shrink();
    }

    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Se não carregou, encolhe a zero sem deixar buracos vazios na tela
    return const SizedBox.shrink();
  }
}
