//
//  WorkoutCalendarViewModel.swift
//  MealCalendar
//
//  Created by Javi on 20/10/25.
//

import Foundation
import Combine

class WorkoutCalendarViewModel: ObservableObject {
    @Published var currentWeek: Week
    @Published var selectedDate: Date = Date()
    @Published var showingEditor = false
    @Published var editingWorkout: Workout? = nil
    @Published var editingDate: Date = Date()
    
    private let workoutsKey = "savedWorkouts"
    private var savedWorkouts: [UUID: Workout] = [:]
    private var calendar = Calendar.current
    
    init() {
        let today = Date()
        self.currentWeek = Week(startDate: today.startOfWeek)
        loadWorkouts()
    }
    
    func nextWeek() {
        if let next = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek.startDate) {
            currentWeek = Week(startDate: next)
        }
    }
    
    func previousWeek() {
        if let prev = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek.startDate) {
            currentWeek = Week(startDate: prev)
        }
    }
    
    func goToToday() {
        let today = Date()
        currentWeek = Week(startDate: today.startOfWeek)
        selectedDate = today
    }
    
    func addOrEditWorkout(for date: Date, workout: Workout?) {
        editingDate = date
        editingWorkout = workout
        showingEditor = true
    }
    
    func saveWorkout(_ workout: Workout) {
        savedWorkouts[workout.id] = workout
        saveWorkouts()
    }
    
    func deleteWorkout(_ workout: Workout) {
        savedWorkouts.removeValue(forKey: workout.id)
        saveWorkouts()
    }
    
    func getWorkout(for date: Date) -> Workout? {
        savedWorkouts.values.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(savedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: workoutsKey)
        }
    }
    
    private func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: workoutsKey),
           let decoded = try? JSONDecoder().decode([UUID: Workout].self, from: data) {
            savedWorkouts = decoded
        }
    }
}

