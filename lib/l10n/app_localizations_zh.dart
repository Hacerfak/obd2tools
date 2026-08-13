// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => '传感器';

  @override
  String get tabHud => '仪表盘';

  @override
  String get tabTests => '测试';

  @override
  String get tabFaults => '故障码';

  @override
  String get tabMore => '更多';

  @override
  String get btnCancel => '取消';

  @override
  String get btnSave => '保存';

  @override
  String get btnSend => '发送';

  @override
  String get btnRefresh => '刷新';

  @override
  String get connTitle => '连接到扫描仪';

  @override
  String get connPaired => '已配对设备';

  @override
  String get connNearby => '附近设备';

  @override
  String get connNoDevices => '未找到设备。';

  @override
  String get connSearching => '搜索中...';

  @override
  String get connSearchNew => '搜索新设备';

  @override
  String get connEstablishing => '正在建立安全连接...';

  @override
  String get connWaitKey => '请打开点火钥匙以为仪表盘供电。';

  @override
  String get connMapping => '正在映射支持的传感器...';

  @override
  String get connSuccess => '连接成功！';

  @override
  String get sensTitle => '映射的传感器';

  @override
  String get sensNone => '未找到传感器。';

  @override
  String get sensInstant => '瞬时值';

  @override
  String get sensRecent => '近期行为';

  @override
  String get sensReading => '正在读取 CAN 总线数据...';

  @override
  String get sensNoHistory => '历史记录不适用于文本状态。';

  @override
  String get hudManage => '管理传感器';

  @override
  String get hudFullscreen => '全屏';

  @override
  String get hudImmersive => '沉浸模式';

  @override
  String get hudImmersiveDesc => '双击屏幕以进入或退出全屏。';

  @override
  String get hudGotIt => '明白了';

  @override
  String get hudConfig => '配置仪表盘';

  @override
  String get hudSelected => '已选传感器';

  @override
  String get hudAvailable => '可用';

  @override
  String get hudSearch => '搜索传感器...';

  @override
  String get testTitle => 'ECU 测试结果';

  @override
  String get testConsulting => '正在查询监视器和测试限制...\n请稍候。';

  @override
  String get testNone => '未找到内部测试。';

  @override
  String get testWaiting => '等待驾驶循环';

  @override
  String get testPassed => '通过';

  @override
  String get testFailed => '超出限制';

  @override
  String get faultTitle => '诊断 (DTC)';

  @override
  String get faultClearMil => '清除发动机故障灯？';

  @override
  String get faultClearDesc => '此操作将重置故障内存和冻结帧。请确保点火开关已打开且发动机已关闭。';

  @override
  String get faultYesClear => '是的，清除！';

  @override
  String get faultAll => '全部';

  @override
  String get faultConfirmed => '已确认';

  @override
  String get faultPending => '待定';

  @override
  String get faultPermanent => '永久';

  @override
  String get faultReading => '正在读取 ECU 内存和冻结帧...\n请稍候。';

  @override
  String get faultNone => '未找到故障！';

  @override
  String get infoTitle => '车辆信息';

  @override
  String get infoConsulting => '正在查询 ECU 模块和校准...\n请稍候。';

  @override
  String get infoNone => '未找到信息。\n车辆可能不支持模式 09。';

  @override
  String get setTitle => '系统设置';

  @override
  String get setColor => '调色板';

  @override
  String get setThemeLight => '浅色主题';

  @override
  String get setThemeDark => '深色主题';

  @override
  String get setMainColor => '主色调 (主题/中性色)';

  @override
  String get setNormalColor => '正常状态 (健康)';

  @override
  String get setWarningColor => '警告状态 (警报)';

  @override
  String get setCriticalColor => '严重状态 (危险)';

  @override
  String get setRestoreColors => '恢复默认颜色';

  @override
  String get setPerf => '性能与电池';

  @override
  String get setRate => '传感器刷新率';

  @override
  String get setRateDesc => '如果手机发热，请增加时间';

  @override
  String get setRateMax => '最大';

  @override
  String get setRateFast => '快 (250毫秒)';

  @override
  String get setRateNormal => '正常 (0.5秒)';

  @override
  String get setRateEco => '节能 (1秒)';

  @override
  String get dbgTitle => '诊断终端';

  @override
  String get dbgHeader => 'Header (可选)';

  @override
  String get dbgCommand => '命令 (PID/AT)';

  @override
  String get dbgFormula => '自定义公式';

  @override
  String get dbgStop => '停止扫描';

  @override
  String get dbgScan => '暴力扫描';

  @override
  String get dbgClear => '清除终端';

  @override
  String get dbgExport => '导出日志';

  @override
  String get dbgEmpty => '终端为空。没有可导出的内容。';

  @override
  String get dbgSaved => '文件已成功保存至：';
}
