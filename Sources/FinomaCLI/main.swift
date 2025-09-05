import Foundation
import FinomaCore
import FinomaServices

@discardableResult
func printErr(_ s: String) -> Int32 { fputs("\(s)\n", stderr); return 1 }

struct Args {
    let command: String?
    let positionals: [String]
    let flags: [String: String]
}

func parseArgs() -> Args {
    var args = CommandLine.arguments
    _ = args.removeFirst()
    let command = args.first
    var positionals: [String] = []
    var flags: [String: String] = [:]
    var i = 0
    while i < args.count {
        let a = args[i]
        if a.hasPrefix("--") {
            let key = String(a.dropFirst(2))
            let next = (i + 1) < args.count ? args[i + 1] : "true"
            if next.hasPrefix("--") { flags[key] = "true"; i += 1; continue }
            flags[key] = next
            i += 2
        } else {
            if i == 0 { /* first positional is command, skip */ i += 1; continue }
            positionals.append(a)
            i += 1
        }
    }
    return Args(command: command, positionals: positionals, flags: flags)
}

func showHelp() {
    print("""
Finoma CLI — Gestão Financeira Pessoal

Uso:
  finoma-cli help
  finoma-cli init [--data-path PATH]
  finoma-cli add --date YYYY-MM-DD --amount NNN.NN [--currency BRL] --type income|expense|transfer --account NAME [--category NAME] [--payee TEXT] [--notes TEXT] [--tags a,b,c] [--data-path PATH]
  finoma-cli list [--month YYYY-MM] [--data-path PATH]
  finoma-cli report month YYYY-MM [--data-path PATH]

Exemplos:
  finoma-cli init
  finoma-cli add --date 2025-09-01 --amount 120.50 --type expense --account Carteira --category Alimentação --payee Padaria --tags cafe,lanche
  finoma-cli list --month 2025-09
  finoma-cli report month 2025-09
""")
}

func env(from flags: [String: String]) -> FinomaEnvironment {
    if let path = flags["data-path"] { return FinomaEnvironment(root: URL(fileURLWithPath: NSString(string: path).expandingTildeInPath, isDirectory: true)) }
    return FinomaEnvironment()
}

func dateFrom(_ yyyy_mm_dd: String) -> Date? {
    let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"; df.locale = Locale(identifier: "en_US_POSIX"); return df.date(from: yyyy_mm_dd)
}

func yearMonthFrom(_ yyyy_mm: String) -> YearMonth? {
    let parts = yyyy_mm.split(separator: "-")
    guard parts.count == 2, let y = Int(parts[0]), let m = Int(parts[1]) else { return nil }
    return YearMonth(year: y, month: m)
}

func cmdInit(_ flags: [String: String]) -> Int32 {
    let env = env(from: flags)
    let bootstrap = BootstrapService(env: env)
    do { try bootstrap.ensureDefaults(); print("Dados padrão criados/garantidos em \(env.store.root.path)"); return 0 } catch { return printErr("Falha ao inicializar: \(error)") }
}

func cmdAdd(_ flags: [String: String]) -> Int32 {
    let env = env(from: flags)
    let svc = TransactionService(env: env)
    guard let ds = flags["date"], let dt = dateFrom(ds) else { return printErr("--date obrigatório (YYYY-MM-DD)") }
    guard let amountStr = flags["amount"], let amount = Decimal(string: amountStr.replacingOccurrences(of: ",", with: ".")) else { return printErr("--amount obrigatório") }
    guard let ts = flags["type"], let type = TransactionType(rawValue: ts.lowercased()) else { return printErr("--type obrigatório (income|expense|transfer)") }
    guard let account = flags["account"] else { return printErr("--account obrigatório") }
    let currency = flags["currency"] ?? "BRL"
    let category = flags["category"]
    let payee = flags["payee"]
    let notes = flags["notes"]
    let tags = (flags["tags"]?.split(separator: ",").map { String($0) }) ?? []
    do {
        let input = TransactionService.CreateInput(date: dt, type: type, amount: amount, currency: currency, accountName: account, categoryName: category, payee: payee, notes: notes, tags: tags)
        let tx = try svc.create(input)
        print("Transação criada: #\(tx.id) \(tx.date) \(tx.type.rawValue) \(tx.amount.formatted())")
        return 0
    } catch { return printErr("Erro: \(error)") }
}

func cmdList(_ flags: [String: String]) -> Int32 {
    let env = env(from: flags)
    let svc = TransactionService(env: env)
    let month = flags["month"].flatMap(yearMonthFrom)
    do {
        let cats = try env.categories.all().reduce(into: [UUID: String]()) { $0[$1.id] = $1.name }
        let txs = try svc.list(month: month)
        if txs.isEmpty { print("Nenhuma transação."); return 0 }
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        for t in txs {
            let date = df.string(from: t.date)
            let cat = t.categoryId.flatMap { cats[$0] } ?? "-"
            let payee = t.payee ?? "-"
            print("\(date) \(t.type.rawValue) \(t.amount.formatted()) cat:\(cat) payee:\(payee) #\(t.id.uuidString.prefix(8))")
        }
        return 0
    } catch { return printErr("Erro: \(error)") }
}

func cmdReport(_ args: [String], _ flags: [String: String]) -> Int32 {
    guard args.count >= 2 else { return printErr("Uso: report month YYYY-MM") }
    let sub = args[0]
    if sub != "month" { return printErr("Subcomando desconhecido: \(sub)") }
    guard let ym = yearMonthFrom(args[1]) else { return printErr("Mês inválido (YYYY-MM)") }
    let env = env(from: flags)
    let svc = ReportService(env: env)
    do {
        let cash = try svc.monthlyCashflow(for: ym)
        print("Relatório de \(ym):")
        print("- Receitas: \(cash.income.formatted())")
        print("- Despesas: \(cash.expenses.formatted())")
        print("- Saldo: \(cash.net.formatted())")
        print("Top despesas por categoria:")
        let cats = try svc.spendingByCategory(for: ym).prefix(10)
        for c in cats { print("  \(c.category.name): \(c.amount.formatted())") }
        return 0
    } catch { return printErr("Erro: \(error)") }
}

let args = parseArgs()
switch args.command?.lowercased() {
case "help", nil: showHelp()
case "init": exit(cmdInit(args.flags))
case "add": exit(cmdAdd(args.flags))
case "list": exit(cmdList(args.flags))
case "report": exit(cmdReport(args.positionals, args.flags))
default:
    _ = printErr("Comando desconhecido. Use 'help'.")
    showHelp()
}
