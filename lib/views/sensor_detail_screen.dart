import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../parser/obd_pid.dart';
import '../state/obd_providers.dart';
import '../connection/obd_manager.dart';

class SensorDetailScreen extends ConsumerStatefulWidget {
  final ObdPid pid;

  const SensorDetailScreen({super.key, required this.pid});

  @override
  ConsumerState<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends ConsumerState<SensorDetailScreen> {
  late final ObdManager _obdManager;

  @override
  void initState() {
    super.initState();
    _obdManager = ref.read(obdManagerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obdManager.setPollingPids([widget.pid.id]);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --- LIMITES FIXOS PARA O GRÁFICO PARAR DE PULAR ---
  List<double> _getFixedBounds(String unit) {
    if (unit == "RPM") return [0, 8000];
    if (unit == "km/h") return [0, 220];
    if (unit == "°C") return [-10, 130];
    if (unit == "%") return [0, 100];
    if (unit == "V") return [9, 16]; // Bateria do carro
    if (unit == "kPa") return [0, 255]; // Pressão
    if (unit == "g/s") return [0, 200]; // Fluxo de ar MAF
    if (unit == "°") return [-20, 60]; // Avanço de ignição
    if (unit == "λ" || unit == "Lambda") return [0, 2]; // Ar/Combustível
    if (unit == "Pa") return [-8192, 8192]; // Pressão Evaporativa
    return [0, 100]; // Padrão seguro
  }

  @override
  Widget build(BuildContext context) {
    final liveData = ref.watch(realTimeStateProvider);
    final sensorData = liveData[widget.pid.name];
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Busca os limites travados baseados na unidade do sensor!
    final bounds = _getFixedBounds(widget.pid.unit);
    final double minY = bounds[0];
    final double maxY = bounds[1];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.pid.name,
          style: TextStyle(fontSize: 18, color: onSurface),
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Valor Instantâneo",
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.54),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            // SE O SENSOR TIVER TRADUTOR (Ex: Malha Fechada)
            if (sensorData != null && widget.pid.formatValue != null)
              Text(
                widget.pid.formatValue!(sensorData.value),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              )
            // SE FOR UM SENSOR NUMÉRICO NORMAL (Ex: RPM, Temp)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    sensorData != null
                        ? sensorData.value.toStringAsFixed(
                            widget.pid.unit == "RPM" ? 0 : 1,
                          )
                        : "--",
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.pid.unit,
                    style: TextStyle(
                      fontSize: 24,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 48),

            // --- NOVA REGRA: MOSTRA O GRÁFICO SÓ SE TIVER UNIDADE ---
            if (widget.pid.unit.isNotEmpty) ...[
              Text(
                "Comportamento Recente",
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.54),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: (sensorData == null || sensorData.history.length < 2)
                    ? Center(
                        child: Text(
                          "Lendo dados do CAN Bus...\n(Aguarde o preenchimento do gráfico)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.38),
                          ),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minY: minY,
                          maxY: maxY,
                          minX: 0, // TRAVA O EIXO X
                          maxX: 29, // TRAVA O EIXO X
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: onSurface.withValues(alpha: 0.1),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: sensorData.history.asMap().entries.map((
                                e,
                              ) {
                                return FlSpot(e.key.toDouble(), e.value);
                              }).toList(),
                              isCurved: false,
                              color: Colors.blueAccent,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blueAccent.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ] else ...[
              // Para sensores estáticos/textuais, exibimos uma mensagem sutil no lugar do gráfico
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: onSurface.withValues(alpha: 0.05),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Histórico não aplicável para status em texto.",
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
