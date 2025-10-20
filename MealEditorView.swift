//
//  MealEditorView.swift
//  MealCalendar
//
//  Created by Javi on 18/10/25.
//
import SwiftUI
import Combine

struct MealEditorView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mealName: String = ""
    @State private var notes: String = ""
    @State private var userFrequentMeals: [String] = []
    
    // 🥗 Lista base de comidas frecuentes (predefinidas)
    private let baseFrequentMeals = [
        "Café", "Tostadas", "Yogur", "Tortilla", "Pasta", "Arroz", "Ensalada",
        "Pollo", "Pescado", "Sopa", "Fruta", "Batido"
    ]
    
    private let frequentMealsKey = "frequentMeals"
    
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
                
                // 🧩 Nueva sección: comidas frecuentes (predeterminadas + del usuario)
                Section(header: Text("Comidas frecuentes")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach((baseFrequentMeals + userFrequentMeals).unique(), id: \.self) { meal in
                                Button(action: {
                                    mealName = meal
                                }) {
                                    Text(meal)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(mealName == meal ? Color.blue.opacity(0.25) : Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // 🗂 Guardar esta comida como favorita
                if !mealName.isEmpty && !baseFrequentMeals.contains(mealName) && !userFrequentMeals.contains(mealName) {
                    Section {
                        Button("⭐ Añadir \"\(mealName)\" a comidas frecuentes") {
                            userFrequentMeals.append(mealName)
                            saveUserFrequentMeals()
                        }
                    }
                }
                
                // 🗑 Eliminar comida si ya existe
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
                    mealName = ""
                    notes = ""
                }
                loadUserFrequentMeals()
            }
        }
    }
    
    // MARK: - Persistencia de comidas frecuentes del usuario
    
    private func loadUserFrequentMeals() {
        if let saved = UserDefaults.standard.array(forKey: frequentMealsKey) as? [String] {
            userFrequentMeals = saved
        }
    }
    
    private func saveUserFrequentMeals() {
        UserDefaults.standard.set(userFrequentMeals, forKey: frequentMealsKey)
    }
}

// 🔧 Pequeña extensión para evitar duplicados
extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

