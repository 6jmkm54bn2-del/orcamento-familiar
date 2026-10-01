import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(.blue)
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SectionTitle: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View { Text(title).font(.headline) }
}

struct EmptyHint: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).foregroundStyle(.secondary).font(.subheadline)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.type == .income ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                .font(.title3)
                .foregroundStyle(transaction.type == .income ? .green : .red)
            VStack(alignment: .leading) {
                Text(transaction.description.isEmpty ? transaction.category : transaction.description)
                    .font(.subheadline.bold())
                Text("\(transaction.category) · \(transaction.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(transaction.type == .income ? "+" : "-")\(transaction.amount.euro)")
                .font(.subheadline.bold())
        }
    }
}

extension View {
    func cardStyle() -> some View {
        self.padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
