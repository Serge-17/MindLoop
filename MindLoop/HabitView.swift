//
//  HabitView.swift
//  MindLoop
//
//  Created by Serge Eliseev on 22.05.2025.
//

import SwiftUI

struct HabitView: View {
    var habit: HabitItem
    @State private var progress: CGFloat = 0.0
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.linearGradient(colors: [.mint, .cyan], startPoint: .top, endPoint: .bottom))
                
               
                Text(habit.name)
                    .font(.system(.subheadline, design: .rounded))
                    .bold()
                
                Spacer()
                
                Text("\(habit.completedDates.count) \(declineDays(habit.completedDates.count)) из \(habit.targetDays) ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                ProgressView(value: calculateProgress())
                    .tint(
                        LinearGradient(
                            colors: [.mint, .teal, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .mint.opacity(0.4), radius: 3, x: 0, y: 2)
                    .animation(.spring(duration: 0.5), value: calculateProgress())
                
                
                
                Text(calculateProgress(), format: .percent)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .fontDesign(.monospaced)
                
                
            }
        }
        .padding(16)
        .frame(width: 350, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    

    private func calculateProgress() -> Double {
        guard habit.targetDays > 0 else { return 0.0 }
        let calculatedProgress = Double(habit.completedDates.count) / Double(habit.targetDays)
        let roundedProgress = (min(calculatedProgress, 1.0) * 100).rounded() / 100
        return roundedProgress
    }
    
    private func declineDays(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "дней"
        }
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
}

#Preview {
    HabitView(habit: HabitItem(
        name: "Пить воду",
        description: "Выпивать 8 стаканов воды в день",
        completedDates: [Date()],
        targetDays: 7
    ))
}
