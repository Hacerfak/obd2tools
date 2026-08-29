import '../models/protocol_profile.dart';
import '../models/ecu_module.dart';

class ObdParser {
  // Pré-compilados para máxima performance
  static final RegExp _canPrefixRegex = RegExp(r'^[0-9A-F]{3}\s');
  static final RegExp _frameHeaderRegex = RegExp(r'\s?[0-9A-F]:');
  static final RegExp _nonHexRegex = RegExp(r'[^0-9A-Fa-f]');

  /// Sanitiza e extrai apenas o payload válido com base no protocolo físico
  static String cleanRawResponse(String rawData, ProtocolProfile profile) {
    String clean = rawData.replaceAll("SEARCHING...", "").trim();

    if (clean.contains("NO DATA") || clean.contains("ERROR")) {
      return "";
    }

    // 1. RECONSTRUTOR DE PACOTES CAN MULTI-FRAME (Montana, Kicks)
    // OBRIGATÓRIO RODAR AQUI: Remove os "0: ", "1: " ANTES de tirar os espaços
    // para não causar deslocamento (shift) nos bytes hexadecimais.
    if (clean.contains("0:")) {
      clean = clean.replaceAll(_canPrefixRegex, '');
      clean = clean.replaceAll(_frameHeaderRegex, '');
    }

    // 2. Limpeza brutal: tira espaços, \n, e qualquer lixo não-hexadecimal (Comum na Linha K)
    clean = clean.replaceAll(_nonHexRegex, '').toUpperCase();

    if (clean.isEmpty) return "";

    // 3. PROTEÇÃO CELTA (K-Line): Ignora respostas negativas explícitas (NRC 7F)
    if (clean.startsWith("7F")) return "";

    // 4. Remove padding do CAN Bus (AA AA ou 00 00 no final)
    while (clean.endsWith("AA") && clean.length > 4) {
      clean = clean.substring(0, clean.length - 2);
    }
    while (clean.endsWith("00000000") && clean.length > 8) {
      clean = clean.substring(0, clean.length - 2);
    }

    // 5. PROTEÇÃO DE RUÍDO (Celta): Garante que a string que vamos processar
    // começa estritamente com um cabeçalho de resposta OBD válido.
    final match = RegExp(
      r'(41|42|43|44|46|47|49|4A)[0-9A-F]*',
    ).firstMatch(clean);

    if (match != null) {
      return match.group(0)!;
    }

    return "";
  }

  /// Extrai os módulos ECU que responderam ao comando '0100' com AT H1 ligado (Identifica Motor, Câmbio, etc)
  static List<EcuModule> discoverEcusFromH1(
    String rawData,
    ProtocolProfile profile,
  ) {
    // Se o protocolo não suporta cabeçalhos ou não tem tamanho definido, assume Módulo Padrão (Motor)
    if (!profile.supportsCanHeaders || profile.headerLength == 0) {
      return [EcuModule.defaultEcu()];
    }

    Set<String> headers = {};

    // Divide as respostas do ELM327 por linha
    final lines = rawData
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.replaceAll(' ', '').toUpperCase());

    for (var line in lines) {
      int hl = profile.headerLength;

      // Exemplo de linha CAN 11-bit com AT H1 ativo: "7E8064100BE1FB813"
      // Se a linha for grande o suficiente e o payload (após o cabeçalho) for uma resposta ao PID 00 ("4100")
      if (line.length > hl + 4 && line.substring(hl).contains("4100")) {
        // Captura apenas o cabeçalho (Ex: "7E8" ou "7E9")
        headers.add(line.substring(0, hl));
      }
    }

    // Se não conseguiu extrair ninguém válido, garante ao menos o módulo do motor
    if (headers.isEmpty) return [EcuModule.defaultEcu()];

    // Converte os cabeçalhos de texto em objetos EcuModule estruturados
    return headers.map((h) => EcuModule.fromRxHeader(h)).toList();
  }
}
