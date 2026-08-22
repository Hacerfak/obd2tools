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

  @override
  String connSensorsMapped(int count) {
    return '$count mapped sensors';
  }

  @override
  String get connSnackSavedNotFound =>
      'Saved scanner not found. Select from the list.';

  @override
  String get connSnackConnFailed =>
      'Connection failed. Try restarting Bluetooth.';

  @override
  String get themeSystemTooltip => 'Theme: System';

  @override
  String get themeLightTooltip => 'Theme: Light';

  @override
  String get themeDarkTooltip => 'Theme: Dark';

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get statusConnected => 'ECU Online';

  @override
  String get statusHibernating => 'ECU Hibernating (Ignition Off)';

  @override
  String get btnDisconnect => 'Disconnect';

  @override
  String get moreMenuTitle => 'More Options';

  @override
  String get moreDiagSection => 'ADVANCED DIAGNOSTICS';

  @override
  String get moreInfoDesc => 'VIN, CVN, Mode 09 Monitors';

  @override
  String get moreTerminalDesc => 'Send manual PIDs and AT commands';

  @override
  String get moreAppSection => 'APPLICATION';

  @override
  String get moreSettings => 'Settings';

  @override
  String get moreSettingsDesc => 'Connection, Protocols, and Preferences';

  @override
  String setChooseColor(String colorName) {
    return 'Choose color: $colorName';
  }

  @override
  String get btnApply => 'Apply';

  @override
  String get testValue => 'Value';

  @override
  String get testMin => 'Min';

  @override
  String get testMax => 'Max';

  @override
  String get sensWaitGraph => '(Wait for the graph to populate)';

  @override
  String get faultDetailsTitle => 'Fault Details';

  @override
  String get faultDescConfirmed =>
      'Turns on the check engine light. The problem is occurring or occurred recently.';

  @override
  String get faultDescPending =>
      'ECU detected an anomaly but needs more drive cycles to confirm.';

  @override
  String get faultDescPermanent =>
      'Serious fault. Only clears after repair and driving the vehicle.';

  @override
  String get faultFreezeFrameTitle => 'Freeze Frame Data:';

  @override
  String dbgExportError(String error) {
    return 'Error exporting: $error';
  }

  @override
  String get dbgScanTitle => 'PID Brute Force Scan';

  @override
  String get dbgScanHeaderHint => 'Header (Optional, e.g., 7E0)';

  @override
  String get dbgScanPrefixHint => 'Mode/Prefix (e.g., 22)';

  @override
  String get dbgScanStartHint => 'Start Hex (e.g., 1100)';

  @override
  String get dbgScanEndHint => 'End Hex (e.g., 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ Warning: The scan will send continuous sequential requests. Large ranges may take several minutes.';

  @override
  String get btnStart => 'Start';

  @override
  String get dbgErrorBounds => 'Start is greater than end';

  @override
  String dbgScanStarting(String start, String end) {
    return 'Starting scan from $start to $end...';
  }

  @override
  String get dbgErrorHex =>
      'Error in hexadecimal parameters! Check your input.';

  @override
  String get dbgScanComplete => 'Scan Complete!';

  @override
  String dbgFormulaResult(String result) {
    return 'Result (Formula): $result';
  }

  @override
  String get dbgFormulaError =>
      'Error: Failed to interpret formula. Check syntax.';

  @override
  String get dbgScanCancelled => 'Scan cancelled by user.';

  @override
  String get techLibTitle => 'Technical Library';

  @override
  String get techHowItWorks => 'How does this sensor work?';

  @override
  String get techWhatIsIt => 'What is it?';

  @override
  String get techFunction => 'Function';

  @override
  String get techImpact => 'System Impact';

  @override
  String get dtcSymptoms => 'Common Symptoms';

  @override
  String get dtcCauses => 'Possible Causes';

  @override
  String get dtcResolution => 'How to Test and Fix';

  @override
  String get errBleDisconnected => 'Bluetooth connection lost!';

  @override
  String get aboutTitle => 'About the App';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutTheProjectTitle => 'The Project';

  @override
  String get aboutTheProjectDesc =>
      'OBD2 Tools was developed to democratize automotive diagnostics. Combining a modern interface with real-time telemetry, this app turns your smartphone into a professional scanner, allowing enthusiasts and mechanics to understand vehicle health clearly, quickly, and objectively.';

  @override
  String get aboutDeveloperTitle => 'Developer';

  @override
  String get aboutDeveloperRole => 'Apprentice';

  @override
  String get aboutDeveloperDesc =>
      'Passionate about technology and the automotive world. Creating solutions to simplify everyday life.';

  @override
  String get unitCounts => 'counts';

  @override
  String midO2Sensor(Object hex) {
    return 'O2 Sensor - Sensor 0x$hex';
  }

  @override
  String midCatalyst(Object bank) {
    return 'Catalyst - Bank $bank';
  }

  @override
  String midEgr(Object bank) {
    return 'EGR System - Bank $bank';
  }

  @override
  String midVvt(Object bank) {
    return 'VVT System - Bank $bank';
  }

  @override
  String get midEvapGeneral => 'EVAP - Tank General Monitor';

  @override
  String get midEvapVacuumInit => 'EVAP - Sealing / Initial Vacuum';

  @override
  String get midEvapGrossLeak => 'EVAP - Gross Leak Test (0.090\")';

  @override
  String get midEvapMedLeak => 'EVAP - Medium Leak Test (0.040\")';

  @override
  String get midEvapSmallLeak => 'EVAP - Small Leak Test (0.020\")';

  @override
  String get midEvapPurgeValve => 'EVAP - Canister Purge Valve';

  @override
  String get midEvapVentValve => 'EVAP - Vent Valve';

  @override
  String midO2Heater(Object hex) {
    return 'O2 Sensor Heater - Sensor 0x$hex';
  }

  @override
  String midSecAir(Object bank) {
    return 'Secondary Air System - Bank $bank';
  }

  @override
  String midFuelSystem(Object bank) {
    return 'Fuel System - Bank $bank';
  }

  @override
  String midMisfireCylinder(Object cylinder) {
    return 'Misfire - Cylinder $cylinder';
  }

  @override
  String get midMisfireAll => 'Misfire - All Cylinders';

  @override
  String midProprietary(Object hex) {
    return 'Proprietary Monitor (0x$hex)';
  }

  @override
  String midObd(Object hex) {
    return 'OBD Monitor (0x$hex)';
  }

  @override
  String get tidO2RichToLean => 'Response Time (Rich to Lean)';

  @override
  String get tidO2LeanToRich => 'Response Time (Lean to Rich)';

  @override
  String get tidO2MinVoltage => 'Minimum Measured Voltage';

  @override
  String get tidO2MaxVoltage => 'Maximum Measured Voltage';

  @override
  String get tidMisfireEwma => 'Misfire Count (EWMA Average)';

  @override
  String get tidMisfireCurrent => 'Misfire Count (Current Cycle)';

  @override
  String get tidEvapPurgeRate => 'EVAP Purge/Leak Rate';

  @override
  String get tidEvapInitGrad => 'EVAP Initial Pressure Gradient';

  @override
  String get tidEvapTankDelta => 'Tank Pressure Delta';

  @override
  String get tidEvapVacDecay => 'EVAP Vacuum Hold/Decay';

  @override
  String get tidEvapInitStab => 'Initial Tank Pressure Stability';

  @override
  String get tidEvapCanisterVac => 'Canister Residual Vacuum Hold';

  @override
  String get tidEvapVentFlow => 'Canister Vent Valve Flow/Blockage';

  @override
  String get tidEvapSolResponse => 'Purge Solenoid Response';

  @override
  String get tidEvapLinePress => 'Purge Line Pressure under Load';

  @override
  String get tidEvapSensorResp => 'EVAP Pressure Sensor Response Time';

  @override
  String get tidEvapSmallDecay => 'Vacuum Decay (Small Leak 0.020\")';

  @override
  String get tidEvapMedDecay => 'Pressure Delta (Medium Leak 0.040\")';

  @override
  String get tidEvapGrossHold => 'Vacuum Hold under Load (Gross Leak 0.090\")';

  @override
  String get tidEvapMinPurgePress => 'Minimum Pressure Reached during Purge';

  @override
  String tidGeneric(Object hex) {
    return 'Test 0x$hex';
  }
}
