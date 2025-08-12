//
//  ContentView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationState: NavigationState = .home
    @State private var selectedDifficulty: DifficultyLevel? = nil
    @State private var soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
    @State private var showTutorial = false
    @State private var hasSeenTutorial = UserDefaults.standard.bool(forKey: "HasSeenTutorial")
    
    enum NavigationState: Equatable {
        case home
        case difficultySelection
        case game(DifficultyLevel)
    }
    
    var body: some View {
        Group {
            if showTutorial {
                HowToPlayView(onDismiss: {
                    hasSeenTutorial = true
                    UserDefaults.standard.set(true, forKey: "HasSeenTutorial")
                    showTutorial = false
                })
            } else {
                switch navigationState {
                case .home:
                    HomeScreenView(soundEnabled: $soundEnabled) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            navigationState = .difficultySelection
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                    
                case .difficultySelection:
                    DifficultySelectionView(
                        selectedDifficulty: $selectedDifficulty,
                        onBack: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                navigationState = .home
                                selectedDifficulty = nil
                            }
                        }
                    )
                    .task(id: selectedDifficulty) {
                        if let difficulty = selectedDifficulty {
                            try? await Task.sleep(nanoseconds: 200_000_000)
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                navigationState = .game(difficulty)
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    
                case .game(let difficulty):
                    GameView(
                        difficulty: difficulty,
                        soundEnabled: $soundEnabled
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            navigationState = .difficultySelection
                            selectedDifficulty = nil
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .interactiveDismissDisabled()
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: navigationState)
        .preferredColorScheme(.dark)
        .statusBarHidden(navigationState == .game(selectedDifficulty ?? .easy))
        .task {
            if UserDefaults.standard.object(forKey: "SoundEnabled") == nil {
                soundEnabled = true
                UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
            }
            
            if !hasSeenTutorial {
                await MainActor.run {
                    showTutorial = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13")
            .previewDisplayName("iPhone 13")
        
        ContentView()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
            .previewDisplayName("iPad Pro")
    }
}
