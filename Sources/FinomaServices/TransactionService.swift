import Foundation
import FinomaCore

public final class TransactionService {
    private let txRepo: TransactionRepository
    private let accRepo: AccountRepository
    private let catRepo: CategoryRepository
    private let ruleRepo: RuleRepository

    public init(env: FinomaEnvironment) {
        self.txRepo = env.transactions
        self.accRepo = env.accounts
        self.catRepo = env.categories
        self.ruleRepo = env.rules
    }

    public struct CreateInput {
        public var date: Date
        public var type: TransactionType
        public var amount: Decimal
        public var currency: String
        public var accountName: String
        public var categoryName: String?
        public var payee: String?
        public var notes: String?
        public var tags: [String]
        public init(date: Date, type: TransactionType, amount: Decimal, currency: String = "BRL", accountName: String, categoryName: String? = nil, payee: String? = nil, notes: String? = nil, tags: [String] = []) {
            self.date = date
            self.type = type
            self.amount = amount
            self.currency = currency
            self.accountName = accountName
            self.categoryName = categoryName
            self.payee = payee
            self.notes = notes
            self.tags = tags
        }
    }

    public func listAll() throws -> [Transaction] { try txRepo.all() }

    public func list(month: YearMonth?) throws -> [Transaction] {
        let all = try txRepo.all()
        guard let m = month else { return all }
        let cal = Calendar.current
        return all.filter { t in
            let comps = cal.dateComponents([.year, .month], from: t.date)
            return comps.year == m.year && comps.month == m.month
        }
    }

    public func create(_ input: CreateInput) throws -> Transaction {
        guard let account = try accRepo.all().first(where: { $0.name.caseInsensitiveCompare(input.accountName) == .orderedSame }) else {
            throw FinomaServiceError.notFound("Conta: \(input.accountName)")
        }
        var categoryId: UUID? = nil
        if let cname = input.categoryName {
            categoryId = try catRepo.all().first(where: { $0.name.caseInsensitiveCompare(cname) == .orderedSame })?.id
        }

        var tx = Transaction(
            date: input.date,
            type: input.type,
            amount: Money(amount: input.amount, currencyCode: input.currency),
            accountId: account.id,
            categoryId: categoryId,
            payee: input.payee,
            notes: input.notes,
            tags: input.tags,
            status: .cleared
        )
        // Aplicar regras (categorização automática)
        tx = try applyRules(to: tx)
        try txRepo.save(tx)
        return tx
    }

    public func update(_ tx: Transaction) throws { try txRepo.save(tx) }
    public func delete(id: UUID) throws { try txRepo.delete(id: id) }

    private func applyRules(to tx: Transaction) throws -> Transaction {
        let rules = try ruleRepo.all()
        guard !rules.isEmpty else { return tx }
        var newTx = tx
        for rule in rules {
            if matches(rule: rule, tx: tx) {
                if let catId = rule.setCategoryId { newTx.categoryId = catId }
                if !rule.addTags.isEmpty {
                    var set = Set(newTx.tags)
                    for t in rule.addTags { set.insert(t) }
                    newTx.tags = Array(set)
                }
            }
        }
        return newTx
    }

    private func matches(rule: CategorizationRule, tx: Transaction) -> Bool {
        // Payee contains
        if !rule.payeeContains.isEmpty {
            let needle = rule.payeeContains.map { $0.lowercased() }
            let payee = (tx.payee ?? "").lowercased()
            if needle.first(where: { payee.contains($0) }) == nil { return false }
        }
        // Amount range
        let amount = (tx.amount.amount as NSDecimalNumber).decimalValue
        if let min = rule.minAmount, amount < min { return false }
        if let max = rule.maxAmount, amount > max { return false }
        return true
    }
}

