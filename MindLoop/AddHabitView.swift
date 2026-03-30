//
//  AddHabitView.swift
//  MindLoop
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var habits: Habit
    @State private var habitName = ""
    @State private var habitDescription = ""
    
    @State private var showNameError = false
    @State private var showDescriptionError = false
    
    private let countRepetitions = [7, 14, 30, 90, 180, 365]
    @State private var selectedRepetitions = 7
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("Введите название привычки", text: $habitName)
                }

                Section("Описание") {
                    TextField("Введите описание привычки", text: $habitDescription)
                        .frame(height: 75)
                }
                
                Section("Количество повторений") {
                    Picker("Выберите количество дней", selection: $selectedRepetitions) {
                        ForEach(countRepetitions, id: \.self) { number in
                            Text("\(number) дней")
                        }
                    }
                    .pickerStyle(.automatic)
                }
            }
            .navigationTitle("Добавить привычку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveHabit()
                    }
                    .disabled(habitName.isEmpty)
                }
            }
            .alert("Ошибка в названии", isPresented: $showNameError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Название должно содержать минимум 3 символа")
            }
            .alert("Ошибка в описании", isPresented: $showDescriptionError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Описание должно содержать минимум 3 символа")
            }
        }
    }
    
    private func saveHabit() {
        // Сначала сбрасываем состояния ошибок
        showNameError = false
        showDescriptionError = false
        
        // Проверяем название
        if habitName.count < 3 {
            showNameError = true
            return
        }
        
        // Проверяем описание (если нужно)
        if habitDescription.count < 3 {
            showDescriptionError = true
            return
        }
        
        // Если все проверки пройдены, сохраняем
        let newHabit = HabitItem(
            name: habitName,
            description: habitDescription,
            completedDates: [],
            targetDays: selectedRepetitions
        )
        
        habits.items.append(newHabit)
        dismiss()
    }
}

#Preview {
    AddHabitView(habits: Habit())
}
