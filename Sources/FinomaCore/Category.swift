import Foundation

public enum CategoryType: String, Codable {
    case income
    case expense
}

public struct Category: Identifiable, Hashable, Codable {
    public var id: UUID
    public var name: String
    public var type: CategoryType
    public var parentId: UUID?

    public init(id: UUID = UUID(), name: String, type: CategoryType, parentId: UUID? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.parentId = parentId
    }
}

