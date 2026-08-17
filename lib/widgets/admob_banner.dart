import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobBanner extends StatefulWidget {
  const AdMobBanner({super.key});

  @override
  State<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<AdMobBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Variável para lembrar a orientação atual e evitar recarregar o anúncio à toa
  Orientation? _currentOrientation;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Descobre se o celular está em pé ou deitado
    final orientation = MediaQuery.of(context).orientation;

    // Se a orientação mudou (ou se é a primeira vez abrindo a tela), carrega o anúncio certo
    if (_currentOrientation != orientation) {
      _currentOrientation = orientation;
      _loadAd(orientation);
    }
  }

  void _loadAd(Orientation orientation) {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    // Descarta o anúncio antigo para não vazar memória no celular do usuário
    _bannerAd?.dispose();
    setState(() => _isLoaded = false);

    // MÁGICA AQUI: Escolhe o tamanho com base na rotação da tela
    final adSize = orientation == Orientation.portrait
        ? AdSize
              .largeBanner // Celular em pé: 320x100
        : AdSize.fullBanner; // Celular deitado: 468x60

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint(
            'AdMob: Anúncio carregado (Orientação: ${orientation.name})',
          );
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdMob: Falha ao carregar anúncio: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    // Altura dinâmica para o "buraco" de espera do anúncio, evitando que a tela pule
    final double fallbackHeight = _currentOrientation == Orientation.portrait
        ? 100
        : 60;

    return SizedBox(height: fallbackHeight);
  }
}
