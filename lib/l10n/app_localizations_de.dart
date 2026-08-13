// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'Sensoren';

  @override
  String get tabHud => 'Armaturenbrett';

  @override
  String get tabTests => 'Tests';

  @override
  String get tabFaults => 'Fehler';

  @override
  String get tabMore => 'Mehr';

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get btnSave => 'Speichern';

  @override
  String get btnSend => 'Senden';

  @override
  String get btnRefresh => 'Aktualisieren';

  @override
  String get connTitle => 'Mit Scanner verbinden';

  @override
  String get connPaired => 'Gekoppelte Geräte';

  @override
  String get connNearby => 'Geräte in der Nähe';

  @override
  String get connNoDevices => 'Keine Geräte gefunden.';

  @override
  String get connSearching => 'Suchen...';

  @override
  String get connSearchNew => 'Neue Geräte Suchen';

  @override
  String get connEstablishing => 'Sichere Verbindung wird hergestellt...';

  @override
  String get connWaitKey =>
      'Zündung einschalten, um das Armaturenbrett mit Strom zu versorgen.';

  @override
  String get connMapping => 'Unterstützte Sensoren werden abgebildet...';

  @override
  String get connSuccess => 'Verbindung Erfolgreich!';

  @override
  String get sensTitle => 'Zugeordnete Sensoren';

  @override
  String get sensNone => 'Keine Sensoren gefunden.';

  @override
  String get sensInstant => 'Momentanwert';

  @override
  String get sensRecent => 'Kürzliches Verhalten';

  @override
  String get sensReading => 'Lese CAN-Bus Daten...';

  @override
  String get sensNoHistory => 'Verlauf gilt nicht für Textstatus.';

  @override
  String get hudManage => 'Sensoren Verwalten';

  @override
  String get hudFullscreen => 'Vollbild';

  @override
  String get hudImmersive => 'Immersiver Modus';

  @override
  String get hudImmersiveDesc =>
      'Tippen Sie zweimal auf den Bildschirm, um das Vollbild zu aktivieren/deaktivieren.';

  @override
  String get hudGotIt => 'Verstanden';

  @override
  String get hudConfig => 'Armaturenbrett konfigurieren';

  @override
  String get hudSelected => 'Ausgewählte Sensoren';

  @override
  String get hudAvailable => 'VERFÜGBAR';

  @override
  String get hudSearch => 'Sensor suchen...';

  @override
  String get testTitle => 'ECU Testergebnisse';

  @override
  String get testConsulting =>
      'Frage Monitore und Testgrenzen ab...\nBitte warten.';

  @override
  String get testNone => 'Keine internen Tests gefunden.';

  @override
  String get testWaiting => 'Warte auf Fahrzyklus';

  @override
  String get testPassed => 'Bestanden';

  @override
  String get testFailed => 'Grenzwert überschritten';

  @override
  String get faultTitle => 'Diagnose (DTC)';

  @override
  String get faultClearMil => 'Motorkontrollleuchte (MIL) löschen?';

  @override
  String get faultClearDesc =>
      'Diese Aktion setzt den Fehlerspeicher und den Freeze Frame zurück. Stellen Sie sicher, dass die ZÜNDUNG EIN und der MOTOR AUS ist.';

  @override
  String get faultYesClear => 'Ja, löschen!';

  @override
  String get faultAll => 'Alle';

  @override
  String get faultConfirmed => 'Bestätigt';

  @override
  String get faultPending => 'Ausstehend';

  @override
  String get faultPermanent => 'Permanent';

  @override
  String get faultReading =>
      'Lese ECU-Speicher und Freeze Frames...\nBitte warten.';

  @override
  String get faultNone => 'Keine Fehler gefunden!';

  @override
  String get infoTitle => 'Fahrzeuginformationen';

  @override
  String get infoConsulting =>
      'Frage ECU-Module und Kalibrierungen ab...\nBitte warten.';

  @override
  String get infoNone =>
      'Keine Informationen gefunden.\nDas Fahrzeug unterstützt möglicherweise Modus 09 nicht.';

  @override
  String get setTitle => 'Systemeinstellungen';

  @override
  String get setColor => 'Farbpalette';

  @override
  String get setThemeLight => 'Helles Design';

  @override
  String get setThemeDark => 'Dunkles Design';

  @override
  String get setMainColor => 'Hauptfarbe (Design/Neutrale)';

  @override
  String get setNormalColor => 'Normaler Status (Gesund)';

  @override
  String get setWarningColor => 'Warnstatus (Alarm)';

  @override
  String get setCriticalColor => 'Kritischer Status (Gefahr)';

  @override
  String get setRestoreColors => 'Standardfarben wiederherstellen';

  @override
  String get setPerf => 'Leistung und Batterie';

  @override
  String get setRate => 'Aktualisierungsrate der Sensoren';

  @override
  String get setRateDesc => 'Erhöhen Sie die Zeit, wenn das Telefon heiß wird';

  @override
  String get setRateMax => 'Maximal';

  @override
  String get setRateFast => 'Schnell (250ms)';

  @override
  String get setRateNormal => 'Normal (0.5s)';

  @override
  String get setRateEco => 'Öko (1s)';

  @override
  String get dbgTitle => 'Diagnose-Terminal';

  @override
  String get dbgHeader => 'Header (Opt)';

  @override
  String get dbgCommand => 'Befehl (PID/AT)';

  @override
  String get dbgFormula => 'Eigene Formel';

  @override
  String get dbgStop => 'Scan stoppen';

  @override
  String get dbgScan => 'Brute-Force Scan';

  @override
  String get dbgClear => 'Terminal leeren';

  @override
  String get dbgExport => 'Protokolle exportieren';

  @override
  String get dbgEmpty => 'Das Terminal ist leer. Nichts zu exportieren.';

  @override
  String get dbgSaved => 'Datei erfolgreich gespeichert unter:';
}
