Finoma — Gestão Financeira Pessoal (iOS/macOS)

Resumo
- Multiplataforma com Swift/SwiftUI: arquitetura modular (Core, Persistence, Services, UI).
- Persistência local simples via JSON (pluggable para Core Data, SQLite/Cloud mais tarde).
- Serviços para transações, orçamentos, recorrências, regras e relatórios.
- CLI incluso para uso rápido: importar CSV, adicionar e listar transações, relatórios mensais.

Estrutura
- `FinomaCore`: Modelos (Transação, Conta, Categoria, Orçamento, Recorrência, Regra), Money, YearMonth e protocolos.
- `FinomaPersistence`: Implementações de repositório em arquivos JSON, thread-safe.
- `FinomaServices`: Lógica de negócio (cadastro, orçamento, relatórios, importadores CSV).
- `FinomaUI`: Views SwiftUI e ViewModels (esboços para app iOS/macOS).
- `FinomaCLI`: Executável de linha de comando para operar a base local.

Requisitos
- Xcode 15+ (iOS 16+/macOS 13+) para UI.
- Swift 5.9+ para compilar os pacotes.

Como usar o CLI
1) Build e execução:
   - `swift build` (se precisar)
   - `swift run finoma-cli -- help`

2) Inicializar dados padrão:
   - `swift run finoma-cli init`

3) Adicionar transação:
   - `swift run finoma-cli add --date 2025-09-01 --amount 120.50 --currency BRL --type expense --account Carteira --category Alimentação --payee "Padaria" --tags cafe,lanche`

4) Listar transações do mês:
   - `swift run finoma-cli list --month 2025-09`

5) Relatório mensal:
   - `swift run finoma-cli report month 2025-09`

Pastas e dados
- O CLI usa por padrão `~/.finoma` para armazenar `accounts.json`, `categories.json`, `transactions.json`, etc.
- Você pode apontar para outra pasta com `--data-path /caminho` em qualquer comando do CLI.

Próximos passos sugeridos
- App iOS/macOS: criar targets de App no Xcode e referenciar os módulos do pacote.
- Sincronização: iCloud/CloudKit ou SQLite + GRDB.
- Importadores: OFX/OFX2, QIF, integrações bancárias.
- Segurança: Keychain para chaves, criptografia local opcional.
- Automação: mais regras de categorização, IA opcional no futuro para classificação.

