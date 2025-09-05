import Foundation

public enum AccountType: String, Codable {
    case checking
    case savings
    case credit
    case cash
    case investment
}

public struct Account: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var type: AccountType
    public var archived: Bool

    public init(id: UUID = UUID(), name: String, type: AccountType, archived: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.archived = archived
    }
}

