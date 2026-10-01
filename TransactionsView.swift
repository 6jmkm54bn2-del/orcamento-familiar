import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var store: FinanceStore
    @State private var showAdd = false
    @State private var search = ""

    var filtered: [Transaction] {
        let base = store.transactions.sorted { $0.date > $1.date }
        guard !search.isEmpty else { return base }
        return base.filter {
            $0.description.localizedCaseInsensitiveContains(search) ||
            $0.category.localizedCaseInsensitiveContains(search) ||
            $0.person.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    ContentUnavailableView("Sem movimentos", systemImage: "creditcard")
                } else {
                    ForEach(filtered) { tx in
                        TransactionRow(transaction: tx)
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.transactions.removeAll { $0.id == tx.id }
                                } label: { Label("Eliminar", systemImage: "trash") }
                            }
                    }
                }
            }
            .searchable(text: $search, prompt: "Pesquisar movimentos")
            .navigationTitle("Movimentos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddTransactionView() }
        }
    }
}

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: FinanceStore

    @State private var type: TransactionType = .expense
    @State private var amount = ""
    @State private var date = Date()
    @State private var description = ""
    @State private var category = "Outros"
    @State private var person = ""
    @State private var recurring = false
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Tipo", selection: $type) {
                    ForEach(TransactionType.allCases) { Text($0.rawValue).tag($0) }
                }
                TextField("Valor (€)", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Data", selection: $date, displayedComponents: .date)
                TextField("Descrição", text: $description)
                Picker("Categoria", selection: $category) {
                    ForEach(store.categories, id: \.self) { Text($0) }
                }
                TextField("Pessoa", text: $person)
                Toggle("Movimento recorrente", isOn: $recurring)
                TextField("Notas", text: $notes, axis: .vertical)
            }
            .navigationTitle("Novo movimento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let normalized = amount.replacingOccurrences(of: ",", with: ".")
                        guard let value = Double(normalized), value > 0 else { return }
                        store.transactions.append(Transaction(
                            type: type, amount: value, date: date,
                            description: description, category: category,
                            person: person, recurring: recurring, notes: notes
                        ))
                        dismiss()
                    }
                }
            }
        }
    }
}
