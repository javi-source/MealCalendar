//
// WorkoutCalendarViewModel.swift
// MealCalendar
// ViewModel para los entrenamientos (Core Data)
//

import Foundation
import Combine
import CoreData

class WorkoutCalendarViewModel: ObservableObject {
    @Published var currentWeek: Week
    @Published var selectedDate: Date = Date()
    
    // Control para editor de entrenamientos
    @Published var showingEditor = false
    @Published var editingWorkout: Workout? = nil
    @Published var editingDate: Date = Date()
    
    private let context: NSManagedObjectContext
    private var calendar = Calendar.current
    
    // Legacy key
    private let legacyWorkoutsKey = "savedWorkouts"
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        let today = Date()
        self.currentWeek = Week(startDate: today.startOfWeek)
        importLegacyWorkoutsIfNeeded()
    }
    
    // Semana
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
    
    // Abrir editor
    func addOrEditWorkout(for date: Date, workout: Workout?) {
        editingDate = date
        editingWorkout = workout
        showingEditor = true
    }
    
    // Guardar/actualizar
    func saveWorkout(_ workout: Workout) {
        let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "WorkoutEntity")
        fetch.predicate = NSPredicate(format: "id == %@", workout.id as CVarArg)
        fetch.fetchLimit = 1
        do {
            let results = try context.fetch(fetch)
            if let obj = results.first {
                obj.setValue(workout.type.rawValue, forKey: "type")
                obj.setValue(workout.date, forKey: "date")
                obj.setValue(workout.distance, forKey: "distance")
                obj.setValue(workout.duration, forKey: "duration")
                obj.setValue(workout.notes, forKey: "notes")
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "WorkoutEntity", in: context)!
                let newObj = NSManagedObject(entity: entity, insertInto: context)
                newObj.setValue(workout.id, forKey: "id")
                newObj.setValue(workout.type.rawValue, forKey: "type")
                newObj.setValue(workout.date, forKey: "date")
                newObj.setValue(workout.distance, forKey: "distance")
                newObj.setValue(workout.duration, forKey: "duration")
                newObj.setValue(workout.notes, forKey: "notes")
            }
            try context.save()
        } catch {
            print("Error guardando Workout en Core Data: \(error)")
        }
    }
    
    // Borrar
    func deleteWorkout(_ workout: Workout) {
        let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "WorkoutEntity")
        fetch.predicate = NSPredicate(format: "id == %@", workout.id as CVarArg)
        do {
            let results = try context.fetch(fetch)
            for obj in results { context.delete(obj) }
            try context.save()
        } catch {
            print("Error eliminando Workout en Core Data: \(error)")
        }
    }
    
    // Obtener workouts de un día
    func getWorkouts(for date: Date) -> [Workout] {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return [] }
        let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "WorkoutEntity")
        fetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        do {
            let objs = try context.fetch(fetch)
            var workouts: [Workout] = objs.compactMap { obj in
                guard
                    let id = obj.value(forKey: "id") as? UUID,
                    let typeRaw = obj.value(forKey: "type") as? String,
                    let date = obj.value(forKey: "date") as? Date
                else { return nil }
                let distance = obj.value(forKey: "distance") as? Double
                let duration = obj.value(forKey: "duration") as? Double
                let notes = obj.value(forKey: "notes") as? String ?? ""
                let type = WorkoutType(rawValue: typeRaw) ?? .other
                return Workout(id: id, type: type, date: date, distance: distance, duration: duration, notes: notes)
            }
            // orden similar al anterior
            workouts.sort {
                if $0.type == $1.type { return ($0.duration ?? 0) > ($1.duration ?? 0) }
                return WorkoutType.allCases.firstIndex(of: $0.type)! < WorkoutType.allCases.firstIndex(of: $1.type)!
            }
            return workouts
        } catch {
            print("Error fetch getWorkouts CoreData: \(error)")
            return []
        }
    }
    
    // MARK: - Import legacy from UserDefaults
    private func importLegacyWorkoutsIfNeeded() {
        // si ya hay datos en Core Data no importamos
        let checkFetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "WorkoutEntity")
        checkFetch.fetchLimit = 1
        do {
            let existing = try context.fetch(checkFetch)
            if !existing.isEmpty { return } // ya hay datos
        } catch {
            print("Error comprobando Core Data antes de import workouts: \(error)")
        }
        
        if let data = UserDefaults.standard.data(forKey: legacyWorkoutsKey),
           let decoded = try? JSONDecoder().decode([String: [Workout]].self, from: data) {
            for (_, workouts) in decoded {
                for w in workouts {
                    let entity = NSEntityDescription.entity(forEntityName: "WorkoutEntity", in: context)!
                    let obj = NSManagedObject(entity: entity, insertInto: context)
                    obj.setValue(w.id, forKey: "id")
                    obj.setValue(w.type.rawValue, forKey: "type")
                    obj.setValue(w.date, forKey: "date")
                    obj.setValue(w.distance, forKey: "distance")
                    obj.setValue(w.duration, forKey: "duration")
                    obj.setValue(w.notes, forKey: "notes")
                }
            }
            do { try context.save() } catch { print("Error guardando workouts importados: \(error)") }
        }
    }
}
