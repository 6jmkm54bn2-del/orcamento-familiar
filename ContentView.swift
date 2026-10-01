import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Início", systemImage: "house.fill") }

            TransactionsView()
                .tabItem { Label("Movimentos", systemImage: "creditcard.fill") }

            BudgetView()
                .tabItem { Label("Orçamento", systemImage: "chart.bar.fill") }

            AnalysisView()
                .tabItem { Label("Análises", systemImage: "chart.pie.fill") }

            MoreView()
                .tabItem { Label("Mais", systemImage: "ellipsis.circle.fill") }
        }
        .tint(.blue)
    }
}

extension Double {
    var euro: String {
        self.formatted(.currency(code: "EUR"))
    }
}
