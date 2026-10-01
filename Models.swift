import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income = "Receita"
    case expense = "Despesa"
    var id: String { rawValue }
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var type: TransactionType
    var amount: Double
    var date: Date
    var description: String
    var category: String
    var person: String
    var recurring: Bool
    var notes: String
}

struct BudgetItem: Identifiable, Codable {
    var id = UUID()
    var category: String
    var limit: Double
}

struct Goal: Identifiable, Codable {
    var id = UUID()
    var name: String
    var target: Double
    var current: Double
    var targetDate: Date
}

struct FamilyMember: Identifiable, Codable {
    var id = UUID()
    var name: String
}

final class FinanceStore: ObservableObject {
    @Published var transactions: [Transaction] = [] { didSet { save() } }
    @Published var budgets: [BudgetItem] = [] { didSet { save() } }
    @Published var goals: [Goal] = [] { didSet { save() } }
    @Published var family: [FamilyMember] = [] { didSet { save() } }

    let categories = [
        "Habitação", "Alimentação", "Transportes", "Saúde",
        "Educação", "Lazer", "Compras", "Seguros", "Subscrições", "Outros"
    ]

    init() { load() }

    var incomeTotal: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    var expenseTotal: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    var balance: Double { incomeTotal - expenseTotal }
    var savingsRate: Double {
        guard incomeTotal > 0 else { return 0 }
        return max(0, balance / incomeTotal)
    }

    func expense(for category: String) -> Double {
        transactions.filter { $0.type == .expense && $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    private func save() {
        let encoder = JSONEncoder()
        let defaults = UserDefaults.standard
        if let data = try? encoder.encode(transactions) { defaults.set(data, forKey: "transactions") }
        if let data = try? encoder.encode(budgets) { defaults.set(data, forKey: "budgets") }
        if let data = try? encoder.encode(goals) { defaults.set(data, forKey: "goals") }
        if let data = try? encoder.encode(family) { defaults.set(data, forKey: "family") }
    }

    private func load() {
        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "transactions"),
           let value = try? decoder.decode([Transaction].self, from: data) { transactions = value }
        if let data = defaults.data(forKey: "budgets"),
           let value = try? decoder.decode([BudgetItem].self, from: data) { budgets = value }
        if let data = defaults.data(forKey: "goals"),
           let value = try? decoder.decode([Goal].self, from: data) { goals = value }
        if let data = defaults.data(forKey: "family"),
           let value = try? decoder.decode([FamilyMember].self, from: data) { family = value }
    }
}
