import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OBD2 Tools'**
  String get appTitle;

  /// No description provided for @tabSensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get tabSensors;

  /// No description provided for @tabHud.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabHud;

  /// No description provided for @tabTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get tabTests;

  /// No description provided for @tabFaults.
  ///
  /// In en, this message translates to:
  /// **'Faults'**
  String get tabFaults;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get btnSend;

  /// No description provided for @btnRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get btnRefresh;

  /// No description provided for @connTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to Scanner'**
  String get connTitle;

  /// No description provided for @connPaired.
  ///
  /// In en, this message translates to:
  /// **'Paired Devices'**
  String get connPaired;

  /// No description provided for @connNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby Devices'**
  String get connNearby;

  /// No description provided for @connNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices found.'**
  String get connNoDevices;

  /// No description provided for @connSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get connSearching;

  /// No description provided for @connSearchNew.
  ///
  /// In en, this message translates to:
  /// **'Search New Devices'**
  String get connSearchNew;

  /// No description provided for @connEstablishing.
  ///
  /// In en, this message translates to:
  /// **'Establishing secure connection...'**
  String get connEstablishing;

  /// No description provided for @connWaitKey.
  ///
  /// In en, this message translates to:
  /// **'Turn the ignition key on to power the dashboard.'**
  String get connWaitKey;

  /// No description provided for @connMapping.
  ///
  /// In en, this message translates to:
  /// **'Mapping supported sensors...'**
  String get connMapping;

  /// No description provided for @connSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection Successful!'**
  String get connSuccess;

  /// No description provided for @sensTitle.
  ///
  /// In en, this message translates to:
  /// **'Mapped Sensors'**
  String get sensTitle;

  /// No description provided for @sensNone.
  ///
  /// In en, this message translates to:
  /// **'No sensors found.'**
  String get sensNone;

  /// No description provided for @sensInstant.
  ///
  /// In en, this message translates to:
  /// **'Instant Value'**
  String get sensInstant;

  /// No description provided for @sensRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent Behavior'**
  String get sensRecent;

  /// No description provided for @sensReading.
  ///
  /// In en, this message translates to:
  /// **'Reading CAN Bus data...'**
  String get sensReading;

  /// No description provided for @sensNoHistory.
  ///
  /// In en, this message translates to:
  /// **'History not applicable for text status.'**
  String get sensNoHistory;

  /// No description provided for @hudManage.
  ///
  /// In en, this message translates to:
  /// **'Manage Sensors'**
  String get hudManage;

  /// No description provided for @hudFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get hudFullscreen;

  /// No description provided for @hudImmersive.
  ///
  /// In en, this message translates to:
  /// **'Immersive Mode'**
  String get hudImmersive;

  /// No description provided for @hudImmersiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Double tap the screen to enter or exit Fullscreen.'**
  String get hudImmersiveDesc;

  /// No description provided for @hudGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get hudGotIt;

  /// No description provided for @hudConfig.
  ///
  /// In en, this message translates to:
  /// **'Configure Dash'**
  String get hudConfig;

  /// No description provided for @hudSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected Sensors'**
  String get hudSelected;

  /// No description provided for @hudAvailable.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get hudAvailable;

  /// No description provided for @hudSearch.
  ///
  /// In en, this message translates to:
  /// **'Search sensor...'**
  String get hudSearch;

  /// No description provided for @testTitle.
  ///
  /// In en, this message translates to:
  /// **'ECU Test Results'**
  String get testTitle;

  /// No description provided for @testConsulting.
  ///
  /// In en, this message translates to:
  /// **'Consulting monitors and test limits...\nPlease wait.'**
  String get testConsulting;

  /// No description provided for @testNone.
  ///
  /// In en, this message translates to:
  /// **'No internal tests found.'**
  String get testNone;

  /// No description provided for @testWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting Driving Cycle'**
  String get testWaiting;

  /// No description provided for @testPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get testPassed;

  /// No description provided for @testFailed.
  ///
  /// In en, this message translates to:
  /// **'Limit Failed'**
  String get testFailed;

  /// No description provided for @faultTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics (DTC)'**
  String get faultTitle;

  /// No description provided for @faultClearMil.
  ///
  /// In en, this message translates to:
  /// **'Clear Check Engine Light?'**
  String get faultClearMil;

  /// No description provided for @faultClearDesc.
  ///
  /// In en, this message translates to:
  /// **'This action will reset the fault memory and Freeze Frame. Make sure the IGNITION is ON and the ENGINE is OFF.'**
  String get faultClearDesc;

  /// No description provided for @faultYesClear.
  ///
  /// In en, this message translates to:
  /// **'Yes, Clear!'**
  String get faultYesClear;

  /// No description provided for @faultAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get faultAll;

  /// No description provided for @faultConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get faultConfirmed;

  /// No description provided for @faultPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get faultPending;

  /// No description provided for @faultPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get faultPermanent;

  /// No description provided for @faultReading.
  ///
  /// In en, this message translates to:
  /// **'Reading ECU memory and freeze frames...\nPlease wait.'**
  String get faultReading;

  /// No description provided for @faultNone.
  ///
  /// In en, this message translates to:
  /// **'No faults found!'**
  String get faultNone;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get infoTitle;

  /// No description provided for @infoConsulting.
  ///
  /// In en, this message translates to:
  /// **'Consulting ECU modules and calibrations...\nPlease wait.'**
  String get infoConsulting;

  /// No description provided for @infoNone.
  ///
  /// In en, this message translates to:
  /// **'No information found.\nThe vehicle may not support Mode 09.'**
  String get infoNone;

  /// No description provided for @setTitle.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get setTitle;

  /// No description provided for @setColor.
  ///
  /// In en, this message translates to:
  /// **'Color Palette'**
  String get setColor;

  /// No description provided for @setThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get setThemeLight;

  /// No description provided for @setThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get setThemeDark;

  /// No description provided for @setMainColor.
  ///
  /// In en, this message translates to:
  /// **'Main Color (Theme/Neutrals)'**
  String get setMainColor;

  /// No description provided for @setNormalColor.
  ///
  /// In en, this message translates to:
  /// **'Normal Status (Healthy)'**
  String get setNormalColor;

  /// No description provided for @setWarningColor.
  ///
  /// In en, this message translates to:
  /// **'Warning Status (Alert)'**
  String get setWarningColor;

  /// No description provided for @setCriticalColor.
  ///
  /// In en, this message translates to:
  /// **'Critical Status (Danger)'**
  String get setCriticalColor;

  /// No description provided for @setRestoreColors.
  ///
  /// In en, this message translates to:
  /// **'Restore Default Colors'**
  String get setRestoreColors;

  /// No description provided for @setPerf.
  ///
  /// In en, this message translates to:
  /// **'Performance & Battery'**
  String get setPerf;

  /// No description provided for @setRate.
  ///
  /// In en, this message translates to:
  /// **'Sensors Refresh Rate'**
  String get setRate;

  /// No description provided for @setRateDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase the time if the phone is heating up'**
  String get setRateDesc;

  /// No description provided for @setRateMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get setRateMax;

  /// No description provided for @setRateFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get setRateFast;

  /// No description provided for @setRateNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get setRateNormal;

  /// No description provided for @setRateEco.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get setRateEco;

  /// No description provided for @dbgTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Terminal'**
  String get dbgTitle;

  /// No description provided for @dbgHeader.
  ///
  /// In en, this message translates to:
  /// **'Header (Opt)'**
  String get dbgHeader;

  /// No description provided for @dbgCommand.
  ///
  /// In en, this message translates to:
  /// **'Command (PID/AT)'**
  String get dbgCommand;

  /// No description provided for @dbgFormula.
  ///
  /// In en, this message translates to:
  /// **'Custom Formula'**
  String get dbgFormula;

  /// No description provided for @dbgStop.
  ///
  /// In en, this message translates to:
  /// **'Stop Scan'**
  String get dbgStop;

  /// No description provided for @dbgScan.
  ///
  /// In en, this message translates to:
  /// **'Brute Force Scan'**
  String get dbgScan;

  /// No description provided for @dbgClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Terminal'**
  String get dbgClear;

  /// No description provided for @dbgExport.
  ///
  /// In en, this message translates to:
  /// **'Export Logs'**
  String get dbgExport;

  /// No description provided for @dbgEmpty.
  ///
  /// In en, this message translates to:
  /// **'The terminal is empty. Nothing to export.'**
  String get dbgEmpty;

  /// No description provided for @dbgSaved.
  ///
  /// In en, this message translates to:
  /// **'File successfully saved at:'**
  String get dbgSaved;

  /// No description provided for @connSensorsMapped.
  ///
  /// In en, this message translates to:
  /// **'{count} mapped sensors'**
  String connSensorsMapped(int count);

  /// No description provided for @connSnackSavedNotFound.
  ///
  /// In en, this message translates to:
  /// **'Saved scanner not found. Select from the list.'**
  String get connSnackSavedNotFound;

  /// No description provided for @connSnackConnFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Try restarting Bluetooth.'**
  String get connSnackConnFailed;

  /// No description provided for @themeSystemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Theme: System'**
  String get themeSystemTooltip;

  /// No description provided for @themeLightTooltip.
  ///
  /// In en, this message translates to:
  /// **'Theme: Light'**
  String get themeLightTooltip;

  /// No description provided for @themeDarkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Theme: Dark'**
  String get themeDarkTooltip;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get statusDisconnected;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'ECU Online'**
  String get statusConnected;

  /// No description provided for @statusHibernating.
  ///
  /// In en, this message translates to:
  /// **'ECU Hibernating (Ignition Off)'**
  String get statusHibernating;

  /// No description provided for @btnDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get btnDisconnect;

  /// No description provided for @moreMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreMenuTitle;

  /// No description provided for @moreDiagSection.
  ///
  /// In en, this message translates to:
  /// **'ADVANCED DIAGNOSTICS'**
  String get moreDiagSection;

  /// No description provided for @moreInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'VIN, CVN, Mode 09 Monitors'**
  String get moreInfoDesc;

  /// No description provided for @moreTerminalDesc.
  ///
  /// In en, this message translates to:
  /// **'Send manual PIDs and AT commands'**
  String get moreTerminalDesc;

  /// No description provided for @moreAppSection.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION'**
  String get moreAppSection;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettings;

  /// No description provided for @moreSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Connection, Protocols, and Preferences'**
  String get moreSettingsDesc;

  /// No description provided for @setChooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose color: {colorName}'**
  String setChooseColor(String colorName);

  /// No description provided for @btnApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get btnApply;

  /// No description provided for @testValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get testValue;

  /// No description provided for @testMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get testMin;

  /// No description provided for @testMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get testMax;

  /// No description provided for @sensWaitGraph.
  ///
  /// In en, this message translates to:
  /// **'(Wait for the graph to populate)'**
  String get sensWaitGraph;

  /// No description provided for @faultDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fault Details'**
  String get faultDetailsTitle;

  /// No description provided for @faultDescConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Turns on the check engine light. The problem is occurring or occurred recently.'**
  String get faultDescConfirmed;

  /// No description provided for @faultDescPending.
  ///
  /// In en, this message translates to:
  /// **'ECU detected an anomaly but needs more drive cycles to confirm.'**
  String get faultDescPending;

  /// No description provided for @faultDescPermanent.
  ///
  /// In en, this message translates to:
  /// **'Serious fault. Only clears after repair and driving the vehicle.'**
  String get faultDescPermanent;

  /// No description provided for @faultFreezeFrameTitle.
  ///
  /// In en, this message translates to:
  /// **'Freeze Frame Data:'**
  String get faultFreezeFrameTitle;

  /// No description provided for @dbgExportError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting: {error}'**
  String dbgExportError(String error);

  /// No description provided for @dbgScanTitle.
  ///
  /// In en, this message translates to:
  /// **'PID Brute Force Scan'**
  String get dbgScanTitle;

  /// No description provided for @dbgScanHeaderHint.
  ///
  /// In en, this message translates to:
  /// **'Header (Optional, e.g., 7E0)'**
  String get dbgScanHeaderHint;

  /// No description provided for @dbgScanPrefixHint.
  ///
  /// In en, this message translates to:
  /// **'Mode/Prefix (e.g., 22)'**
  String get dbgScanPrefixHint;

  /// No description provided for @dbgScanStartHint.
  ///
  /// In en, this message translates to:
  /// **'Start Hex (e.g., 1100)'**
  String get dbgScanStartHint;

  /// No description provided for @dbgScanEndHint.
  ///
  /// In en, this message translates to:
  /// **'End Hex (e.g., 11FF)'**
  String get dbgScanEndHint;

  /// No description provided for @dbgScanWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: The scan will send continuous sequential requests. Large ranges may take several minutes.'**
  String get dbgScanWarning;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get btnStart;

  /// No description provided for @dbgErrorBounds.
  ///
  /// In en, this message translates to:
  /// **'Start is greater than end'**
  String get dbgErrorBounds;

  /// No description provided for @dbgScanStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting scan from {start} to {end}...'**
  String dbgScanStarting(String start, String end);

  /// No description provided for @dbgErrorHex.
  ///
  /// In en, this message translates to:
  /// **'Error in hexadecimal parameters! Check your input.'**
  String get dbgErrorHex;

  /// No description provided for @dbgScanComplete.
  ///
  /// In en, this message translates to:
  /// **'Scan Complete!'**
  String get dbgScanComplete;

  /// No description provided for @dbgFormulaResult.
  ///
  /// In en, this message translates to:
  /// **'Result (Formula): {result}'**
  String dbgFormulaResult(String result);

  /// No description provided for @dbgFormulaError.
  ///
  /// In en, this message translates to:
  /// **'Error: Failed to interpret formula. Check syntax.'**
  String get dbgFormulaError;

  /// No description provided for @dbgScanCancelled.
  ///
  /// In en, this message translates to:
  /// **'Scan cancelled by user.'**
  String get dbgScanCancelled;

  /// No description provided for @techLibTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical Library'**
  String get techLibTitle;

  /// No description provided for @techHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How does this sensor work?'**
  String get techHowItWorks;

  /// No description provided for @techWhatIsIt.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get techWhatIsIt;

  /// No description provided for @techFunction.
  ///
  /// In en, this message translates to:
  /// **'Function'**
  String get techFunction;

  /// No description provided for @techImpact.
  ///
  /// In en, this message translates to:
  /// **'System Impact'**
  String get techImpact;

  /// No description provided for @dtcSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Common Symptoms'**
  String get dtcSymptoms;

  /// No description provided for @dtcCauses.
  ///
  /// In en, this message translates to:
  /// **'Possible Causes'**
  String get dtcCauses;

  /// No description provided for @dtcResolution.
  ///
  /// In en, this message translates to:
  /// **'How to Test and Fix'**
  String get dtcResolution;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
