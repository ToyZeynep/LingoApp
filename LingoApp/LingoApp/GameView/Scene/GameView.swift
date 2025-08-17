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
                                            Text("Geri")
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
                    title: game.gameState == .won ? "Tebrikler! 🎉" : "Oyun Bitti 😔",
                    message: game.gameState == .won ?
                        "Kelimeyi \(game.guesses.count + 1) tahminde buldun!\n\nDoğru kelime: \(game.targetWord)" :
                        "Doğru kelime: \(game.targetWord)",
                    primaryButtonTitle: "Yeni Oyun",
                    primaryAction: {
                        game.startNewGame()
                    },
                    secondaryButtonTitle: "Ana Menü",
                    secondaryAction: {
                        onBackToMenu()
                    },
                    icon: game.gameState == .won ? "trophy.fill" : "gamecontroller.fill",
                    iconColor: game.gameState == .won ? .yellow : .purple,
                    wordMeaning: game.currentWordMeaning.isEmpty ? "Anlam bulunamadı" : game.currentWordMeaning,  // ✅ Kelimenin anlamı
                    isPresented: $showGameOver
                )
            }
            
            if showJokerReward {
                if let jokerType = game.rewardedJokerType {
                    CustomAlertView(
                        title: "Joker Kazandın! 🎁",
                        message: """
                        \(game.totalCorrectGuesses). doğru tahminin için
                        \(jokerType.title) jokeri kazandın!
                        
                        Sonraki ödül için \(game.getProgressToNextReward().needed) tahmin daha!
                        """,
                        primaryButtonTitle: "Harika!",
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

// MARK: - Timer Progress View
struct TimerProgressView: View {
    @ObservedObject var game: GameModel
    
    var progressValue: Double {
        min(game.timeRemaining / game.gameDuration, 1.0) // 1.0'ı geçmemesini sağla
    }
    
    var timeColor: Color {
        if game.timeRemaining > 60 {
            return .green
        } else if game.timeRemaining > 30 {
            return .orange
        } else {
            return .red.opacity(0.8)
        }
    }
    
    var formattedTime: String {
        let minutes = Int(game.timeRemaining) / 60
        let seconds = Int(game.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Süre metni
            HStack {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundColor(timeColor)
                
                Text(formattedTime)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(timeColor)
                
                Spacer()
                
                if game.timeRemaining <= 10 && game.timeRemaining > 0 {
                    Text("⚠️")
                        .font(.caption)
                        .foregroundColor(.red)
                        .animation(.blink(duration: 0.5), value: game.timeRemaining)
                }
            }
            
            // Progress bar - SABİT GENİŞLİK
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Arkaplan - tam genişlik
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                        .frame(height: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Progress - dinamik genişlik ama sınırlı
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: progressValue > 0.5 ?
                                [.green, .green.opacity(0.8)] :
                                    progressValue > 0.25 ?
                                [.orange, .red] :
                                    [.red, .red.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * progressValue), height: 8)
                        .animation(.linear(duration: 1), value: progressValue)
                }
            }
            .frame(height: 8) // Progress bar yüksekliği sabit
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(timeColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
// MARK: - Oyun Tahtası
struct GameBoard: View {
    @ObservedObject var game: GameModel
    
    // Dinamik kutu boyutu hesapla
    private var boxSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - 80 // Padding için
        let spacing = CGFloat(game.wordLength - 1) * 8 // Kutular arası boşluk
        return min((availableWidth - spacing) / CGFloat(game.wordLength), 55)
    }
    
    private var spacing: CGFloat {
        game.wordLength > 5 ? 6 : 8
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Harf Kutuları
            VStack(spacing: 12) {
                ForEach(0..<game.maxGuesses, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<game.wordLength, id: \.self) { col in
                            LetterBox(
                                letter: game.getLetterForPosition(row: row, col: col),
                                state: game.getStateForPosition(row: row, col: col),
                                boxSize: boxSize
                            )
                        }
                    }
                }
            }
            
                JokerCompactView(game: game)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - Animation Extension
extension Animation {
    static func blink(duration: Double = 1.0) -> Animation {
        Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}

// MARK: - Invalid Word Toast
struct InvalidWordToast: View {
    @ObservedObject var game: GameModel
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundColor(.orange)
            
            Text("Lütfen geçerli Türkçe bir kelime girin")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.orange.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: -2)
        )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
         
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isVisible = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    game.showInvalidWordAlert = false
                }
            }
        }
    }
}
