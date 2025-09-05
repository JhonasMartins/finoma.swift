import Foundation

public enum MoneyError: Error {
    case currencyMismatch
}

public struct Money: Hashable, Codable {
    public var amount: Decimal
    public var currencyCode: String

    public init(amount: Decimal, currencyCode: String = Locale.current.currency?.identifier ?? "BRL") {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    public func adding(_ other: Money) throws -> Money {
        guard currencyCode == other.currencyCode else { throw MoneyError.currencyMismatch }
        return Money(amount: amount + other.amount, currencyCode: currencyCode)
    }

    public func subtracting(_ other: Money) throws -> Money {
        guard currencyCode == other.currencyCode else { throw MoneyError.currencyMismatch }
        return Money(amount: amount - other.amount, currencyCode: currencyCode)
    }

    public func formatted(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount) \(currencyCode)"
    }

    // Encode Decimal como string para evitar variações binárias
    enum CodingKeys: CodingKey { case amount, currencyCode }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decode(String.self, forKey: .currencyCode)
        if let s = try? c.decode(String.self, forKey: .amount), let dec = Decimal(string: s) {
            self.amount = dec
        } else {
            let n = try c.decode(Double.self, forKey: .amount)
            self.amount = Decimal(n)
        }
        self.currencyCode = currency
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(currencyCode, forKey: .currencyCode)
        try c.encode(NSDecimalNumber(decimal: amount).stringValue, forKey: .amount)
    }
}

