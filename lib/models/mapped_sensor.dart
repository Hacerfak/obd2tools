import '../parser/obd_pid.dart';
import 'ecu_module.dart';

class MappedSensor {
  final ObdPid pid;
  final EcuModule module;

  MappedSensor({required this.pid, required this.module});

  // Chave única para salvar estado e preferências (Ex: "0C_7E0")
  String get uniqueId =>
      "${pid.id.toRadixString(16).padLeft(2, '0').toUpperCase()}_${module.txHeader}";

  // Nome amigável para a Interface do Usuário
  String get displayName => "${pid.name} (${module.name})";
}
