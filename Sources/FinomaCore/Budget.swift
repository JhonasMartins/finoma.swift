import Foundation

public struct BudgetItem: Identifiable, Hashable, Codable {
    public var id: UUID
    public var categoryId: UUID
    public var limit: Money

    public init(id: UUID = UUID(), categoryId: UUID, limit: Money) {
        self.id = id
        self.categoryId = categoryId
        self.limit = limit
    }
}

public struct Budget: Identifiable, Hashable, Codable {
    public var id: UUID
    public var month: YearMonth
    public var items: [BudgetItem]

    public init(id: UUID = UUID(), month: YearMonth, items: [BudgetItem]) {
        self.id = id
        self.month = month
        self.items = items
    }
}

