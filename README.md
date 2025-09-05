# 💰 Finoma

**Gestão Financeira Pessoal para iOS e macOS**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016%2B%20%7C%20macOS%2013%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue.svg)](https://developer.apple.com/xcode/swiftui/)

> Uma solução completa e moderna para controle financeiro pessoal, construída com Swift e SwiftUI, oferecendo tanto interface gráfica quanto linha de comando.

## ✨ Características

- 🏗️ **Arquitetura Modular**: Separação clara entre Core, Persistence, Services e UI
- 📱 **Multiplataforma**: Suporte nativo para iOS 16+ e macOS 13+
- 💾 **Persistência Flexível**: JSON local com possibilidade de migração para Core Data/SQLite
- 🔄 **Transações Recorrentes**: Automatização de receitas e despesas regulares
- 📊 **Relatórios Detalhados**: Análises mensais e categorizadas
- 🏷️ **Sistema de Tags**: Organização avançada com etiquetas personalizadas
- ⚡ **CLI Integrado**: Interface de linha de comando para automação e scripts
- 🎯 **Orçamentos Inteligentes**: Controle de gastos por categoria
- 📈 **Importação CSV**: Suporte para dados de bancos e outras fontes

## 🏛️ Arquitetura

O Finoma segue uma arquitetura em camadas bem definida:

```
┌─────────────────┐    ┌─────────────────┐
│   FinomaUI      │    │   FinomaCLI     │
│  (SwiftUI)      │    │  (Terminal)     │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────┬───────────────┘
                 │
         ┌───────▼───────┐
         │ FinomaServices │
         │ (Business Logic)│
         └───────┬───────┘
                 │
      ┌──────────▼──────────┐
      │  FinomaPersistence  │
      │   (Data Layer)      │
      └──────────┬──────────┘
                 │
         ┌───────▼───────┐
         │  FinomaCore   │
         │   (Models)    │
         └───────────────┘
```

### 📦 Módulos

- **`FinomaCore`**: Modelos fundamentais (Transaction, Account, Category, Budget, etc.), tipos Money e YearMonth, protocolos de repositório
- **`FinomaPersistence`**: Implementações thread-safe de repositórios usando arquivos JSON
- **`FinomaServices`**: Lógica de negócio (TransactionService, BudgetService, ReportService, CSVImporter)
- **`FinomaUI`**: Componentes SwiftUI e ViewModels para aplicações iOS/macOS
- **`FinomaCLI`**: Interface de linha de comando completa para automação

## 🛠️ Requisitos

- **Xcode 15+** para desenvolvimento iOS/macOS
- **Swift 5.9+** para compilação
- **iOS 16+** ou **macOS 13+** para execução
- **Git** para controle de versão

## 🚀 Instalação e Uso

### 📋 Clonando o Repositório

```bash
git clone git@github.com:JhonasMartins/finoma.swift.git
cd finoma.swift
```

### ⚡ Interface de Linha de Comando (CLI)

O Finoma inclui uma poderosa interface CLI para automação e uso rápido:

#### 🔧 Build e Execução

```bash
# Compilar o projeto
swift build

# Executar CLI diretamente
swift run finoma-cli help
```

#### 🎯 Comandos Principais

**1. Inicializar dados padrão:**
```bash
swift run finoma-cli init
```

**2. Adicionar transação:**
```bash
swift run finoma-cli add \
  --date 2025-01-15 \
  --amount 120.50 \
  --currency BRL \
  --type expense \
  --account "Carteira" \
  --category "Alimentação" \
  --payee "Padaria do Bairro" \
  --tags "cafe,lanche,manhã"
```

**3. Listar transações do mês:**
```bash
swift run finoma-cli list --month 2025-01
```

**4. Gerar relatório mensal:**
```bash
swift run finoma-cli report month 2025-01
```

**5. Usar diretório personalizado:**
```bash
swift run finoma-cli init --data-path ~/meus-dados-financeiros
```

### 📁 Armazenamento de Dados

Por padrão, o Finoma armazena os dados em `~/.finoma/` com a seguinte estrutura:

```
~/.finoma/
├── accounts.json      # Contas (Carteira, Banco, etc.)
├── categories.json    # Categorias de transações
├── transactions.json  # Histórico de transações
├── budgets.json      # Orçamentos por categoria
├── recurring.json    # Transações recorrentes
└── rules.json        # Regras de categorização automática
```

> 💡 **Dica**: Use `--data-path` para especificar um diretório personalizado em qualquer comando.

## 📱 Desenvolvimento de Apps iOS/macOS

Para criar aplicações nativas:

1. **Abra o projeto no Xcode:**
   ```bash
   open Package.swift
   ```

2. **Crie um novo target de App** e importe os módulos:
   ```swift
   import FinomaCore
   import FinomaServices
   import FinomaUI
   ```

3. **Configure o ambiente:**
   ```swift
   let environment = FinomaEnvironment()
   let viewModel = AppViewModel(environment: environment)
   ```

## 🗺️ Roadmap

### 🎯 Próximas Funcionalidades

- [ ] **📱 App iOS/macOS**: Interface nativa completa com SwiftUI
- [ ] **☁️ Sincronização**: Suporte a iCloud/CloudKit
- [ ] **📊 Gráficos Avançados**: Visualizações interativas de dados
- [ ] **🔄 Importadores**: Suporte a OFX, QIF e APIs bancárias
- [ ] **🔐 Segurança**: Integração com Keychain e criptografia
- [ ] **🤖 IA**: Categorização automática inteligente
- [ ] **📈 Investimentos**: Tracking de ações e fundos
- [ ] **🌍 Multi-moeda**: Suporte completo a múltiplas moedas
- [ ] **📱 Widgets**: Widgets para iOS e macOS
- [ ] **🔔 Notificações**: Alertas de orçamento e lembretes

### 🏗️ Melhorias Técnicas

- [ ] **🗄️ Core Data**: Migração opcional do JSON para Core Data
- [ ] **⚡ Performance**: Otimizações para grandes volumes de dados
- [ ] **🧪 Testes**: Cobertura completa de testes unitários
- [ ] **📚 Documentação**: DocC e guias detalhados
- [ ] **🔄 CI/CD**: Pipeline automatizado de build e testes

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. **Fork** o repositório
2. **Crie** uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. **Commit** suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. **Push** para a branch (`git push origin feature/nova-funcionalidade`)
5. **Abra** um Pull Request

### 📋 Diretrizes

- Siga as convenções de código Swift
- Adicione testes para novas funcionalidades
- Mantenha a documentação atualizada
- Use commits semânticos

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Jhonas Martins**
- GitHub: [@JhonasMartins](https://github.com/JhonasMartins)
- Email: [seu-email@exemplo.com](mailto:seu-email@exemplo.com)

---

<div align="center">
  <p>Feito com ❤️ e Swift</p>
  <p>⭐ Se este projeto te ajudou, considere dar uma estrela!</p>
          <p>Codnodo Studio</p>
</div>

