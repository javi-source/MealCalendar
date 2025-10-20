//
//  WorkoutCalendarView.swift
//  MealCalendar
//
//  Created by Javi on 20/10/25.
//
import SwiftUI

struct WorkoutCalendarView: View {
    @ObservedObject var viewModel: WorkoutCalendarViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: viewModel.previousWeek) { Image(systemName: "chevron.left") }
                Spacer()
                Text("Semana del \(viewModel.currentWeek.startDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                Spacer()
                Button(action: viewModel.nextWeek) { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)
            
            HStack(spacing: 10) {
                ForEach(viewModel.currentWeek.days) { day in
                    VStack {
                        Text(day.date.formattedWeekday())
                            .font(.caption)
                        Text(day.date.formattedDay())
                            .font(.headline)
                            .foregroundColor(day.date.isToday() ? .blue : .primary)
                            .padding(6)
                            .background(day.date.isToday() ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                        
                        if let workout = viewModel.getWorkout(for: day.date) {
                            Button(action: {
                                // Abre el editor en modo edición
                                viewModel.addOrEditWorkout(for: day.date, workout: workout)
                            }) {
                                Text(workout.type.icon)
                                    .font(.title)
                                    .padding(6)
                                    .background(Color.green.opacity(0.15))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button("+") {
                                // Abre el editor para crear nuevo
                                viewModel.addOrEditWorkout(for: day.date, workout: nil)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
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
}

