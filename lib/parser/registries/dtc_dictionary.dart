class DtcInfo {
  final String title;
  final String description;
  const DtcInfo(this.title, this.description);
}

final Map<String, DtcInfo> dtcDictionary = {
  // --- TEMPERATURA E AR ---
  "P0118": const DtcInfo(
    "Sensor de Temperatura do Motor (ECT) - Circuito Alto",
    "A injeção detectou uma voltagem excessivamente alta no circuito do sensor de temperatura da água. Isso geralmente indica um circuito aberto (fio rompido ou sensor desconectado). A ECU adotará uma temperatura de emergência (ex: 80ºC) e ligará a ventoinha no máximo para proteger o motor.",
  ),
  "P0113": const DtcInfo(
    "Sensor de Temperatura do Ar Admissão (IAT) - Circuito Alto",
    "O circuito do sensor IAT está aberto. Geralmente causado por cabo desconectado ou rompido.",
  ),
  "P0102": const DtcInfo(
    "Sensor de Fluxo de Ar (MAF) - Circuito Baixo",
    "A voltagem do sensor MAF está abaixo do limite mínimo. Pode indicar entrada falsa de ar (furo na mangueira), sensor muito sujo ou desconectado.",
  ),
  // --- SONDAS E CATALISADOR ---
  "P0130": const DtcInfo(
    "Circuito do Sensor de O2 (Banco 1, Sensor 1) - Defeito",
    "A Sonda Lambda primária não está variando a voltagem corretamente. Pode ser sonda travada ou defeito no aquecedor.",
  ),
  "P0420": const DtcInfo(
    "Eficiência do Sistema Catalítico Abaixo do Limite (Banco 1)",
    "O clássico erro de Catalisador. A Sonda Lambda secundária está copiando a leitura da primária, indicando que o catalisador não está mais filtrando os gases. Pode ser desgaste do catalisador ou combustível adulterado.",
  ),
  // --- IGNIÇÃO ---
  "P0300": const DtcInfo(
    "Múltiplas Falhas de Ignição Detectadas (Random Misfire)",
    "O motor está falhando de forma aleatória em vários cilindros. Geralmente causado por combustível ruim, pressão de bomba baixa ou bobina trincada.",
  ),
};

/// Busca a falha no dicionário. Se não achar, retorna um texto genérico.
DtcInfo getDtcExplanation(String code) {
  return dtcDictionary[code] ??
      DtcInfo(
        "Falha Específica da Montadora",
        "A descrição exata deste código requer consulta ao manual técnico de reparações do seu veículo.",
      );
}
