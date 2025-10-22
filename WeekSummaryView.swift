//
//  WeekSummaryView.swift
//  MealCalendar
//
//  Vista de resumen semanal de comidas y entrenamientos (Core Data en tiempo real)
//

import SwiftUI
import CoreData

struct WeekSummaryView: View {
    @ObservedObject var mealViewModel: CalendarViewModel
    @ObservedObject var workoutViewModel: WorkoutCalendarViewModel
    @Environment(\.managedObjectContext) private var context

    // 📆 Fecha actual para determinar la semana
    @State private var currentWeek: Week = Week(startDate: Date().startOfWeek)

    // MARK: - FetchRequests en tiempo real
    @FetchRequest(
        entity: MealEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MealEntity.date, ascending: true)],
        animation: .default
    ) private var allMeals: FetchedResults<MealEntity>

    @FetchRequest(
        entity: WorkoutEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutEntity.date, ascending: true)],
        animation: .default
    ) private var allWorkouts: FetchedResults<WorkoutEntity>

    var body: some View {
        VStack {
            // Cabecera: navegación de semana
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text("Semana del \(formattedWeekRange(for: currentWeek.startDate))")
                    .font(.headline)
                Spacer()
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            Divider()

            // Lista de días con comidas y entrenamientos
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(currentWeek.days) { day in
                        VStack(alignment: .leading, spacing: 8) {
                            // Día de la semana
                            HStack {
                                Text("\(day.date.formattedWeekday()) \(day.date.formattedDay())")
                                    .font(.headline)
                                if day.date.isToday() {
                                    Text("(hoy)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }

                            // Sección comidas
                            let meals = mealsFor(date: day.date)
                            if !meals.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("🍽️ Comidas")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    ForEach(meals, id: \.id) { meal in
                                        HStack {
                                            Text(meal.type)
                                                .bold()
                                            Text(meal.name)
                                            if !meal.notes.isEmpty {
                                                Text("(\(meal.notes))")
                                                    .italic()
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("🍽️ No hay comidas registradas")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }

                            // Sección entrenamientos
                            let workouts = workoutsFor(date: day.date)
                            if !workouts.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("💪 Entrenamientos")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    ForEach(workouts, id: \.id) { workout in
                                        HStack {
                                            Text(workout.type)
                                                .bold()
                                            if let distance = workout.distance {
                                                Text("• \(String(format: "%.1f", distance)) km")
                                            }
                                            if let duration = workout.duration {
                                                Text("• \(Int(duration)) min")
                                            }
                                            if !workout.notes.isEmpty {
                                                Text("(\(workout.notes))")
                                                    .italic()
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("💪 No hay entrenamientos registrados")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }

    // MARK: - Funciones auxiliares

    private func formattedWeekRange(for startDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .medium
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    private func nextWeek() {
        if let next = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek.startDate) {
            currentWeek = Week(startDate: next)
        }
    }

    private func previousWeek() {
        if let prev = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek.startDate) {
            currentWeek = Week(startDate: prev)
        }
    }

    // MARK: - Filtros locales para un día específico

    private func mealsFor(date: Date) -> [MealDisplay] {
        let calendar = Calendar.current
        let filtered = allMeals.filter { calendar.isDate($0.date ?? .now, inSameDayAs: date) }
        return filtered.map { MealDisplay(entity: $0) }
    }

    private func workoutsFor(date: Date) -> [WorkoutDisplay] {
        let calendar = Calendar.current
        let filtered = allWorkouts.filter { calendar.isDate($0.date ?? .now, inSameDayAs: date) }
        return filtered.map { WorkoutDisplay(entity: $0) }
    }
}

// MARK: - Modelos intermedios para mostrar datos

struct MealDisplay: Identifiable {
    let id: UUID
    let name: String
    let type: String
    let notes: String

    init(entity: MealEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? "Sin nombre"
        self.type = entity.type ?? "Otro"
        self.notes = entity.notes ?? ""
    }
}

struct WorkoutDisplay: Identifiable {
    let id: UUID
    let type: String
    let distance: Double?
    let duration: Double?
    let notes: String

    init(entity: WorkoutEntity) {
        self.id = entity.id ?? UUID()
        self.type = entity.type ?? "Otro"
        self.distance = entity.distance
        self.duration = entity.duration
        self.notes = entity.notes ?? ""
    }
}
