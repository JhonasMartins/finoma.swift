import Foundation
import FinomaCore

public final class JSONRecurringRepository: RecurringRepository {
    private let store: JSONFileStore<RecurringTransaction>

    public init(root: FinomaStore) {
        self.store = JSONFileStore<RecurringTransaction>(fileURL: root.url(for: "recurring.json"))
    }

    public func all() throws -> [RecurringTransaction] { try store.load() }

    public func save(_ recurring: RecurringTransaction) throws {
        try store.mutate { items in
            if let idx = items.firstIndex(where: { $0.id == recurring.id }) { items[idx] = recurring } else { items.append(recurring) }
        }
    }

    public func delete(id: UUID) throws { try store.mutate { $0.removeAll { $0.id == id } } }
}

