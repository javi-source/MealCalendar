//
// MealEditorView.swift
// MealCalendar
//
// Editor para añadir o editar comidas
//

import SwiftUI
import Combine

struct MealEditorView: View {
    // ViewModel compartido (inyección desde fuera)
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Campos del formulario
    @State private var mealName: String = ""
    @State private var notes: String = ""
    @State private var selectedType: MealType = .breakfast
    @State private var date: Date = Date()
    
    // Comidas frecuentes (base + personalizable guardada en UserDefaults)
    private let baseFrequentMeals = ["Café", "Tostadas", "Yogur", "Tortilla", "Pasta", "Arroz", "Ensalada", "Pollo", "Pescado"]
    @State private var userFrequentMeals: [String] = []
    private let frequentMealsKey = "frequentMeals"
    
    var body: some View {
        NavigationView {
            Form {
                // Información básica
                Section(header: Text("Información")) {
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(MealType.allCases, id: \.self) { t in
                            Text("\(t.icon) \(t.rawValue)").tag(t)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Nombre de la comida", text: $mealName)
                    DatePicker("Fecha", selection: $date, displayedComponents: [.date])
                    TextField("Notas (opcional)", text: $notes)
                }
                
                // Comidas frecuentes para rellenar rápido
                Section(header: Text("Comidas frecuentes")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach((baseFrequentMeals + userFrequentMeals).unique(), id: \.self) { item in
                                Button(action: { mealName = item }) {
                                    Text(item)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(mealName == item ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Opción para guardar este nombre en favoritos del usuario
                if !mealName.isEmpty && !baseFrequentMeals.contains(mealName) && !userFrequentMeals.contains(mealName) {
                    Section {
                        Button("⭐ Añadir \"\(mealName)\" a frecuentes") {
                            userFrequentMeals.append(mealName)
                            saveUserFrequentMeals()
                        }
                    }
                }
                
                // Lista de comidas ya guardadas para este tipo + fecha (edición rápida)
                Section(header: Text("Comidas guardadas para este día/tipo")) {
                    let existing = viewModel.getMeals(for: date, type: selectedType)
                    if existing.isEmpty {
                        Text("No hay comidas de este tipo en esta fecha").foregroundColor(.secondary)
                    } else {
                        ForEach(existing) { meal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meal.name).font(.subheadline)
                                    if !meal.notes.isEmpty { Text("📝 \(meal.notes)").font(.caption).foregroundColor(.secondary) }
                                }
                                Spacer()
                                Button("Editar") {
                                    // Abrir el editor con la comida existente
                                    viewModel.addOrEditMeal(for: meal.date, type: meal.type, meal: meal)
                                }
                            }
                        }
                    }
                }
                
                // Si estamos editando una comida concreta, opción de eliminar
                if viewModel.editingMeal != nil {
                    Section {
                        Button("Eliminar comida", role: .destructive) {
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
                    Button("Cancelar") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // usar el id existente si estamos editando
                        let id = viewModel.editingMeal?.id ?? UUID()
                        let meal = Meal(id: id, name: mealName, type: selectedType, date: date, notes: notes)
                        viewModel.saveMeal(meal)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(mealName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                // Si venimos a editar, rellenar campos
                if let existing = viewModel.editingMeal {
                    mealName = existing.name
                    notes = existing.notes
                    selectedType = existing.type
                    date = existing.date
                } else {
                    // si venimos a crear, usar los valores del viewModel si fueron seteados
                    mealName = ""
                    notes = ""
                    selectedType = viewModel.editingMealType
                    date = viewModel.editingDate
                }
                loadUserFrequentMeals()
            }
        }
    }
    
    // MARK: - Persistencia comidas frecuentes del usuario
    private func loadUserFrequentMeals() {
        if let saved = UserDefaults.standard.array(forKey: frequentMealsKey) as? [String] {
            userFrequentMeals = saved
        }
    }
    private func saveUserFrequentMeals() {
        UserDefaults.standard.set(userFrequentMeals, forKey: frequentMealsKey)
    }
}

// Extensión para eliminar duplicados en arrays Hashable
extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
