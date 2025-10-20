// Workout.swift
import Foundation

enum WorkoutType: String, CaseIterable, Codable {
    case running = "Correr"
    case walking = "Caminar"
    case gym = "Gimnasio"
    case cycling = "Ciclismo"
    case swimming = "Natación"
    case yoga = "Yoga"
    case other = "Otro"
    
    var icon: String {
        switch self {
        case .running: return "🏃‍♀️"
        case .walking: return "🚶‍♀️"
        case .gym: return "🏋️‍♂️"
        case .cycling: return "🚴‍♀️"
        case .swimming: return "🏊‍♀️"
        case .yoga: return "🧘‍♀️"
        case .other: return "⚡️"
        }
    }
}

struct Workout: Identifiable, Codable {
    var id: UUID = UUID()
    var type: WorkoutType
    var date: Date
    var distance: Double? = nil   // km
    var duration: Double? = nil   // minutos
    var notes: String = ""
}
