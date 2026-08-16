// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'सेंसर';

  @override
  String get tabHud => 'डैशबोर्ड';

  @override
  String get tabTests => 'परीक्षण';

  @override
  String get tabFaults => 'दोष';

  @override
  String get tabMore => 'अधिक';

  @override
  String get btnCancel => 'रद्द करें';

  @override
  String get btnSave => 'सहेजें';

  @override
  String get btnSend => 'भेजें';

  @override
  String get btnRefresh => 'रीफ्रेश करें';

  @override
  String get connTitle => 'स्कैनर से कनेक्ट करें';

  @override
  String get connPaired => 'पेयर किए गए डिवाइस';

  @override
  String get connNearby => 'नज़दीकी डिवाइस';

  @override
  String get connNoDevices => 'कोई डिवाइस नहीं मिला।';

  @override
  String get connSearching => 'खोज रहा है...';

  @override
  String get connSearchNew => 'नए डिवाइस खोजें';

  @override
  String get connEstablishing => 'सुरक्षित कनेक्शन स्थापित किया जा रहा है...';

  @override
  String get connWaitKey =>
      'डैशबोर्ड को चालू करने के लिए इग्निशन कुंजी चालू करें।';

  @override
  String get connMapping => 'समर्थित सेंसर की मैपिंग हो रही है...';

  @override
  String get connSuccess => 'कनेक्शन सफल!';

  @override
  String get sensTitle => 'मैप किए गए सेंसर';

  @override
  String get sensNone => 'कोई सेंसर नहीं मिला।';

  @override
  String get sensInstant => 'तत्काल मूल्य';

  @override
  String get sensRecent => 'हाल का व्यवहार';

  @override
  String get sensReading => 'CAN बस डेटा पढ़ा जा रहा है...';

  @override
  String get sensNoHistory => 'टेक्स्ट स्थिति के लिए इतिहास लागू नहीं है।';

  @override
  String get hudManage => 'सेंसर प्रबंधित करें';

  @override
  String get hudFullscreen => 'फ़ुलस्क्रीन';

  @override
  String get hudImmersive => 'इमर्सिव मोड';

  @override
  String get hudImmersiveDesc =>
      'फ़ुलस्क्रीन में प्रवेश करने या बाहर निकलने के लिए स्क्रीन पर डबल टैप करें।';

  @override
  String get hudGotIt => 'समझ गया';

  @override
  String get hudConfig => 'डैशबोर्ड कॉन्फ़िगर करें';

  @override
  String get hudSelected => 'चयनित सेंसर';

  @override
  String get hudAvailable => 'उपलब्ध';

  @override
  String get hudSearch => 'सेंसर खोजें...';

  @override
  String get testTitle => 'ECU परीक्षण परिणाम';

  @override
  String get testConsulting =>
      'मॉनिटर और परीक्षण सीमा की जांच की जा रही है...\nकृपया प्रतीक्षा करें।';

  @override
  String get testNone => 'कोई आंतरिक परीक्षण नहीं मिला।';

  @override
  String get testWaiting => 'ड्राइविंग साइकिल की प्रतीक्षा';

  @override
  String get testPassed => 'उत्तीर्ण';

  @override
  String get testFailed => 'सीमा विफल';

  @override
  String get faultTitle => 'डायग्नोस्टिक्स (DTC)';

  @override
  String get faultClearMil => 'चेक इंजन लाइट साफ़ करें?';

  @override
  String get faultClearDesc =>
      'यह क्रिया फॉल्ट मेमोरी और फ्रीज फ्रेम को रीसेट कर देगी। सुनिश्चित करें कि इग्निशन चालू है और इंजन बंद है।';

  @override
  String get faultYesClear => 'हां, साफ़ करें!';

  @override
  String get faultAll => 'सभी';

  @override
  String get faultConfirmed => 'पुष्ट';

  @override
  String get faultPending => 'लंबित';

  @override
  String get faultPermanent => 'स्थायी';

  @override
  String get faultReading =>
      'ECU मेमोरी और फ्रीज फ्रेम पढ़ा जा रहा है...\nकृपया प्रतीक्षा करें।';

  @override
  String get faultNone => 'कोई दोष नहीं मिला!';

  @override
  String get infoTitle => 'वाहन की जानकारी';

  @override
  String get infoConsulting =>
      'ECU मॉड्यूल और कैलिब्रेशन की जांच की जा रही है...\nकृपया प्रतीक्षा करें।';

  @override
  String get infoNone =>
      'कोई जानकारी नहीं मिली।\nवाहन संभवतः मोड 09 का समर्थन नहीं करता है।';

  @override
  String get setTitle => 'सिस्टम सेटिंग्स';

  @override
  String get setColor => 'कलर पैलेट';

  @override
  String get setThemeLight => 'लाइट थीम';

  @override
  String get setThemeDark => 'डार्क थीम';

  @override
  String get setMainColor => 'मुख्य रंग (थीम/तटस्थ)';

  @override
  String get setNormalColor => 'सामान्य स्थिति (स्वस्थ)';

  @override
  String get setWarningColor => 'चेतावनी स्थिति (अलर्ट)';

  @override
  String get setCriticalColor => 'महत्वपूर्ण स्थिति (खतरा)';

  @override
  String get setRestoreColors => 'डिफ़ॉल्ट रंग पुनर्स्थापित करें';

  @override
  String get setPerf => 'प्रदर्शन और बैटरी';

  @override
  String get setRate => 'सेंसर रिफ्रेश रेट';

  @override
  String get setRateDesc => 'यदि फोन गर्म हो रहा है तो समय बढ़ाएं';

  @override
  String get setRateMax => 'अधिकतम';

  @override
  String get setRateFast => 'तेज़';

  @override
  String get setRateNormal => 'सामान्य';

  @override
  String get setRateEco => 'इको';

  @override
  String get dbgTitle => 'डायग्नोस्टिक टर्मिनल';

  @override
  String get dbgHeader => 'Header (वैकल्पिक)';

  @override
  String get dbgCommand => 'कमांड (PID/AT)';

  @override
  String get dbgFormula => 'कस्टम फ़ॉर्मूला';

  @override
  String get dbgStop => 'स्कैन रोकें';

  @override
  String get dbgScan => 'ब्रूट फ़ोर्स स्कैन';

  @override
  String get dbgClear => 'टर्मिनल साफ़ करें';

  @override
  String get dbgExport => 'लॉग निर्यात करें';

  @override
  String get dbgEmpty => 'टर्मिनल खाली है। निर्यात करने के लिए कुछ नहीं है।';

  @override
  String get dbgSaved => 'फ़ाइल सफलतापूर्वक यहाँ सहेजी गई:';

  @override
  String connSensorsMapped(int count) {
    return '$count मैप किए गए सेंसर';
  }

  @override
  String get connSnackSavedNotFound =>
      'सहेजा गया स्कैनर नहीं मिला। सूची से चुनें।';

  @override
  String get connSnackConnFailed =>
      'कनेक्शन विफल। ब्लूटूथ को पुनरारंभ करने का प्रयास करें।';

  @override
  String get themeSystemTooltip => 'थीम: सिस्टम';

  @override
  String get themeLightTooltip => 'थीम: लाइट';

  @override
  String get themeDarkTooltip => 'थीम: डार्क';

  @override
  String get statusDisconnected => 'डिस्कनेक्ट हो गया';

  @override
  String get statusConnected => 'ECU ऑनलाइन';

  @override
  String get statusHibernating => 'ECU हाइबरनेटिंग (इग्निशन ऑफ)';

  @override
  String get btnDisconnect => 'डिस्कनेक्ट करें';

  @override
  String get moreMenuTitle => 'अधिक विकल्प';

  @override
  String get moreDiagSection => 'उन्नत डायग्नोस्टिक्स';

  @override
  String get moreInfoDesc => 'VIN, CVN, मोड 09 मॉनिटर';

  @override
  String get moreTerminalDesc => 'मैनुअल PID और AT कमांड भेजें';

  @override
  String get moreAppSection => 'एप्लिकेशन';

  @override
  String get moreSettings => 'सेटिंग्स';

  @override
  String get moreSettingsDesc => 'कनेक्शन, प्रोटोकॉल और प्राथमिकताएं';

  @override
  String setChooseColor(String colorName) {
    return 'रंग चुनें: $colorName';
  }

  @override
  String get btnApply => 'लागू करें';

  @override
  String get testValue => 'मूल्य';

  @override
  String get testMin => 'न्यूनतम';

  @override
  String get testMax => 'अधिकतम';

  @override
  String get sensWaitGraph => '(ग्राफ़ के भरने की प्रतीक्षा करें)';

  @override
  String get faultDetailsTitle => 'दोष विवरण';

  @override
  String get faultDescConfirmed =>
      'चेक इंजन लाइट चालू करता है। समस्या अभी हो रही है या हाल ही में हुई है।';

  @override
  String get faultDescPending =>
      'ECU ने विसंगति का पता लगाया लेकिन पुष्टि के लिए अधिक ड्राइव साइकिल की आवश्यकता है।';

  @override
  String get faultDescPermanent =>
      'गंभीर दोष। मरम्मत और वाहन चलाने के बाद ही मिटता है।';

  @override
  String get faultFreezeFrameTitle => 'फ़्रीज़ फ़्रेम डेटा:';

  @override
  String dbgExportError(String error) {
    return 'निर्यात त्रुटि: $error';
  }

  @override
  String get dbgScanTitle => 'PID ब्रूट फोर्स स्कैन';

  @override
  String get dbgScanHeaderHint => 'हेडर (वैकल्पिक, उदाहरण: 7E0)';

  @override
  String get dbgScanPrefixHint => 'मोड/उपसर्ग (उदाहरण: 22)';

  @override
  String get dbgScanStartHint => 'प्रारंभ Hex (उदाहरण: 1100)';

  @override
  String get dbgScanEndHint => 'अंत Hex (उदाहरण: 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ चेतावनी: स्कैन लगातार अनुक्रमिक अनुरोध भेजेगा। बड़ी श्रेणियों में कई मिनट लग सकते हैं।';

  @override
  String get btnStart => 'शुरू';

  @override
  String get dbgErrorBounds => 'प्रारंभ अंत से बड़ा है';

  @override
  String dbgScanStarting(String start, String end) {
    return '$start से $end तक स्कैन शुरू हो रहा है...';
  }

  @override
  String get dbgErrorHex =>
      'हेक्साडेसिमल मापदंडों में त्रुटि! अपना इनपुट जांचें।';

  @override
  String get dbgScanComplete => 'स्कैन पूर्ण!';

  @override
  String dbgFormulaResult(String result) {
    return 'परिणाम (फ़ॉर्मूला): $result';
  }

  @override
  String get dbgFormulaError =>
      'त्रुटि: फ़ॉर्मूला की व्याख्या करने में विफल। सिंटैक्स जांचें।';

  @override
  String get dbgScanCancelled => 'उपयोगकर्ता द्वारा स्कैन रद्द किया गया।';
}
