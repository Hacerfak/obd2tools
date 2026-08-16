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

  // NOVO: Callback para avisar o Manager que o Bluetooth caiu fisicamente
  VoidCallback? onDisconnected;

  // --- BUSCA DE PAREADOS ---
  Future<List<Map<String, String>>> getPairedDevices() async {
    List<Map<String, String>> deviceList = [];
    bool hasPermission = true;

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
        if (kDebugMode) debugPrint("Erro ao buscar dispositivos pareados: $e");
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
        if (kDebugMode) debugPrint("Erro ao escanear novos dispositivos: $e");
      }
    }
  }

  /// Conecta ao scanner usando o endereço MAC
  Future<bool> connect(String macAddress) async {
    try {
      _activeConnection = await _bluetooth.connect(address: macAddress);

      // NOVO: Escutando ativamente as quedas e erros!
      _dataSubscription = _activeConnection!.input.listen(
        (data) {
          String decodedText = ascii.decode(data);
          _dataStreamController.add(decodedText);
        },
        onDone: () {
          // O adaptador OBD2 foi desligado ou o Bluetooth do celular fechou
          if (kDebugMode) debugPrint("Conexão Bluetooth fechada (onDone).");
          onDisconnected?.call();
        },
        onError: (error) {
          // Perda de sinal, interferência grave, etc.
          if (kDebugMode) {
            debugPrint("Erro na conexão Bluetooth (onError): $error");
          }
          onDisconnected?.call();
        },
        cancelOnError: true,
      );

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao conectar ao veículo: $e');
      return false;
    }
  }

  /// Envia comandos AT para o chip ou PIDs para a ECU
  void sendCommand(String command) async {
    if (_activeConnection == null) return;
    try {
      String fullCommand = "$command\r";
      await _activeConnection!.output.writeString(fullCommand);
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao enviar comando: $e');
      // Se não conseguir enviar, também forçamos a queda
      onDisconnected?.call();
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
      if (kDebugMode) debugPrint('Aviso ao desconectar (ignorado): $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await _bluetooth.stopDiscovery();
    } catch (e) {
      if (kDebugMode) debugPrint("Aviso ao parar scan: $e");
    }
  }
}
