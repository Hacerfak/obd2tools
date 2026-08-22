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
      'Consultando monitores e limites de testes...\nPor favor, aguarde.';

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

  @override
  String get aboutTitle => 'Sobre o App';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutTheProjectTitle => 'O Projeto';

  @override
  String get aboutTheProjectDesc =>
      'O OBD2 Tools foi desenvolvido com o objetivo de democratizar o diagnóstico automotivo. Combinando uma interface moderna com telemetria em tempo real, este aplicativo transforma o seu smartphone em um scanner profissional, permitindo que entusiastas e mecânicos entendam a saúde do veículo de forma clara, rápida e objetiva.';

  @override
  String get aboutDeveloperTitle => 'Desenvolvedor';

  @override
  String get aboutDeveloperRole => 'Aprendiz';

  @override
  String get aboutDeveloperDesc =>
      'Apaixonado por tecnologia e pelo mundo automotivo. Criando soluções para simplificar o dia a dia.';

  @override
  String get unitCounts => 'contas';

  @override
  String midO2Sensor(Object hex) {
    return 'Sonda Lambda (O2) - Sensor 0x$hex';
  }

  @override
  String midCatalyst(Object bank) {
    return 'Catalisador - Banco $bank';
  }

  @override
  String midEgr(Object bank) {
    return 'Sistema EGR - Banco $bank';
  }

  @override
  String midVvt(Object bank) {
    return 'Comando de Válvulas (VVT) - Banco $bank';
  }

  @override
  String get midEvapGeneral => 'EVAP - Monitor Geral do Tanque';

  @override
  String get midEvapVacuumInit => 'EVAP - Estanqueidade / Vácuo Inicial';

  @override
  String get midEvapGrossLeak => 'EVAP - Teste de Grande Vazamento (0.090\")';

  @override
  String get midEvapMedLeak => 'EVAP - Teste de Vazamento Médio (0.040\")';

  @override
  String get midEvapSmallLeak => 'EVAP - Teste de Micro Vazamento (0.020\")';

  @override
  String get midEvapPurgeValve => 'EVAP - Válvula de Purga do Canister';

  @override
  String get midEvapVentValve => 'EVAP - Válvula de Ventilação (Vent Valve)';

  @override
  String midO2Heater(Object hex) {
    return 'Aquecedor Sonda Lambda - Sensor 0x$hex';
  }

  @override
  String midSecAir(Object bank) {
    return 'Sistema de Ar Secundário - Banco $bank';
  }

  @override
  String midFuelSystem(Object bank) {
    return 'Sistema de Combustível - Banco $bank';
  }

  @override
  String midMisfireCylinder(Object cylinder) {
    return 'Misfire (Falha de Ignição) - Cilindro $cylinder';
  }

  @override
  String get midMisfireAll => 'Misfire (Falha de Ignição) - Todos os Cilindros';

  @override
  String midProprietary(Object hex) {
    return 'Monitor Proprietário (0x$hex)';
  }

  @override
  String midObd(Object hex) {
    return 'Monitor OBD (0x$hex)';
  }

  @override
  String get tidO2RichToLean => 'Tempo de Resposta (Rica para Magra)';

  @override
  String get tidO2LeanToRich => 'Tempo de Resposta (Magra para Rica)';

  @override
  String get tidO2MinVoltage => 'Tensão Mínima Medida';

  @override
  String get tidO2MaxVoltage => 'Tensão Máxima Medida';

  @override
  String get tidMisfireEwma => 'Contagem de Misfire (Média Móvel EWMA)';

  @override
  String get tidMisfireCurrent => 'Contagem de Misfire (Ciclo Atual)';

  @override
  String get tidEvapPurgeRate => 'Taxa de Purga/Vazamento EVAP';

  @override
  String get tidEvapInitGrad => 'Gradiente de Pressão Inicial EVAP';

  @override
  String get tidEvapTankDelta => 'Variação de Pressão do Tanque (Delta)';

  @override
  String get tidEvapVacDecay => 'Retenção / Queda de Vácuo EVAP';

  @override
  String get tidEvapInitStab => 'Estabilidade de Pressão Inicial do Tanque';

  @override
  String get tidEvapCanisterVac => 'Retenção de Vácuo Residual do Canister';

  @override
  String get tidEvapVentFlow => 'Fluxo / Bloqueio da Válvula Vent do Canister';

  @override
  String get tidEvapSolResponse => 'Resposta do Solenoide de Purga';

  @override
  String get tidEvapLinePress => 'Pressão da Linha de Purga sob Carga';

  @override
  String get tidEvapSensorResp => 'Tempo de Resposta do Sensor de Pressão EVAP';

  @override
  String get tidEvapSmallDecay =>
      'Decaimento de Vácuo (Micro-Vazamento 0.020\")';

  @override
  String get tidEvapMedDecay =>
      'Variação de Pressão por Evaporação (Vazamento 0.040\")';

  @override
  String get tidEvapGrossHold =>
      'Retenção de Vácuo em Carga (Grande Vazamento 0.090\")';

  @override
  String get tidEvapMinPurgePress => 'Pressão Mínima Atingida na Purga';

  @override
  String tidGeneric(Object hex) {
    return 'Teste 0x$hex';
  }
}
