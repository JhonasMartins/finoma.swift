import Foundation
import FinomaCore

public final class JSONRuleRepository: RuleRepository {
    private let store: JSONFileStore<CategorizationRule>

    public init(root: FinomaStore) {
        self.store = JSONFileStore<CategorizationRule>(fileURL: root.url(for: "rules.json"))
    }

    public func all() throws -> [CategorizationRule] { try store.load() }

    public func save(_ rule: CategorizationRule) throws {
        try store.mutate { items in
            if let idx = items.firstIndex(where: { $0.id == rule.id }) { items[idx] = rule } else { items.append(rule) }
        }
    }

    public func delete(id: UUID) throws { try store.mutate { $0.removeAll { $0.id == id } } }
}

