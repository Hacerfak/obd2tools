// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'Датчики';

  @override
  String get tabHud => 'Панель';

  @override
  String get tabTests => 'Тесты';

  @override
  String get tabFaults => 'Ошибки';

  @override
  String get tabMore => 'Еще';

  @override
  String get btnCancel => 'Отмена';

  @override
  String get btnSave => 'Сохранить';

  @override
  String get btnSend => 'Отправить';

  @override
  String get btnRefresh => 'Обновить';

  @override
  String get connTitle => 'Подключение к сканеру';

  @override
  String get connPaired => 'Сопряженные устройства';

  @override
  String get connNearby => 'Устройства поблизости';

  @override
  String get connNoDevices => 'Устройства не найдены.';

  @override
  String get connSearching => 'Поиск...';

  @override
  String get connSearchNew => 'Поиск новых устройств';

  @override
  String get connEstablishing => 'Установка защищенного соединения...';

  @override
  String get connWaitKey =>
      'Включите зажигание, чтобы включить панель приборов.';

  @override
  String get connMapping => 'Сопоставление поддерживаемых датчиков...';

  @override
  String get connSuccess => 'Подключение успешно!';

  @override
  String get sensTitle => 'Найденные датчики';

  @override
  String get sensNone => 'Датчики не найдены.';

  @override
  String get sensInstant => 'Текущее значение';

  @override
  String get sensRecent => 'Недавнее поведение';

  @override
  String get sensReading => 'Чтение данных шины CAN...';

  @override
  String get sensNoHistory => 'История неприменима для текстовых статусов.';

  @override
  String get hudManage => 'Управление датчиками';

  @override
  String get hudFullscreen => 'Полный экран';

  @override
  String get hudImmersive => 'Иммерсивный режим';

  @override
  String get hudImmersiveDesc =>
      'Дважды коснитесь экрана, чтобы войти или выйти из полноэкранного режима.';

  @override
  String get hudGotIt => 'Понятно';

  @override
  String get hudConfig => 'Настроить панель';

  @override
  String get hudSelected => 'Выбранные датчики';

  @override
  String get hudAvailable => 'ДОСТУПНЫЕ';

  @override
  String get hudSearch => 'Поиск датчика...';

  @override
  String get testTitle => 'Результаты тестов ЭБУ';

  @override
  String get testConsulting =>
      'Опрос мониторов и лимитов тестов...\nПожалуйста, подождите.';

  @override
  String get testNone => 'Внутренние тесты не найдены.';

  @override
  String get testWaiting => 'Ожидание ездового цикла';

  @override
  String get testPassed => 'Пройден';

  @override
  String get testFailed => 'Превышен предел';

  @override
  String get faultTitle => 'Диагностика (DTC)';

  @override
  String get faultClearMil => 'Сбросить Check Engine?';

  @override
  String get faultClearDesc =>
      'Это действие сбросит память ошибок и Freeze Frame. Убедитесь, что ЗАЖИГАНИЕ ВКЛЮЧЕНО, а ДВИГАТЕЛЬ ЗАГЛУШЕН.';

  @override
  String get faultYesClear => 'Да, сбросить!';

  @override
  String get faultAll => 'Все';

  @override
  String get faultConfirmed => 'Подтвержденные';

  @override
  String get faultPending => 'В ожидании';

  @override
  String get faultPermanent => 'Постоянные';

  @override
  String get faultReading =>
      'Чтение памяти ЭБУ и Freeze Frames...\nПожалуйста, подождите.';

  @override
  String get faultNone => 'Ошибки не найдены!';

  @override
  String get infoTitle => 'Информация об автомобиле';

  @override
  String get infoConsulting =>
      'Опрос модулей ЭБУ и калибровок...\nПожалуйста, подождите.';

  @override
  String get infoNone =>
      'Информация не найдена.\nАвтомобиль может не поддерживать Режим 09.';

  @override
  String get setTitle => 'Настройки системы';

  @override
  String get setColor => 'Цветовая палитра';

  @override
  String get setThemeLight => 'Светлая тема';

  @override
  String get setThemeDark => 'Темная тема';

  @override
  String get setMainColor => 'Основной цвет (Тема)';

  @override
  String get setNormalColor => 'Нормальный статус (Исправно)';

  @override
  String get setWarningColor => 'Статус предупреждения (Внимание)';

  @override
  String get setCriticalColor => 'Критический статус (Опасность)';

  @override
  String get setRestoreColors => 'Восстановить цвета по умолчанию';

  @override
  String get setPerf => 'Производительность и батарея';

  @override
  String get setRate => 'Частота обновления датчиков';

  @override
  String get setRateDesc => 'Увеличьте время, если телефон нагревается';

  @override
  String get setRateMax => 'Максимальная';

  @override
  String get setRateFast => 'Быстро';

  @override
  String get setRateNormal => 'Нормально';

  @override
  String get setRateEco => 'Эко';

  @override
  String get dbgTitle => 'Диагностический терминал';

  @override
  String get dbgHeader => 'Header (Опц)';

  @override
  String get dbgCommand => 'Команда (PID/AT)';

  @override
  String get dbgFormula => 'Своя формула';

  @override
  String get dbgStop => 'Остановить сканирование';

  @override
  String get dbgScan => 'Brute-force сканирование';

  @override
  String get dbgClear => 'Очистить терминал';

  @override
  String get dbgExport => 'Экспорт журналов';

  @override
  String get dbgEmpty => 'Терминал пуст. Нечего экспортировать.';

  @override
  String get dbgSaved => 'Файл успешно сохранен в:';

  @override
  String connSensorsMapped(int count) {
    return 'Найдено датчиков: $count';
  }

  @override
  String get connSnackSavedNotFound =>
      'Сохраненный сканер не найден. Выберите из списка.';

  @override
  String get connSnackConnFailed =>
      'Ошибка подключения. Попробуйте перезапустить Bluetooth.';

  @override
  String get themeSystemTooltip => 'Тема: Система';

  @override
  String get themeLightTooltip => 'Тема: Светлая';

  @override
  String get themeDarkTooltip => 'Тема: Темная';

  @override
  String get statusDisconnected => 'Отключено';

  @override
  String get statusConnected => 'ЭБУ в сети';

  @override
  String get statusHibernating => 'Спящий режим ЭБУ (Зажигание выкл)';

  @override
  String get btnDisconnect => 'Отключить';

  @override
  String get moreMenuTitle => 'Больше опций';

  @override
  String get moreDiagSection => 'РАСШИРЕННАЯ ДИАГНОСТИКА';

  @override
  String get moreInfoDesc => 'VIN, CVN, Мониторы Режима 09';

  @override
  String get moreTerminalDesc => 'Отправка ручных PID и AT-команд';

  @override
  String get moreAppSection => 'ПРИЛОЖЕНИЕ';

  @override
  String get moreSettings => 'Настройки';

  @override
  String get moreSettingsDesc => 'Подключение, Протоколы и Настройки';

  @override
  String setChooseColor(String colorName) {
    return 'Выберите цвет: $colorName';
  }

  @override
  String get btnApply => 'Применить';

  @override
  String get testValue => 'Значение';

  @override
  String get testMin => 'Мин';

  @override
  String get testMax => 'Макс';

  @override
  String get sensWaitGraph => '(Подождите заполнения графика)';

  @override
  String get faultDetailsTitle => 'Детали ошибки';

  @override
  String get faultDescConfirmed =>
      'Включает Check Engine. Проблема возникает сейчас или возникла недавно.';

  @override
  String get faultDescPending =>
      'ЭБУ обнаружил аномалию, но нужно больше циклов для подтверждения.';

  @override
  String get faultDescPermanent =>
      'Серьезная ошибка. Сбрасывается только после ремонта и поездки.';

  @override
  String get faultFreezeFrameTitle => 'Сохраненные данные (Freeze Frame):';

  @override
  String dbgExportError(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get dbgScanTitle => 'Brute-Force сканирование PID';

  @override
  String get dbgScanHeaderHint => 'Header (Опционально, напр. 7E0)';

  @override
  String get dbgScanPrefixHint => 'Режим/Префикс (напр. 22)';

  @override
  String get dbgScanStartHint => 'Начало Hex (напр. 1100)';

  @override
  String get dbgScanEndHint => 'Конец Hex (напр. 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ Внимание: Сканирование отправляет непрерывные запросы. Большие диапазоны могут занять несколько минут.';

  @override
  String get btnStart => 'Начать';

  @override
  String get dbgErrorBounds => 'Начало больше конца';

  @override
  String dbgScanStarting(String start, String end) {
    return 'Запуск сканирования от $start до $end...';
  }

  @override
  String get dbgErrorHex =>
      'Ошибка в шестнадцатеричных параметрах! Проверьте ввод.';

  @override
  String get dbgScanComplete => 'Сканирование завершено!';

  @override
  String dbgFormulaResult(String result) {
    return 'Результат (Формула): $result';
  }

  @override
  String get dbgFormulaError =>
      'Ошибка: Не удалось интерпретировать формулу. Проверьте синтаксис.';

  @override
  String get dbgScanCancelled => 'Сканирование отменено пользователем.';

  @override
  String get techLibTitle => 'Техническая библиотека';

  @override
  String get techHowItWorks => 'Как работает этот датчик?';

  @override
  String get techWhatIsIt => 'Что это?';

  @override
  String get techFunction => 'Функция';

  @override
  String get techImpact => 'Влияние на систему';

  @override
  String get dtcSymptoms => 'Общие симптомы';

  @override
  String get dtcCauses => 'Возможные причины';

  @override
  String get dtcResolution => 'Как проверить и исправить';

  @override
  String get errBleDisconnected => 'Соединение Bluetooth потеряно!';
}
