//
//  Models.swift
//  MealCalendar
//
//  Created by Javi on 18/10/25.
//
import Foundation

// Tipos de comidas
enum MealType: String, CaseIterable, Codable {
    case breakfast = "Desayuno"
    case lunch = "Almuerzo"
    case meal = "Comida"
    case snack = "Merienda"
    case dinner = "Cena"
    
    var icon: String {
        switch self {
        case .breakfast: return "☕"
        case .lunch: return "🥪"
        case .meal: return "🍲"
        case .snack: return "🍎"
        case .dinner: return "🍽️"
        }
    }
}


// Modelo para una comida
struct Meal: Identifiable, Codable {
    var id: UUID = UUID()   // ← ahora es 'var' y decodable correctamente
    var name: String
    var type: MealType
    var date: Date
    var notes: String = ""
}


// Modelo para un día
struct Day: Identifiable {
    let id = UUID()
    let date: Date
    var meals: [MealType: Meal] = [:]
}

// Modelo para una semana
struct Week {
    let startDate: Date
    var days: [Day] = []
    
    init(startDate: Date) {
        self.startDate = startDate
        self.days = Week.generateDays(for: startDate)
    }
    
    private static func generateDays(for startDate: Date) -> [Day] {
        var days: [Day] = []
        let calendar = Calendar.current
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(Day(date: date))
            }
        }
        return days
    }
}

extension Date {
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    func formattedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    func formattedWeekday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self).capitalized
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
}
