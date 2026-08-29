import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LoadingLargeAd extends StatefulWidget {
  const LoadingLargeAd({super.key});

  @override
  State<LoadingLargeAd> createState() => _LoadingLargeAdState();
}

class _LoadingLargeAdState extends State<LoadingLargeAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final String _adUnitId = 'ca-app-pub-4241608895500197/7320780298';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded && _bannerAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    final AdSize adSize = AdSize.mediumRectangle;

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdMob Inline Loading Error: $err');
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
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
    // No Desktop, Web ou enquanto o anúncio não carrega, não ocupa espaço nem exibe spinner extra
    if (kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS) ||
        !_isLoaded ||
        _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
