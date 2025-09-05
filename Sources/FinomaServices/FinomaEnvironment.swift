import Foundation
import FinomaCore
import FinomaPersistence

public struct FinomaEnvironment {
    public let store: FinomaStore

    public let transactions: TransactionRepository
    public let accounts: AccountRepository
    public let categories: CategoryRepository
    public let budgets: BudgetRepository
    public let recurring: RecurringRepository
    public let rules: RuleRepository

    public init(root: URL? = nil) {
        let rootURL = root ?? FinomaStore.defaultRoot()
        let finomaStore = FinomaStore(root: rootURL)
        self.store = finomaStore
        self.transactions = JSONTransactionRepository(root: finomaStore)
        self.accounts = JSONAccountRepository(root: finomaStore)
        self.categories = JSONCategoryRepository(root: finomaStore)
        self.budgets = JSONBudgetRepository(root: finomaStore)
        self.recurring = JSONRecurringRepository(root: finomaStore)
        self.rules = JSONRuleRepository(root: finomaStore)
    }
}

public enum FinomaServiceError: Error, CustomStringConvertible {
    case notFound(String)
    case invalidInput(String)

    public var description: String {
        switch self {
        case .notFound(let s): return "Não encontrado: \(s)"
        case .invalidInput(let s): return "Entrada inválida: \(s)"
        }
    }
}

