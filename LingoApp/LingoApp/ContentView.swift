//
//  ContentView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDifficulty: DifficultyLevel? = nil
    @State private var showDifficultySelection = false
    @State private var soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
    
    var body: some View {
        Group {
            if let difficulty = selectedDifficulty {
                // Oyun ekranı
                GameView(difficulty: difficulty, soundEnabled: $soundEnabled) {
                    // Geri dönüş için - ana menüye dön
                    selectedDifficulty = nil
                    showDifficultySelection = false
                }
            } else if showDifficultySelection {
                // Zorluk seçimi ekranı
                DifficultySelectionView(selectedDifficulty: $selectedDifficulty)
            } else {
                // Ana menü ekranı
                HomeScreenView(soundEnabled: $soundEnabled) {
                    // Play butonuna basıldığında zorluk seçimine git
                    showDifficultySelection = true
                }
            }
        }
        .onAppear {
            // İlk açılışta default olarak true olsun
            if UserDefaults.standard.object(forKey: "SoundEnabled") == nil {
                soundEnabled = true
                UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
