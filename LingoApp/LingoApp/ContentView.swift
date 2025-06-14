//
//  ContentView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDifficulty: DifficultyLevel? = nil
    
    var body: some View {
        if let difficulty = selectedDifficulty {
            GameView(difficulty: difficulty) {
                // Geri dönüş için
                selectedDifficulty = nil
            }
        } else {
            DifficultySelectionView(selectedDifficulty: $selectedDifficulty)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
