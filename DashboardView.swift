import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: FinanceStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    balanceCard
                    quickStats
                    budgetSection
                    recentSection
                    goalsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Orçamento Familiar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Resumo mensal")
                .font(.title2.bold())
            Text(Date.now.formatted(.dateTime.month(.wide).year()))
                .foregroundStyle(.secondary)
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Saldo disponível").font(.subheadline).foregroundStyle(.secondary)
            Text(store.balance.euro)
                .font(.system(size: 36, weight: .bold))
            HStack {
                Label("Receitas \(store.incomeTotal.euro)", systemImage: "arrow.down.left")
                Spacer()
                Label("Despesas \(store.expenseTotal.euro)", systemImage: "arrow.up.right")
            }
            .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private var quickStats: some View {
        HStack {
            StatCard(title: "Poupança", value: store.balance.euro, icon: "banknote")
            StatCard(title: "Taxa", value: "\(Int(store.savingsRate * 100))%", icon: "percent")
        }
    }

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("Orçamento")
            if store.budgets.isEmpty {
                EmptyHint("Ainda não definiste o orçamento por categoria.")
            } else {
                ForEach(store.budgets.prefix(4)) { item in
                    let spent = store.expense(for: item.category)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(item.category)
                            Spacer()
                            Text("\(spent.euro) / \(item.limit.euro)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: item.limit > 0 ? min(spent / item.limit, 1) : 0)
                    }
                }
            }
        }
        .cardStyle()
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("Últimos movimentos")
            if store.transactions.isEmpty {
                EmptyHint("Ainda não existem movimentos.")
            } else {
                ForEach(store.transactions.sorted { $0.date > $1.date }.prefix(5)) { tx in
                    TransactionRow(transaction: tx)
                }
            }
        }
        .cardStyle()
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle("Objetivos")
            if store.goals.isEmpty {
                EmptyHint("Adiciona um objetivo de poupança em Mais → Objetivos.")
            } else {
                ForEach(store.goals.prefix(2)) { goal in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(goal.name).bold()
                            Spacer()
                            Text(goal.current.euro)
                        }
                        ProgressView(value: goal.target > 0 ? min(goal.current / goal.target, 1) : 0)
                        Text("Objetivo: \(goal.target.euro)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .cardStyle()
    }
}
