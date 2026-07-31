import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_classic_bluetooth/flutter_classic_bluetooth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class ObdConnection {
  final _bluetooth = FlutterClassicBluetooth();
  BtcConnection? _activeConnection;

  final _dataStreamController = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStreamController.stream;

  StreamSubscription? _dataSubscription;

  // --- BUSCA DE PAREADOS ---
  Future<List<Map<String, String>>> getPairedDevices() async {
    List<Map<String, String>> deviceList = [];
    bool hasPermission = true;

    // Só pede permissão de tela se for Android ou iOS
    if (Platform.isAndroid || Platform.isIOS) {
      hasPermission = await Permission.bluetoothConnect.request().isGranted;
    }

    if (hasPermission) {
      try {
        final paired = await _bluetooth.getPairedDevices();
        for (var device in paired) {
          deviceList.add({
            "name": device.name ?? "Dispositivo Desconhecido",
            "mac": device.address,
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Erro ao buscar dispositivos pareados: $e");
        }
      }
    }
    return deviceList;
  }

  // --- BUSCA DE NÃO PAREADOS (DISCOVERY) ---
  Stream<Map<String, String>> startDiscovery() async* {
    bool hasPermission = true;

    if (Platform.isAndroid || Platform.isIOS) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      hasPermission =
          statuses[Permission.bluetoothScan]!.isGranted &&
          statuses[Permission.location]!.isGranted;
    }

    if (hasPermission) {
      try {
        await _bluetooth.startDiscovery();

        await for (var device in _bluetooth.discoveryResults) {
          yield {
            "name": device.name ?? "Aparelho sem nome",
            "mac": device.address,
          };
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Erro ao escanear novos dispositivos: $e");
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          "Permissões de localização/scan negadas pelo usuário no mobile.",
        );
      }
    }
  }

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
      if (kDebugMode) {
        debugPrint('Erro ao conectar ao veículo: $e');
      }
      return false;
    }
  }

  /// Envia comandos AT para o chip ou PIDs para a ECU
  void sendCommand(String command) async {
    if (_activeConnection == null) return;

    //print("=== Command: '$command' ===");

    try {
      // O ELM327 exige que todo comando termine com Carriage Return (\r)
      String fullCommand = "$command\r";

      // Usamos a propriedade 'output' e o método facilitador 'writeString'
      await _activeConnection!.output.writeString(fullCommand);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao enviar comando: $e');
      }
    }
  }

  /// Encerra a comunicação de forma segura
  Future<void> disconnect() async {
    try {
      await _dataSubscription?.cancel();
      if (_activeConnection != null) {
        await _activeConnection!.finish();
        _activeConnection!.dispose();
        _activeConnection = null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Aviso ao desconectar (ignorado): $e');
      }
    }
  }

  Future<void> stopScan() async {
    try {
      await _bluetooth.stopDiscovery();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Aviso ao parar scan: $e");
      }
    }
  }
}
