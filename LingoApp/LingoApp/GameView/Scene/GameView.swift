//
//  GameView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

struct GameView: View {
    let difficulty: DifficultyLevel
    @Binding var soundEnabled: Bool
    let onBackToMenu: () -> Void
    
    @StateObject private var game: GameModel
    @State private var showStatistics = false
    @State private var showGameOver = false
    @State private var showInvalidWord = false
    @State private var showJokerReward = false
    
    init(difficulty: DifficultyLevel, soundEnabled: Binding<Bool>, onBackToMenu: @escaping () -> Void) {
        self.difficulty = difficulty
        self._soundEnabled = soundEnabled
        self.onBackToMenu = onBackToMenu
        self._game = StateObject(wrappedValue: GameModel(difficulty: difficulty))
    }
    
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.1, blue: 0.2),
                        Color(red: 0.1, green: 0.15, blue: 0.3),
                        Color(red: 0.08, green: 0.12, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(.cyan.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -100, y: -200)
                
                Circle()
                    .fill(.blue.opacity(0.12))
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)
                    .offset(x: 120, y: 150)
                
                RoundedRectangle(cornerRadius: 50)
                    .fill(.indigo.opacity(0.1))
                    .frame(width: 180, height: 100)
                    .blur(radius: 40)
                    .offset(x: -50, y: 100)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 15) {
                            if game.gameState == .playing {
                                HStack {
                                    Button(action: onBackToMenu) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "chevron.left.circle.fill")
                                                .font(.system(size: 16))
                                            Text("Geri".localized)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.cyan.opacity(0.9))
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            
                            TimerProgressView(game: game)
                                .padding(.horizontal)
                            
                            GameBoard(game: game)
                                .padding(.horizontal)
                            
                            if game.showHintText {
                                HintView(meaning: game.currentWordMeaning)
                                    .padding(.horizontal)
                                    .id("hintView")
                            }
                        }
                    }
                    .onChange(of: game.showHintText) { showHint in
                        if showHint {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                proxy.scrollTo("hintView", anchor: .bottom)
                            }
                        }
                    }
                }
                
                if game.showInvalidWordAlert {
                     InvalidWordToast(game: game)
                         .padding(.horizontal)
                         .transition(.move(edge: .bottom).combined(with: .opacity))
                 }
                
                KeyboardView(game: game)
                    .padding(.bottom, 10)

            }
            
            if showGameOver {
                CustomAlertView(
                    title: game.gameState == .won ? "Tebrikler! 🎉".localized : "Oyun Bitti 😔".localized,
                    // FIX
                    message: game.gameState == .won ?
                        "Kelimeyi \(game.guesses.count + 1) tahminde buldun!\n\nDoğru kelime: \(game.targetWord)" :
                        "Doğru kelime: \(game.targetWord)",
                    primaryButtonTitle: "Yeni Oyun".localized,
                    primaryAction: {
                        game.startNewGame()
                    },
                    secondaryButtonTitle: "Ana Menü".localized,
                    secondaryAction: {
                        onBackToMenu()
                    },
                    icon: game.gameState == .won ? "trophy.fill" : "gamecontroller.fill",
                    iconColor: game.gameState == .won ? .yellow : .purple,
                    wordMeaning: game.currentWordMeaning.isEmpty ? "Anlam bulunamadı".localized : game.currentWordMeaning,
                    isPresented: $showGameOver
                )
            }
            
            if showJokerReward {
                //FIX
                if let jokerType = game.rewardedJokerType {
                    CustomAlertView(
                        title: "Joker Kazandın! 🎁".localized,
                        message: """
                        \(game.totalCorrectGuesses). doğru tahminin için
                        \(jokerType.title) jokeri kazandın!
                        
                        Sonraki ödül için \(game.getProgressToNextReward().needed) tahmin daha!
                        """,
                        primaryButtonTitle: "Harika!".localized,
                        primaryAction: {},
                        icon: "gift.fill",
                        iconColor: jokerType.brightColor,
                        isPresented: $showJokerReward
                    )
                }
            }
        }
        .onAppear {
            game.soundEnabled = soundEnabled
        }
        .onChange(of: soundEnabled) { newValue in
            game.soundEnabled = newValue
        }
        .onChange(of: game.showInvalidWordAlert) { newValue in
            showInvalidWord = newValue
        }
        .onChange(of: game.gameState) { newState in
            if newState != .playing {
                if newState == .won {
                    showGameOver = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showGameOver = true
                    }
                }
            }
        }
        .onChange(of: game.showJokerRewardAlert) { newValue in
            showJokerReward = newValue
            if !newValue {
                game.showJokerRewardAlert = false
            }
        }
    }
}
