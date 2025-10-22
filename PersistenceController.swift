//
//  PersistenceController.swift
//  MealCalendar
//
//  Created by Javi on 22/10/25.
// Controlador de persistencia Core Data (stack)

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Nombre del modelo debe coincidir con el .xcdatamodeld que crees
    let container: NSPersistentContainer

    init(inMemory: Bool = false, modelName: String = "MealCalendarModel") {
        container = NSPersistentContainer(name: modelName)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Error cargando Core Data store: \(error), \(error.userInfo)")
            }
        }
        // Esto mejora el rendimiento en el hilo principal al guardar desde UI
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
