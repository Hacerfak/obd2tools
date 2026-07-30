import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../parser/registries/mode_01_registry.dart';
import '../state/obd_providers.dart';
import '../widgets/obd_gauge.dart';

class HudScreen extends ConsumerStatefulWidget {
  const HudScreen({super.key});

  @override
  ConsumerState<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends ConsumerState<HudScreen> {
  Timer? _hudPollingTimer;
  int _currentChunkIndex = 0;

  // Limite estrito de 12 (Vamos popular 6 para teste inicial)
  final List<int> _activeGaugesPids = [0x0C, 0x0D, 0x05, 0x04, 0x0F, 0x11];

  GaugeStyle _currentStyle = GaugeStyle.digital;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startHudPolling();
    });
  }

  // A LÓGICA DE OURO DO REVEZAMENTO (ROUND-ROBIN) A CADA 250ms
  void _startHudPolling() {
    _hudPollingTimer = Timer.periodic(const Duration(milliseconds: 250), (
      timer,
    ) {
      if (_activeGaugesPids.isEmpty) return;

      // Agrupa a lista de PIDs em pedaços de 3 itens
      List<List<int>> chunks = [];
      for (var i = 0; i < _activeGaugesPids.length; i += 3) {
        chunks.add(
          _activeGaugesPids.sublist(
            i,
            i + 3 > _activeGaugesPids.length ? _activeGaugesPids.length : i + 3,
          ),
        );
      }

      // Reinicia o loop se chegou no final
      if (_currentChunkIndex >= chunks.length) {
        _currentChunkIndex = 0;
      }

      // Monta o comando (ex: "01 0C 0D 05")
      String multiCommand = "01";
      for (var pidId in chunks[_currentChunkIndex]) {
        multiCommand += pidId.toRadixString(16).padLeft(2, '0').toUpperCase();
      }

      ref.read(obdManagerProvider).queueCommand(multiCommand);
      _currentChunkIndex++;
    });
  }

  @override
  void dispose() {
    _hudPollingTimer?.cancel();
    super.dispose();
  }

  // --- CÁLCULO DE GRID PARA NUNCA TER SCROLL ---
  int _getCrossAxisCount(int totalItems, bool isDesktop) {
    if (isDesktop) return totalItems > 6 ? 4 : (totalItems > 3 ? 3 : 2);

    // Mobile: Distribuição vertical inteligente
    if (totalItems <= 2) return 1;
    if (totalItems <= 6) return 2;
    if (totalItems <= 9) return 3;
    return 3; // 10 a 12 relógios no mobile usam 3 colunas e 4 linhas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12151C),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 600;

          int crossAxisCount = _getCrossAxisCount(
            _activeGaugesPids.length,
            isDesktop,
          );
          int rowCount = (_activeGaugesPids.length / crossAxisCount).ceil();

          // Calcula a altura da tela, removendo o Banner Ad e o cabeçalho
          double availableHeight =
              constraints.maxHeight - 80 - 60; // 80 pro topo, 60 pro Ad
          if (availableHeight < 200) availableHeight = 200; // Segurança

          double itemHeight = availableHeight / (rowCount == 0 ? 1 : rowCount);
          double itemWidth =
              (constraints.maxWidth - 32 - ((crossAxisCount - 1) * 12)) /
              crossAxisCount;

          double childAspectRatio = itemWidth / itemHeight;

          return Column(
            children: [
              // CABEÇALHO DO HUD
              // CABEÇALHO DO HUD
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "HUD (${_activeGaugesPids.length}/12)",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    Row(
                      children: [
                        // NOVO: BOTÃO DE ADICIONAR/REMOVER RELÓGIOS
                        IconButton.filledTonal(
                          onPressed: () {
                            // Lógica para abrir a tela de escolha de PIDs entra aqui!
                          },
                          icon: const Icon(Icons.edit_attributes),
                          color: Colors.blueAccent,
                          tooltip: 'Adicionar Sensores',
                        ),
                        const SizedBox(width: 12),

                        // SELETOR DE ESTILO COM 3 OPÇÕES
                        SegmentedButton<GaugeStyle>(
                          segments: const [
                            ButtonSegment(
                              value: GaugeStyle.digital,
                              icon: Icon(Icons.speed, size: 18),
                            ),
                            ButtonSegment(
                              value: GaugeStyle.analog,
                              icon: Icon(Icons.av_timer, size: 18),
                            ),
                            ButtonSegment(
                              value: GaugeStyle.lineChart,
                              icon: Icon(Icons.show_chart, size: 18),
                            ),
                          ],
                          selected: {_currentStyle},
                          onSelectionChanged: (Set<GaugeStyle> newSelection) {
                            setState(() => _currentStyle = newSelection.first);
                          },
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            selectedForegroundColor: Colors.white,
                            selectedBackgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ÁREA DOS RELÓGIOS (NUNCA ROLA A TELA)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // BLOQUEIA O SCROLL
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          childAspectRatio, // Força os itens a caberem na tela
                    ),
                    itemCount: _activeGaugesPids.length,
                    itemBuilder: (context, index) {
                      final pidCode = _activeGaugesPids[index];
                      final pid = pidRegistry[pidCode]!;
                      return ObdGauge(pid: pid, style: _currentStyle);
                    },
                  ),
                ),
              ),

              // RESERVA DE ESPAÇO PARA O BANNER DE ANÚNCIO (Fixo no rodapé)
              Container(
                width: double.infinity,
                height: 60,
                margin: const EdgeInsets.only(top: 8),
                color: Colors.black, // Placeholder visual do Ad
                child: const Center(
                  child: Text(
                    "ESPAÇO RESERVADO PARA ADMOB",
                    style: TextStyle(color: Colors.white38, letterSpacing: 2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
