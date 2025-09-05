import Foundation
import FinomaCore

public final class JSONTransactionRepository: TransactionRepository {
    private let store: JSONFileStore<Transaction>

    public init(root: FinomaStore) {
        self.store = JSONFileStore<Transaction>(fileURL: root.url(for: "transactions.json"))
    }

    public func all() throws -> [Transaction] { try store.load().sorted { $0.date < $1.date } }

    public func find(id: UUID) throws -> Transaction? { try store.load().first { $0.id == id } }

    public func save(_ transaction: Transaction) throws {
        try store.mutate { items in
            if let idx = items.firstIndex(where: { $0.id == transaction.id }) { items[idx] = transaction } else { items.append(transaction) }
        }
    }

    public func saveMany(_ transactions: [Transaction]) throws {
        try store.mutate { items in
            for t in transactions {
                if let idx = items.firstIndex(where: { $0.id == t.id }) { items[idx] = t } else { items.append(t) }
            }
        }
    }

    public func delete(id: UUID) throws { try store.mutate { $0.removeAll { $0.id == id } } }
}

