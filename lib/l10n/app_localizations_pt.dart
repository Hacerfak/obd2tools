// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'Sensores';

  @override
  String get tabHud => 'Painel';

  @override
  String get tabTests => 'Testes';

  @override
  String get tabFaults => 'Falhas';

  @override
  String get tabMore => 'Mais';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnSave => 'Salvar';

  @override
  String get btnSend => 'Enviar';

  @override
  String get btnRefresh => 'Atualizar';

  @override
  String get connTitle => 'Conectar ao Scanner';

  @override
  String get connPaired => 'Dispositivos Pareados';

  @override
  String get connNearby => 'Dispositivos Próximos';

  @override
  String get connNoDevices => 'Nenhum aparelho encontrado.';

  @override
  String get connSearching => 'Buscando...';

  @override
  String get connSearchNew => 'Buscar Novos Dispositivos';

  @override
  String get connEstablishing => 'Estabelecendo conexão segura...';

  @override
  String get connWaitKey => 'Gire a chave na ignição para ligar o painel.';

  @override
  String get connMapping => 'Mapeando sensores suportados pela ECU...';

  @override
  String get connSuccess => 'Conexão Bem-Sucedida!';

  @override
  String get sensTitle => 'Sensores Mapeados';

  @override
  String get sensNone => 'Nenhum sensor encontrado.';

  @override
  String get sensInstant => 'Valor Instantâneo';

  @override
  String get sensRecent => 'Comportamento Recente';

  @override
  String get sensReading => 'Lendo dados do CAN Bus...';

  @override
  String get sensNoHistory => 'Histórico não aplicável para status em texto.';

  @override
  String get hudManage => 'Gerenciar Sensores';

  @override
  String get hudFullscreen => 'Tela Cheia';

  @override
  String get hudImmersive => 'Modo Imersivo';

  @override
  String get hudImmersiveDesc =>
      'Dê dois toques na tela para entrar ou sair da Tela Cheia.';

  @override
  String get hudGotIt => 'Entendi';

  @override
  String get hudConfig => 'Configurar Painel';

  @override
  String get hudSelected => 'Sensores Selecionados';

  @override
  String get hudAvailable => 'DISPONÍVEIS';

  @override
  String get hudSearch => 'Pesquisar sensor...';

  @override
  String get testTitle => 'Resultados de testes da ECU';

  @override
  String get testConsulting =>
      'Consulting monitores e limites de testes...\nPor favor, aguarde.';

  @override
  String get testNone => 'Nenhum teste interno encontrado.';

  @override
  String get testWaiting => 'Aguardando Ciclo de Condução';

  @override
  String get testPassed => 'Aprovado';

  @override
  String get testFailed => 'Falha no Limite';

  @override
  String get faultTitle => 'Diagnóstico (DTC)';

  @override
  String get faultClearMil => 'Apagar Luz de Injeção?';

  @override
  String get faultClearDesc =>
      'Esta ação vai resetar a memória de falhas e o Freeze Frame da injeção. Certifique-se de estar com a CHAVE LIGADA e o MOTOR DESLIGADO.';

  @override
  String get faultYesClear => 'Sim, Apagar!';

  @override
  String get faultAll => 'Todas';

  @override
  String get faultConfirmed => 'Confirmadas';

  @override
  String get faultPending => 'Em avaliação';

  @override
  String get faultPermanent => 'Monitorada pela ECU';

  @override
  String get faultReading =>
      'Lendo memória da ECU e dados congelados...\nPor favor, aguarde.';

  @override
  String get faultNone => 'Nenhuma falha encontrada!';

  @override
  String get infoTitle => 'Informações do Veículo';

  @override
  String get infoConsulting =>
      'Consultando módulos e calibrações da ECU...\nPor favor, aguarde.';

  @override
  String get infoNone =>
      'Nenhuma informação encontrada.\nO veículo pode não suportar o Modo 09.';

  @override
  String get setTitle => 'Configurações do Sistema';

  @override
  String get setColor => 'Paleta de Cores';

  @override
  String get setThemeLight => 'Tema Claro';

  @override
  String get setThemeDark => 'Tema Escuro';

  @override
  String get setMainColor => 'Cor Principal (Tema/Neutros)';

  @override
  String get setNormalColor => 'Status Normal (Saudável)';

  @override
  String get setWarningColor => 'Status Atenção (Alerta)';

  @override
  String get setCriticalColor => 'Status Crítico (Perigo)';

  @override
  String get setRestoreColors => 'Restaurar Cores Padrão';

  @override
  String get setPerf => 'Performance e Economia';

  @override
  String get setRate => 'Taxa de Atualização dos Sensores';

  @override
  String get setRateDesc => 'Aumente o tempo se o celular estiver aquecendo';

  @override
  String get setRateMax => 'Máxima';

  @override
  String get setRateFast => 'Rápido';

  @override
  String get setRateNormal => 'Normal';

  @override
  String get setRateEco => 'Econômico';

  @override
  String get dbgTitle => 'Terminal de Diagnóstico';

  @override
  String get dbgHeader => 'Header';

  @override
  String get dbgCommand => 'Comando (PID/AT)';

  @override
  String get dbgFormula => 'Fórmula Customizada';

  @override
  String get dbgStop => 'Parar Varredura';

  @override
  String get dbgScan => 'Varredura Força Bruta';

  @override
  String get dbgClear => 'Limpar Terminal';

  @override
  String get dbgExport => 'Exportar Logs';

  @override
  String get dbgEmpty => 'O terminal está vazio. Nada para exportar.';

  @override
  String get dbgSaved => 'Arquivo salvo com sucesso em:';

  @override
  String connSensorsMapped(int count) {
    return '$count sensores mapeados';
  }

  @override
  String get connSnackSavedNotFound =>
      'O scanner salvo não foi encontrado. Selecione na lista.';

  @override
  String get connSnackConnFailed =>
      'Falha ao conectar. Tente reiniciar o Bluetooth.';

  @override
  String get themeSystemTooltip => 'Tema: Sistema';

  @override
  String get themeLightTooltip => 'Tema: Claro';

  @override
  String get themeDarkTooltip => 'Tema: Escuro';

  @override
  String get statusDisconnected => 'Desconectado';

  @override
  String get statusConnected => 'ECU Online';

  @override
  String get statusHibernating => 'ECU Hibernando (Chave Desligada)';

  @override
  String get btnDisconnect => 'Desconectar';

  @override
  String get moreMenuTitle => 'Mais Opções';

  @override
  String get moreDiagSection => 'DIAGNÓSTICO AVANÇADO';

  @override
  String get moreInfoDesc => 'Chassi, CVN, Monitores Modo 09';

  @override
  String get moreTerminalDesc => 'Envio de PIDs e Comandos AT manuais';

  @override
  String get moreAppSection => 'APLICATIVO';

  @override
  String get moreSettings => 'Ajustes';

  @override
  String get moreSettingsDesc => 'Conexão, Protocolos e Preferências';

  @override
  String setChooseColor(String colorName) {
    return 'Escolher cor: $colorName';
  }

  @override
  String get btnApply => 'Aplicar';

  @override
  String get testValue => 'Valor';

  @override
  String get testMin => 'Mín';

  @override
  String get testMax => 'Máx';

  @override
  String get sensWaitGraph => '(Aguarde o preenchimento do gráfico)';

  @override
  String get faultDetailsTitle => 'Detalhes da Falha';

  @override
  String get faultDescConfirmed =>
      'Acende a luz. O problema está ocorrendo ou ocorreu agora.';

  @override
  String get faultDescPending =>
      'ECU detectou anomalia, mas precisa de mais ciclos para confirmar.';

  @override
  String get faultDescPermanent =>
      'Falha grave. Só apaga após o conserto e rodagem do veículo.';

  @override
  String get faultFreezeFrameTitle => 'Dados Congelados (Freeze Frame):';

  @override
  String dbgExportError(String error) {
    return 'Erro ao exportar: $error';
  }

  @override
  String get dbgScanTitle => 'Varredura de PIDs (Força Bruta)';

  @override
  String get dbgScanHeaderHint => 'Header (Opcional, ex: 7E0)';

  @override
  String get dbgScanPrefixHint => 'Modo/Prefixo (ex: 22)';

  @override
  String get dbgScanStartHint => 'Início Hex (ex: 1100)';

  @override
  String get dbgScanEndHint => 'Fim Hex (ex: 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ Atenção: A varredura enviará requisições sequenciais contínuas. Faixas muito grandes podem demorar vários minutos.';

  @override
  String get btnStart => 'Iniciar';

  @override
  String get dbgErrorBounds => 'Início maior que o fim';

  @override
  String dbgScanStarting(String start, String end) {
    return 'Iniciando varredura de $start até $end...';
  }

  @override
  String get dbgErrorHex =>
      'Erro nos parâmetros hexadecimais! Verifique a digitação.';

  @override
  String get dbgScanComplete => 'Varredura Concluída!';

  @override
  String dbgFormulaResult(String result) {
    return 'Resultado (Fórmula): $result';
  }

  @override
  String get dbgFormulaError =>
      'Erro: Falha ao interpretar a fórmula. Verifique a sintaxe.';

  @override
  String get dbgScanCancelled => 'Varredura cancelada pelo usuário.';

  @override
  String get techLibTitle => 'Biblioteca Técnica';

  @override
  String get techHowItWorks => 'Como este sensor funciona?';

  @override
  String get techWhatIsIt => 'O que é?';

  @override
  String get techFunction => 'Função';

  @override
  String get techImpact => 'Impacto no Sistema';

  @override
  String get dtcSymptoms => 'Sintomas Comuns';

  @override
  String get dtcCauses => 'Possíveis Causas';

  @override
  String get dtcResolution => 'Como Testar e Resolver';

  @override
  String get errBleDisconnected => 'Conexão Bluetooth perdida!';
}
