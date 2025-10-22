//
//  WorkoutEditorView.swift
//  MealCalendar
//
//  Created by Javi on 20/10/25.
//

import SwiftUI

/// Vista para añadir o editar un entrenamiento en una fecha concreta.
struct WorkoutEditorView: View {
    @ObservedObject var viewModel: WorkoutCalendarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Estado local del formulario
    @State private var selectedType: WorkoutType = .running
    @State private var distance: String = ""
    @State private var duration: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                // 🔹 Sección principal del formulario
                Section(header: Text("Detalles del entrenamiento")) {
                    
                    // Tipo de entrenamiento
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text("\(type.icon) \(type.rawValue)").tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // Fecha del entrenamiento
                    DatePicker("Fecha",
                               selection: $viewModel.editingDate,
                               displayedComponents: [.date])
                    
                    // Distancia recorrida (opcional)
                    TextField("Distancia (km)", text: $distance)
                        .keyboardType(.decimalPad)
                    
                    // Duración del entrenamiento (opcional)
                    TextField("Duración (min)", text: $duration)
                        .keyboardType(.decimalPad)
                    
                    // Notas o comentarios
                    TextField("Notas (opcional)", text: $notes)
                }
                
                // 🔹 Opción para eliminar si se está editando un entrenamiento existente
                if viewModel.editingWorkout != nil {
                    Section {
                        Button("Eliminar entrenamiento", role: .destructive) {
                            if let workout = viewModel.editingWorkout {
                                viewModel.deleteWorkout(workout)
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            // 🔹 Barra de navegación superior
            .navigationTitle(viewModel.editingWorkout == nil ? "Añadir entrenamiento" : "Editar entrenamiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón Cancelar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                // Botón Guardar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // Creamos el nuevo entrenamiento
                        let workout = Workout(
                            type: selectedType,
                            date: viewModel.editingDate,
                            distance: Double(distance),
                            duration: Double(duration),
                            notes: notes
                        )
                        
                        // Lo guardamos en el modelo
                        viewModel.saveWorkout(workout)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(distance.isEmpty && duration.isEmpty)
                }
            }
            // 🔹 Cargamos datos si estamos editando uno existente
            .onAppear {
                if let w = viewModel.editingWorkout {
                    selectedType = w.type
                    distance = w.distance.map { String($0) } ?? ""
                    duration = w.duration.map { String($0) } ?? ""
                    notes = w.notes
                    viewModel.editingDate = w.date
                }
            }
        }
    }
}
