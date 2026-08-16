// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'Sensores';

  @override
  String get tabHud => 'Panel';

  @override
  String get tabTests => 'Pruebas';

  @override
  String get tabFaults => 'Fallas';

  @override
  String get tabMore => 'Más';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnSend => 'Enviar';

  @override
  String get btnRefresh => 'Actualizar';

  @override
  String get connTitle => 'Conectar al Escáner';

  @override
  String get connPaired => 'Dispositivos Emparejados';

  @override
  String get connNearby => 'Dispositivos Cercanos';

  @override
  String get connNoDevices => 'No se encontraron dispositivos.';

  @override
  String get connSearching => 'Buscando...';

  @override
  String get connSearchNew => 'Buscar Nuevos Dispositivos';

  @override
  String get connEstablishing => 'Estableciendo conexión segura...';

  @override
  String get connWaitKey => 'Gire la llave de encendido para activar el panel.';

  @override
  String get connMapping => 'Mapeando sensores compatibles...';

  @override
  String get connSuccess => '¡Conexión Exitosa!';

  @override
  String get sensTitle => 'Sensores Mapeados';

  @override
  String get sensNone => 'No se encontraron sensores.';

  @override
  String get sensInstant => 'Valor Instantáneo';

  @override
  String get sensRecent => 'Comportamiento Reciente';

  @override
  String get sensReading => 'Leyendo datos del bus CAN...';

  @override
  String get sensNoHistory => 'El historial no aplica para estado de texto.';

  @override
  String get hudManage => 'Administrar Sensores';

  @override
  String get hudFullscreen => 'Pantalla Completa';

  @override
  String get hudImmersive => 'Modo Inmersivo';

  @override
  String get hudImmersiveDesc =>
      'Toque dos veces la pantalla para entrar o salir de Pantalla Completa.';

  @override
  String get hudGotIt => 'Entendido';

  @override
  String get hudConfig => 'Configurar Panel';

  @override
  String get hudSelected => 'Sensores Seleccionados';

  @override
  String get hudAvailable => 'DISPONIBLES';

  @override
  String get hudSearch => 'Buscar sensor...';

  @override
  String get testTitle => 'Resultados de pruebas ECU';

  @override
  String get testConsulting =>
      'Consultando monitores y límites de pruebas...\nPor favor, espere.';

  @override
  String get testNone => 'No se encontraron pruebas internas.';

  @override
  String get testWaiting => 'Esperando Ciclo de Conducción';

  @override
  String get testPassed => 'Aprobado';

  @override
  String get testFailed => 'Límite Fallido';

  @override
  String get faultTitle => 'Diagnóstico (DTC)';

  @override
  String get faultClearMil => '¿Borrar luz del motor (MIL)?';

  @override
  String get faultClearDesc =>
      'Esta acción borrará la memoria de fallas y el Freeze Frame. Asegúrese de que la IGNICIÓN esté encendida y el MOTOR APAGADO.';

  @override
  String get faultYesClear => '¡Sí, borrar!';

  @override
  String get faultAll => 'Todas';

  @override
  String get faultConfirmed => 'Confirmadas';

  @override
  String get faultPending => 'Pendientes';

  @override
  String get faultPermanent => 'Permanentes';

  @override
  String get faultReading =>
      'Leyendo memoria de la ECU y datos congelados...\nPor favor, espere.';

  @override
  String get faultNone => '¡No se encontraron fallas!';

  @override
  String get infoTitle => 'Información del Vehículo';

  @override
  String get infoConsulting =>
      'Consultando módulos y calibraciones de la ECU...\nPor favor, espere.';

  @override
  String get infoNone =>
      'No se encontró información.\nEl vehículo podría no soportar el Modo 09.';

  @override
  String get setTitle => 'Configuración del Sistema';

  @override
  String get setColor => 'Paleta de Colores';

  @override
  String get setThemeLight => 'Tema Claro';

  @override
  String get setThemeDark => 'Tema Oscuro';

  @override
  String get setMainColor => 'Color Principal (Tema/Neutros)';

  @override
  String get setNormalColor => 'Estado Normal (Saludable)';

  @override
  String get setWarningColor => 'Estado de Advertencia (Alerta)';

  @override
  String get setCriticalColor => 'Estado Crítico (Peligro)';

  @override
  String get setRestoreColors => 'Restaurar Colores Predeterminados';

  @override
  String get setPerf => 'Rendimiento y Batería';

  @override
  String get setRate => 'Tasa de actualización de sensores';

  @override
  String get setRateDesc => 'Aumente el tiempo si el teléfono se calienta';

  @override
  String get setRateMax => 'Máxima';

  @override
  String get setRateFast => 'Rápido';

  @override
  String get setRateNormal => 'Normal';

  @override
  String get setRateEco => 'Económico';

  @override
  String get dbgTitle => 'Terminal de Diagnóstico';

  @override
  String get dbgHeader => 'Header';

  @override
  String get dbgCommand => 'Comando (PID/AT)';

  @override
  String get dbgFormula => 'Fórmula Personalizada';

  @override
  String get dbgStop => 'Detener Búsqueda';

  @override
  String get dbgScan => 'Búsqueda Fuerza Bruta';

  @override
  String get dbgClear => 'Limpiar Terminal';

  @override
  String get dbgExport => 'Exportar Registros';

  @override
  String get dbgEmpty => 'El terminal está vacío. Nada que exportar.';

  @override
  String get dbgSaved => 'Archivo guardado exitosamente en:';

  @override
  String connSensorsMapped(int count) {
    return '$count sensores mapeados';
  }

  @override
  String get connSnackSavedNotFound =>
      'No se encontró el escáner guardado. Seleccione de la lista.';

  @override
  String get connSnackConnFailed =>
      'Fallo al conectar. Intente reiniciar el Bluetooth.';

  @override
  String get themeSystemTooltip => 'Tema: Sistema';

  @override
  String get themeLightTooltip => 'Tema: Claro';

  @override
  String get themeDarkTooltip => 'Tema: Oscuro';

  @override
  String get statusDisconnected => 'Desconectado';

  @override
  String get statusConnected => 'ECU en línea';

  @override
  String get statusHibernating => 'ECU Hibernando (Ignición apagada)';

  @override
  String get btnDisconnect => 'Desconectar';

  @override
  String get moreMenuTitle => 'Más Opciones';

  @override
  String get moreDiagSection => 'DIAGNÓSTICO AVANZADO';

  @override
  String get moreInfoDesc => 'VIN, CVN, Monitores Modo 09';

  @override
  String get moreTerminalDesc => 'Enviar PIDs manuales y comandos AT';

  @override
  String get moreAppSection => 'APLICACIÓN';

  @override
  String get moreSettings => 'Ajustes';

  @override
  String get moreSettingsDesc => 'Conexión, Protocolos y Preferencias';

  @override
  String setChooseColor(String colorName) {
    return 'Elegir color: $colorName';
  }

  @override
  String get btnApply => 'Aplicar';

  @override
  String get testValue => 'Valor';

  @override
  String get testMin => 'Mín';

  @override
  String get testMax => 'Máx';

  @override
  String get sensWaitGraph => '(Espere a que se llene el gráfico)';

  @override
  String get faultDetailsTitle => 'Detalles de la Falla';

  @override
  String get faultDescConfirmed =>
      'Enciende la luz del motor. El problema está ocurriendo o acaba de ocurrir.';

  @override
  String get faultDescPending =>
      'La ECU detectó una anomalía, pero necesita más ciclos para confirmar.';

  @override
  String get faultDescPermanent =>
      'Falla grave. Solo se borra después de reparar y conducir el vehículo.';

  @override
  String get faultFreezeFrameTitle => 'Datos Congelados (Freeze Frame):';

  @override
  String dbgExportError(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get dbgScanTitle => 'Búsqueda de PIDs (Fuerza Bruta)';

  @override
  String get dbgScanHeaderHint => 'Header (Opcional, ej: 7E0)';

  @override
  String get dbgScanPrefixHint => 'Modo/Prefijo (ej: 22)';

  @override
  String get dbgScanStartHint => 'Inicio Hex (ej: 1100)';

  @override
  String get dbgScanEndHint => 'Fin Hex (ej: 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ Atención: La búsqueda enviará solicitudes secuenciales continuas. Rangos grandes pueden tardar varios minutos.';

  @override
  String get btnStart => 'Iniciar';

  @override
  String get dbgErrorBounds => 'El inicio es mayor que el fin';

  @override
  String dbgScanStarting(String start, String end) {
    return 'Iniciando búsqueda de $start hasta $end...';
  }

  @override
  String get dbgErrorHex =>
      '¡Error en los parámetros hexadecimales! Verifique su entrada.';

  @override
  String get dbgScanComplete => '¡Búsqueda completada!';

  @override
  String dbgFormulaResult(String result) {
    return 'Resultado (Fórmula): $result';
  }

  @override
  String get dbgFormulaError =>
      'Error: Fallo al interpretar la fórmula. Verifique la sintaxis.';

  @override
  String get dbgScanCancelled => 'Búsqueda cancelada por el usuario.';

  @override
  String get techLibTitle => 'Biblioteca Técnica';

  @override
  String get techHowItWorks => '¿Cómo funciona este sensor?';

  @override
  String get techWhatIsIt => '¿Qué es?';

  @override
  String get techFunction => 'Función';

  @override
  String get techImpact => 'Impacto en el Sistema';

  @override
  String get dtcSymptoms => 'Síntomas Comunes';

  @override
  String get dtcCauses => 'Posibles Causas';

  @override
  String get dtcResolution => 'Cómo Probar y Resolver';
}
