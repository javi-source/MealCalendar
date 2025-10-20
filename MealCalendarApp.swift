//
//  MealCalendarApp.swift
//  MealCalendar
//
//  Created by Javi on 18/10/25.
//
import SwiftUI

@main
struct MealCalendarApp: App {
    // 🔁 Crear una sola instancia de cada ViewModel
    @StateObject private var mealViewModel = CalendarViewModel()
    @StateObject private var workoutViewModel = WorkoutCalendarViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MealCalendarView(viewModel: mealViewModel)
                    .tabItem {
                        Label("Comidas", systemImage: "fork.knife")
                    }
                
                WorkoutCalendarView(viewModel: workoutViewModel)
                    .tabItem {
                        Label("Deporte", systemImage: "figure.run")
                    }
                
                WeekSummaryView(
                    mealViewModel: mealViewModel,
                    workoutViewModel: workoutViewModel
                )
                .tabItem {
                    Label("Resumen", systemImage: "calendar")
                }
            }
        }
    }
}

