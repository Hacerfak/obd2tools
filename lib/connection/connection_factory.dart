import 'dart:io';
import 'obd_connection.dart';

// Importações futuras das nossas implementações
// import 'android_obd_connection.dart';
// import 'desktop_obd_connection.dart';

class ConnectionFactory {
  static ObdConnection getConnection() {
    if (Platform.isAndroid) {
      // Retornaremos a implementação via flutter_bluetooth_serial
      throw UnimplementedError('Bluetooth do Android ainda não implementado');
    } else if (Platform.isLinux || Platform.isWindows) {
      // Retornaremos a implementação via flutter_libserialport
      throw UnimplementedError('Serial do Desktop ainda não implementado');
    } else {
      throw UnsupportedError('Plataforma não suportada para este scanner.');
    }
  }
}
