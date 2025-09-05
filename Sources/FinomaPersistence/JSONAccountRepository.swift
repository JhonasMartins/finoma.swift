import Foundation
import FinomaCore

public final class JSONAccountRepository: AccountRepository {
    private let store: JSONFileStore<Account>

    public init(root: FinomaStore) {
        self.store = JSONFileStore<Account>(fileURL: root.url(for: "accounts.json"))
    }

    public func all() throws -> [Account] { try store.load() }

    public func find(id: UUID) throws -> Account? { try store.load().first { $0.id == id } }

    public func save(_ account: Account) throws {
        try store.mutate { items in
            if let idx = items.firstIndex(where: { $0.id == account.id }) {
                items[idx] = account
            } else { items.append(account) }
        }
    }

    public func saveMany(_ accounts: [Account]) throws {
        try store.mutate { items in
            for a in accounts {
                if let idx = items.firstIndex(where: { $0.id == a.id }) { items[idx] = a } else { items.append(a) }
            }
        }
    }

    public func delete(id: UUID) throws {
        try store.mutate { items in
            items.removeAll { $0.id == id }
        }
    }
}

