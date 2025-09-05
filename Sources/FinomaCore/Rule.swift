import Foundation

public struct CategorizationRule: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var payeeContains: [String]
    public var minAmount: Decimal?
    public var maxAmount: Decimal?
    public var setCategoryId: UUID?
    public var addTags: [String]

    public init(id: UUID = UUID(), name: String, payeeContains: [String] = [], minAmount: Decimal? = nil, maxAmount: Decimal? = nil, setCategoryId: UUID? = nil, addTags: [String] = []) {
        self.id = id
        self.name = name
        self.payeeContains = payeeContains
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.setCategoryId = setCategoryId
        self.addTags = addTags
    }
}

