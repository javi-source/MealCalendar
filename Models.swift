//
// Models.swift
// MealCalendar
//
// Modelos y extensiones comunes
//

import Foundation

// MARK: - Tipos de comida (con icono)
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

// Modelo para una comida.
// Incluyo un initializer para poder crear con id existente (útil al editar).
struct Meal: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var type: MealType
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), name: String, type: MealType, date: Date, notes: String = "") {
        self.id = id
        self.name = name
        self.type = type
        self.date = date
        self.notes = notes
    }
}

// Tipos de entrenamiento (con icono)
enum WorkoutType: String, CaseIterable, Codable {
    case running = "Correr"
    case walking = "Caminar"
    case cycling = "Ciclismo"
    case gym = "Gimnasio"
    case yoga = "Yoga"
    case swimming = "Natación"
    case other = "Otro"
    
    var icon: String {
        switch self {
        case .running: return "🏃‍♀️"
        case .walking: return "🚶‍♀️"
        case .cycling: return "🚴‍♀️"
        case .gym: return "🏋️‍♂️"
        case .yoga: return "🧘‍♀️"
        case .swimming: return "🏊‍♀️"
        case .other: return "⚡️"
        }
    }
}

// Modelo para un entrenamiento
struct Workout: Identifiable, Codable, Equatable {
    var id: UUID
    var type: WorkoutType
    var date: Date
    var distance: Double? // km
    var duration: Double? // minutos
    var notes: String
    
    init(id: UUID = UUID(), type: WorkoutType, date: Date, distance: Double? = nil, duration: Double? = nil, notes: String = "") {
        self.id = id
        self.type = type
        self.date = date
        self.distance = distance
        self.duration = duration
        self.notes = notes
    }
}

// Día y semana — estructuras para generar la semana
struct Day: Identifiable {
    let id = UUID()
    let date: Date
}

struct Week {
    let startDate: Date
    var days: [Day] {
        (0..<7).map { offset in
            Day(date: Calendar.current.date(byAdding: .day, value: offset, to: startDate)!)
        }
    }
}

// MARK: - Extensiones de Date (utiles para formatear y claves)
extension Date {
    /// Inicio de la semana (según calendario actual)
    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    /// Formato para mostrar el día numérico (ej. "20")
    func formattedDay() -> String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: self)
    }
    
    /// Formato abreviado de día de la semana (ej. "Lun")
    func formattedWeekday() -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df.string(from: self).capitalized
    }
    
    /// Indica si la fecha es hoy
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Clave diaria "yyyy-MM-dd" para agrupar por día (usa zona local)
    var startOfDayKey: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        // usamos zona local para que las agrupaciones sigan el día del usuario
        df.timeZone = TimeZone.current
        return df.string(from: self)
    }
}
