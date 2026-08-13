// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'センサー';

  @override
  String get tabHud => 'ダッシュボード';

  @override
  String get tabTests => 'テスト';

  @override
  String get tabFaults => 'エラー';

  @override
  String get tabMore => 'さらに';

  @override
  String get btnCancel => 'キャンセル';

  @override
  String get btnSave => '保存';

  @override
  String get btnSend => '送信';

  @override
  String get btnRefresh => '更新';

  @override
  String get connTitle => 'スキャナーに接続';

  @override
  String get connPaired => 'ペアリング済みデバイス';

  @override
  String get connNearby => '近くのデバイス';

  @override
  String get connNoDevices => 'デバイスが見つかりません。';

  @override
  String get connSearching => '検索中...';

  @override
  String get connSearchNew => '新しいデバイスを検索';

  @override
  String get connEstablishing => '安全な接続を確立しています...';

  @override
  String get connWaitKey => 'イグニッションキーを回してダッシュボードの電源をオンにしてください。';

  @override
  String get connMapping => 'サポートされているセンサーをマッピングしています...';

  @override
  String get connSuccess => '接続に成功しました！';

  @override
  String get sensTitle => 'マッピングされたセンサー';

  @override
  String get sensNone => 'センサーが見つかりません。';

  @override
  String get sensInstant => '瞬間値';

  @override
  String get sensRecent => '最近の動作';

  @override
  String get sensReading => 'CANバスデータを読み取っています...';

  @override
  String get sensNoHistory => 'テキストステータスに履歴は適用されません。';

  @override
  String get hudManage => 'センサーの管理';

  @override
  String get hudFullscreen => 'フルスクリーン';

  @override
  String get hudImmersive => '没入モード';

  @override
  String get hudImmersiveDesc => '画面をダブルタップしてフルスクリーンに切り替えます。';

  @override
  String get hudGotIt => '了解';

  @override
  String get hudConfig => 'ダッシュボードの設定';

  @override
  String get hudSelected => '選択されたセンサー';

  @override
  String get hudAvailable => '利用可能';

  @override
  String get hudSearch => 'センサーを検索...';

  @override
  String get testTitle => 'ECUテスト結果';

  @override
  String get testConsulting => 'モニターとテストの制限を照会しています...\nお待ちください。';

  @override
  String get testNone => '内部テストが見つかりません。';

  @override
  String get testWaiting => '運転サイクルを待機中';

  @override
  String get testPassed => '合格';

  @override
  String get testFailed => '制限超過';

  @override
  String get faultTitle => '診断 (DTC)';

  @override
  String get faultClearMil => 'エンジンチェックランプを消去しますか？';

  @override
  String get faultClearDesc =>
      'この操作により、障害メモリとフリーズフレームがリセットされます。イグニッションがオン、エンジンがオフであることを確認してください。';

  @override
  String get faultYesClear => 'はい、消去します！';

  @override
  String get faultAll => 'すべて';

  @override
  String get faultConfirmed => '確認済み';

  @override
  String get faultPending => '保留中';

  @override
  String get faultPermanent => '永久';

  @override
  String get faultReading => 'ECUメモリとフリーズフレームを読み取っています...\nお待ちください。';

  @override
  String get faultNone => 'エラーは見つかりませんでした！';

  @override
  String get infoTitle => '車両情報';

  @override
  String get infoConsulting => 'ECUモジュールとキャリブレーションを照会しています...\nお待ちください。';

  @override
  String get infoNone => '情報が見つかりません。\n車両がモード09をサポートしていない可能性があります。';

  @override
  String get setTitle => 'システム設定';

  @override
  String get setColor => 'カラーパレット';

  @override
  String get setThemeLight => 'ライトテーマ';

  @override
  String get setThemeDark => 'ダークテーマ';

  @override
  String get setMainColor => 'メインカラー (テーマ/ニュートラル)';

  @override
  String get setNormalColor => '通常ステータス (正常)';

  @override
  String get setWarningColor => '警告ステータス (注意)';

  @override
  String get setCriticalColor => 'クリティカルステータス (危険)';

  @override
  String get setRestoreColors => 'デフォルトの色を復元';

  @override
  String get setPerf => 'パフォーマンスとバッテリー';

  @override
  String get setRate => 'センサー更新レート';

  @override
  String get setRateDesc => '電話が熱くなる場合は時間を増やしてください';

  @override
  String get setRateMax => '最大';

  @override
  String get setRateFast => '速い';

  @override
  String get setRateNormal => '通常';

  @override
  String get setRateEco => 'エコ';

  @override
  String get dbgTitle => '診断ターミナル';

  @override
  String get dbgHeader => 'Header (任意)';

  @override
  String get dbgCommand => 'コマンド (PID/AT)';

  @override
  String get dbgFormula => 'カスタム数式';

  @override
  String get dbgStop => 'スキャンを停止';

  @override
  String get dbgScan => 'ブルートフォーススキャン';

  @override
  String get dbgClear => 'ターミナルをクリア';

  @override
  String get dbgExport => 'ログをエクスポート';

  @override
  String get dbgEmpty => 'ターミナルが空です。エクスポートするものはありません。';

  @override
  String get dbgSaved => 'ファイルが正常に保存されました：';

  @override
  String connSensorsMapped(int count) {
    return '$count 個のセンサーをマッピングしました';
  }

  @override
  String get connSnackSavedNotFound => '保存されたスキャナーが見つかりません。リストから選択してください。';

  @override
  String get connSnackConnFailed => '接続に失敗しました。Bluetoothを再起動してみてください。';

  @override
  String get themeSystemTooltip => 'テーマ: システム';

  @override
  String get themeLightTooltip => 'テーマ: ライト';

  @override
  String get themeDarkTooltip => 'テーマ: ダーク';

  @override
  String get statusDisconnected => '切断されました';

  @override
  String get statusConnected => 'ECU オンライン';

  @override
  String get statusHibernating => 'ECU 休止中 (イグニッション オフ)';

  @override
  String get btnDisconnect => '切断';

  @override
  String get moreMenuTitle => 'その他のオプション';

  @override
  String get moreDiagSection => '高度な診断';

  @override
  String get moreInfoDesc => 'VIN、CVN、モード09モニター';

  @override
  String get moreTerminalDesc => '手動PIDとATコマンドを送信';

  @override
  String get moreAppSection => 'アプリケーション';

  @override
  String get moreSettings => '設定';

  @override
  String get moreSettingsDesc => '接続、プロトコル、および設定';

  @override
  String setChooseColor(String colorName) {
    return '色を選択: $colorName';
  }

  @override
  String get btnApply => '適用する';
}
