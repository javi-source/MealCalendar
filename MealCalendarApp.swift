//
// MealCalendarApp.swift
// MealCalendar
//
// App principal con tabs: Comidas / Deporte / Resumen
//

import SwiftUI
import CoreData

@main
struct MealCalendarApp: App {
    // Core Data stack
    let persistenceController = PersistenceController.shared

    // Crear viewModels con el context compartido
    @StateObject private var mealViewModel = CalendarViewModel(context: PersistenceController.shared.container.viewContext)
    @StateObject private var workoutViewModel = WorkoutCalendarViewModel(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            TabView {
                MealCalendarView(viewModel: mealViewModel)
                    .tabItem { Label("Comidas", systemImage: "fork.knife") }

                WorkoutCalendarView(viewModel: workoutViewModel)
                    .tabItem { Label("Deporte", systemImage: "figure.run") }

                WeekSummaryView(mealViewModel: mealViewModel, workoutViewModel: workoutViewModel)
                    .tabItem { Label("Resumen", systemImage: "calendar") }
            }
            // también inyectamos el managedObjectContext globalmente por si alguna vista lo quiere usar directamente con @Environment
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
