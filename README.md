# 🚗 Smart OBD-II Scanner (ODB2Tools)

Um aplicativo de diagnóstico automotivo de alto desempenho desenvolvido em **Flutter**. Este projeto conecta-se a adaptadores Bluetooth ELM327 para ler, em tempo real, a telemetria e as informações vitais da Injeção Eletrônica (ECU) do veículo via rede CAN Bus.

## ✨ Destaques da Arquitetura

Diferente de scanners genéricos simples, este projeto foi construído com foco em **baixa latência** e **robustez de dados**, implementando técnicas avançadas de comunicação:

*   **⚡ Multi-PID Polling:** Otimiza o barramento CAN agrupando múltiplas requisições de sensores em um único comando (ex: Carga, Temp, MAP e RPM simultâneos), reduzindo a latência pela metade.
*   **🛡️ Tokenization Parser:** Um analisador léxico customizado e à prova de falhas que limpa a sujeira do protocolo CAN (fragmentação `0:`, `1:`, bytes de preenchimento `AA` e colisões de Hex/ASCII), garantindo dados 100% confiáveis.
*   **🏗️ Arquitetura S.O.L.I.D:** Separação clara entre a Camada de Conexão, o Motor de Varredura e Parsers Especialistas para cada Modo do padrão SAE J1979.

## 🛠️ Funcionalidades Suportadas

O aplicativo atualmente suporta os seguintes serviços da norma OBD-II:

### ⏱️ Modo 01 (Dados em Tempo Real)
*   `04` - Carga Calculada do Motor (%)
*   `05` - Temperatura do Arrefecimento (°C)
*   `0B` - Pressão Absoluta do Coletor - MAP (kPa)
*   `0C` - Rotação do Motor (RPM)
*   *(Expansível para mais de 200 PIDs)*

### ℹ️ Modo 09 (Informações do Veículo)
*   `02` - Número do Chassi (VIN)
*   `04` - ID de Calibração da ECU
*   `06` - CVN (Calibration Verification Number)
*   `0A` - Nome da ECU

## 🚀 Próximos Passos (Roadmap)

- [ ] Implementação de Gerenciamento de Estado com **Riverpod**.
- [ ] Criação de um Dashboard (Painel de Instrumentos) com *Gauges* dinâmicos.
- [ ] Implementação do Modo 03 (Leitura de Códigos de Falha / DTCs).
- [ ] Implementação do Modo 04 (Limpeza de Falhas e reset da luz de injeção).

Desenvolvido com 💙 em Dart & Flutter.