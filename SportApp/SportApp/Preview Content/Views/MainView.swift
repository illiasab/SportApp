//
//  ContentView.swift
//  SportApp
//
//  Created by Ylyas Abdywahytow on 11/5/24.
//

import SwiftUI
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = SportViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
//MARK: - ScrollView with types
                VStack(spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(type.allCases, id: \.self) { exerciseType in
                                Button(action: {
                                    viewModel.selectedType = exerciseType
                                    Task {
                                        await viewModel.fetchExercises()
                                    }
                                }) {
                                    Text("\(exerciseType.rawValue.capitalized)")
                                        .frame(width: 100, height: 40)
                                        .background(viewModel.selectedType == exerciseType ? .blue : .green)
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

//MARK: - Pickers
                    HStack(spacing: 30) {
                        VStack {
                            Text(viewModel.firstPicker)
                                .font(.title2)
                            Picker(viewModel.firstPicker, selection: $viewModel.selectedMuscle) {
                                ForEach(muscle.allCases, id: \.self) { muscleType in
                                    Text(muscleType.rawValue.capitalized).tag(muscleType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: viewModel.selectedMuscle) { _ in
                                Task {
                                    await viewModel.fetchExercises()
                                }
                            }
                        }
                       
                        VStack {
                            Text(viewModel.secondPicker)
                                .font(.title2)
                            Picker(viewModel.secondPicker, selection: $viewModel.selectedDifficulty) {
                                ForEach(difficulty.allCases, id: \.self) { level in
                                    Text(level.rawValue.capitalized).tag(level)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: viewModel.selectedDifficulty) { _ in
                                Task {
                                    await viewModel.fetchExercises()
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    
//MARK: - Display Exercieses
                    if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else if viewModel.exercises.isEmpty {
                        Text("")
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(viewModel.filteredExercises) { exercise in
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    Text("Type: \(exercise.type)")
                                    Text("Muscle: \(exercise.muscle)")
                                    Text("Difficulty: \(exercise.difficulty)")
                                    Text("Equipment: \(exercise.equipment)")
                                    Text("Instructions: \(exercise.instructions)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle(viewModel.title)
            .searchable(text: $viewModel.searchText)
            .onChange(of: viewModel.searchText) { _ in
                Task {
                    await viewModel.fetchExercises()
                }
            }
            .task {
                await viewModel.fetchExercises()
            }
        }
    }
}

#Preview {
    MainView()
}
