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
  String get setRateFast => 'Schnell';

  @override
  String get setRateNormal => 'Normal';

  @override
  String get setRateEco => 'Öko';

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

  @override
  String connSensorsMapped(int count) {
    return '$count zugeordnete Sensoren';
  }

  @override
  String get connSnackSavedNotFound =>
      'Gespeicherter Scanner nicht gefunden. Bitte aus der Liste auswählen.';

  @override
  String get connSnackConnFailed =>
      'Verbindung fehlgeschlagen. Versuchen Sie, Bluetooth neu zu starten.';

  @override
  String get themeSystemTooltip => 'Design: System';

  @override
  String get themeLightTooltip => 'Design: Hell';

  @override
  String get themeDarkTooltip => 'Design: Dunkel';

  @override
  String get statusDisconnected => 'Getrennt';

  @override
  String get statusConnected => 'ECU Online';

  @override
  String get statusHibernating => 'ECU im Ruhezustand (Zündung aus)';

  @override
  String get btnDisconnect => 'Trennen';

  @override
  String get moreMenuTitle => 'Weitere Optionen';

  @override
  String get moreDiagSection => 'ERWEITERTE DIAGNOSE';

  @override
  String get moreInfoDesc => 'VIN, CVN, Modus 09 Monitore';

  @override
  String get moreTerminalDesc => 'Manuelle PIDs und AT-Befehle senden';

  @override
  String get moreAppSection => 'ANWENDUNG';

  @override
  String get moreSettings => 'Einstellungen';

  @override
  String get moreSettingsDesc => 'Verbindung, Protokolle und Einstellungen';

  @override
  String setChooseColor(String colorName) {
    return 'Farbe wählen: $colorName';
  }

  @override
  String get btnApply => 'Anwenden';

  @override
  String get testValue => 'Wert';

  @override
  String get testMin => 'Min';

  @override
  String get testMax => 'Max';

  @override
  String get sensWaitGraph => '(Warten Sie, bis das Diagramm gefüllt ist)';

  @override
  String get faultDetailsTitle => 'Fehlerdetails';

  @override
  String get faultDescConfirmed =>
      'Schaltet die Motorkontrollleuchte ein. Das Problem tritt auf oder ist kürzlich aufgetreten.';

  @override
  String get faultDescPending =>
      'ECU hat eine Anomalie erkannt, benötigt aber weitere Fahrzyklen zur Bestätigung.';

  @override
  String get faultDescPermanent =>
      'Schwerwiegender Fehler. Wird erst nach Reparatur und Fahrt gelöscht.';

  @override
  String get faultFreezeFrameTitle => 'Freeze Frame Daten:';

  @override
  String dbgExportError(String error) {
    return 'Fehler beim Exportieren: $error';
  }

  @override
  String get dbgScanTitle => 'PID Brute-Force-Scan';

  @override
  String get dbgScanHeaderHint => 'Header (Optional, z.B. 7E0)';

  @override
  String get dbgScanPrefixHint => 'Modus/Präfix (z.B. 22)';

  @override
  String get dbgScanStartHint => 'Start Hex (z.B. 1100)';

  @override
  String get dbgScanEndHint => 'Ende Hex (z.B. 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ Warnung: Der Scan sendet kontinuierliche sequentielle Anfragen. Große Bereiche können mehrere Minuten dauern.';

  @override
  String get btnStart => 'Starten';

  @override
  String get dbgErrorBounds => 'Start ist größer als das Ende';

  @override
  String dbgScanStarting(String start, String end) {
    return 'Starte Scan von $start bis $end...';
  }

  @override
  String get dbgErrorHex =>
      'Fehler in hexadezimalen Parametern! Überprüfen Sie Ihre Eingabe.';

  @override
  String get dbgScanComplete => 'Scan abgeschlossen!';

  @override
  String dbgFormulaResult(String result) {
    return 'Ergebnis (Formel): $result';
  }

  @override
  String get dbgFormulaError =>
      'Fehler: Formel konnte nicht interpretiert werden. Überprüfen Sie die Syntax.';

  @override
  String get dbgScanCancelled => 'Scan vom Benutzer abgebrochen.';

  @override
  String get techLibTitle => 'Technische Bibliothek';

  @override
  String get techHowItWorks => 'Wie funktioniert dieser Sensor?';

  @override
  String get techWhatIsIt => 'Was ist das?';

  @override
  String get techFunction => 'Funktion';

  @override
  String get techImpact => 'Systemauswirkung';

  @override
  String get dtcSymptoms => 'Häufige Symptome';

  @override
  String get dtcCauses => 'Mögliche Ursachen';

  @override
  String get dtcResolution => 'Prüfung und Behebung';
}
