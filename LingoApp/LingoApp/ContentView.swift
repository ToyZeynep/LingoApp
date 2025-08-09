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
    @State private var showTutorial = false
    @State private var hasSeenTutorial = UserDefaults.standard.bool(forKey: "HasSeenTutorial")
    
    var body: some View {
        Group {
            if showTutorial {
                HowToPlayView(onDismiss: {
                    hasSeenTutorial = true
                    UserDefaults.standard.set(true, forKey: "HasSeenTutorial")
                    showTutorial = false
                })
            } else if let difficulty = selectedDifficulty {
                GameView(difficulty: difficulty, soundEnabled: $soundEnabled) {
                    selectedDifficulty = nil
                    showDifficultySelection = false
                }
            } else if showDifficultySelection {
                DifficultySelectionView(selectedDifficulty: $selectedDifficulty)
            } else {
                HomeScreenView(soundEnabled: $soundEnabled) {
                    showDifficultySelection = true
                }
            }
        }
        .onAppear {
            if UserDefaults.standard.object(forKey: "SoundEnabled") == nil {
                soundEnabled = true
                UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
            }
            
            if !hasSeenTutorial {
                showTutorial = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
