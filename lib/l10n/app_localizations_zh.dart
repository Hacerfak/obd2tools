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
  String get setRateFast => '快';

  @override
  String get setRateNormal => '正常';

  @override
  String get setRateEco => '节能';

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

  @override
  String connSensorsMapped(int count) {
    return '已映射 $count 个传感器';
  }

  @override
  String get connSnackSavedNotFound => '未找到保存的扫描仪。请从列表中选择。';

  @override
  String get connSnackConnFailed => '连接失败。请尝试重新启动蓝牙。';

  @override
  String get themeSystemTooltip => '主题：系统';

  @override
  String get themeLightTooltip => '主题：浅色';

  @override
  String get themeDarkTooltip => '主题：深色';

  @override
  String get statusDisconnected => '已断开';

  @override
  String get statusConnected => 'ECU 在线';

  @override
  String get statusHibernating => 'ECU 休眠（点火关闭）';

  @override
  String get btnDisconnect => '断开连接';

  @override
  String get moreMenuTitle => '更多选项';

  @override
  String get moreDiagSection => '高级诊断';

  @override
  String get moreInfoDesc => 'VIN、CVN、模式 09 监视器';

  @override
  String get moreTerminalDesc => '发送手动 PID 和 AT 命令';

  @override
  String get moreAppSection => '应用';

  @override
  String get moreSettings => '设置';

  @override
  String get moreSettingsDesc => '连接、协议和偏好设置';

  @override
  String setChooseColor(String colorName) {
    return '选择颜色：$colorName';
  }

  @override
  String get btnApply => '应用';

  @override
  String get testValue => '值';

  @override
  String get testMin => '最小';

  @override
  String get testMax => '最大';

  @override
  String get sensWaitGraph => '（等待图表填充）';

  @override
  String get faultDetailsTitle => '故障详情';

  @override
  String get faultDescConfirmed => '点亮发动机故障灯。问题正在发生或最近发生过。';

  @override
  String get faultDescPending => 'ECU 检测到异常，但需要更多驾驶循环来确认。';

  @override
  String get faultDescPermanent => '严重故障。仅在维修和驾驶车辆后才会清除。';

  @override
  String get faultFreezeFrameTitle => '冻结帧数据 (Freeze Frame)：';

  @override
  String dbgExportError(String error) {
    return '导出错误：$error';
  }

  @override
  String get dbgScanTitle => 'PID 暴力扫描';

  @override
  String get dbgScanHeaderHint => 'Header（可选，例：7E0）';

  @override
  String get dbgScanPrefixHint => '模式/前缀（例：22）';

  @override
  String get dbgScanStartHint => '开始 Hex（例：1100）';

  @override
  String get dbgScanEndHint => '结束 Hex（例：11FF）';

  @override
  String get dbgScanWarning => '⚠️ 警告：扫描将发送连续的顺序请求。大范围可能需要几分钟的时间。';

  @override
  String get btnStart => '开始';

  @override
  String get dbgErrorBounds => '开始大于结束';

  @override
  String dbgScanStarting(String start, String end) {
    return '正在开始扫描从 $start 到 $end...';
  }

  @override
  String get dbgErrorHex => '十六进制参数错误！请检查您的输入。';

  @override
  String get dbgScanComplete => '扫描完成！';

  @override
  String dbgFormulaResult(String result) {
    return '结果（公式）：$result';
  }

  @override
  String get dbgFormulaError => '错误：无法解释公式。请检查语法。';

  @override
  String get dbgScanCancelled => '扫描已由用户取消。';

  @override
  String get techLibTitle => '技术资料库';

  @override
  String get techHowItWorks => '这个传感器是如何工作的？';

  @override
  String get techWhatIsIt => '这是什么？';

  @override
  String get techFunction => '功能';

  @override
  String get techImpact => '系统影响';

  @override
  String get dtcSymptoms => '常见症状';

  @override
  String get dtcCauses => '可能原因';

  @override
  String get dtcResolution => '如何测试和解决';

  @override
  String get errBleDisconnected => '蓝牙连接丢失！';

  @override
  String get aboutTitle => '关于应用';

  @override
  String get aboutVersion => '版本';

  @override
  String get aboutTheProjectTitle => '关于项目';

  @override
  String get aboutTheProjectDesc =>
      'OBD2 Tools 的开发旨在让汽车诊断变得平民化。结合现代界面和实时遥测技术，这款应用程序将您的智能手机变成一个专业的扫描仪，让爱好者和机械师能够清晰、快速、客观地了解车辆的健康状况。';

  @override
  String get aboutDeveloperTitle => '开发者';

  @override
  String get aboutDeveloperRole => '学徒';

  @override
  String get aboutDeveloperDesc => '热爱技术和汽车世界。创造解决方案以简化日常生活。';

  @override
  String get unitCounts => '计数';

  @override
  String midO2Sensor(Object hex) {
    return '氧传感器 - 传感器 0x$hex';
  }

  @override
  String midCatalyst(Object bank) {
    return '催化转换器 - 气缸排 $bank';
  }

  @override
  String midEgr(Object bank) {
    return 'EGR系统 - 气缸排 $bank';
  }

  @override
  String midVvt(Object bank) {
    return 'VVT系统 - 气缸排 $bank';
  }

  @override
  String get midEvapGeneral => 'EVAP - 油箱综合监测';

  @override
  String get midEvapVacuumInit => 'EVAP - 密封性/初始真空';

  @override
  String get midEvapGrossLeak => 'EVAP - 大泄漏测试 (0.090\")';

  @override
  String get midEvapMedLeak => 'EVAP - 中泄漏测试 (0.040\")';

  @override
  String get midEvapSmallLeak => 'EVAP - 微泄漏测试 (0.020\")';

  @override
  String get midEvapPurgeValve => 'EVAP - 碳罐清除阀';

  @override
  String get midEvapVentValve => 'EVAP - 通气阀';

  @override
  String midO2Heater(Object hex) {
    return '氧传感器加热器 - 传感器 0x$hex';
  }

  @override
  String midSecAir(Object bank) {
    return '二次空气系统 - 气缸排 $bank';
  }

  @override
  String midFuelSystem(Object bank) {
    return '燃油系统 - 气缸排 $bank';
  }

  @override
  String midMisfireCylinder(Object cylinder) {
    return '失火 - 气缸 $cylinder';
  }

  @override
  String get midMisfireAll => '失火 - 所有气缸';

  @override
  String midProprietary(Object hex) {
    return '专用监测器 (0x$hex)';
  }

  @override
  String midObd(Object hex) {
    return 'OBD监测器 (0x$hex)';
  }

  @override
  String get tidO2RichToLean => '响应时间（浓到稀）';

  @override
  String get tidO2LeanToRich => '响应时间（稀到浓）';

  @override
  String get tidO2MinVoltage => '最小测量电压';

  @override
  String get tidO2MaxVoltage => '最大测量电压';

  @override
  String get tidMisfireEwma => '失火次数（EWMA滑动平均）';

  @override
  String get tidMisfireCurrent => '失火次数（当前行程）';

  @override
  String get tidEvapPurgeRate => 'EVAP 清除/泄漏率';

  @override
  String get tidEvapInitGrad => 'EVAP 初始压力梯度';

  @override
  String get tidEvapTankDelta => '油箱压力变化';

  @override
  String get tidEvapVacDecay => 'EVAP 真空保持率';

  @override
  String get tidEvapInitStab => '初始油箱压力稳定性';

  @override
  String get tidEvapCanisterVac => '碳罐残余真空保持';

  @override
  String get tidEvapVentFlow => '通气阀流量';

  @override
  String get tidEvapSolResponse => '清除电磁阀响应';

  @override
  String get tidEvapLinePress => '负载下清除管路压力';

  @override
  String get tidEvapSensorResp => 'EVAP压力传感器响应时间';

  @override
  String get tidEvapSmallDecay => '真空衰减（微泄漏 0.020\"）';

  @override
  String get tidEvapMedDecay => '压力变化（中泄漏 0.040\"）';

  @override
  String get tidEvapGrossHold => '真空保持（大泄漏 0.090\"）';

  @override
  String get tidEvapMinPurgePress => '清除时达到最小压力';

  @override
  String tidGeneric(Object hex) {
    return '测试 0x$hex';
  }
}
