import 'package:flutter/material.dart';

class AdMobBanner extends StatelessWidget {
  const AdMobBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // O SafeArea impede que o banner seja cortado pelos cantos arredondados ou barra gestual do celular
    return SafeArea(
      child: Container(
        width: double.infinity,
        height:
            90, // Altura ampliada ideal para o formato Large Banner (320x100)
        color: onSurface.withValues(alpha: 0.05),
        child: Center(
          child: Text(
            "ESPAÇO RESERVADO PARA ADMOB\n(LARGE BANNER)",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
