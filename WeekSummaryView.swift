//
//  WeekSummaryView.swift
//  MealCalendar
//
//  Created by Javi on 20/10/25.
//

import SwiftUI

struct WeekSummaryView: View {
    @ObservedObject var mealViewModel: CalendarViewModel
    @ObservedObject var workoutViewModel: WorkoutCalendarViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Encabezado
                HStack {
                    Button(action: previousWeek) { Image(systemName: "chevron.left") }
                    Spacer()
                    Text("Resumen: Semana del \(mealViewModel.currentWeek.startDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.headline)
                    Spacer()
                    Button(action: nextWeek) { Image(systemName: "chevron.right") }
                }
                .padding(.horizontal)
                
                // Lista de días
                ForEach(mealViewModel.currentWeek.days) { day in
                    VStack(alignment: .leading, spacing: 8) {
                        // 📅 Encabezado del día
                        HStack {
                            Text("\(day.date.formattedWeekday()) \(day.date.formattedDay())")
                                .font(.headline)
                                .foregroundColor(day.date.isToday() ? .blue : .primary)
                            Spacer()
                        }
                        
                        // 🍽️ Comidas del día
                        let mealsForDay = mealViewModel.getMeals(for: day.date)
                        if mealsForDay.isEmpty {
                            Text("🍽️ No registraste comidas")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(mealsForDay) { meal in
                                    HStack {
                                        Text(meal.type.icon)
                                        Text("\(meal.type.rawValue): \(meal.name)")
                                            .font(.subheadline)
                                        if !meal.notes.isEmpty {
                                            Text("📝 \(meal.notes)")
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 💪 Entrenamiento del día
                        if let workout = workoutViewModel.getWorkout(for: day.date) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(workout.type.icon)
                                    Text(workout.type.rawValue)
                                        .font(.subheadline)
                                }
                                if let distance = workout.distance {
                                    Text("🏃‍♂️ Distancia: \(String(format: "%.2f", distance)) km")
                                        .font(.footnote)
                                }
                                if let duration = workout.duration {
                                    Text("⏱️ Tiempo: \(String(format: "%.0f", duration)) min")
                                        .font(.footnote)
                                }
                                if !workout.notes.isEmpty {
                                    Text("📝 \(workout.notes)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            Text("💪 No hiciste deporte")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider().padding(.vertical, 4)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Resumen Semanal")
    }
    
    // MARK: - Funciones de navegación
    private func nextWeek() {
        mealViewModel.nextWeek()
        workoutViewModel.nextWeek()
    }
    
    private func previousWeek() {
        mealViewModel.previousWeek()
        workoutViewModel.previousWeek()
    }
}

