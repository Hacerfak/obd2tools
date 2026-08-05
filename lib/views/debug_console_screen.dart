import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
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

  @override
  void initState() {
    super.initState();

    // ASSUME O CONTROLE DA COMUNICAÇÃO
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

  void _printToConsole(String text, {bool isCommand = false}) {
    setState(() {
      final prefix = isCommand ? ">> " : "<< ";
      _consoleLogs.add("$prefix$text");
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

  void _processResponse(String response) {
    _printToConsole(response);

    final formula = _formulaController.text.trim().toUpperCase();
    if (formula.isEmpty ||
        response.contains("NO DATA") ||
        response.contains("ERROR")) {
      return;
    }

    String cleanHex = response.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

    // 1. TAMANHO DINÂMICO DO CABEÇALHO
    // Se for Modo 01 (41...), o cabeçalho tem 4 caracteres (ex: 4144)
    int headerLength = 4;
    // Se for Modo 22 (62...), Modo 09 (49...) ou Freeze Frame (42...), tem 6 caracteres
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

        // 2. BLINDAGEM: Inicializa todas as variáveis com 0.0
        // Se a fórmula pedir 'C' mas o carro só mandar A e B, o app calcula com C=0 em vez de crashar.
        for (var v in variableNames) {
          cm.bindVariable(Variable(v), Number(0.0));
        }

        int byteIndex = 0;
        // 3. ATRIBUI OS BYTES REAIS QUE O CARRO ENVIOU
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

        // Formata o resultado para ficar bonito (se for número inteiro, tira o .0)
        String formattedResult = result == result.truncateToDouble()
            ? result.toInt().toString()
            : result.toStringAsFixed(2);

        _printToConsole("Resultado (Fórmula): $formattedResult");
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

    return Scaffold(
      // Removemos a AppBar para seguir o padrão visual do restante do app[cite: 8]
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO NO PADRÃO DO SISTEMA
            Text(
              "Terminal de Diagnóstico",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // ÁREA DE CONTROLES (Estilo Cartão)
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
                        const SizedBox(width: 12),

                        // BOTÃO DE LIMPAR (LIXEIRA) ALINHADO[cite: 8]
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _consoleLogs.clear();
                            });
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text("Limpar"),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.redAccent.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // BOTÃO DE ENVIAR
                        FilledButton.icon(
                          onPressed: _sendCommand,
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TELA DO CONSOLE (Estilo Hacker/Terminal)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF0F172A,
                  ), // Fundo noturno profundo (estilo console)
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
                    final isResult = log.startsWith("<< Resultado");

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isCommand
                              ? Colors.tealAccent
                              : (isResult
                                    ? Colors.amberAccent
                                    : Colors.grey[300]),
                          fontSize: 14,
                          fontWeight: isResult
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
