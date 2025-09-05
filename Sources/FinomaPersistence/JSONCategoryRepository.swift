import Foundation
import FinomaCore

public final class JSONCategoryRepository: CategoryRepository {
    private let store: JSONFileStore<FinomaCore.Category>

    public init(root: FinomaStore) {
        self.store = JSONFileStore<FinomaCore.Category>(fileURL: root.url(for: "categories.json"))
    }

    public func all() throws -> [FinomaCore.Category] { try store.load() }

    public func find(id: UUID) throws -> FinomaCore.Category? { try store.load().first { $0.id == id } }

    public func save(_ category: FinomaCore.Category) throws {
        try store.mutate { items in
            if let idx = items.firstIndex(where: { $0.id == category.id }) { items[idx] = category } else { items.append(category) }
        }
    }

    public func saveMany(_ categories: [FinomaCore.Category]) throws {
        try store.mutate { items in
            for c in categories {
                if let idx = items.firstIndex(where: { $0.id == c.id }) { items[idx] = c } else { items.append(c) }
            }
        }
    }

    public func delete(id: UUID) throws { try store.mutate { $0.removeAll { $0.id == id } } }
}
