//
//  ContentView.swift
//  MindLoop
//

import SwiftUI

struct ContentView: View {
    @State private var habits = Habit()
    @State private var habitToDelete: HabitItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фоновый цвет
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Основной контент с List
                List {
                    ForEach($habits.items) { $habitItem in
                        NavigationLink {
                            DetailsHabitView(habit: $habitItem)
                                .background(.thinMaterial)
                        } label: {
                            HabitView(habit: habitItem)
                                .padding(.vertical, 8)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                habitToDelete = habitItem
                            } label: {
                                Label("Удалить", systemImage: "trash.fill")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            habitToDelete = habits.items[index]
                        }
                    }
                }
                .listStyle(.plain)
                .background(.regularMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("MindLoop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        AddHabitView(habits: habits)
                            .background(.thinMaterial)
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .padding(8)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .alert("Удалить привычку?", isPresented: Binding(
                get: { habitToDelete != nil },
                set: { if !$0 { habitToDelete = nil } }
            ), presenting: habitToDelete) { _ in
                Button("Удалить", role: .destructive) {
                    if let habit = habitToDelete {
                        withAnimation(.easeOut(duration: 0.3)) {
                            habits.items.removeAll { $0.id == habit.id }
                        }
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: { habit in
                Text("Вы уверены, что хотите удалить привычку \"\(habit.name)\"?")
            }
        }
    }
    
    private func markAsCompleted(_ habit: HabitItem) {
        if let index = habits.items.firstIndex(where: { $0.id == habit.id }) {
            habits.items[index].completedDates.append(Date())
        }
    }
}

#Preview {
    ContentView()
}
