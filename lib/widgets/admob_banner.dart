import 'package:flutter/material.dart';

class AdMobBanner extends StatelessWidget {
  const AdMobBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      height: 50, // Altura padrão de um banner de anúncio
      color: onSurface.withValues(alpha: 0.05),
      child: Center(
        child: Text(
          "ESPAÇO RESERVADO PARA ADMOB",
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
