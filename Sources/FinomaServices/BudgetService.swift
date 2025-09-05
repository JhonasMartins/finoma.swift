import Foundation
import FinomaCore

public struct BudgetSummaryItem: Hashable {
    public var category: FinomaCore.Category
    public var limit: Money
    public var spent: Money
    public var available: Money { (try? limit.subtracting(spent)) ?? limit }
}

public struct BudgetSummary {
    public var month: YearMonth
    public var items: [BudgetSummaryItem]
}

public final class BudgetService {
    private let txRepo: TransactionRepository
    private let catRepo: CategoryRepository
    private let budgetRepo: BudgetRepository

    public init(env: FinomaEnvironment) {
        self.txRepo = env.transactions
        self.catRepo = env.categories
        self.budgetRepo = env.budgets
    }

    public func summary(for month: YearMonth) throws -> BudgetSummary {
        let categories = try catRepo.all().reduce(into: [UUID: FinomaCore.Category]()) { $0[$1.id] = $1 }
        let budget = try budgetRepo.find(month: month)
        let items = budget?.items ?? []
        let spentByCategory = try spentByCategory(for: month)
        let result: [BudgetSummaryItem] = items.compactMap { item in
            guard let cat = categories[item.categoryId] else { return nil }
            let spent = spentByCategory[item.categoryId] ?? Money(amount: 0, currencyCode: item.limit.currencyCode)
            return BudgetSummaryItem(category: cat, limit: item.limit, spent: spent)
        }
        return BudgetSummary(month: month, items: result)
    }

    public func spentByCategory(for month: YearMonth) throws -> [UUID: Money] {
        let cal = Calendar.current
        let txs = try txRepo.all().filter { t in
            let c = cal.dateComponents([.year, .month], from: t.date)
            return c.year == month.year && c.month == month.month && t.type == .expense && t.status == .cleared
        }
        var dict: [UUID: Money] = [:]
        for t in txs {
            guard let catId = t.categoryId else { continue }
            let money = Money(amount: t.amount.amount, currencyCode: t.amount.currencyCode)
            if let existing = dict[catId] {
                dict[catId] = (try? existing.adding(money)) ?? money
            } else {
                dict[catId] = money
            }
        }
        return dict
    }
}
