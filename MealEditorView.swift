// MealEditorView.swift
import SwiftUI

struct MealEditorView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mealName: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Comida")) {
                    HStack {
                        Text(viewModel.editingMealType.icon)
                            .font(.title2)
                        Text(viewModel.editingMealType.rawValue)
                            .font(.headline)
                    }
                    
                    TextField("Nombre de la comida", text: $mealName)
                    
                    DatePicker("Fecha",
                             selection: $viewModel.editingDate,
                             displayedComponents: [.date])
                    
                    TextField("Notas (opcional)", text: $notes)
                }
                
                if viewModel.editingMeal != nil {
                    Section {
                        Button("Eliminar Comida", role: .destructive) {
                            if let meal = viewModel.editingMeal {
                                viewModel.deleteMeal(meal)
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.editingMeal == nil ? "Añadir Comida" : "Editar Comida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        let meal = Meal(
                            name: mealName,
                            type: viewModel.editingMealType,
                            date: viewModel.editingDate,
                            notes: notes
                        )
                        viewModel.saveMeal(meal)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(mealName.isEmpty)
                }
            }
            .onAppear {
                if let existingMeal = viewModel.editingMeal {
                    mealName = existingMeal.name
                    notes = existingMeal.notes
                    viewModel.editingDate = existingMeal.date
                } else {
                    // Si es nueva, resetear los campos
                    mealName = ""
                    notes = ""
                }
            }
        }
    }
}
