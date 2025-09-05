import Foundation
#if canImport(SwiftUI)
import SwiftUI
import FinomaCore
import FinomaServices

@MainActor
public final class AppViewModel: ObservableObject {
    public let env: FinomaEnvironment
    public let txService: TransactionService
    public let budgetService: BudgetService
    public let reportService: ReportService

    @Published public var transactions: [FinomaCore.Transaction] = []
    @Published public var selectedMonth: YearMonth = YearMonth(date: Date())

    public init(env: FinomaEnvironment = FinomaEnvironment()) {
        self.env = env
        self.txService = TransactionService(env: env)
        self.budgetService = BudgetService(env: env)
        self.reportService = ReportService(env: env)
        Task { await reload() }
    }

    public func reload() async {
        do { self.transactions = try txService.list(month: selectedMonth) } catch { print("Falha ao carregar: \(error)") }
    }
}
#endif
