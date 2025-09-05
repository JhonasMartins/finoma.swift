import Foundation
import FinomaCore

public final class BootstrapService {
    private let accRepo: AccountRepository
    private let catRepo: CategoryRepository

    public init(env: FinomaEnvironment) {
        self.accRepo = env.accounts
        self.catRepo = env.categories
    }

    public func ensureDefaults(currency: String = "BRL") throws {
        // Contas padrão
        let accounts = try accRepo.all()
        if !accounts.contains(where: { $0.name.caseInsensitiveCompare("Carteira") == .orderedSame }) {
            try accRepo.save(Account(name: "Carteira", type: .cash))
        }
        if !accounts.contains(where: { $0.name.caseInsensitiveCompare("Conta Corrente") == .orderedSame }) {
            try accRepo.save(Account(name: "Conta Corrente", type: .checking))
        }

        // Categorias padrão (PT-BR)
        let existing = try catRepo.all()
        let defaults: [(String, CategoryType)] = [
            ("Renda", .income),
            ("Alimentação", .expense),
            ("Moradia", .expense),
            ("Transporte", .expense),
            ("Lazer", .expense),
            ("Saúde", .expense),
            ("Educação", .expense),
            ("Serviços", .expense),
            ("Outros", .expense)
        ]
        var toInsert: [FinomaCore.Category] = []
        for (name, type) in defaults {
            if !existing.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                toInsert.append(FinomaCore.Category(name: name, type: type))
            }
        }
        if !toInsert.isEmpty { try catRepo.saveMany(toInsert) }
    }
}
