import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var store: FinanceStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                if store.budgets.isEmpty {
                    ContentUnavailableView(
                        "Orçamento vazio",
                        systemImage: "chart.bar",
                        description: Text("Adiciona limites mensais por categoria.")
                    )
                } else {
                    ForEach(store.budgets) { item in
                        let spent = store.expense(for: item.category)
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text(item.category).bold()
                                Spacer()
                                Text("\(spent.euro) / \(item.limit.euro)")
                                    .font(.caption)
                            }
                            ProgressView(value: item.limit > 0 ? min(spent / item.limit, 1) : 0)
                            Text("Disponível: \(max(item.limit - spent, 0).euro)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { store.budgets.remove(atOffsets: $0) }
                }
            }
            .navigationTitle("Orçamento")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddBudgetView() }
        }
    }
}

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: FinanceStore
    @State private var category = "Alimentação"
    @State private var limit = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Categoria", selection: $category) {
                    ForEach(store.categories, id: \.self) { Text($0) }
                }
                TextField("Limite mensal (€)", text: $limit)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Novo orçamento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let normalized = limit.replacingOccurrences(of: ",", with: ".")
                        guard let value = Double(normalized), value >= 0 else { return }
                        store.budgets.append(BudgetItem(category: category, limit: value))
                        dismiss()
                    }
                }
            }
        }
    }
}
