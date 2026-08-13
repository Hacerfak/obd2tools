// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'Sensors';

  @override
  String get tabHud => 'Dashboard';

  @override
  String get tabTests => 'Tests';

  @override
  String get tabFaults => 'Faults';

  @override
  String get tabMore => 'More';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnSend => 'Send';

  @override
  String get btnRefresh => 'Refresh';

  @override
  String get connTitle => 'Connect to Scanner';

  @override
  String get connPaired => 'Paired Devices';

  @override
  String get connNearby => 'Nearby Devices';

  @override
  String get connNoDevices => 'No devices found.';

  @override
  String get connSearching => 'Searching...';

  @override
  String get connSearchNew => 'Search New Devices';

  @override
  String get connEstablishing => 'Establishing secure connection...';

  @override
  String get connWaitKey => 'Turn the ignition key on to power the dashboard.';

  @override
  String get connMapping => 'Mapping supported sensors...';

  @override
  String get connSuccess => 'Connection Successful!';

  @override
  String get sensTitle => 'Mapped Sensors';

  @override
  String get sensNone => 'No sensors found.';

  @override
  String get sensInstant => 'Instant Value';

  @override
  String get sensRecent => 'Recent Behavior';

  @override
  String get sensReading => 'Reading CAN Bus data...';

  @override
  String get sensNoHistory => 'History not applicable for text status.';

  @override
  String get hudManage => 'Manage Sensors';

  @override
  String get hudFullscreen => 'Fullscreen';

  @override
  String get hudImmersive => 'Immersive Mode';

  @override
  String get hudImmersiveDesc =>
      'Double tap the screen to enter or exit Fullscreen.';

  @override
  String get hudGotIt => 'Got it';

  @override
  String get hudConfig => 'Configure Dash';

  @override
  String get hudSelected => 'Selected Sensors';

  @override
  String get hudAvailable => 'AVAILABLE';

  @override
  String get hudSearch => 'Search sensor...';

  @override
  String get testTitle => 'ECU Test Results';

  @override
  String get testConsulting =>
      'Consulting monitors and test limits...\nPlease wait.';

  @override
  String get testNone => 'No internal tests found.';

  @override
  String get testWaiting => 'Waiting Driving Cycle';

  @override
  String get testPassed => 'Passed';

  @override
  String get testFailed => 'Limit Failed';

  @override
  String get faultTitle => 'Diagnostics (DTC)';

  @override
  String get faultClearMil => 'Clear Check Engine Light?';

  @override
  String get faultClearDesc =>
      'This action will reset the fault memory and Freeze Frame. Make sure the IGNITION is ON and the ENGINE is OFF.';

  @override
  String get faultYesClear => 'Yes, Clear!';

  @override
  String get faultAll => 'All';

  @override
  String get faultConfirmed => 'Confirmed';

  @override
  String get faultPending => 'Pending';

  @override
  String get faultPermanent => 'Permanent';

  @override
  String get faultReading =>
      'Reading ECU memory and freeze frames...\nPlease wait.';

  @override
  String get faultNone => 'No faults found!';

  @override
  String get infoTitle => 'Vehicle Information';

  @override
  String get infoConsulting =>
      'Consulting ECU modules and calibrations...\nPlease wait.';

  @override
  String get infoNone =>
      'No information found.\nThe vehicle may not support Mode 09.';

  @override
  String get setTitle => 'System Settings';

  @override
  String get setColor => 'Color Palette';

  @override
  String get setThemeLight => 'Light Theme';

  @override
  String get setThemeDark => 'Dark Theme';

  @override
  String get setMainColor => 'Main Color (Theme/Neutrals)';

  @override
  String get setNormalColor => 'Normal Status (Healthy)';

  @override
  String get setWarningColor => 'Warning Status (Alert)';

  @override
  String get setCriticalColor => 'Critical Status (Danger)';

  @override
  String get setRestoreColors => 'Restore Default Colors';

  @override
  String get setPerf => 'Performance & Battery';

  @override
  String get setRate => 'Sensors Refresh Rate';

  @override
  String get setRateDesc => 'Increase the time if the phone is heating up';

  @override
  String get setRateMax => 'Maximum';

  @override
  String get setRateFast => 'Fast';

  @override
  String get setRateNormal => 'Normal';

  @override
  String get setRateEco => 'Eco';

  @override
  String get dbgTitle => 'Diagnostic Terminal';

  @override
  String get dbgHeader => 'Header (Opt)';

  @override
  String get dbgCommand => 'Command (PID/AT)';

  @override
  String get dbgFormula => 'Custom Formula';

  @override
  String get dbgStop => 'Stop Scan';

  @override
  String get dbgScan => 'Brute Force Scan';

  @override
  String get dbgClear => 'Clear Terminal';

  @override
  String get dbgExport => 'Export Logs';

  @override
  String get dbgEmpty => 'The terminal is empty. Nothing to export.';

  @override
  String get dbgSaved => 'File successfully saved at:';
}
