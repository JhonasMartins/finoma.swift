import Foundation

public protocol TransactionRepository {
    func all() throws -> [Transaction]
    func find(id: UUID) throws -> Transaction?
    func save(_ transaction: Transaction) throws
    func saveMany(_ transactions: [Transaction]) throws
    func delete(id: UUID) throws
}

public protocol AccountRepository {
    func all() throws -> [Account]
    func find(id: UUID) throws -> Account?
    func save(_ account: Account) throws
    func saveMany(_ accounts: [Account]) throws
    func delete(id: UUID) throws
}

public protocol CategoryRepository {
    func all() throws -> [Category]
    func find(id: UUID) throws -> Category?
    func save(_ category: Category) throws
    func saveMany(_ categories: [Category]) throws
    func delete(id: UUID) throws
}

public protocol BudgetRepository {
    func all() throws -> [Budget]
    func find(month: YearMonth) throws -> Budget?
    func save(_ budget: Budget) throws
    func delete(id: UUID) throws
}

public protocol RecurringRepository {
    func all() throws -> [RecurringTransaction]
    func save(_ recurring: RecurringTransaction) throws
    func delete(id: UUID) throws
}

public protocol RuleRepository {
    func all() throws -> [CategorizationRule]
    func save(_ rule: CategorizationRule) throws
    func delete(id: UUID) throws
}

