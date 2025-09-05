import Foundation
import FinomaCore

public struct CSVImporter {
    public struct Mapping {
        public var date: String
        public var amount: String
        public var currency: String?
        public var type: String? // income|expense|transfer
        public var account: String
        public var category: String?
        public var payee: String?
        public var notes: String?
        public var tags: String?
        public init(date: String = "date", amount: String = "amount", currency: String? = "currency", type: String? = "type", account: String = "account", category: String? = "category", payee: String? = "payee", notes: String? = "notes", tags: String? = "tags") {
            self.date = date
            self.amount = amount
            self.currency = currency
            self.type = type
            self.account = account
            self.category = category
            self.payee = payee
            self.notes = notes
            self.tags = tags
        }
    }

    private let txService: TransactionService

    public init(transactionService: TransactionService) {
        self.txService = transactionService
    }

    public func importFile(url: URL, mapping: Mapping = Mapping(), delimiter: Character = ",") throws -> Int {
        let content = try String(contentsOf: url)
        var lines = content.split(whereSeparator: { $0.isNewline }).map(String.init)
        guard let header = lines.first else { return 0 }
        let headers = header.split(separator: delimiter).map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        lines.removeFirst()

        func idx(_ key: String?) -> Int? {
            guard let k = key?.lowercased() else { return nil }
            return headers.firstIndex(of: k)
        }

        let iDate = idx(mapping.date)
        let iAmount = idx(mapping.amount)
        let iCurrency = idx(mapping.currency)
        let iType = idx(mapping.type)
        let iAccount = idx(mapping.account)
        let iCategory = idx(mapping.category)
        let iPayee = idx(mapping.payee)
        let iNotes = idx(mapping.notes)
        let iTags = idx(mapping.tags)

        var inserted = 0
        let df = ISO8601DateFormatter()
        let altDF = DateFormatter()
        altDF.dateFormat = "yyyy-MM-dd"

        for line in lines {
            let cols = line.split(separator: delimiter, omittingEmptySubsequences: false).map { String($0).trimmingCharacters(in: .whitespaces) }
            guard let idate = iDate, let iamount = iAmount, let iacc = iAccount, idate < cols.count, iamount < cols.count, iacc < cols.count else { continue }
            let dateStr = cols[idate]
            let amountStr = cols[iamount].replacingOccurrences(of: ",", with: ".")
            let currency = (iCurrency != nil && iCurrency! < cols.count) ? cols[iCurrency!] : "BRL"
            let typeStr = (iType != nil && iType! < cols.count) ? cols[iType!] : "expense"
            let accountName = cols[iacc]
            let categoryName = (iCategory != nil && iCategory! < cols.count) ? cols[iCategory!] : nil
            let payee = (iPayee != nil && iPayee! < cols.count) ? cols[iPayee!] : nil
            let notes = (iNotes != nil && iNotes! < cols.count) ? cols[iNotes!] : nil
            let tags = (iTags != nil && iTags! < cols.count) ? cols[iTags!].split(separator: ";").map { String($0) } : []

            let date = df.date(from: dateStr) ?? altDF.date(from: dateStr) ?? Date()
            guard let amount = Decimal(string: amountStr) else { continue }
            let type: TransactionType = TransactionType(rawValue: typeStr.lowercased()) ?? .expense
            let input = TransactionService.CreateInput(date: date, type: type, amount: amount, currency: currency, accountName: accountName, categoryName: categoryName, payee: payee, notes: notes, tags: tags)
            _ = try? txService.create(input)
            inserted += 1
        }
        return inserted
    }
}

