//
//  SportViewModel.swift
//  SportApp
//
//  Created by Ylyas Abdywahytow on 11/9/24.
//

import SwiftUI
import Combine

class SportViewModel: ObservableObject {
    //MARK: - properties
    @Published var exercises: [Exercise] = []
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var selectedMuscle: muscle = .biceps
    @Published var selectedDifficulty: difficulty = .beginner
    @Published var selectedType: type = .strength
    @Published var title: String = "Let's Workout"
    @Published var firstPicker: String = "Pick Muscle"
    @Published var secondPicker: String = "Choose Difficulty"
    // MARK: - Checking filter
    var filteredExercises: [Exercise] {
      
        if searchText.isEmpty &&
            selectedType == .strength &&
            selectedMuscle == .biceps &&
            selectedDifficulty == .beginner {
            return []
        } else if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    // MARK: - Fetching Exerciese for UI
    func fetchExercises() async {
        do {
            print("Fetching exercises with:")
            print("Difficulty: \(selectedDifficulty.rawValue)")
            print("Muscle: \(selectedMuscle.rawValue)")
            print("Type: \(selectedType.rawValue)")
            
            exercises = try await SportApp.fetchExercises(
                difficulty: selectedDifficulty,
                muscle: selectedMuscle,
                type: selectedType
            )
            
            if !searchText.isEmpty {
                exercises = exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
            
            errorMessage = nil
            print("Fetched \(exercises.count) exercises")
        } catch {
            errorMessage = error.localizedDescription
            exercises = []
            print("Error fetching exercises: \(error.localizedDescription)")
        }
    }
}

