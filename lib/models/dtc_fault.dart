import '../parser/parsers/mode_01_parser.dart'; // Para importar o ObdReadResult

enum DtcStatus {
  confirmed, // Modo 03 - Acende a luz
  pending, // Modo 07 - A ECU está desconfiada, mas não acendeu a luz
  permanent, // Modo 0A - Falha grave que não apaga com scanner
}

class DtcFault {
  final String code;
  final Set<DtcStatus>
  statuses; // Um erro pode ser "Confirmado" e "Permanente" ao mesmo tempo
  Map<String, ObdReadResult> freezeFrame;

  DtcFault({
    required this.code,
    required this.statuses,
    this.freezeFrame = const {},
  });

  // Função para adicionar um novo status a uma falha já existente
  void addStatus(DtcStatus status) {
    statuses.add(status);
  }
}
