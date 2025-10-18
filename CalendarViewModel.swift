// CalendarViewModel.swift
import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentWeek: Week
    @Published var selectedDate: Date = Date()
    @Published var showingMealEditor = false
    @Published var editingMeal: Meal?
    @Published var editingDate: Date = Date()
    @Published var editingMealType: MealType = .breakfast
    
    // Para persistencia simple (UserDefaults)
    private let mealsKey = "savedMeals"
    private var savedMeals: [UUID: Meal] = [:]
    
    private var calendar = Calendar.current
    
    init() {
        let today = Date()
        self.currentWeek = Week(startDate: today.startOfWeek)
        loadMeals()
    }
    
    func nextWeek() {
        if let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek.startDate) {
            currentWeek = Week(startDate: nextWeekStart)
        }
    }
    
    func previousWeek() {
        if let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek.startDate) {
            currentWeek = Week(startDate: previousWeekStart)
        }
    }
    
    func goToToday() {
        let today = Date()
        currentWeek = Week(startDate: today.startOfWeek)
        selectedDate = today
    }
    
    func addOrEditMeal(for date: Date, type: MealType, meal: Meal?) {
        editingDate = date
        editingMealType = type
        editingMeal = meal
        showingMealEditor = true
    }
    
    func saveMeal(_ meal: Meal) {
        // Guardar en el diccionario
        savedMeals[meal.id] = meal
        // Persistir
        saveMeals()
    }
    
    func deleteMeal(_ meal: Meal) {
        savedMeals.removeValue(forKey: meal.id)
        saveMeals()
    }
    
    func getMeal(for date: Date, type: MealType) -> Meal? {
        // Buscar en los meals guardados uno que coincida con la fecha y tipo
        let foundMeal = savedMeals.values.first { meal in
            return Calendar.current.isDate(meal.date, inSameDayAs: date) && meal.type == type
        }
        return foundMeal
    }
    
    private func saveMeals() {
        if let encoded = try? JSONEncoder().encode(savedMeals) {
            UserDefaults.standard.set(encoded, forKey: mealsKey)
        }
    }
    
    private func loadMeals() {
        if let data = UserDefaults.standard.data(forKey: mealsKey),
           let decoded = try? JSONDecoder().decode([UUID: Meal].self, from: data) {
            savedMeals = decoded
        }
    }
}
