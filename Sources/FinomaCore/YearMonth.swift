import Foundation

public struct YearMonth: Hashable, Codable, CustomStringConvertible {
    public let year: Int
    public let month: Int // 1...12

    public init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    public init(date: Date, calendar: Calendar = .current) {
        let comps = calendar.dateComponents([.year, .month], from: date)
        self.year = comps.year ?? 1970
        self.month = comps.month ?? 1
    }

    public var description: String { String(format: "%04d-%02d", year, month) }

    public func startDate(calendar: Calendar = .current) -> Date {
        let comps = DateComponents(year: year, month: month, day: 1)
        return calendar.date(from: comps) ?? Date(timeIntervalSince1970: 0)
    }

    public func endDate(calendar: Calendar = .current) -> Date {
        var comps = DateComponents()
        comps.month = 1
        let start = startDate(calendar: calendar)
        let next = calendar.date(byAdding: comps, to: start) ?? start
        return calendar.date(byAdding: .second, value: -1, to: next) ?? next
    }
}

