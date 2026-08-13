import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../state/obd_providers.dart';

class DebugConsoleScreen extends ConsumerStatefulWidget {
  const DebugConsoleScreen({super.key});

  @override
  ConsumerState<DebugConsoleScreen> createState() => _DebugConsoleScreenState();
}

class _DebugConsoleScreenState extends ConsumerState<DebugConsoleScreen> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _formulaController = TextEditingController();

  final List<String> _consoleLogs = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _rawSubscription;

  // --- VARIÁVEIS DA VARREDURA FORÇA BRUTA ---
  bool _isScanning = false;
  int _scanStart = 0;
  int _scanCurrent = 0;
  int _scanEnd = 0;
  String _scanPrefix = "22";
  String _scanHeader = "";

  @override
  void initState() {
    super.initState();

    // Assume o controle da comunicação e limpa a fila do painel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(obdManagerProvider).setPollingPids([]);
    });

    _rawSubscription = ref.read(obdManagerProvider).logStream.listen((data) {
      _processResponse(data);
    });
  }

  @override
  void dispose() {
    _rawSubscription?.cancel();
    _headerController.dispose();
    _commandController.dispose();
    _formulaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _printToConsole(
    String text, {
    bool isCommand = false,
    bool isSuccess = false,
  }) {
    setState(() {
      if (isSuccess) {
        _consoleLogs.add("[OK] $text");
      } else {
        final prefix = isCommand ? ">> " : "<< ";
        _consoleLogs.add("$prefix$text");
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendCommand() {
    if (_isScanning) return; // Bloqueia envio manual durante a varredura

    final obdManager = ref.read(obdManagerProvider);
    final header = _headerController.text.trim().toUpperCase();
    final command = _commandController.text.trim().toUpperCase();

    if (command.isEmpty) return;

    if (header.isNotEmpty) {
      _printToConsole("AT SH $header", isCommand: true);
      obdManager.sendCustomCommand("AT SH $header");
    }

    _printToConsole(command, isCommand: true);
    obdManager.sendCustomCommand(command);
  }

  // --- EXPORTAR LOGS PARA ARQUIVO TXT ---
  Future<void> _exportLogs() async {
    if (_consoleLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O terminal está vazio. Nada para exportar."),
        ),
      );
      return;
    }

    try {
      final text = _consoleLogs.join('\n');

      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/obd2_terminal_log.txt');
        await file.writeAsString(text);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Logs do Terminal OBD2 Tools');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/obd2_terminal_log.txt');
        await file.writeAsString(text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Arquivo salvo com sucesso em:\n${file.path}"),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao exportar: $e")));
      }
    }
  }

  // --- LÓGICA DA VARREDURA FORÇA BRUTA ---
  void _showScanDialog() {
    final headerCtrl = TextEditingController(text: _headerController.text);
    final prefixCtrl = TextEditingController(text: "22");
    final startCtrl = TextEditingController(text: "1100");
    final endCtrl = TextEditingController(text: "11FF");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Varredura de PIDs (Força Bruta)"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: headerCtrl,
                decoration: const InputDecoration(
                  labelText: "Header (Opcional, ex: 7E0)",
                ),
              ),
              TextField(
                controller: prefixCtrl,
                decoration: const InputDecoration(
                  labelText: "Modo/Prefixo (ex: 22)",
                ),
              ),
              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(
                  labelText: "Início Hex (ex: 1100)",
                ),
              ),
              TextField(
                controller: endCtrl,
                decoration: const InputDecoration(
                  labelText: "Fim Hex (ex: 11FF)",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "⚠️ Atenção: A varredura enviará requisições sequenciais contínuas. Faixas muito grandes podem demorar vários minutos.",
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _startScan(
                headerCtrl.text,
                prefixCtrl.text,
                startCtrl.text,
                endCtrl.text,
              );
            },
            child: const Text("Iniciar"),
          ),
        ],
      ),
    );
  }

  void _startScan(
    String header,
    String prefix,
    String startHex,
    String endHex,
  ) {
    try {
      _scanHeader = header.trim().toUpperCase();
      _scanPrefix = prefix.trim().toUpperCase();
      _scanStart = int.parse(startHex.trim(), radix: 16);
      _scanCurrent = _scanStart;
      _scanEnd = int.parse(endHex.trim(), radix: 16);

      if (_scanCurrent > _scanEnd) throw Exception("Início maior que o fim");

      setState(() {
        _isScanning = true;
        _consoleLogs.clear();
      });

      _printToConsole(
        "Iniciando varredura de $_scanPrefix${startHex.toUpperCase()} até $_scanPrefix${endHex.toUpperCase()}...",
        isSuccess: true,
      );

      if (_scanHeader.isNotEmpty) {
        ref.read(obdManagerProvider).sendCustomCommand("AT SH $_scanHeader");
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_isScanning) _sendNextScanCommand();
        });
      } else {
        _sendNextScanCommand();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Erro nos parâmetros hexadecimais! Verifique a digitação.",
          ),
        ),
      );
    }
  }

  void _sendNextScanCommand() {
    if (!_isScanning) return;

    if (_scanCurrent > _scanEnd) {
      setState(() => _isScanning = false);
      _printToConsole("Varredura Concluída!", isSuccess: true);
      return;
    }

    String hexSuffix = _scanCurrent
        .toRadixString(16)
        .padLeft(4, '0')
        .toUpperCase();
    String command = "$_scanPrefix$hexSuffix";

    ref.read(obdManagerProvider).sendCustomCommand(command);
  }

  // --- PROCESSAMENTO DE RESPOSTA ---
  void _processResponse(String response) {
    if (_isScanning) {
      String cleanHex = response.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

      if (!response.contains("NO DATA") &&
          !response.contains("ERROR") &&
          !cleanHex.startsWith("7F")) {
        _printToConsole(response, isSuccess: true);
      }

      // IMPORTANTE: Atualiza o estado para a barra de progresso andar!
      setState(() {
        _scanCurrent++;
      });

      Future.delayed(const Duration(milliseconds: 50), () {
        if (_isScanning) _sendNextScanCommand();
      });
      return;
    }

    _printToConsole(response);

    final formula = _formulaController.text.trim().toUpperCase();
    if (formula.isEmpty ||
        response.contains("NO DATA") ||
        response.contains("ERROR")) {
      return;
    }

    String cleanHex = response.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

    int headerLength = 4;
    if (cleanHex.startsWith("62") ||
        cleanHex.startsWith("49") ||
        cleanHex.startsWith("42")) {
      headerLength = 6;
    }

    if (cleanHex.length > headerLength) {
      String dataHex = cleanHex.substring(headerLength);
      try {
        Parser p = Parser();
        Expression exp = p.parse(formula);
        ContextModel cm = ContextModel();

        List<String> variableNames = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

        for (var v in variableNames) {
          cm.bindVariable(Variable(v), Number(0.0));
        }

        int byteIndex = 0;
        for (
          int i = 0;
          i < dataHex.length && byteIndex < variableNames.length;
          i += 2
        ) {
          if (i + 2 <= dataHex.length) {
            String byteStr = dataHex.substring(i, i + 2);
            double byteValue = int.parse(byteStr, radix: 16).toDouble();
            cm.bindVariable(
              Variable(variableNames[byteIndex]),
              Number(byteValue),
            );
            byteIndex++;
          }
        }

        double result = exp.evaluate(EvaluationType.REAL, cm);

        String formattedResult = result == result.truncateToDouble()
            ? result.toInt().toString()
            : result.toStringAsFixed(2);

        _printToConsole(
          "Resultado (Fórmula): $formattedResult",
          isSuccess: true,
        );
      } catch (e) {
        _printToConsole(
          "Erro: Falha ao interpretar a fórmula. Verifique a sintaxe.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    // Calcula o progresso dinamicamente
    double progress = 0.0;
    if (_isScanning && _scanEnd > _scanStart) {
      progress = (_scanCurrent - _scanStart) / (_scanEnd - _scanStart);
      progress = progress.clamp(0.0, 1.0);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terminal de Diagnóstico",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 0,
              color: colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _headerController,
                            enabled: !_isScanning,
                            decoration: InputDecoration(
                              labelText: "Header (Opc)",
                              hintText: "7E0",
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _commandController,
                            enabled: !_isScanning,
                            decoration: InputDecoration(
                              labelText: "Comando (PID/AT)",
                              hintText: "2211A1",
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _formulaController,
                            enabled: !_isScanning,
                            decoration: InputDecoration(
                              labelText: "Fórmula Customizada",
                              hintText: "Ex: (A*256+B)/10",
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        if (_isScanning)
                          IconButton.filledTonal(
                            onPressed: () {
                              setState(() => _isScanning = false);
                              _printToConsole(
                                "Varredura cancelada pelo usuário.",
                                isSuccess: true,
                              );
                            },
                            icon: const Icon(Icons.stop),
                            tooltip: "Parar Varredura",
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.redAccent,
                            ),
                          )
                        else
                          IconButton.filledTonal(
                            icon: const Icon(Icons.radar),
                            tooltip: "Varredura Força Bruta",
                            onPressed: _showScanDialog,
                          ),
                        const SizedBox(width: 8),

                        // Botão desabilitado se estiver escaneando
                        IconButton.filledTonal(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: "Limpar Terminal",
                          onPressed: _isScanning
                              ? null
                              : () => setState(() => _consoleLogs.clear()),
                        ),
                        const SizedBox(width: 8),

                        // Botão desabilitado se estiver escaneando
                        IconButton.filledTonal(
                          icon: const Icon(Icons.save_alt),
                          tooltip: "Exportar Logs",
                          onPressed: _isScanning ? null : _exportLogs,
                        ),
                        const SizedBox(width: 16),

                        FilledButton.icon(
                          onPressed: _isScanning ? null : _sendCommand,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text("Enviar"),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // BARRA DE PROGRESSO VISÍVEL APENAS DURANTE O SCAN
                    if (_isScanning) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: onSurface.withValues(
                                  alpha: 0.1,
                                ),
                                color: Colors.amberAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${(progress * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _consoleLogs.length,
                  itemBuilder: (context, index) {
                    final log = _consoleLogs[index];
                    final isCommand = log.startsWith(">>");
                    final isSuccess = log.startsWith("[OK]");

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isCommand
                              ? Colors.tealAccent
                              : (isSuccess
                                    ? Colors.amberAccent
                                    : Colors.grey[400]),
                          fontSize: 14,
                          fontWeight: isSuccess
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
