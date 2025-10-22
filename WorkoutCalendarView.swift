//
//  WorkoutCalendarView.swift
//  MealCalendar
//
//  Created by Javi on 20/10/25.
//

import SwiftUI

/// Vista principal donde se muestra el calendario semanal de entrenamientos
struct WorkoutCalendarView: View {
    @ObservedObject var viewModel: WorkoutCalendarViewModel

    
    var body: some View {
        VStack {
            // 🔹 Encabezado con navegación de semana
            HStack {
                Button(action: viewModel.previousWeek) { Image(systemName: "chevron.left") }
                Spacer()
                Text("Semana del \(viewModel.currentWeek.startDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                Spacer()
                Button(action: viewModel.nextWeek) { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)
            
            // 🔹 Días de la semana
            HStack(spacing: 10) {
                ForEach(viewModel.currentWeek.days) { day in
                    VStack {
                        // Día de la semana
                        Text(day.date.formattedWeekday())
                            .font(.caption)
                        Text(day.date.formattedDay())
                            .font(.headline)
                            .foregroundColor(day.date.isToday() ? .blue : .primary)
                            .padding(6)
                            .background(day.date.isToday() ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                        
                        // 🔹 Entrenamientos del día
                        let workouts = viewModel.getWorkouts(for: day.date)
                        
                        if workouts.isEmpty {
                            // Si no hay entrenamientos, botón para añadir
                            Button("+") {
                                viewModel.addOrEditWorkout(for: day.date, workout: nil)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        } else {
                            // Si hay entrenamientos, los mostramos todos
                            VStack(spacing: 2) {
                                ForEach(workouts) { workout in
                                    Button(action: {
                                        // Al tocar un entrenamiento, se abre el editor para editar/eliminar
                                        viewModel.addOrEditWorkout(for: day.date, workout: workout)
                                    }) {
                                        HStack(spacing: 4) {
                                            Text(workout.type.icon)
                                            Text(shortWorkoutText(workout))
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // Botón extra para añadir más entrenamientos el mismo día
                                Button("+ Añadir") {
                                    viewModel.addOrEditWorkout(for: day.date, workout: nil)
                                }
                                .font(.caption2)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(4)
                }
            }
            Spacer()
        }
        .sheet(isPresented: $viewModel.showingEditor) {
            WorkoutEditorView(viewModel: viewModel)
        }
    }
    
    // MARK: - Función auxiliar para mostrar texto corto del entrenamiento
    private func shortWorkoutText(_ workout: Workout) -> String {
        var text = workout.type.rawValue
        if let distance = workout.distance {
            text += " \(String(format: "%.1f", distance)) km"
        }
        if let duration = workout.duration {
            text += " ⏱ \(Int(duration)) min"
        }
        return text
    }
}
