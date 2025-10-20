//
//  WeeklyCalendarView.swift
//  MealCalendar
//
//  Created by Javi on 18/10/25.
//
import SwiftUI

struct MealCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con controles de navegación
                headerView
                
                // Días de la semana
                weekDaysHeader
                
                // Tabla de comidas
                mealsTableView
            }
            .navigationTitle("Mi Calendario de Comidas")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingMealEditor) {
                MealEditorView(viewModel: viewModel)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                viewModel.previousWeek()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            
            Spacer()
            
            Button("Hoy") {
                viewModel.goToToday()
            }
            .font(.headline)
            
            Spacer()
            
            Button(action: {
                viewModel.nextWeek()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var weekDaysHeader: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.currentWeek.days, id: \.id) { day in
                VStack(spacing: 8) {
                    Text(day.date.formattedWeekday())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(day.date.formattedDay())
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(day.date.isToday() ? .white : .primary)
                        .frame(width: 36, height: 36)
                        .background(day.date.isToday() ? Color.blue : Color.clear)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var mealsTableView: some View {
        List {
            ForEach(MealType.allCases, id: \.self) { mealType in
                Section {
                    HStack(spacing: 0) {
                        ForEach(viewModel.currentWeek.days, id: \.id) { day in
                            MealCell(
                                date: day.date,
                                mealType: mealType,
                                viewModel: viewModel
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .background(Color(.systemBackground))
                } header: {
                    HStack {
                        Text(mealType.icon)
                        Text(mealType.rawValue)
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct MealCell: View {
    let date: Date
    let mealType: MealType
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        Button(action: {
            let existingMeal = viewModel.getMeal(for: date, type: mealType)
            viewModel.addOrEditMeal(for: date, type: mealType, meal: existingMeal)
        }) {
            VStack {
                if let meal = viewModel.getMeal(for: date, type: mealType) {
                    Text(meal.name)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                } else {
                    Text("+")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(Color(.systemGray6))
                    .overlay(
                        Rectangle()
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
