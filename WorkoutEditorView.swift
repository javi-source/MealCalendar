//
//  WorkoutEditorView.swift
//  MealCalendar
//
//  Created by Javi on 20/10/25.
//
import SwiftUI
import Combine

struct WorkoutEditorView: View {
    @ObservedObject var viewModel: WorkoutCalendarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedType: WorkoutType = .running
    @State private var distance: String = ""
    @State private var duration: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entrenamiento")) {
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text("\(type.icon) \(type.rawValue)").tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    DatePicker("Fecha", selection: $viewModel.editingDate, displayedComponents: [.date])
                    
                    TextField("Distancia (km)", text: $distance)
                        .keyboardType(.decimalPad)
                    
                    TextField("Duración (min)", text: $duration)
                        .keyboardType(.decimalPad)
                    
                    TextField("Notas (opcional)", text: $notes)
                }
                
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
            .navigationTitle(viewModel.editingWorkout == nil ? "Añadir Entrenamiento" : "Editar Entrenamiento")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        let workout = Workout(
                            type: selectedType,
                            date: viewModel.editingDate,
                            distance: Double(distance),
                            duration: Double(duration),
                            notes: notes
                        )
                        viewModel.saveWorkout(workout)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(distance.isEmpty && duration.isEmpty)
                }
            }
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
