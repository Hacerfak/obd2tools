// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'الحساسات';

  @override
  String get tabHud => 'لوحة القيادة';

  @override
  String get tabTests => 'الاختبارات';

  @override
  String get tabFaults => 'الأعطال';

  @override
  String get tabMore => 'المزيد';

  @override
  String get btnCancel => 'إلغاء';

  @override
  String get btnSave => 'حفظ';

  @override
  String get btnSend => 'إرسال';

  @override
  String get btnRefresh => 'تحديث';

  @override
  String get connTitle => 'الاتصال بالماسح الضوئي';

  @override
  String get connPaired => 'الأجهزة المقترنة';

  @override
  String get connNearby => 'الأجهزة القريبة';

  @override
  String get connNoDevices => 'لم يتم العثور على أجهزة.';

  @override
  String get connSearching => 'جاري البحث...';

  @override
  String get connSearchNew => 'البحث عن أجهزة جديدة';

  @override
  String get connEstablishing => 'جاري إنشاء اتصال آمن...';

  @override
  String get connWaitKey => 'أدر مفتاح التشغيل لتزويد اللوحة بالطاقة.';

  @override
  String get connMapping => 'جاري رسم خريطة الحساسات المدعومة...';

  @override
  String get connSuccess => 'تم الاتصال بنجاح!';

  @override
  String get sensTitle => 'الحساسات المرسومة';

  @override
  String get sensNone => 'لم يتم العثور على حساسات.';

  @override
  String get sensInstant => 'القيمة اللحظية';

  @override
  String get sensRecent => 'السلوك الأخير';

  @override
  String get sensReading => 'جاري قراءة بيانات ناقل CAN...';

  @override
  String get sensNoHistory => 'السجل لا ينطبق على حالة النص.';

  @override
  String get hudManage => 'إدارة الحساسات';

  @override
  String get hudFullscreen => 'ملء الشاشة';

  @override
  String get hudImmersive => 'الوضع المغمور';

  @override
  String get hudImmersiveDesc =>
      'انقر مرتين على الشاشة للدخول أو الخروج من وضع ملء الشاشة.';

  @override
  String get hudGotIt => 'فهمت';

  @override
  String get hudConfig => 'تكوين اللوحة';

  @override
  String get hudSelected => 'الحساسات المحددة';

  @override
  String get hudAvailable => 'المتاحة';

  @override
  String get hudSearch => 'البحث عن حساس...';

  @override
  String get testTitle => 'نتائج اختبارات وحدة التحكم (ECU)';

  @override
  String get testConsulting =>
      'جاري الاستعلام عن أجهزة المراقبة وحدود الاختبارات...\nيرجى الانتظار.';

  @override
  String get testNone => 'لم يتم العثور على اختبارات داخلية.';

  @override
  String get testWaiting => 'في انتظار دورة القيادة';

  @override
  String get testPassed => 'تم بنجاح';

  @override
  String get testFailed => 'تجاوز الحد (فشل)';

  @override
  String get faultTitle => 'التشخيص (DTC)';

  @override
  String get faultClearMil => 'مسح لمبة المحرك (Check Engine)؟';

  @override
  String get faultClearDesc =>
      'سيؤدي هذا الإجراء إلى إعادة ضبط ذاكرة الأعطال وإطار التجميد. تأكد من أن مفتاح التشغيل مُمَكَّن والمحرك متوقف.';

  @override
  String get faultYesClear => 'نعم، إمسح!';

  @override
  String get faultAll => 'الكل';

  @override
  String get faultConfirmed => 'مؤكدة';

  @override
  String get faultPending => 'معلقة';

  @override
  String get faultPermanent => 'دائمة';

  @override
  String get faultReading =>
      'جاري قراءة ذاكرة ECU وأطر التجميد...\nيرجى الانتظار.';

  @override
  String get faultNone => 'لم يتم العثور على أعطال!';

  @override
  String get infoTitle => 'معلومات السيارة';

  @override
  String get infoConsulting =>
      'جاري الاستعلام عن وحدات ECU والمعايرات...\nيرجى الانتظار.';

  @override
  String get infoNone =>
      'لم يتم العثور على معلومات.\nقد لا تدعم السيارة النمط 09 (Mode 09).';

  @override
  String get setTitle => 'إعدادات النظام';

  @override
  String get setColor => 'لوحة الألوان';

  @override
  String get setThemeLight => 'المظهر الفاتح';

  @override
  String get setThemeDark => 'المظهر الداكن';

  @override
  String get setMainColor => 'اللون الرئيسي (المظهر/محايد)';

  @override
  String get setNormalColor => 'الحالة العادية (سليم)';

  @override
  String get setWarningColor => 'حالة التحذير (تنبيه)';

  @override
  String get setCriticalColor => 'الحالة الحرجة (خطر)';

  @override
  String get setRestoreColors => 'استعادة الألوان الافتراضية';

  @override
  String get setPerf => 'الأداء والبطارية';

  @override
  String get setRate => 'معدل تحديث الحساسات';

  @override
  String get setRateDesc => 'زد الوقت إذا كانت درجة حرارة الهاتف ترتفع';

  @override
  String get setRateMax => 'الأقصى';

  @override
  String get setRateFast => 'سريع';

  @override
  String get setRateNormal => 'عادي';

  @override
  String get setRateEco => 'اقتصادي';

  @override
  String get dbgTitle => 'طرفية التشخيص';

  @override
  String get dbgHeader => 'الترويسة (اختياري)';

  @override
  String get dbgCommand => 'الأمر (PID/AT)';

  @override
  String get dbgFormula => 'صيغة مخصصة';

  @override
  String get dbgStop => 'إيقاف المسح';

  @override
  String get dbgScan => 'مسح القوة الغاشمة';

  @override
  String get dbgClear => 'مسح الطرفية';

  @override
  String get dbgExport => 'تصدير السجلات';

  @override
  String get dbgEmpty => 'الطرفية فارغة. لا يوجد شيء للتصدير.';

  @override
  String get dbgSaved => 'تم حفظ الملف بنجاح في:';

  @override
  String connSensorsMapped(int count) {
    return '$count حساس تم تعيينه';
  }

  @override
  String get connSnackSavedNotFound =>
      'لم يتم العثور على الماسح المحفوظ. اختر من القائمة.';

  @override
  String get connSnackConnFailed => 'فشل الاتصال. حاول إعادة تشغيل البلوتوث.';

  @override
  String get themeSystemTooltip => 'المظهر: النظام';

  @override
  String get themeLightTooltip => 'المظهر: فاتح';

  @override
  String get themeDarkTooltip => 'المظهر: داكن';

  @override
  String get statusDisconnected => 'غير متصل';

  @override
  String get statusConnected => 'وحدة التحكم (ECU) متصلة';

  @override
  String get statusHibernating =>
      'وحدة التحكم (ECU) في وضع الخمول (المفتاح مطفأ)';

  @override
  String get btnDisconnect => 'قطع الاتصال';

  @override
  String get moreMenuTitle => 'خيارات إضافية';

  @override
  String get moreDiagSection => 'تشخيص متقدم';

  @override
  String get moreInfoDesc =>
      'رقم الشاسي (VIN)، المعايرة (CVN)، أجهزة مراقبة النمط 09';

  @override
  String get moreTerminalDesc => 'إرسال أوامر PIDs و AT يدوياً';

  @override
  String get moreAppSection => 'التطبيق';

  @override
  String get moreSettings => 'الإعدادات';

  @override
  String get moreSettingsDesc => 'الاتصال، البروتوكولات، والتفضيلات';

  @override
  String setChooseColor(String colorName) {
    return 'اختر اللون: $colorName';
  }

  @override
  String get btnApply => 'تطبيق';

  @override
  String get testValue => 'القيمة';

  @override
  String get testMin => 'الحد الأدنى';

  @override
  String get testMax => 'الحد الأقصى';

  @override
  String get sensWaitGraph => '(انتظر حتى يمتلئ الرسم البياني)';

  @override
  String get faultDetailsTitle => 'تفاصيل العطل';

  @override
  String get faultDescConfirmed =>
      'يضيء لمبة المحرك. المشكلة تحدث حالياً أو حدثت مؤخراً.';

  @override
  String get faultDescPending =>
      'اكتشفت ECU خللاً ولكنها تحتاج إلى المزيد من دورات القيادة للتأكيد.';

  @override
  String get faultDescPermanent =>
      'عطل خطير. لا يُمحى إلا بعد الإصلاح وقيادة السيارة.';

  @override
  String get faultFreezeFrameTitle => 'بيانات إطار التجميد (Freeze Frame):';

  @override
  String dbgExportError(String error) {
    return 'خطأ أثناء التصدير: $error';
  }

  @override
  String get dbgScanTitle => 'مسح القوة الغاشمة لـ PID';

  @override
  String get dbgScanHeaderHint => 'الترويسة (اختياري، مثال: 7E0)';

  @override
  String get dbgScanPrefixHint => 'النمط/السيئة (مثال: 22)';

  @override
  String get dbgScanStartHint => 'بداية Hex (مثال: 1100)';

  @override
  String get dbgScanEndHint => 'نهاية Hex (مثال: 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ تحذير: سيرسل المسح طلبات متتالية مستمرة. قد تستغرق النطاقات الكبيرة عدة دقائق.';

  @override
  String get btnStart => 'بدء';

  @override
  String get dbgErrorBounds => 'البداية أكبر من النهاية';

  @override
  String dbgScanStarting(String start, String end) {
    return 'جاري بدء المسح من $start إلى $end...';
  }

  @override
  String get dbgErrorHex => 'خطأ في معلمات الست عشرية! تحقق من المدخلات.';

  @override
  String get dbgScanComplete => 'اكتمل المسح!';

  @override
  String dbgFormulaResult(String result) {
    return 'النتيجة (الصيغة): $result';
  }

  @override
  String get dbgFormulaError =>
      'خطأ: فشل في تفسير الصيغة. تحقق من بناء الجملة.';

  @override
  String get dbgScanCancelled => 'تم إلغاء المسح بواسطة المستخدم.';

  @override
  String get techLibTitle => 'المكتبة التقنية';

  @override
  String get techHowItWorks => 'كيف يعمل هذا الحساس؟';

  @override
  String get techWhatIsIt => 'ما هو هذا؟';

  @override
  String get techFunction => 'الوظيفة';

  @override
  String get techImpact => 'التأثير على النظام';

  @override
  String get dtcSymptoms => 'الأعراض الشائعة';

  @override
  String get dtcCauses => 'الأسباب المحتملة';

  @override
  String get dtcResolution => 'كيفية الاختبار والإصلاح';

  @override
  String get errBleDisconnected => 'تم فقدان اتصال البلوتوث!';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutTheProjectTitle => 'المشروع';

  @override
  String get aboutTheProjectDesc =>
      'تم تطوير OBD2 Tools لجعل تشخيص السيارات متاحاً للجميع. يجمع التطبيق بين واجهة حديثة والقياس عن بُعد في الوقت الفعلي لتحويل هاتفك الذكي إلى ماسح ضوئي احترافي، مما يتيح لعشاق السيارات والميكانيكيين فهم صحة المركبة بشكل واضح وسريع وموضوعي.';

  @override
  String get aboutDeveloperTitle => 'المطور';

  @override
  String get aboutDeveloperRole => 'متدرب';

  @override
  String get aboutDeveloperDesc =>
      'شغوف بالتكنولوجيا وعالم السيارات. خلق حلول لتبسيط الحياة اليومية.';

  @override
  String get unitCounts => 'عدات';

  @override
  String get btnCopy => 'نسخ';

  @override
  String infoCopiedSnack(String item) {
    return 'تم نسخ $item إلى الحافظة!';
  }

  @override
  String get infoExportTooltip => 'تصدير JSON';

  @override
  String get infoShareSubject => 'معلومات السيارة - OBD2 Tools';

  @override
  String get monMisfire => 'Misfire';

  @override
  String get monFuelSystem => 'Fuel System';

  @override
  String get monComponents => 'Comprehensive Components';

  @override
  String get monCatalyst => 'Catalyst';

  @override
  String get monHeatedCatalyst => 'Heated Catalyst';

  @override
  String get monEvaporativeSystem => 'Evaporative System';

  @override
  String get monSecondaryAir => 'Secondary Air System';

  @override
  String get monGpfFilter => 'Gasoline Particulate Filter';

  @override
  String get monOxygenSensor => 'Oxygen Sensor';

  @override
  String get monOxygenHeater => 'Oxygen Sensor Heater';

  @override
  String get monEgrVvt => 'EGR and/or VVT System';

  @override
  String get monNmhcCatalyst => 'NMHC Catalyst';

  @override
  String get monNoxScr => 'NOx/SCR Monitor';

  @override
  String get monBoostPressure => 'Boost Pressure System';

  @override
  String get monExhaustGasSensor => 'Exhaust Gas Sensor';

  @override
  String get monPmFilter => 'PM Filter Monitoring';

  @override
  String get statusComplete => 'Complete';

  @override
  String get statusIncomplete => 'Incomplete';

  @override
  String get chartNow => 'Now';

  @override
  String get chartTitle10s => 'Real-Time Chart';

  @override
  String get sessionStats => 'Session Statistics';

  @override
  String get statMin => 'Minimum';

  @override
  String get statMax => 'Maximum';

  @override
  String get milTitle => 'Check Engine Light (MIL)';

  @override
  String get milStatusOn => 'ON';

  @override
  String get milStatusOff => 'OFF';

  @override
  String get confirmedErrors => 'Confirmed Errors';

  @override
  String dtcCountFormat(int count) {
    return '$count DTC(s)';
  }

  @override
  String ignitionTypeFormat(String type) {
    return 'Ignition Type: $type';
  }

  @override
  String get ignitionCompression => 'Compression (Diesel)';

  @override
  String get ignitionSpark => 'Spark (Gasoline / Flex)';

  @override
  String get readinessMonitorsTitle => 'Readiness Checks';

  @override
  String supportedEgtSensors(int bank) {
    return 'Supported EGT Sensors (Bank $bank)';
  }

  @override
  String sensorLabelIndex(int index) {
    return 'Sensor $index';
  }

  @override
  String get cumulativeTitle => 'Cumulative Value / Status';

  @override
  String get cumulativeDesc =>
      'Continuous count or text status sensors do not support oscillation statistics.';

  @override
  String get setGraphFps => 'Graph refresh rate';

  @override
  String get setGraphFpsDesc =>
      'Adjust visual smoothness (FPS) for sensor charts';
}
