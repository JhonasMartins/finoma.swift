import Foundation

public enum TransactionType: String, Codable {
    case income
    case expense
    case transfer
}

public enum TransactionStatus: String, Codable {
    case pending
    case cleared
}

public struct Transaction: Identifiable, Hashable, Codable {
    public var id: UUID
    public var date: Date
    public var type: TransactionType
    public var amount: Money
    public var accountId: UUID
    public var categoryId: UUID?
    public var counterpartAccountId: UUID?
    public var payee: String?
    public var notes: String?
    public var tags: [String]
    public var status: TransactionStatus

    public init(
        id: UUID = UUID(),
        date: Date,
        type: TransactionType,
        amount: Money,
        accountId: UUID,
        categoryId: UUID? = nil,
        counterpartAccountId: UUID? = nil,
        payee: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        status: TransactionStatus = .cleared
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.amount = amount
        self.accountId = accountId
        self.categoryId = categoryId
        self.counterpartAccountId = counterpartAccountId
        self.payee = payee
        self.notes = notes
        self.tags = tags
        self.status = status
    }
}

