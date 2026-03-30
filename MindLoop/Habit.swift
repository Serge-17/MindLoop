//
//  Habit.swift
//  MindLoop

import SwiftUI

struct HabitItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let description: String
    var completedDates: [Date]
    let targetDays : Int
    
    var days: Int {
        completedDates.count
    }
    
    var progressValue: Double = 0
    
    
    var progress: Double {
        get {
            return min(Double(completedDates.count) / Double(targetDays), 1.0)
        }
        set {
            progressValue = newValue
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

@Observable
class Habit {
    var items = [HabitItem]() {
        didSet {
            saveItems()
        }
    }
    
    init() {
        loadItems()
    }
    
    private func saveItems() {
        // Кодируем только массив items, а не весь класс Habit
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "HabitItems")
        }
    }
    
    private func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: "HabitItems"),
           let decodedItems = try? JSONDecoder().decode([HabitItem].self, from: savedItems) {
            items = decodedItems
        }
    }
    
    
}
