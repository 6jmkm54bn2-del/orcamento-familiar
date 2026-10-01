import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    GoalsView()
                } label: {
                    Label("Objetivos", systemImage: "target")
                }
                NavigationLink {
                    FamilyView()
                } label: {
                    Label("Família", systemImage: "person.2.fill")
                }
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Definições", systemImage: "gearshape.fill")
                }
            }
            .navigationTitle("Mais")
        }
    }
}

struct GoalsView: View {
    @EnvironmentObject var store: FinanceStore
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(store.goals) { goal in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(goal.name).bold()
                        Spacer()
                        Text(goal.current.euro)
                    }
                    ProgressView(value: goal.target > 0 ? min(goal.current / goal.target, 1) : 0)
                    Text("Meta: \(goal.target.euro) · \(goal.targetDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .onDelete { store.goals.remove(atOffsets: $0) }
        }
        .navigationTitle("Objetivos")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAdd) { AddGoalView() }
    }
}

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: FinanceStore
    @State private var name = ""
    @State private var target = ""
    @State private var current = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome do objetivo", text: $name)
                TextField("Valor objetivo (€)", text: $target).keyboardType(.decimalPad)
                TextField("Valor atual (€)", text: $current).keyboardType(.decimalPad)
                DatePicker("Data objetivo", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Novo objetivo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let t = Double(target.replacingOccurrences(of: ",", with: ".")) ?? 0
                        let c = Double(current.replacingOccurrences(of: ",", with: ".")) ?? 0
                        guard !name.isEmpty, t > 0 else { return }
                        store.goals.append(Goal(name: name, target: t, current: c, targetDate: date))
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FamilyView: View {
    @EnvironmentObject var store: FinanceStore
    @State private var name = ""

    var body: some View {
        List {
            Section("Elementos da família") {
                ForEach(store.family) { member in
                    Label(member.name, systemImage: "person.fill")
                }
                .onDelete { store.family.remove(atOffsets: $0) }
            }
            Section {
                HStack {
                    TextField("Novo elemento", text: $name)
                    Button("Adicionar") {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        store.family.append(FamilyMember(name: name))
                        name = ""
                    }
                }
            }
        }
        .navigationTitle("Família")
    }
}

struct SettingsView: View {
    @AppStorage("currency") private var currency = "EUR"
    @AppStorage("notifications") private var notifications = true

    var body: some View {
        Form {
            Section("Preferências") {
                HStack {
                    Text("Moeda")
                    Spacer()
                    Text(currency)
                }
                Toggle("Notificações", isOn: $notifications)
            }
            Section("Aplicação") {
                LabeledContent("Nome", value: "Orçamento Familiar")
                LabeledContent("Versão", value: "1.0")
            }
        }
        .navigationTitle("Definições")
    }
}
