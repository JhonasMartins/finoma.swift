import Foundation
import FinomaCore

public final class JSONBudgetRepository: BudgetRepository {
    private let store: JSONFileStore<Budget>

    public init(root: FinomaStore) {
        self.store = JSONFileStore<Budget>(fileURL: root.url(for: "budgets.json"))
    }

    public func all() throws -> [Budget] { try store.load() }

    public func find(month: YearMonth) throws -> Budget? { try store.load().first { $0.month == month } }

    public func save(_ budget: Budget) throws {
        try store.mutate { items in
            if let idx = items.firstIndex(where: { $0.id == budget.id }) { items[idx] = budget } else { items.append(budget) }
        }
    }

    public func delete(id: UUID) throws { try store.mutate { $0.removeAll { $0.id == id } } }
}

