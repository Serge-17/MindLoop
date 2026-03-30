//
//  DetailsHabitView.swift
//  MindLoop

import SwiftUI

struct DetailsHabitView: View {
    @Binding var habit: HabitItem

    
    @State private var selectedDate = Date()
   
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок с иконкой
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.mint)
                        .font(.title)
                    
                    Text(habit.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.mint)
                }
                .padding(.top, 20)
                
                // Описание
                Text(habit.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                // Кнопка сегодня
                Button(action: { selectedDate = Date() }) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text("Сегодня")
                    }
                    .font(.headline)
                    .foregroundColor(.mint)
                }
                .padding(.top, 10)

                
                // Календарь
                VStack {
                    // Заголовок календаря с навигацией
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Дни недели
                    let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                    HStack {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Ячейки календаря
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        ForEach(daysInMonth(), id: \.self) { date in
                            if calendar.isDate(date, equalTo: selectedDate, toGranularity: .month) {
                                CalendarDayView(
                                    date: date,
                                    isCompleted: habit.completedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }),
                                    isToday: calendar.isDateInToday(date),
                                    isSelectable: !calendar.isDateInFuture(date)
                                )
                                .onTapGesture {
                                    toggleDateCompletion(date: date)
                                }
                            } else {
                                Text("")
                                    .frame(height: 40)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                
                // Счетчик дней
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    
                    Text("Выполнено дней: \(habit.completedDates.count) из \(habit.targetDays)")
                        .font(.system(size: 18, weight: .medium))
                }
                
                // Прогресс
                VStack(spacing: 8) {
                    Text("Прогресс")
                        .font(.headline)
                    
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 10)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        
                        Circle()
                            .trim(from: 0.0, to: habit.progress)
                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.mint)
                            .rotationEffect(Angle(degrees: 270))
                            .animation(.easeInOut(duration: 1.5), value: habit.progress)
                        
                        Text("\(Int(habit.progress * 100))%")
                            .font(.title2)
                            .bold()
                    }
                    .frame(width: 150, height: 150)
                    .padding()
                }
                .padding(.vertical, 10)
            }
            .padding(.bottom, 30)
        }
        .onAppear {
            habit.progress = min(CGFloat(habit.completedDates.count) / CGFloat(habit.targetDays), 1.0)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleDateCompletion(date: Date) {
        if let index = habit.completedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            habit.completedDates.remove(at: index)
        } else {
            habit.completedDates.append(date)
        }
        
        withAnimation(.easeInOut) {
            // Прогресс будет автоматически пересчитан через computed property
            // Не нужно явно присваивать значение progress
        }
    }
    
    private func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = monthFirstWeek.start
        
        // Добавляем дни предыдущего месяца (если есть)
        while currentDate < monthInterval.start {
            days.append(currentDate)
            guard let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = newDate
        }
        
        // Добавляем дни текущего месяца
        while currentDate < monthInterval.end {
            days.append(currentDate)
            guard let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = newDate
        }
        
        // Добавляем дни следующего месяца (если есть)
        let endOfFirstWeek = calendar.date(byAdding: .weekOfMonth, value: 1, to: monthFirstWeek.start)!
        while days.count % 7 != 0 {
            days.append(currentDate)
            guard let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = newDate
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    

}

struct CalendarDayView: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    let isSelectable: Bool
    
    private var dayNumber: String {
        Calendar.current.component(.day, from: date).description
    }
    
    var body: some View {
        VStack {
            Text(dayNumber)
                .font(.system(size: 14))
                .frame(width: 30, height: 30)
                .background(isToday ? Color.mint.opacity(0.2) : Color.clear)
                .cornerRadius(15)
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.mint : Color.clear, lineWidth: 1)
                )
                .foregroundColor(
                    isCompleted ? .white :
                    !isSelectable ? .gray :
                    isToday ? .mint : .primary
                )
                .background(
                    Circle()
                        .fill(isCompleted ? Color.mint : Color.clear)
                        .frame(width: 30, height: 30)
                )
                .opacity(isSelectable ? 1.0 : 0.5)
        }
        .frame(height: 40)
        .allowsHitTesting(isSelectable)
    }
}

// Добавляем extension для Calendar для удобной проверки будущих дат
extension Calendar {
    func isDateInFuture(_ date: Date) -> Bool {
        return date > Date()
    }
}



#Preview {
    // Теперь передаем HabitItem
    DetailsHabitView(habit: .constant(HabitItem(
        name: "Утренний бег",
        description: "Пробежка 2 км",
        completedDates: [
            Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Date()
        ], targetDays: 7
    )))
}
