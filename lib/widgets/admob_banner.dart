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
  int? _currentWidth;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4241608895500197/7309130446'
      : 'ca-app-pub-4241608895500197/7562768546';

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mediaQuery = MediaQuery.of(context);
    final newOrientation = mediaQuery.orientation;
    final newWidth = mediaQuery.size.width.truncate();

    // Detecta se mudou de posição ou largura
    if (_currentOrientation != newOrientation || _currentWidth != newWidth) {
      _currentOrientation = newOrientation;
      _currentWidth = newWidth;

      // Cancela retentativas pendentes e reseta o estado
      _retryTimer?.cancel();
      _retryAttempts = 0;

      // Descarta o anúncio antigo e recarrega para a nova largura
      _reloadAdForNewWidth(newWidth);
    }
  }

  Future<void> _reloadAdForNewWidth(int width) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    // 1. Limpa o anúncio anterior da memória
    _bannerAd?.dispose();
    _bannerAd = null;

    setState(() {
      _isLoaded = false;
      _isLoadingAd = true;
    });

    // 2. Recalcula o tamanho para a nova largura horizontal
    final AdSize? adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (adSize == null) {
      setState(() => _isLoadingAd = false);
      return;
    }

    // 3. Instancia e carrega o novo banner
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isLoadingAd = false;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _isLoadingAd = false;
            });
            _scheduleRetry(width);
          }
        },
      ),
    );

    await _bannerAd?.load();
  }

  Future<void> _loadAd(int width) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    if (_isLoaded || _isLoadingAd) return;

    _isLoadingAd = true;

    // 1. SOLICITA O TAMANHO ADAPTATIVO BASEADO NA LARGURA TOTAL DA TELA
    final AdSize? adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (adSize == null) {
      _isLoadingAd = false;
      return;
    }

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size:
          adSize, // Aplica o tamanho adaptativo calculando a altura proporcional
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdMob: Anúncio adaptativo carregado com sucesso!');
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
            _scheduleRetry(width);
          }
        },
      ),
    );

    await _bannerAd?.load();
  }

  // AGENDA UMA NOVA TENTATIVA APÓS ALGUNS SEGUNDOS
  void _scheduleRetry(int width) {
    if (_retryAttempts >= _maxRetryAttempts) {
      debugPrint('AdMob: Limite de retentativas atingido.');
      return;
    }

    _retryTimer?.cancel();
    final int delaySeconds = 5 * (_retryAttempts + 1);
    _retryAttempts++;

    debugPrint(
      'AdMob: Tentando novamente em $delaySeconds segundos... (Tentativa $_retryAttempts)',
    );

    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (mounted && !_isLoaded && !_isLoadingAd) {
        _loadAd(width);
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
        color: Theme.of(context).scaffoldBackgroundColor,
        width: double.infinity, // Força o Container a esticar 100% na largura
        height: _bannerAd!.size.height.toDouble(), // Altura dinâmica do ad
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Se não carregou, encolhe a zero sem deixar buracos vazios na tela
    return const SizedBox.shrink();
  }
}
