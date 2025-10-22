//
// MealCalendarView.swift
// MealCalendar
//
// Vista principal del calendario de comidas (semana)
//

import SwiftUI

struct MealCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel

    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                weekDaysHeader
                mealsTableView
            }
            .navigationTitle("Mi Calendario de Comidas")
            .navigationBarTitleDisplayMode(.inline)
            // sheet para el editor (añadir/editar)
            .sheet(isPresented: $viewModel.showingMealEditor) {
                MealEditorView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Header con controles semana / hoy
    private var headerView: some View {
        HStack {
            Button(action: { viewModel.previousWeek() }) {
                Image(systemName: "chevron.left").font(.title2)
            }
            Spacer()
            Button("Hoy") { viewModel.goToToday() }.font(.headline)
            Spacer()
            Button(action: { viewModel.nextWeek() }) {
                Image(systemName: "chevron.right").font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Cabecera con días
    private var weekDaysHeader: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.currentWeek.days, id: \.id) { day in
                VStack(spacing: 8) {
                    Text(day.date.formattedWeekday()).font(.caption).foregroundColor(.secondary)
                    Text(day.date.formattedDay())
                        .font(.title2).fontWeight(.medium)
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
    
    // MARK: - Tabla: por cada MealType muestra una fila con 7 celdas (una por día)
    private var mealsTableView: some View {
        List {
            ForEach(MealType.allCases, id: \.self) { mealType in
                Section {
                    HStack(spacing: 0) {
                        ForEach(viewModel.currentWeek.days, id: \.id) { day in
                            MealCell(date: day.date, mealType: mealType, viewModel: viewModel)
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
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

// MARK: - Celda por día y tipo
struct MealCell: View {
    let date: Date
    let mealType: MealType
    @ObservedObject var viewModel: CalendarViewModel
    
    @State private var showingList = false
    
    var body: some View {
        Button(action: {
            // Si hay comidas para este día/tipo, abrimos la lista; si no, abrimos editor para crear
            let existing = viewModel.getMeals(for: date, type: mealType)
            if existing.isEmpty {
                viewModel.addOrEditMeal(for: date, type: mealType, meal: nil)
            } else {
                showingList = true
            }
        }) {
            VStack {
                // Mostrar hasta dos nombres compactados
                let existing = viewModel.getMeals(for: date, type: mealType)
                if existing.isEmpty {
                    Text("+").font(.title2).foregroundColor(.secondary)
                } else {
                    VStack(spacing: 4) {
                        ForEach(existing.prefix(2)) { meal in
                            Text(meal.name)
                                .font(.caption)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                        }
                        if existing.count > 2 {
                            Text("+\(existing.count - 2) más")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 68)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(Color(.systemGray6))
                    .overlay(Rectangle().stroke(Color(.systemGray4), lineWidth: 0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
        // Sheet que muestra la lista completa de comidas de ese día/tipo (y permite editar cada una)
        .sheet(isPresented: $showingList) {
            NavigationView {
                List {
                    let existing = viewModel.getMeals(for: date, type: mealType)
                    ForEach(existing) { meal in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(meal.name).font(.body)
                                if !meal.notes.isEmpty { Text("📝 \(meal.notes)").font(.caption).foregroundColor(.secondary) }
                            }
                            Spacer()
                            Button("Editar") {
                                viewModel.addOrEditMeal(for: meal.date, type: meal.type, meal: meal)
                                showingList = false
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    // opción para añadir nueva en esta fecha/tipo
                    Button(action: {
                        viewModel.addOrEditMeal(for: date, type: mealType, meal: nil)
                        showingList = false
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Añadir \(mealType.rawValue)")
                        }
                    }
                }
                .navigationTitle("\(mealType.rawValue) — \(date.formattedDay())")
                .navigationBarItems(trailing: Button("Cerrar") { showingList = false })
            }
        }
    }
}
