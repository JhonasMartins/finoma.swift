import Foundation
import FinomaCore

public struct MonthlyCashflowReport: Hashable {
    public var month: YearMonth
    public var income: Money
    public var expenses: Money
    public var net: Money
}

public struct CategorySpending: Hashable {
    public var category: FinomaCore.Category
    public var amount: Money
}

public final class ReportService {
    private let txRepo: TransactionRepository
    private let catRepo: CategoryRepository

    public init(env: FinomaEnvironment) {
        self.txRepo = env.transactions
        self.catRepo = env.categories
    }

    public func monthlyCashflow(for month: YearMonth, currency: String = "BRL") throws -> MonthlyCashflowReport {
        let cal = Calendar.current
        let txs = try txRepo.all().filter { t in
            let c = cal.dateComponents([.year, .month], from: t.date)
            return c.year == month.year && c.month == month.month && t.status == .cleared
        }
        var income = Decimal(0)
        var expenses = Decimal(0)
        for t in txs {
            switch t.type {
            case .income: income += t.amount.amount
            case .expense: expenses += t.amount.amount
            case .transfer: break
            }
        }
        let incomeM = Money(amount: income, currencyCode: currency)
        let expenseM = Money(amount: expenses, currencyCode: currency)
        let netM = (try? incomeM.subtracting(expenseM)) ?? Money(amount: income - expenses, currencyCode: currency)
        return MonthlyCashflowReport(month: month, income: incomeM, expenses: expenseM, net: netM)
    }

    public func spendingByCategory(for month: YearMonth) throws -> [CategorySpending] {
        let categories = try catRepo.all().reduce(into: [UUID: FinomaCore.Category]()) { $0[$1.id] = $1 }
        let cal = Calendar.current
        let txs = try txRepo.all().filter { t in
            let c = cal.dateComponents([.year, .month], from: t.date)
            return c.year == month.year && c.month == month.month && t.type == .expense && t.status == .cleared
        }
        var dict: [UUID: Decimal] = [:]
        for t in txs {
            guard let catId = t.categoryId else { continue }
            dict[catId, default: 0] += t.amount.amount
        }
        let result: [CategorySpending] = dict.compactMap { (catId, value) in
            guard let cat = categories[catId] else { return nil }
            return CategorySpending(category: cat, amount: Money(amount: value, currencyCode: Locale.current.currency?.identifier ?? "BRL"))
        }.sorted { $0.amount.amount > $1.amount.amount }
        return result
    }
}
