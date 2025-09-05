import Foundation
#if canImport(SwiftUI)
import SwiftUI
import FinomaCore

public struct DashboardView: View {
    @ObservedObject var vm: AppViewModel
    public init(vm: AppViewModel) { self.vm = vm }
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Finoma").font(.largeTitle).bold()
            MonthSelector(selected: $vm.selectedMonth) {
                Task { await vm.reload() }
            }
            TransactionsList(transactions: vm.transactions)
        }.padding()
    }
}

struct MonthSelector: View {
    @Binding var selected: YearMonth
    var onChange: () -> Void
    var body: some View {
        HStack {
            Button(action: { changeMonth(-1) }) { Image(systemName: "chevron.left") }
            Text("\(selected.description)").font(.headline)
            Button(action: { changeMonth(1) }) { Image(systemName: "chevron.right") }
        }
    }
    func changeMonth(_ delta: Int) {
        var year = selected.year
        var month = selected.month + delta
        while month < 1 { month += 12; year -= 1 }
        while month > 12 { month -= 12; year += 1 }
        selected = YearMonth(year: year, month: month)
        onChange()
    }
}

struct TransactionsList: View {
    var transactions: [FinomaCore.Transaction]
    var body: some View {
        List(transactions, id: \.id) { t in
            HStack {
                Text(dateString(t.date)).frame(width: 100, alignment: .leading)
                Text(label(t)).frame(maxWidth: .infinity, alignment: .leading)
                Text(t.amount.formatted()).frame(width: 120, alignment: .trailing)
            }
        }
    }
    func dateString(_ d: Date) -> String { let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"; return df.string(from: d) }
    func label(_ t: FinomaCore.Transaction) -> String { t.payee ?? t.notes ?? t.type.rawValue.capitalized }
}

#endif
