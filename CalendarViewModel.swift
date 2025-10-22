//
// CalendarViewModel.swift
// MealCalendar
//
// ViewModel para las comidas (ahora usando Core Data)
//

import Foundation
import Combine
import CoreData

class CalendarViewModel: ObservableObject {
    // Semana mostrada actualmente
    @Published var currentWeek: Week
    @Published var selectedDate: Date = Date()
    
    // Control para abrir el editor de comidas
    @Published var showingMealEditor = false
    @Published var editingMeal: Meal? = nil        // si no es nil => editar
    @Published var editingDate: Date = Date()
    @Published var editingMealType: MealType = .breakfast
    
    // Core Data context
    private let context: NSManagedObjectContext
    private var calendar = Calendar.current
    
    // Clave legacy (UserDefaults) - usada solo por la importación inicial
    private let legacyMealsKey = "savedMeals"
    
    // MARK: - Inicializador: inyectar contexto para facilitar testing
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        let today = Date()
        self.currentWeek = Week(startDate: today.startOfWeek)
        // Intentar importar datos antiguos (si existen) y luego cargar
        importLegacyMealsIfNeeded()
    }
    
    // MARK: - Navegación semanas
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
    
    // MARK: - Editor (abrir para añadir o editar)
    /// Abrir editor para una fecha y tipo. `meal` puede ser nil (crear) o una Meal existente (editar).
    func addOrEditMeal(for date: Date, type: MealType, meal: Meal?) {
        editingDate = date
        editingMealType = type
        editingMeal = meal
        showingMealEditor = true
    }
    
    // MARK: - Operaciones sobre comidas (Core Data)
    
    /// Guardar o actualizar una comida. Si el id ya existe, la reemplaza.
    func saveMeal(_ meal: Meal) {
        // Buscar entidad existente por id
        let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MealEntity")
        fetch.predicate = NSPredicate(format: "id == %@", meal.id as CVarArg)
        fetch.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetch)
            if let obj = results.first {
                // actualizar
                obj.setValue(meal.name, forKey: "name")
                obj.setValue(meal.type.rawValue, forKey: "type")
                obj.setValue(meal.date, forKey: "date")
                obj.setValue(meal.notes, forKey: "notes")
            } else {
                // crear nuevo
                let entity = NSEntityDescription.entity(forEntityName: "MealEntity", in: context)!
                let newObj = NSManagedObject(entity: entity, insertInto: context)
                newObj.setValue(meal.id, forKey: "id")
                newObj.setValue(meal.name, forKey: "name")
                newObj.setValue(meal.type.rawValue, forKey: "type")
                newObj.setValue(meal.date, forKey: "date")
                newObj.setValue(meal.notes, forKey: "notes")
            }
            try context.save()
        } catch {
            print("Error guardando Meal en Core Data: \(error)")
        }
    }
    
    /// Eliminar una comida por id
    func deleteMeal(_ meal: Meal) {
        let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MealEntity")
        fetch.predicate = NSPredicate(format: "id == %@", meal.id as CVarArg)
        do {
            let results = try context.fetch(fetch)
            for obj in results {
                context.delete(obj)
            }
            try context.save()
        } catch {
            print("Error eliminando Meal en Core Data: \(error)")
        }
    }
    
    /// Devuelve todas las comidas de un día
    /// Conserva la misma firma que antes (Array de Meal)
    func getMeals(for date: Date) -> [Meal] {
        // rango desde inicio del día hasta fin del día
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return [] }
        
        let fetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MealEntity")
        fetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        
        do {
            let objs = try context.fetch(fetch)
            // convertir a Meal structs
            var meals: [Meal] = objs.compactMap { obj in
                guard
                    let id = obj.value(forKey: "id") as? UUID,
                    let name = obj.value(forKey: "name") as? String,
                    let typeRaw = obj.value(forKey: "type") as? String,
                    let date = obj.value(forKey: "date") as? Date
                else { return nil }
                let notes = obj.value(forKey: "notes") as? String ?? ""
                let type = MealType(rawValue: typeRaw) ?? .meal
                return Meal(id: id, name: name, type: type, date: date, notes: notes)
            }
            // ordenar como antes por tipo y nombre
            meals.sort {
                if $0.type == $1.type { return $0.name < $1.name }
                return MealType.allCases.firstIndex(of: $0.type)! < MealType.allCases.firstIndex(of: $1.type)!
            }
            return meals
        } catch {
            print("Error fetch getMeals CoreData: \(error)")
            return []
        }
    }
    
    /// Devuelve las comidas de un día para un tipo concreto
    func getMeals(for date: Date, type: MealType) -> [Meal] {
        getMeals(for: date).filter { $0.type == type }
    }
    
    // MARK: - Importación desde UserDefaults (legacy)
    /// Si existe data antigua en UserDefaults bajo la clave `savedMeals`, la importamos a Core Data la primera vez.
    private func importLegacyMealsIfNeeded() {
        // Si ya hay datos en Core Data no importamos
        let checkFetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "MealEntity")
        checkFetch.fetchLimit = 1
        do {
            let existing = try context.fetch(checkFetch)
            if !existing.isEmpty { return } // ya hay datos -> no importar
        } catch {
            print("Error comprobando Core Data antes de import: \(error)")
        }
        
        // Intentar leer UserDefaults
        if let data = UserDefaults.standard.data(forKey: legacyMealsKey),
           let decoded = try? JSONDecoder().decode([String: [Meal]].self, from: data) {
            // decoded es mapa fechaKey -> [Meal]
            for (_, meals) in decoded {
                for meal in meals {
                    // crear entidad por cada meal
                    let entity = NSEntityDescription.entity(forEntityName: "MealEntity", in: context)!
                    let obj = NSManagedObject(entity: entity, insertInto: context)
                    obj.setValue(meal.id, forKey: "id")
                    obj.setValue(meal.name, forKey: "name")
                    obj.setValue(meal.type.rawValue, forKey: "type")
                    obj.setValue(meal.date, forKey: "date")
                    obj.setValue(meal.notes, forKey: "notes")
                }
            }
            do {
                try context.save()
                // opcional: borrar legacy si quieres
                // UserDefaults.standard.removeObject(forKey: legacyMealsKey)
            } catch {
                print("Error guardando datos importados a Core Data: \(error)")
            }
        }
    }
}
