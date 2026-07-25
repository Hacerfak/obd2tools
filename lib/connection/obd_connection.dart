import 'dart:async';
import 'dart:convert';
import 'package:flutter_classic_bluetooth/flutter_classic_bluetooth.dart';

class ObdConnection {
  final _bluetooth = FlutterClassicBluetooth();

  // Classe correta fornecida pelo pacote
  BtcConnection? _activeConnection;

  final _dataStreamController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStreamController.stream;

  StreamSubscription? _dataSubscription;

  /// Conecta ao scanner usando o endereço MAC
  Future<bool> connect(String macAddress) async {
    try {
      // Conecta usando o parâmetro nomeado correto
      _activeConnection = await _bluetooth.connect(address: macAddress);

      // Lê os dados a partir do getter 'input'
      _dataSubscription = _activeConnection!.input.listen((data) {
        // O input retorna um Uint8List, então fazemos o decode para texto
        String decodedText = ascii.decode(data);
        _dataStreamController.add(decodedText);
      });

      return true;
    } catch (e) {
      print('Erro ao conectar na Montana: $e');
      return false;
    }
  }

  /// Envia comandos AT para o chip ou PIDs para a ECU
  void sendCommand(String command) async {
    if (_activeConnection == null) return;

    try {
      // O ELM327 exige que todo comando termine com Carriage Return (\r)
      String fullCommand = "$command\r";

      // Usamos a propriedade 'output' e o método facilitador 'writeString'
      await _activeConnection!.output.writeString(fullCommand);
    } catch (e) {
      print('Erro ao enviar comando: $e');
    }
  }

  /// Encerra a comunicação
  Future<void> disconnect() async {
    await _dataSubscription?.cancel();

    if (_activeConnection != null) {
      // O método finish() aguarda envios pendentes antes de desconectar
      await _activeConnection!.finish();
      // O método dispose() limpa a memória da conexão
      _activeConnection!.dispose();
      _activeConnection = null;
    }
  }
}
