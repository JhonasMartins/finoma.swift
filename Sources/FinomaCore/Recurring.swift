import Foundation

public enum RecurrenceFrequency: String, Codable { case daily, weekly, monthly, yearly }

public struct RecurrenceRule: Hashable, Codable {
    public var frequency: RecurrenceFrequency
    public var interval: Int
    public var byWeekday: [Int]? // 1=Domingo ... 7=Sábado (Calendar.component .weekday)
    public var byMonthDay: [Int]?
    public var until: Date?

    public init(frequency: RecurrenceFrequency, interval: Int = 1, byWeekday: [Int]? = nil, byMonthDay: [Int]? = nil, until: Date? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.byWeekday = byWeekday
        self.byMonthDay = byMonthDay
        self.until = until
    }
}

public struct RecurringTransaction: Identifiable, Hashable, Codable {
    public var id: UUID
    public var startDate: Date
    public var rule: RecurrenceRule
    public var template: TransactionTemplate

    public init(id: UUID = UUID(), startDate: Date, rule: RecurrenceRule, template: TransactionTemplate) {
        self.id = id
        self.startDate = startDate
        self.rule = rule
        self.template = template
    }
}

public struct TransactionTemplate: Hashable, Codable {
    public var type: TransactionType
    public var amount: Money
    public var accountId: UUID
    public var categoryId: UUID?
    public var counterpartAccountId: UUID?
    public var payee: String?
    public var notes: String?
    public var tags: [String]

    public init(type: TransactionType, amount: Money, accountId: UUID, categoryId: UUID? = nil, counterpartAccountId: UUID? = nil, payee: String? = nil, notes: String? = nil, tags: [String] = []) {
        self.type = type
        self.amount = amount
        self.accountId = accountId
        self.categoryId = categoryId
        self.counterpartAccountId = counterpartAccountId
        self.payee = payee
        self.notes = notes
        self.tags = tags
    }
}

