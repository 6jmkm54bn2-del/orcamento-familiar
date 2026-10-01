import SwiftUI
import Charts

struct AnalysisView: View {
    @EnvironmentObject var store: FinanceStore

    var categoryData: [(String, Double)] {
        store.categories.map { ($0, store.expense(for: $0)) }.filter { $0.1 > 0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Resumo").font(.title2.bold())
                    HStack {
                        StatCard(title: "Receitas", value: store.incomeTotal.euro, icon: "arrow.down.left")
                        StatCard(title: "Despesas", value: store.expenseTotal.euro, icon: "arrow.up.right")
                    }

                    VStack(alignment: .leading) {
                        Text("Despesas por categoria").font(.headline)
                        if categoryData.isEmpty {
                            EmptyHint("Adiciona despesas para ver a distribuição.")
                                .padding(.vertical)
                        } else {
                            Chart {
                                ForEach(categoryData, id: \.0) { item in
                                    SectorMark(
                                        angle: .value("Valor", item.1),
                                        innerRadius: .ratio(0.55)
                                    )
                                    .foregroundStyle(by: .value("Categoria", item.0))
                                }
                            }
                            .frame(height: 280)
                        }
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Taxa de poupança").font(.headline)
                        Text("\(Int(store.savingsRate * 100))%")
                            .font(.system(size: 40, weight: .bold))
                        ProgressView(value: min(store.savingsRate, 1))
                    }
                    .cardStyle()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Análises")
        }
    }
}
